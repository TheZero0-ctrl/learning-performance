# frozen_string_literal: true

require_relative 'time_helpers'

module Profiler
  # profiler/tracer.rb
  class Tracer
    include TimeHelpers
    @profiles = {}

    def initialize(events, options: {})
      starting_time = read_cpu_timer
      @trace_points = TracePoint.new(events) do |trace|
        key = options[:name] || trace.method_id
        if options[:line_number]
          if trace.lineno >= options[:line_number]
            profiles[key] = read_cpu_timer - starting_time
            disable
          end
        else
          profiles[key] = read_cpu_timer - starting_time
          disable
        end
      end
    end

    def profiles
      self.class.profiles
    end

    def self.profiles
      @profiles
    end

    def self.call(type, options)
      case type
      when :function
        tracer = new(:return, options: options)
        tracer.enable(method_name: options[:method_name])
      when :line
        tracer = new(:line, options: options)
        tracer.enable
      end
    end

    def enable(options = {})
      if options[:method_name]
        @trace_points.enable(
          target: method(options[:method_name]),
          target_line: options[:line_number]
        )
      else
        @trace_points.enable
      end
    end

    def disable
      @trace_points.disable
    end

    def clear
      @profiles = {}
    end
  end
end
