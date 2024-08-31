# frozen_string_literal: true

require '../profiler/time_helpers'

# Enum-like constants
TEST_MODE = {
  UNINITIALIZED: 0,
  TESTING: 1,
  COMPLETED: 2,
  ERROR: 3
}.freeze

# RepetitionTestResults
class RepetitionTestResults
  attr_accessor :test_count, :total_time, :max_time, :min_time

  def initialize
    @test_count = 0
    @total_time = 0
    @max_time = 0
    @min_time = Float::INFINITY
  end
end

class RepetitionTester
  include Profiler::TimeHelpers
  attr_accessor :target_processed_byte_count, :cpu_timer_freq, :try_for_time, :tests_started_at,
                :mode, :print_new_minimums, :open_block_count, :close_block_count,
                :time_accumulated_on_this_test, :bytes_accumulated_on_this_test, :results

  def initialize
    @mode = TEST_MODE[:UNINITIALIZED]
    @print_new_minimums = true
    @open_block_count = 0
    @close_block_count = 0
    @time_accumulated_on_this_test = 0
    @bytes_accumulated_on_this_test = 0
    @results = RepetitionTestResults.new
  end

  def seconds_from_cpu_time(cpu_time)
    @cpu_timer_freq ? (cpu_time.to_f / @cpu_timer_freq) : 0.0
  end

  def print_time(label, cpu_time, byte_count = 0)
    print "#{label}: #{cpu_time.round}"
    if @cpu_timer_freq
      seconds = seconds_from_cpu_time(cpu_time)
      print " (#{(seconds * 1000).round(6)}ms)"

      if byte_count.positive?
        gigabyte = 1024.0 * 1024.0 * 1024.0
        best_bandwidth = byte_count / (gigabyte * seconds)
        print " #{best_bandwidth.round(6)}gb/s"
      end
    end
    puts
  end

  def print_results
    print_time('Min', @results.min_time, @target_processed_byte_count)
    print_time('Max', @results.max_time, @target_processed_byte_count)
    return unless @results.test_count.positive?

    print_time('Avg', @results.total_time.to_f / @results.test_count, @target_processed_byte_count)
  end

  def error(message)
    @mode = TEST_MODE[:ERROR]
    warn "ERROR: #{message}"
  end

  def new_test_wave(target_processed_byte_count, cpu_timer_freq, seconds_to_try = 10)
    if @mode == TEST_MODE[:UNINITIALIZED]
      @mode = TEST_MODE[:TESTING]
      @target_processed_byte_count = target_processed_byte_count
      @cpu_timer_freq = cpu_timer_freq
    elsif @mode == TEST_MODE[:COMPLETED]
      @mode = TEST_MODE[:TESTING]
      error('TargetProcessedByteCount changed') if @target_processed_byte_count != target_processed_byte_count
      error('CPU frequency changed') if @cpu_timer_freq != cpu_timer_freq
    end

    @try_for_time = seconds_to_try * cpu_timer_freq
    @tests_started_at = read_cpu_timer
  end

  def begin_time
    @open_block_count += 1
    @time_accumulated_on_this_test -= read_cpu_timer
  end

  def end_time
    @close_block_count += 1
    @time_accumulated_on_this_test += read_cpu_timer
  end

  def count_bytes(byte_count)
    @bytes_accumulated_on_this_test += byte_count
  end

  def is_testing?
    if @mode == TEST_MODE[:TESTING]
      current_time = read_cpu_timer

      if @open_block_count.positive?
        error('Unbalanced BeginTime/EndTime') if @open_block_count != @close_block_count

        error('Processed byte count mismatch') if @bytes_accumulated_on_this_test != @target_processed_byte_count

        if @mode == TEST_MODE[:TESTING]
          elapsed_time = @time_accumulated_on_this_test
          @results.test_count += 1
          @results.total_time += elapsed_time
          @results.max_time = elapsed_time if @results.max_time < elapsed_time

          if @results.min_time > elapsed_time
            @results.min_time = elapsed_time
            @tests_started_at = current_time

            if @print_new_minimums
              print_time('Min', @results.min_time, @bytes_accumulated_on_this_test)
              puts ' ' * 15
            end
          end

          @open_block_count = 0
          @close_block_count = 0
          @time_accumulated_on_this_test = 0
          @bytes_accumulated_on_this_test = 0
        end
      end

      if (current_time - @tests_started_at) > @try_for_time
        @mode = TEST_MODE[:COMPLETED]
        puts ' ' * 60
        print_results
      end
    end

    @mode == TEST_MODE[:TESTING]
  end
end
