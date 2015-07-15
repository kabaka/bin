#!/usr/bin/env ruby

abort "Usage: #{$0} directories" if ARGV.empty?
 
Dir.chdir __dir__

ARGV.each do |dir|

  unless Dir.exists? dir
    warn "no such directory: #{dir}"
    next
  end

  Dir.chdir dir do
    Dir['*'].each do |dir_item|
      if File.directory? dir_item
        warn "skipping directory: #{dir_item}"
        next
      end

      unless File.executable? dir_item
        warn "skipping non-executable file: #{dir_item}"
        next
      end

      puts "running: #{dir_item}"

      system "./#{dir_item}"
    end
  end
end

