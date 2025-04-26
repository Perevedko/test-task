# frozen_string_literal: true
require_relative './database_helper'

module App
  class DatabaseReader
    include DatabaseHelper

    CURSOR_NAME = "#{TABLE_NAME}_cursor"
    private_constant :CURSOR_NAME

    attr_reader :batch_size

    def initialize(batch_size:)
      @batch_size = batch_size
    end

    def read
      connection.transaction do
        init_cursor

        loop do
          batch = connection.exec("FETCH FORWARD #{batch_size} FROM #{CURSOR_NAME}")
          break if batch.ntuples == 0

          batch.each do |row|
            csv_row = row.values_at(*COLUMN_ORDER_IN_CSV).join(',')
            yield "#{csv_row}\n"
          end
        end

        cleanup
      end
    end

    private

    def init_cursor
      connection.exec <<~SQL
          DECLARE #{CURSOR_NAME} CURSOR FOR
          SELECT * FROM #{TABLE_NAME} ORDER BY amount::MONEY DESC
      SQL
    end

    def cleanup
      connection.exec <<~SQL
        CLOSE #{CURSOR_NAME};
        DROP TABLE IF EXISTS #{TABLE_NAME};
      SQL
    end
  end
end
