#!/usr/bin/env ruby

password_file = "#{__dir__}/.passwd"

unless File.exists? password_file
  abort 'no password file'
end

IO.read(password_file).each_line.each_with_index do |line, line_num|
  host, user_name, password = line.chomp.split(/\s/, 3)

  if password.nil? or password.empty?
    $stderr.puts "skipping line #{line_num} due to parse error"
  end

  system "wget -mNc \"ftp://#{user_name}:#{password}@#{host}\" -P ~/backups/ftp/"
end

