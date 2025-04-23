# frozen_string_literal: true

module App
  module DatabaseHelper
    private

    def table_name
      'transactions'
    end

    def connection
      @connection ||= Database.instance.connection
    end
  end
end