# frozen_string_literal: true

require 'time'

def os_timer_freq
  1_000_000 # Frequency in microseconds
end

def read_os_timer
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
end

def read_cpu_timer
  Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID, :nanosecond)
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

def measure
  freq = os_timer_freq
  puts "Frequency: #{freq} microseconds"

  cpu_start = read_cpu_timer
  os_start = read_os_timer
  os_end = 0
  os_elapsed = 0
  wait_time = 100
  os_wait_time = freq * wait_time / 1000

  while os_elapsed < os_wait_time
    os_end = read_os_timer
    os_elapsed = os_end - os_start
  end

  cpu_end = read_cpu_timer
  cpu_elapsed = cpu_end - cpu_start
  cpu_freq = freq * cpu_elapsed / os_elapsed

  puts "OS Timer: #{os_start} -> #{os_end} = #{os_elapsed}"
  puts "OS seconds: #{(os_elapsed / freq.to_f).round(4)}"

  puts "CPU Timer: #{cpu_start} -> #{cpu_end} = #{cpu_elapsed}"
  puts "CPU Frequency: #{cpu_freq}"
end

def print_time_elapsed(label, total_cpu_elapsed, elasped)
  percent = 100.0 * (elasped / total_cpu_elapsed.to_f)
  puts "#{label}: #{elasped} (#{percent.round(2)}%)"
end
