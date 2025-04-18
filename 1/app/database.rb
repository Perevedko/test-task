# frozen_string_literal: true
require 'singleton'
require 'pg'

module App
  class Database
    include Singleton

    def connection
      @connection ||= PG.connect(
        dbname: ENV['DB_NAME'],
        user: ENV['DB_USER'],
        password: ENV['DB_PASSWORD'],
        host: ENV['DB_HOST']
      )
    end
  end
end
