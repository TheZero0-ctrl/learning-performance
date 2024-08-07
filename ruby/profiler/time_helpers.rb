# frozen_string_literal: true

module Profiler
  # profiler/time_helpers.rb
  module TimeHelpers
    def os_timer_freq
      1_000_000 # Frequency in microseconds
    end

    def read_os_timer
      Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
    end

    def read_cpu_timer
      Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID, :microsecond)
    end

    def estimate_cpu_timer_freq
      miliseconds_to_wait = 100
      os_freq = os_timer_freq

      cpu_start = read_cpu_timer
      os_start = read_os_timer
      os_elapsed = 0
      os_wait_time = os_freq * miliseconds_to_wait / 1000
      while os_elapsed < os_wait_time
        os_end = read_os_timer
        os_elapsed = os_end - os_start
      end

      cpu_end = read_cpu_timer
      cpu_elapsed = cpu_end - cpu_start
      cpu_freq = 0

      cpu_freq = os_freq * cpu_elapsed / os_elapsed if os_elapsed.positive?
      cpu_freq
    end

    def print_time_elapsed(label, total_cpu_elapsed, elapsed)
      percent = 100.0 * (elapsed / total_cpu_elapsed.to_f)
      puts "#{label}: #{elapsed} (#{percent.round(2)}%)"
    end
  end
end
