# frozen_string_literal: true

require './generator'
require './json_parser'
require './haversine'
require '../profiler/tracer'
require '../profiler/time_helpers'

include Profiler::TimeHelpers

# puts 'Enter number of pairs'
# number = gets.chomp.to_i
# puts 'Enter seed'
# seed = gets.chomp.to_i
# puts 'Enter type'
# type = gets.chomp
# generate(number, seed, type)

def parse_json(file)
  Profiler::Tracer.call(:function, { name: :parse_json })
  lexer = JsonLexer.new(file)
  parser = JsonParser.new(lexer)
  parser.parse
end

def main
  Profiler::Tracer.call(:function, { name: :main, is_main: true })
  file = File.open('./data.json', 'r')

  parsed_json = parse_json(file)
  count = parsed_json['pairs'].count
  sum = haversine_average(parsed_json['pairs'], count)
  puts "Average: #{sum}"
end

Profiler::Tracer.active = true
main

profile = Profiler::Tracer.profiles
p profile

Profiler::Tracer.print
