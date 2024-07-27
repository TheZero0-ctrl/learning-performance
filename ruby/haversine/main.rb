# frozen_string_literal: true

require './generator'
require './json_parser'
require './haversine'

puts 'Enter number of pairs'
number = gets.chomp.to_i
puts 'Enter seed'
seed = gets.chomp.to_i
puts 'Enter type'
type = gets.chomp
generate(number, seed, type)

lexer = JsonLexer.new(File.open('./data.json', 'r'))

parser = JsonParser.new(lexer)
parsed_json = parser.parse
count = parsed_json['pairs'].count
total = parsed_json['pairs'].reduce(0) do |sum, pair|
  sum + reference_haversine(pair['x0'], pair['y0'], pair['x1'], pair['y1'])
end

average = total / count
puts average
