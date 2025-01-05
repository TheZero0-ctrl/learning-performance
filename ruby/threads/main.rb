require 'gvl-tracing'
require 'concurrent-ruby'

def run_forever(pool_size: 10)
  pool = Concurrent::FixedThreadPool.new(
    pool_size
  )
  i = Concurrent::AtomicFixnum.new

  loop do
    pool.post do
      yield i.increment
    end
  end
end

class Result
  attr_accessor :value
end

class Fibonacci
  class << self
    attr_accessor :result

    def calculate(n)
      self.result = Result.new
      result.value = fib(n)
    end

    def fib(n)
      return n if n <= 1

      fib(n - 1) + fib(n - 2)
    end
  end
end

# if used this, thread will not get switch as calculation will not exceed 100ms
# answers = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]

# if used this, thread will get switch as calculation will exceed 100ms
answers = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10_946, 17_711,
           28_657, 46_368, 75_025, 121_393, 196_418, 317_811, 514_229, 832_040, 1_346_269, 2_178_309, 3_524_578, 5_702_887, 9_227_465, 14_930_352, 24_157_817]

GvlTracing.start('timeline.json') do
  answers.size.times.map do |n|
    Thread.new do
      Fibonacci.calculate(n)
      answer = answers[n]
      result = Fibonacci.result.value

      raise "[#{result}] != [#{answer}]" if result != answer
    end
  end.map(&:join)
end

# even with smaller verson, if we run forever we can see thread switch
# run_forever do |iteration|
#   n = iteration % answers.size
#   Fibonacci.calculate(n)
#   answer = answers[n]
#   result = Fibonacci.result.value

#   if result != answer
#     raise "[#{result}] != [#{answer}]"
#   end
# rescue => e
#   puts "Iteration[#{iteration}] #{e.message}"
# end
