# frozen_string_literal: true

module App
  class DatabaseReader
    attr_reader :batch_size

    def initialize(batch_size:)
      @batch_size = batch_size
    end

    def read
      connection.transaction do
        connection.exec <<~SQL
          DECLARE #{cursor_name} CURSOR FOR
          SELECT * FROM transactions ORDER BY amount::MONEY DESC
        SQL

        loop do
          batch = connection.exec("FETCH FORWARD #{batch_size} FROM #{cursor_name}")
          break if batch.ntuples == 0

          batch.each do |row|
            yield [row['time_stamp'], row['transaction_id'], row['user_id'], row['amount']].join(',')
          end
        end

        connection.exec("CLOSE #{cursor_name}")
        cleanup_db
      end
    end

    private

    def cleanup_db
      connection.exec <<~SQL
        DROP TABLE IF EXISTS transactions;
      SQL
    end

    def connection
      @connection ||= Database.instance.connection
    end

    def cursor_name
      'transactions_cursor'
    end
  end
end
