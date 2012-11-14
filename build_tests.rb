#!/usr/bin/env ruby
require 'socket'

def yaml2json(yml)
  require 'yaml'
  require 'json'
  thing = YAML.load(yml)
  json = thing.to_json
end

def build(json, host='localhost', port=1976)
  socket = TCPSocket.new host, port
  while line=socket.gets
    puts line
    break if line=~/READY/
  end
  socket.puts "build #{json}"
  while line=socket.gets
    keep_fetching = false
    case line
    when /percent=(\d+)/
      puts "#{$1}%"
      keep_fetching = true
    when /apk_path=(.+)/
      path = $1
      puts "apk_path=#{path}"
    when /error=(.+)/
      puts "error=#{$1}"
    else
      puts "SOME WEIRD RESPONSE? #{line}"
    end
    break unless keep_fetching
  end
  save!
  socket.close
end

blocki = yaml2json(%q{
id: 1
name: Fruit
block: App
children:
  - id: 2
    name: Screen1
    block: Screen
    children: 
      - id: 3
        name: button1
        block: Button4Test
        eventHandlers:
          - event: clicked
            actorId: 4
            action: set_text
            params: [value1, $4.text]
      - id: 4
        name: text1
        block: TextView4Test
})

build(blocki)
