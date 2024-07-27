# frozen_string_literal: true

require './haversine'
require 'json'

def generate(number, seed, type)
  initial_number = number
  random = Random.new(seed)
  sum = 0
  center_x = random.rand(-180.0...180.0)
  center_y = random.rand(-90.0...90.0)
  angle = random.rand * 2 * Math::PI
  radius = 100
  break_point = number / 2
  File.open('data.json', 'w') do |file|
    file.write("{\"pairs\": [\n")
    while number.positive?
      if (initial_number % break_point).zero? && type == 'cluster'
        center_x = random.rand(-180.0...180.0)
        center_y = random.rand(-90.0...90.0)
        angle = random.rand * 2 * Math::PI
      end

      if type == 'cluster'
        x0 = center_x + ((random.rand * radius) * sin(angle))
        y0 = center_y + ((random.rand * radius) * cos(angle))
        x1 = center_x + ((random.rand * radius) * sin(angle))
        y1 = center_y + ((random.rand * radius) * cos(angle))
      else
        x0 = random.rand(-180.0...180.0)
        y0 = random.rand(-90.0...90.0)
        x1 = random.rand(-180.0...180.0)
        y1 = random.rand(-90.0...90.0)
      end

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
