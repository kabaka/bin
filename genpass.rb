#!/usr/bin/env ruby

def rand_string length = 8
  if length.zero?
    warn 'ignoring request for empty or non-numeric length'
    return
  end

  o      = [('a'..'z'),('A'..'Z'),('0'..'9')].map{ |i| i.to_a }.flatten
  string = (1..length).map { o[rand(o.length)] }.join
end

ARGV << 8 if ARGV.empty?

puts ARGV.map { |a| rand_string a.to_i }

