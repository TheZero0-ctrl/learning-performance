# frozen_string_literal: true

require './generator'
require './json_parser'
require './haversine'
require '../profiler/tracer'
require '../profiler/time_helpers'
require '../repetition/repetition_test'

include Profiler::TimeHelpers

# puts 'Enter number of pairs'
# number = gets.chomp.to_i
# puts 'Enter seed'
# seed = gets.chomp.to_i
# puts 'Enter type'
# type = gets.chomp
# generate(number, seed, type)

def parse_json(data)
  # Profiler::Tracer.call(:function, { name: :parse_json })
  lexer = JsonLexer.new(data)
  parser = JsonParser.new(lexer)
  parser.parse
end

def main
  Profiler::Tracer.call(:function, { name: :main, is_main: true })

  tracer = Profiler::Tracer.call(:block, { name: :file_read, is_custom: true, byte_count: 121110528 })
  data = []
  File.open('./data.json', 'r') do |file|
    data = file.readlines
  end
  tracer.close
  parsed_json = parse_json(data)

  count = parsed_json['pairs'].count
  sum = haversine_average(parsed_json['pairs'], count)
  puts "Average: #{sum}"
end

# Profiler::Tracer.active = false
main

Profiler::Tracer.print
