#!/usr/bin/ruby

# MKV -> MP4 remux script. Should produce mpeg-4 files which can be played on
# Xbox 360 and other systems without transcoding the video (audio is transcoded
# to something simple for the Xbox).
#
# Based on the commands found here:
# http://forums.xbox-scene.com/index.php?showtopic=640413
# (Posted by M3_DeL, Feb 6 2008, 05:39 AM, downloaded 2011-10-24)
#
# 
# I don't use this any longer, as I don't bother with the hassle of trying to
# play videos on video game consoles. Now, I just have my workstation connected
# directly to my large display. But I'll leave this here just in case...
#
# Also note: I cannot test this, as it requires NeroAacEnc, which is not
# available on my platform. So I won't be refactoring this or updating the code
# style to meet my current standards. Sorry.
#
#
# Copyright (C) 2013 Kyle Johnson <kyle@vacantminded.com>
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

if ARGV.length != 1
  puts "Usage: #{__FILE__} filename"
  exit
end

input = ARGV[0]

unless File.exists? input and not File.directory? input
  puts "Input file #{input} does not exist."
  exit -1
end

output_suffix = ".mov"

# If our output file exists, add a .n before the extension, where n is the
# first unused number from 1.

input_arr = input.split(".")
output_prefix = input_arr[0..input_arr.length - 2].join(".")
output_num = 0
output_num_str = ""

while File.exists? output_prefix + output_num_str + output_suffix
  output_num += 1
  output_num_str = ".#{output_num}"
end

output = output_prefix + output_num_str + output_suffix

width = Integer(`tput cols`) - 6

header = "  \033[1mChecking MKV track info...\033[0m"
print sprintf("%-#{width}.#{width}s", header)


# Get output from mkvinfo and parse it. We'll do this one line at a time.
# I hope this works for all cases!
mkv_info = `mkvinfo \"#{input}\"`

tracks = Array.new

current_track_number = 0
current_track_type = ""
current_track_format = ""

have_video_track = false
have_audio_track = false

tmp = `mktemp -d`.chomp

video_dump = "#{tmp}/video.h264"
audio_dump = "#{tmp}/audio."

extract_cmd = "mkvextract tracks \"#{input}\" "

mkv_info.each_line do |line|
  if line =~ /Track number: ([0-9]+)$/
    current_track_number = Integer($1)
  elsif line =~ /Track type: (.+)$/
    current_track_type = $1
  elsif line =~ /Codec ID: (.+)$/
    current_track_format = $1
  end
  unless current_track_number == 0 or current_track_type.empty? or current_track_format.empty?
    if current_track_type == "video"

      if have_video_track
        puts "[\033[31mFAIL\033[0m]"
        puts "More than one video track was found. Multi-track MKV remuxing is not yet supported."
        exit -1
      end

      extract_cmd += "#{current_track_number}:#{video_dump} "

      have_video_track = true
    elsif current_track_type == "audio"

      if have_audio_track
        puts "[\033[31mFAIL\033[0m]"
        puts "More than one audio track was found. Multi-track MKV remuxing is not yet supported."
        exit -1
      end

      current_track_format = current_track_format[2..current_track_format.length - 1].downcase

      audio_dump += current_track_format
      extract_cmd += "#{current_track_number}:#{audio_dump} "

      have_audio_track = true
    end

    current_track_number = 0
    current_track_type = ""
    current_track_format = ""
  end
end

if not have_video_track or not have_audio_track
  puts "Did not find a video and audio track."
  exit -1
end

puts "[ \033[32mOK\033[0m ]"


header = "  \033[1mExtracting tracks...\033[0m"
print sprintf("%-#{width}.#{width}s", header)

if system(extract_cmd + " &> /dev/null")
  puts "[ \033[32mOK\033[0m ]"
else
  puts "[\033[31mFAIL\033[0m]"
  exit -1
end

header = "  \033[1mConverting audio...\033[0m"
print sprintf("%-#{width}.#{width}s", header)

`mkfifo #{tmp}/audiodump.wav`

# This Nero AAC encoder is retarded and discards the directory for the input
# and output files, so we need to write them in our current directory.
# TODO: Find out if we can just use ffmpeg/mencoder here.
working_dir = Dir.pwd
Dir.chdir tmp

if system("neroAacEnc -lc -ignorelength -q 0.20 -if audiodump.wav -of audio_out.m4a &> /dev/null & mplayer #{audio_dump} -vc null -vo null -channels 2 -ao pcm:fast &> /dev/null")
  puts "[ \033[32mOK\033[0m ]"
else
  puts "[\033[31mFAIL\033[0m]"
  exit -1
end


Dir.chdir working_dir

header = "  \033[1mRemuxing to MP4...\033[0m"
print sprintf("%-#{width}.#{width}s", header)

if system("MP4Box -new #{output} -add #{video_dump} -add #{tmp}/audio_out.m4a &> /dev/null")
  puts "[ \033[32mOK\033[0m ]"
else
  puts "[\033[31mFAIL\033[0m]"
  exit -1
end

header = "  \033[1mCleaning up...\033[0m"
print sprintf("%-#{width}.#{width}s", header)

if system("rm -rf #{tmp}")
  puts "[ \033[32mOK\033[0m ]"
else
  puts "[\033[31mFAIL\033[0m]"
  exit -1
end
