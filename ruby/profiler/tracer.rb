# frozen_string_literal: true

require_relative 'time_helpers'

module Profiler
  # profiler/tracer.rb
  class Tracer
    include TimeHelpers
    attr_reader :key

    @profiles = {}
    @active_tracers = []
    @active = true

    class << self
      attr_reader :profiles, :active_tracers
      attr_accessor :active
    end

    def initialize(event, options)
      @starting_time = read_cpu_timer
      @key = options[:name]
      @options = options
      @profiles = self.class.profiles
      @profiles[@key] ||= { count: 1, is_main: options[:is_main], processed_byte_count: options[:byte_count] }
      @trace_points = TracePoint.new(event, &method(:trace_handler))
    end

    def self.call(type, options)
      return unless active || options[:is_main]

      tracer = new(type == :function ? :return : :b_return, options)
      tracer.enable(add_to_tracers: !options[:is_main])
      tracer
    end

    def enable(add_to_tracers: true)
      @trace_points.enable
      self.class.active_tracers << @key if add_to_tracers
    end

    def disable
      @trace_points.disable
      self.class.active_tracers.delete(@key)
    end

    def self.clear
      @profiles.clear
      @active_tracers.clear
      @active = true
    end

    def self.print
      cpu_freq = estimate_cpu_timer_freq
      main_profile = @profiles.values.find { |value| value[:is_main] }
      total_cpu_elapsed = main_profile[:elapsed]
      puts "Total Time: #{1000 * total_cpu_elapsed / cpu_freq.to_f}ms (CPU freq: #{cpu_freq})"
      mega_byte = 1_048_576
      giga_byte = 1_073_741_824

      @profiles.each do |key, profile|
        next if profile[:is_main]

        if profile[:processed_byte_count]&.positive?
          seconds = profile[:elapsed] / cpu_freq.to_f
          bytes_per_second = profile[:processed_byte_count] / seconds
          mega_bytes = profile[:processed_byte_count] / mega_byte.to_f
          giga_bytes = bytes_per_second / giga_byte
          throughput = "#{mega_bytes.round(3)} mb at (#{giga_bytes.round(3)} gb/s)"
        else
          throughput = nil
        end

        print_time_elapsed(
          key,
          total_cpu_elapsed,
          profile[:elapsed],
          children_elapsed: profile[:children] && @profiles[profile[:children]][:elapsed],
          throughput: throughput
        )
      end

      clear
    end

    def close
      disable
      elapsed = read_cpu_timer - @starting_time
      profile = @profiles[@key]
      profile[:elapsed] = elapsed
      update_parent_profile
    end

    private

    def trace_handler(trace)
      return if @options[:is_custom]

      elapsed = read_cpu_timer - @starting_time
      profile = @profiles[@key]

      if @options[:count]
        handle_block_return(elapsed, profile)
      else
        handle_function_return(trace, elapsed, profile)
      end
    end

    def handle_block_return(elapsed, profile)
      if profile[:count] >= @options[:count]
        disable
        profile[:elapsed] = elapsed
        update_parent_profile
      else
        profile[:count] += 1
        profile[:processed_byte_count] += @options[:byte_count] if @options[:byte_count]
      end
    end

    def handle_function_return(trace, elapsed, profile)
      return unless trace.method_id == @key

      disable
      if profile[:elapsed]
        profile[:elapsed] += elapsed
      else
        profile[:elapsed] = elapsed
        update_parent_profile
      end
    end

    def update_parent_profile
      parent_key = self.class.active_tracers.last
      @profiles[parent_key][:children] = @key if parent_key
    end
  end
end
