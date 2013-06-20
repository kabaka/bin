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
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

abort "Usage: #{$0} filename lines" unless ARGV.length == 2

#network   = ARGV.shift
#channel   = ARGV.shift
file_name = ARGV.shift
lines     = ARGV.shift.to_i

#file_name = "/home/#{ENV['USER']}/.weechat/logs/irc.#{network}.#{channel}.weechatlog"

abort "File #{file_name} does not exist." unless File.exists? file_name

abort "Usage: #{$0} filename lines" if lines.zero?

def format(line)
  if line =~ (/\A[0-9-]+ ([0-9:]+)\t(.+)\t(.+)\Z/)
    time, nick, text = $1, $2, $3

    if nick =~ /<?-->?|\s\*/
      puts "%s %s %s" % [time, nick, text]
    else
      puts "%s <%s> %s" % [time, nick, text]
    end
  end
end

lines = `tail -n #{lines} #{file_name}`

lines.each_line {|line| format line.force_encoding('ASCII-8BIT').chomp}

