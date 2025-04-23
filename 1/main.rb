# frozen_string_literal: true
require 'csv'
require_relative 'app/database'
require_relative 'app/database_reader'
require_relative 'app/database_writer'

BATCH_SIZE = 1_000

def main
  writer = App::DatabaseWriter.new(batch_size: BATCH_SIZE)
  $stdin.each_line do |line|
    row = CSV.parse_line(line.chomp)
    break if row.nil?
    writer.add(row)
  end
  writer.flush

  reader = App::DatabaseReader.new(batch_size: BATCH_SIZE)
  reader.read do |csv_row|
    puts csv_row
  end
end

main
