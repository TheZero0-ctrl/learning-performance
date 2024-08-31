# frozen_string_literal: true

require './repetition_test'
require '../profiler/time_helpers'
require 'objspace'

include Profiler::TimeHelpers

def test_file_read(tester)
  while tester.is_testing?
    data = []
    tester.begin_time
    File.open('../haversine/data.json', 'r') do |file|
      data = file.readlines
    end
    tester.end_time
    tester.count_bytes(ObjectSpace.memsize_of(data))
  end
end

def main
  cpu_timer_freq = estimate_cpu_timer_freq
  tester = RepetitionTester.new
  tester.new_test_wave(58908728, cpu_timer_freq)
  require 'objspace'

  test_file_read(tester)
end

main
 

