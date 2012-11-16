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
  socket.puts "build"
  socket.puts json
  socket.puts "#build"
  while line=socket.gets
    keep_fetching = false
    case line
    when /percent=(\d+)/
      puts "#{$1}%"
      keep_fetching = true
    when /src_path=([^;]+);apk_path=([^;]+)/
      src_path, apk_path = $1, $2
      puts "src_path=#{src_path}"
      puts "apk_path=#{apk_path}"
    when /error=(.+)/
      puts "error=#{$1}"
    else
      puts "SOME WEIRD RESPONSE? #{line}"
    end
    break unless keep_fetching
  end
  socket.close
end

blocki = yaml2json(%q{
id: 1
name: Fruit
block: App
properties:
  appName: Fruit
  packageName: com.jimulabs.fruit
children:
  - id: 2
    name: Screen1
    block: Screen
    children: 
      - id: 4
        name: Text1
        block: TextView
})

build(blocki)
