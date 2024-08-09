# frozen_string_literal: true

require_relative 'time_helpers'

module Profiler
  # profiler/tracer.rb
  class Tracer
    include TimeHelpers
    attr_reader :key

    @profiles = {}
    @active_tracers = []

    def initialize(event, options)
      starting_time = read_cpu_timer
      @key = options[:name]
      profiles[key] = { count: 1 }
      @trace_points = TracePoint.new(event) do |_trace|
        elapsed = read_cpu_timer - starting_time
        if event == :b_return
          if profiles[key][:count] >= options[:count]
            disable
            profiles[key][:elapsed] = elapsed
            profiles[active_tracers.last][:children] = key if active_tracers.any?
          else
            profiles[key][:count] += 1
          end
        else
          disable
          profiles[key][:elapsed] = elapsed
          profiles[active_tracers.last][:children] = key if active_tracers.any?
        end
      end
    end

    def profiles
      self.class.profiles
    end

    def active_tracers
      self.class.active_tracers
    end

    def self.profiles
      @profiles
    end

    def self.active_tracers
      @active_tracers
    end

    def self.call(type, options)
      case type
      when :function
        tracer = new(:return, options)
        tracer.enable(name: options[:name], add_to_tracers: !options[:is_main])
      when :block
        tracer = new(:b_return, options)
        tracer.enable(add_to_tracers: !options[:is_main])
      end
    end

    def enable(name: nil, add_to_tracers: true)
      if name
        @trace_points.enable(target: method(name))
      else
        @trace_points.enable
      end

      active_tracers << key if add_to_tracers
    end

    def disable
      @trace_points.disable
      active_tracers.delete(key)
    end

    def self.clear
      @profiles = {}
      @active_tracers = []
    end
  end
end
