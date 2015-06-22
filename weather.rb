#!/usr/bin/ruby

require 'uri'
require 'rexml/document'
require 'eventmachine'
require 'em-http-request'

# overkill to use EM for one request? maybe

EventMachine.run do
  http = EventMachine::HttpRequest.new('http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml').get :query => {'query' => '75254'}

  http.errback do
    puts 'Weather conditions could not be retrieved.'
    EM.stop
  end

  http.callback do
    root = (REXML::Document.new(http.response)).root

    weather = root.elements["//weather"].text rescue nil

    temperature = root.elements["//temperature_string"].text
    humidity = root.elements["//relative_humidity"].text
    wind = root.elements["//wind_string"].text

    puts "Current Weather Conditions: #{weather}, #{temperature}, #{humidity} Humidity, Wind #{wind}"

    EM.stop
  end

end


