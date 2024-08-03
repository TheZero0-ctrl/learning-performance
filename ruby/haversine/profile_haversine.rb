require './haversine'
require './json_parser'
require './timer'

def print_time_elapsed(label, total_cpu_elapsed, start, finish)
  elasped = finish - start
  percent = 100.0 * (elasped / total_cpu_elapsed.to_f)
  puts "#{label}: #{elasped} (#{percent.round(2)}%)"
end

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

  print_time_elapsed('Startup', total_cpu_elapsed, prof_begin, prof_read)
  print_time_elapsed('Read', total_cpu_elapsed, prof_read, prof_misc_setup)
  print_time_elapsed('Misc Setup', total_cpu_elapsed, prof_misc_setup, prof_parse)
  print_time_elapsed('Parse', total_cpu_elapsed, prof_parse, prof_sum)
  print_time_elapsed('Sum', total_cpu_elapsed, prof_sum, prof_misc_output)
  print_time_elapsed('Misc Output', total_cpu_elapsed, prof_misc_output, prof_end)
end

profile
