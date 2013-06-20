#!/usr/bin/ruby

require 'strscan'

names = Hash.new
full = File.read(ARGV[0])


# Extract the names sent during connection.
list = StringScanner.new(full)
list.skip_until(/{\"users/)

list = list.scan_until(/}/)
list = list.split("],\"")

list.each do |item|
  items = item.split("\"")

  if items[0].empty?
    items[0] = items[2]
    items[2] = 'Kabaka'
  end

  #puts "#{items[0]} -- #{items[2]}"

  names[items[0]] = items[2]
end


# Print all the lines of chat, substituting in nicks.
full.each_line do |line|

  if line[0..3] == "[\"<\""

    line = line.split("\"")
    nick = names[line[3]]

    puts "<#{nick}> #{line[5]}"
    
  end

end

