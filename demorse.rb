#!/usr/bin/env ruby

#
# Morse Code Brute Forcer
#
# Some kind idiot provided me with some morse code text that contained no
# spaces, so I hacked this together to produce a list of possible translations
# as part of the solving process.
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

def decode remainder, so_far = ''
  if remainder.nil?
    puts so_far
    return
  end

  5.times do |length|
    return if length > remainder.length

    part = remainder[0..length]

    if KEY.has_key? part
      next_part = decode remainder[length+1..-1], "#{so_far}#{KEY[part]}"
    end
  end
end


decode ARGV.first
