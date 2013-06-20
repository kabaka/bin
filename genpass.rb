#!/usr/bin/ruby

def rand_string length = 8
  o      = [('a'..'z'),('A'..'Z'),('0'..'9')].map{ |i| i.to_a }.flatten;  
  string = (1..length).map{ o[rand(o.length)] }.join;
end

if ARGV.empty?
  puts rand_string
else
  puts rand_string ARGV.first.to_i
end

