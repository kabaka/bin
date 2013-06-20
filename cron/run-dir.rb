#!/usr/bin/env ruby

if ARGV.empty?
  abort "Usage: #{$0} directories"
end

ARGV.each do |dir|
  Dir.chdir __dir__

  unless Dir.exists? dir
    $stderr.puts "no such directory \"#{dir}\""
    next
  end

  Dir.chdir dir

  Dir['*'].each do |dir_item|
    if File.directory? dir_item
      $stderr.puts "skipping directory \"#{dir_item}\""
      next
    end

    unless File.executable? dir_item
      $stderr.puts "skipping non-executable file \"#{dir_item}\""
      next
    end

    $stdout.puts "running \"#{dir_item}\""

    system "./#{dir_item}"
  end
end

