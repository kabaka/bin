#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'strscan'

user_name = 'KabakaDragon'


Dir.chdir __dir__

uri = URI("http://ws.audioscrobbler.com/2.0/user/#{user_name}/podcast.rss")
downloaded_list = []
downloaded_file = 'lastfm.dat'


puts "Downloading page..."

page = Net::HTTP.get uri

if File.exists? downloaded_file
  downloaded_list = File.read(downloaded_file).lines
end

dat = File.open downloaded_file, 'a'

page.scan(/http.+\.mp3/) do |match|
  next if downloaded_list.include? match

  print "Downloading #{match}..."

  if system "wget -q -P /home/kabaka/downloads/last-fm/ #{match}"
    dat.puts match
    puts ' Done'
  else
    puts ' FAILED'
  end
end

dat.close

