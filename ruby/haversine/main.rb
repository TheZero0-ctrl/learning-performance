# frozen_string_literal: true

require './generator'

number = gets.chomp.to_i
seed = gets.chomp.to_i
type = gets.chomp
generate(number, seed, type)
