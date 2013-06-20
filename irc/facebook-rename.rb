#!/usr/bin/ruby

require 'json'
require "net/http"
require "uri"

unless ARGV.length == 1
  exit -1
end

PAGE = "http://graph.facebook.com/#{ARGV[0]}"

begin 
  result = JSON.parse(Net::HTTP.get URI.parse(PAGE))

  if result.has_key? "name"
    name = result['name'].gsub!(/[^a-zA-Z0-9\[\]\\_{|}@.-]/, "_")

    `/home/kabaka/scripts/weechat_cmd.sh "*/jabber alias add #{name} -#{ARGV[0]}@chat.facebook.com"`
  else
    exit -1
  end
rescue
  exit -1
end

