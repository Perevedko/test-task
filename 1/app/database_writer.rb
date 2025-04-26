# frozen_string_literal: true
require_relative './database_helper'

module App
  class DatabaseWriter
    include App::DatabaseHelper

    attr_reader :batch_size

    def initialize(batch_size:)
      @batch_size = batch_size
      @rows = []
      init_db
    end

    def add(row)
      rows << row
      flush if rows.length == batch_size
    end

    def flush
      connection.exec <<~SQL
        INSERT INTO #{TABLE_NAME} (#{COLUMN_ORDER_IN_CSV.join(',')})
        VALUES #{values_to_insert};
      SQL
      rows = []
    end

    private

    attr_accessor :rows

    def values_to_insert
      rows
        .map { |row| "(#{row.map { connection.escape(_1) }.join(',')})" }
        .join(',')
    end

    def init_db
      connection.exec <<~SQL
        CREATE TABLE IF NOT EXISTS transactions (
            id SERIAL PRIMARY KEY,
            time_stamp TEXT NOT NULL,
            transaction_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            amount TEXT NOT NULL
        );
      SQL
    end
  end
end
