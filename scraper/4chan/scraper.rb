#!/usr/bin/env ruby
# 
# Copyright (C) 2012-2013 Kyle Johnson <kyle@vacantminded.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# TODO:
# - Rewrite using EventMachine (no more threads?)
# - Tie in to my visual image comparison tool
# - Kill all these global variables

require 'open-uri'
require 'net/http'
require 'thread'
require 'logger'
require 'digest/md5'
require 'optparse'


# Globals like mad, because I don't care!
# TODO: Care

$pages_hit  = []                  # HTML pages we've already parsed
$downloaded = []                  # File names we already downloaded
$no_q       = []                  # File names we have already queued
$hashes     = []                  # MD5 fingerprints
$q          = Queue.new           # Download queue
$log        = Logger.new(STDOUT)  # Logger
$threads    = 0                   # Number of running download threads
$exiting    = false               # True when we're trying to exit
$options    = {}                  # Set by OptionParser

$log.level = Logger::INFO

if File.exists? "hashes.dat"
  f = File.new "hashes.dat"
  $hashes = f.readlines
  f.close
end

if File.exists? "downloaded.dat"
  f = File.new "downloaded.dat"
  $downloaded = f.readlines
  $no_q = $downloaded.clone
  f.close
end

$hash_file  = File.open "hashes.dat",     "a"
$down_file  = File.open "downloaded.dat", "a"

at_exit do
  $hash_file.close
  $down_file.close
end

# Parse the text for links to images.
def parse_image_links text, ref
  text.scan(/(\/\/[^"' ]+\/[0-9]+\.(jpe?g|png|gif|bmp|svg))/).each do |link|
    link = link.shift
    next if link.include? "thumb"

    handle_image_link "http:#{link}", ref
  end
end


# Add links to the queue.
def handle_image_link str, ref
  filename = str.split(/\//).last

  if $downloaded.include? filename or $no_q.include? filename
    $log.debug('handle_image_link') { "Skipping #{filename}" }
    return
  end

  $no_q << filename
  $q << [str, filename, ref]
end


# Parse out links to threads.
def get_thread_links text
  links = Array.new

  text.scan(/"res\/[0-9]+"/).each do |page|
    links << "#{$options[:base_url]}#{page[1..-2]}"
  end

  text.scan(/\[<a href="([0-9]+)">[0-9]+<\/a>\]/).each do |page|
    links << "#{$options[:base_url]}#{page[0]}"
  end

  return links
end


# Do the acutal work! This is called recursively with new URLs to spider.
def spider url = $options[:base_url]
  $pages_hit << url

  $log.info('spider') { "Downloading page #{url}" }

  begin
    body = open(url, 'User-Agent' => $options[:user_agent]).read

    pages = get_thread_links body
    parse_image_links body, url

    pages.each do |p|
      spider p unless $pages_hit.include? p
    end

  rescue => e
    $log.error("spider") { "Error on #{url}: #{e}" }
  end
end


# Start the thread that will manage image downloads.
def download_images
  Thread.new do
    while true
      link = $q.pop

      break if link == "EOF"

      download_thread link[0], link[1], link[2]

      $log.debug("download_images") { "Pending images: #{$q.length}" }

    end

    while $threads > 0
      $log.info("download_images") { "Waiting for all threads to exit (#{$threads})" }
      sleep 1
    end
  end
end


# Download the given URL with a new thread. If too many threads are running,
# wait until there is room for more.
def download_thread url, filename, ref
  while $threads >= $options[:threads]
    return if $exiting
    sleep 0.01
  end

  $threads += 1

  return Thread.new do
    begin
      $log.debug('download_thread') { "Starting: #{url} (#{$threads})" }

      $downloaded << filename
      $down_file.puts filename

      uri = URI(url)
      filename = "files/" + filename

      if File.exists? filename
        $log.warn('download_thread') { "File exists. Skipping: #{filename}" }

        $threads -= 1
        Thread.exit
      end

      check_dupes(filename) if download_image(uri, filename, url)

    rescue => e
      $log.error('download_thread') { "#{filename} => #{e}" }
    end

    $threads -= 1

    $log.debug('download_thread') { "Done: #{filename}" }
  end

end


# Save the file at the given URL and save it with the given name.
def download_image uri, filename, ref
  $log.info('download_image') { "Starting #{filename}" }

  f = File.open filename, "w"

  begin

    Net::HTTP.start(uri.host, uri.port) do |http|

      http.request_get(uri.request_uri,
                       'User-Agent' => $options[:user_agent],
                        'Referer' => ref) do |resp|

        # Write the file as we receive it. This also lets us do threading
        # more efficiently since we can give other threads a turn between
        # calls rather than blocking the whole app while a large file arrives.
        resp.read_body do |segment|
          f.write segment
        end

      end

    end

  rescue => e
    $log.error("download_image") { "#{filename} => #{e}" }

    f.close
    return false
  end

  $log.info('download_image') { "Finished #{filename}" }

  f.close
  return true
end


# Check for a duplicate file by MD5 hash and delete the passed file name if
# there is a match. This is sort of expensive, but it is going to take almost
# no time compared to how long we spend actually downloading files.
def check_dupes filename
  $log.debug('check_dupes') { "Begin: #{filename}" }

  begin
    m = get_md5 filename

    if $hashes.include? m
      $log.warn('check_dupes') { "Duplicate found. Deleting #{filename}" }
      File.delete filename
    else
      $hashes << m
      $hash_file.puts m
    end

  rescue => e
    $log.error('check_dupes') { "Error on #{filename}: #{e}" }
  end

  $log.debug('check_dupes') { "Finsihed: #{filename}" }
end


# Get MD5 sum of the file.
def get_md5 filename
  Digest::MD5.file filename
end


# Parse command line options

OptionParser.new do |opts|

  opts.banner = "Usage: #{$0} [options]"

  opts.separator ""
  opts.separator "Scrape all images from imageboards with numerical image filenames."
  opts.separator ""
  opts.separator "Options:"

  $options[:threads] = 4
  opts.on("-t", "--threads N", Integer, "Number of download threads to use") do |v|
    $options[:threads] = v
  end

  $options[:base_url] = 'http://boards.4chan.org/mlp/'
  opts.on("-u", "--url URL", "Base URL for spidering (default: #{$options[:base_url]})") do |v|
    $options[:base_url] = v
  end

  $options[:user_agent] = 'Mozilla/5.0 (X11; Linux x86_64; rv:14.0) Gecko/20120725 Firefox/14.0.1'
  opts.on("-a", "--user-agent URL", "User agent to send to the server (default: #{$options[:user_agent]})") do |v|
    $options[:user_agent] = v
  end

  $options[:output_dir] = ''
  opts.on("-o", "--output-dir DIR", "Directory into which files should be downloaded.") do |v|
    $options[:base_url] = v
  end

  opts.on("-h", "--help", "Display this help.") do
    puts opts
    exit
  end

end.parse!


Dir.mkdir "files" unless Dir.exists? "files"

# download thread
d = download_images

# start spidering!
$s = Thread.new do
  spider
end

# If we're interrupted, try to make sure we complete current downloads. We
# don't want any incomplete downloads.
trap("INT") {
  $log.info("main") { "SIGINT Received. Aborting!" }

  $q.clear
  $q << "EOF"

  $exiting = true

  $s.kill
}


$s.join

# Once the spider thread is done, stick this in the queue so it knows to exit
# once the queue is empty.
$q << "EOF"

d.join

