# frozen_string_literal: true
require 'csv'
require_relative './database'
require_relative './database_reader'
require_relative './database_writer'

module App
  class Performer
    BATCH_SIZE = 1_000

    def initialize(input_stream:, output_stream:)
      @input_stream = input_stream
      @output_stream = output_stream
    end

    def call
      input_and_write
      read_and_output
    end

    private

    attr_accessor :input_stream, :output_stream

    def input_and_write
      input_stream.each_line do |line|
        row = CSV.parse_line line.chomp
        break if row.nil?
        writer.add row
      end
      writer.flush
    end

    def read_and_output
      reader.read do |csv_row|
        output_stream.write csv_row
      end
      output_stream.flush
      output_stream.close
    end

    def writer
      @writer ||= App::DatabaseWriter.new(batch_size: BATCH_SIZE)
    end

    def reader
      @reader ||= App::DatabaseReader.new(batch_size: BATCH_SIZE)
    end
  end
end
