#!/usr/bin/ruby

require 'date'

now = Time.now.to_i

if ARGV.length != 1
  puts "Usage: paypal.rb <filename>"
  exit
end

filename = ARGV[0]
rrdname = (ARGV[0].split ".")[0]

num = 0
start_date = 0

File.open(filename).each_line do |line|
  if num == 0
    num += 1
    next
  end

  line.chomp!

  next if line.empty? or not line.include? " "

  arr = line.split ","

  date = arr[0].delete '"'
  time = arr[1].delete '"'
  balance = arr[15].delete '"'

  next if balance.empty?

  date = DateTime.strptime("#{date} #{time}", "%m/%d/%Y %H:%M:%S")
  date = date.to_time.to_i

  if num == 1
    File.delete("rrd/#{rrdname}.rrd") if File.exists? "rrd/#{rrdname}.rrd"

    if not File.exists? "rrd/#{rrdname}.rrd"
      `rrdtool create rrd/#{rrdname}.rrd \
      --start #{date} --step 1 \
      DS:balance:GAUGE:604800:0:5000 \
      RRA:AVERAGE:0.5:947:10000000`
    end
    start_date = date
  end

  `rrdupdate rrd/#{rrdname}.rrd #{date}:#{balance}`
  #puts "rrdupdate rrd/#{rrdname}.rrd #{date}:#{balance}"

  print "[Line: #{num}]\r" if num % 5 == 0

  num += 1
end

print "[Line: #{num}]\n"

File.delete("#{rrdname}.png") if File.exists? "#{rrdname}.png"

`rrdtool graph #{rrdname}.png -a PNG \
-s #{start_date} -e #{now} \
--title="#{rrdname}" --vertical-label="Account Balance ($)" \
'DEF:#{rrdname}=rrd/#{rrdname}.rrd:balance:AVERAGE' \
'AREA:#{rrdname}#00ff00:#{rrdname}' \
-w 1800 -h 200`

