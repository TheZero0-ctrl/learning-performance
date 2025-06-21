require 'net/http'
require 'async'

def log_then_get(url)
  puts "Requesting #{url}..."
  get(url)
end

def get(uri)
  response = Net::HTTP.get(uri)
  puts caller(0).join("\n")
  response
end

def get_http_thread(url)
  Thread.new do
    log_then_get(URI(url))
  end
end

def get_http_via_threads
  threads = []
  threads << get_http_thread(
    'https://httpbin.org/delay/3?ex=1'
  )
  threads << get_http_thread(
    'https://httpbin.org/delay/3?ex=2'
  )
  threads << get_http_thread(
    'https://httpbin.org/delay/3?ex=3'
  )
  threads << get_http_thread(
    'https://httpbin.org/delay/3?ex=4'
  )
  threads.map(&:value)
end

def get_http_fiber(url, responses)
  Fiber.schedule do
    responses << log_then_get(URI(url))
  end
end

def get_http_via_fibers
  Fiber.set_scheduler(Async::Scheduler.new)
  responses = []
  responses << get_http_fiber(
    'https://httpbin.org/delay/3?ex=1', responses
  )
  responses << get_http_fiber(
    'https://httpbin.org/delay/3?ex=2', responses
  )
  responses << get_http_fiber(
    'https://httpbin.org/delay/3?ex=3', responses
  )
  responses << get_http_fiber(
    'https://httpbin.org/delay/3?ex=4', responses
  )
  responses
ensure
  Fiber.set_scheduler(nil)
end

now = Time.now
# get_http_via_threads
get_http_via_fibers
puts "Thread runtime: #{Time.now - now}"
