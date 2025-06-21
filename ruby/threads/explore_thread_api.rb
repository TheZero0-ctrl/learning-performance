# frozen_string_literal: true

# t = Thread.new do
#   # new thread t started
#   sleep 10
#   puts 'finished'
# end

# this is main thread, Thread.main

# ## join ##
# it join thread t to main thread
#
# t.join

# ## value ##
# this join thread t and get last value thread t reutrn
#
# puts t.value

# require 'net/http'
# require 'json'

# def generate_uuid_thread
#   url = 'https://httpbin.org/uuid'

#   Thread.new do
#     response = Net::HTTP.get(URI(url))
#     JSON.parse(response)['uuid']
#   end
# end

# uuid = 4.times.map do
#   generate_uuid_thread
# end.map(&:value)

# puts uuid

# ## join(timeout_in_seconds) ##
# it will return the thread while it is still running and return nil once it finishes

# t1 = Thread.new do
#   sleep 20
# end

# while t1.alive?
#   puts "wait a bit more...#{t1.join(5)}"
# end

# puts "done"

# def fib(n)
#   return n if n <= 1

#   fib(n - 1) + fib(n - 2)
# end

# t2 = Thread.new do
#   fib(40)
# end

# while t2.alive?
#   puts "wait a bit more... #{t2.join(0.01)}"
# end

# puts "done! #{t2.value}"

## report_on_exception  and abort_on_exception ###
# t = Thread.new do
#   raise 'error'
# end

# this will not log errors
# t.report_on_exception = false

# can do this on global level
# Thread.abort_on_exception = false
#
# if we do not call join or value on thread t it will not raise error on main thread
# t.join
#
# this will raise error on main thread even if we do not call join or value
# t.abort_on_exception = true
# can do this on global level
# Thread.abort_on_exception = true

# ## Thread.list ##
# it will return list of all threads
#
# ## name ##
# can set name of thread to diffrientiate them
#
# t1 = Thread.new do
#   sleep 1
# end

# t1.name = 'my_thread'
# puts t1.name
#
# ## thread status ##
# t1.status
# run => the thread is running
# sleep => the thread is sleeping, There is some blocking operation going on or
# the thread went to sleep or was put to sleep by the thread scheduler
# aborting => thread is failed but have not finish running
# nil => error is raised and thread is dead
# false => thread finish normally
#
# ThreadStatus = Data.define(
#   :status, :error
# )

# def thread_status(thread)
#   error = nil
#   status = case thread.status
#   when NilClass
#     error = begin
#       thread.join
#     rescue => e
#       e
#     end
#     "failed w/ error: #{error}"
#   when FalseClass then "finished"
#   when "run" then "running"
#   when "sleep"
#     parse_thread_sleep_status(thread)
#   else thread.status
#   end
#   ThreadStatus.new(status: status, error: error)
# end

# def parse_thread_sleep_status(thread)
#   status = thread.to_s
#   status[status.index("sleep")..-2].sub(
#     "sleep", "sleeping"
#   )
# end

# a = Thread.new { raise("bye bye") }
# b = Thread.new { Thread.stop }
# c = Thread.new {}
# d = Thread.new { 
#   IO.select(nil, nil, nil, 3)
# }
# d.join(1)

# puts thread_status(a)
# puts thread_status(b)
# puts thread_status(c)
# puts thread_status(d)
# puts thread_status(Thread.current)
#
# ## Thread scheduler ##
# Thread.pass => tells scheduler it can switch to other thread
# Thread.new do
#   Thread.pass
#   puts "done"
# end
# Thread.wakeup => make thread eligible for scheduler
