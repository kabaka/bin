#!/usr/bin/ruby

require "net/http"
require "uri"
require "strscan"

Dir.chdir("/home/kabaka/scripts/rss/")

URL = "http://ws.audioscrobbler.com/2.0/user/KabakaDragon/podcast.rss"

puts "Downloading page..."

begin
  page = Net::HTTP.get URI.parse(URL)
rescue => e
  puts "I was unable to get the page: #{e}"
  exit -1
end

downloaded_list = Array.new

if File.exists? "last_lastfm.dat"
  downloaded_list = File.read("lastfm.dat").split("\n")
else
  puts "Looks like we've never downloaded from this feed. Getting everything!"
end

num = 1

dat = File.open("lastfm.dat", 'a')

matches = page.scan(/http.+\.mp3/)

matches.each do |match|
    if downloaded_list.include? match
    next
  end

  puts "[#{num}/#{matches.length}] Downloading #{match}"

  if system("wget -q -P /home/kabaka/downloads/last-fm/ #{match}")
    dat.puts match
  else
    puts " - Failed!"
  end

  num += 1
end

dat.close

