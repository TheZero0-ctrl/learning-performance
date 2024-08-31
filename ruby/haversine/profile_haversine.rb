require './haversine'
require './json_parser'
require '../profiler/tracer'
require '../profiler/time_helpers'

include Profiler::TimeHelpers

def profile
  prof_begin = read_cpu_timer
  prof_read = read_cpu_timer

  file = File.open('./data.json', 'r')

  prof_misc_setup = read_cpu_timer

  lexer = JsonLexer.new(file)
  parser = JsonParser.new(lexer)

  prof_parse = read_cpu_timer

  parsed_json = parser.parse

  prof_sum = read_cpu_timer

  count = parsed_json['pairs'].count
  total = parsed_json['pairs'].reduce(0) do |sum, pair|
    sum + reference_haversine(pair['x0'], pair['y0'], pair['x1'], pair['y1'])
  end
  average = total / count

  prof_misc_output = read_cpu_timer

  puts "Pair count: #{count}"
  puts "Average: #{average}"

  prof_end = read_cpu_timer

  total_cpu_elapsed = prof_end - prof_begin

  cpu_freq = estimate_cpu_timer_freq

  puts "Total Time: #{total_cpu_elapsed / cpu_freq.to_f}ms (CPU freq: #{cpu_freq})"

  print_time_elapsed('Startup', total_cpu_elapsed, (prof_read - prof_begin))
  print_time_elapsed('Read', total_cpu_elapsed, (prof_misc_setup - prof_begin))
  print_time_elapsed('Misc Setup', total_cpu_elapsed, (prof_parse - prof_misc_setup))
  print_time_elapsed('Parse', total_cpu_elapsed, (prof_sum - prof_parse))
  print_time_elapsed('Sum', total_cpu_elapsed, (prof_misc_output - prof_sum))
  print_time_elapsed('Misc Output', total_cpu_elapsed, (prof_end - prof_misc_output))
end

def test
  Profiler::Tracer.call(:function, { name: :test })
  count = 2
  sum = 0

  Profiler::Tracer.call(:block, { name: :count, count: 3, byte_count: 10})

  for i in 0..count
    sum += reference_haversine(0, 0, 0, 0)
  end
  puts "Average: #{sum / count}"
end

test

p Profiler::Tracer.profiles
