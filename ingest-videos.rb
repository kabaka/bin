#!/usr/bin/env ruby

# Television show renaming/moving utility.
#
# Attempts (often very wrongly) to extract the show title, season number, and
# episode number from a file name, then copy it into a sorted location.
#
# TODO:
#   * OptionParser for:
#     * Destination directory
#     * Dry run
#     * Verbosity
#   * Extract compressed videos (such as multi-part RAR)
#   * Transcode/remux to uniform format
#   * Remove source directories for files that come nested in some mess
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
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


require 'fileutils'

# this is hax -- sorry

#SOURCE_DIR = file.expand_path '~/downloads/'
DEST_DIR = File.expand_path '~/media/visual/video/television/'

VIDEO_EXTENSIONS = %w[
  .mkv
  .avi
  .mp4
]

REGEX = [
  /\b(?<series_title>\S+)\./,
  /[Ss](?<season>[0-9]{1,2})[Ee](?<episode>[0-9]{1,2})\./,
  /(?<misc_info>\S+)\./, # would be nice if this portion were consistent...
  /(?<extension>[^\.]+)$/
].join

NAME_MAP = {
  /mlp/     => 'my-little-pony-friendship-is-magic',
  /merlin/  => 'merlin'
}


def ingest_file path, match
  series = match[:series_title].downcase.tr_s '^a-z0-9', '-'

  NAME_MAP.each do |regex, title|
    if series.match regex
      series = title
      break
    end
  end

  new_file_name = "#{series}_S#{match[:season]}E#{match[:episode]}.#{match[:extension]}"

  puts "#{series}: S: #{match[:season]} E: #{match[:episode]} (#{match[:extension]})"

  FileUtils.mkdir_p File.join DEST_DIR, series, match[:season]

  destination = File.join DEST_DIR, series, match[:season], new_file_name

  p path

  File.rename path, destination
end


def ingest_dir dir
  Dir.chdir dir do

    Dir.foreach dir do |path|
      match = path.match REGEX

      #p path, match

      next unless match

      if File.directory? path
        ingest_dir File.join dir, path
      end

      unless VIDEO_EXTENSIONS.include? File.extname path
        warn "warning: unknown extension on possible match \"#{path}\""
        next
      end

      ingest_file path, match
    end

  end
end

ARGV.each do |dir|
  unless File.directory? dir
    warn "skipping non-existent directory \"#{dir}\""
  end

  ingest_dir File.expand_path dir
end

#ingest_dir SOURCE_DIR

