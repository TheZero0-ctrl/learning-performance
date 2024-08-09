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

main

cpu_freq = estimate_cpu_timer_freq
profile = Profiler::Tracer.profiles
p profile

total_cpu_elapsed = profile[:main][:elapsed]
puts "Total Time: #{total_cpu_elapsed / cpu_freq.to_f}ms (CPU freq: #{cpu_freq})"
print_time_elapsed(
  'jason parse',
  total_cpu_elapsed,
  profile[:parse_json][:elapsed],
  children_elapsed: profile[:parse_json][:children] && profile[profile[:parse_json][:children]][:elapsed]
)
print_time_elapsed(
  'haversine sum',
  total_cpu_elapsed,
  profile[:haversine_average][:elapsed],
  children_elapsed: profile[:haversine_average][:children] && profile[profile[:haversine_average][:children]][:elapsed]
)
print_time_elapsed(
  'haversine loop',
  total_cpu_elapsed,
  profile[:haversine_loop][:elapsed],
  children_elapsed: profile[:haversine_loop][:children] && profile[profile[:haversine_loop][:children]][:elapsed]
)
