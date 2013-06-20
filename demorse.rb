#!/usr/bin/env ruby

#
# Morse Code Translator
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
#

KEY = {
 '.-'   => 'A',
 '-...' => 'B',
 '---'  => 'O',
 '-.'   => 'N',
 '-.-.' => 'C',
 '.--.' => 'P',
 '-..'  => 'D',
 '--.-' => 'Q',
 '.'    => 'E',
 '.-.'  => 'R',
 '..-.' => 'F',
 '...'  => 'S',
 '--.'  => 'G',
 '-'    => 'T',
 '....' => 'H',
 '..-'  => 'U',
 '..'   => 'I',
 '...-' => 'V',
 '.---' => 'J',
 '.--'  => 'W',
 '-.-'  => 'K',
 '-..-' => 'X',
 '.-..' => 'L',
 '-.--' => 'Y',
 '--'   => 'M',
 '--..' => 'Z'
}

@buffer  = ''
@passes  = []
@current = []

def decode so_far, remainder
  #puts so_far

  if remainder.nil?
    puts so_far
    return
  end

  5.times do |length|
    if length > remainder.length
      #abort so_far
      #puts 'failed'
      return
    end

    part = remainder[0..length]

    if KEY.has_key? part
      #puts "#{part} #{length} #{remainder[length..-1]}"
      #puts "#{KEY.index(part).chr}"


      next_part = decode "#{so_far}#{KEY[part]}", remainder[length+1..-1]
    end
  end
end


#decode '', '..-.-------....-.-.'
decode '', ARGV.first
