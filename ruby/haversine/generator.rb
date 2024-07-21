# frozen_string_literal: true

require './haversine'
require 'json'

def generate(number, seed, type)
  initial_number = number
  random = Random.new(seed)
  sum = 0
  max_x = type == 'cluster' ? random.rand(0..180.0) : 180.0
  max_y = type == 'cluster' ? random.rand(0..90.0) : 90.0
  break_point = number / 2
  File.open('data.json', 'w') do |file|
    file.write("{\"pairs\": [\n")
    while number.positive?
      if (initial_number % break_point).zero? && type == 'cluster'
        max_x = random.rand(0..180.0)
        max_y = random.rand(0..90.0)
      end

      x0 = random.rand(-max_x..max_x)
      y0 = random.rand(-max_y..max_y)
      x1 = random.rand(-max_x..max_x)
      y1 = random.rand(-max_y..max_y)

      data = {
        'x0' => x0,
        'y0' => y0,
        'x1' => x1,
        'y1' => y1
      }

      json_data = JSON.pretty_generate(data)
      file.write(json_data)
      file.write(",\n") unless number == 1
      sum += reference_haversine(x0, y0, x1, y1)
      number -= 1
    end
    file.write(']}')
  end

  puts "Sum: #{sum / initial_number}"
end

