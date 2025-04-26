# frozen_string_literal: true

module App
  module DatabaseHelper
    COLUMN_ORDER_IN_CSV = %w[time_stamp transaction_id user_id amount]
    TABLE_NAME = 'transactions'
    private_constant :COLUMN_ORDER_IN_CSV, :TABLE_NAME

    private

    def connection
      @connection ||= Database.instance.connection
    end
  end
end
