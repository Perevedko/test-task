# frozen_string_literal: true
require_relative './app/performer'

App::Performer.new(input_stream: STDIN, output_stream: STDOUT).call
# puts 'hello'
# binding.pry
