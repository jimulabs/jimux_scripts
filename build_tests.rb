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

def apps
  as = {}
  as[:one_screen] = yaml2json(%q{
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

  as[:fruit] = %q{
    app = App.new.config { app_name 'Fruit'}
    geo_location = GeoLocation.new
    photo_dialog = PhotoPickerDialog.new
    image_view = ImageView.new
    image_view.on(:clicked) do
      z photo_dialog._show_
    end
    photo_dialog.on(:photo_picked) do |results|
      z image_view._set_image_(results[:photo])
    end
    label_notes = TextView.new('label_notes') {text 'Notes:'}
    label_address = TextView.new('label_address') {text 'Address:'}
    text_notes = EditText.new('text_notes') { hint 'Enter some notes.' }
    text_address = EditText.new('text_address') {text 'Loading...'}
    geo_location.on(:location_changed) do |results|
      z text_address._set_text_(results[:address])
    end
    screen = Screen.new do
      class_name_prefix 'Main'
      add_parts geo_location, image_view, label_notes, text_notes,
        label_address, text_address, photo_dialog
      on_launcher true
    end
    app.add_parts(screen)
    app
  }

  as[:responsive] = %q{
    app = App.new.config {app_name "Responsive"}
    s2 = Screen.new('SecondScreen') {
      class_name_prefix 'Second'
      add_parts label = TextView.new {text 'second'}
    }
    s3 = Screen.new('ThirdScreen') {
      class_name_prefix 'Third'
      add_parts TextView.new {text 'third'}
    }
    master_screen = Screen.new('MasterScreen') do
      class_name_prefix 'Master'
      on_launcher true
      add_parts bt2 = Button.new {text 'Second Screen'}, bt3 = Button.new{text 'Third Screen'}
      bt2.on(:clicked) { z s2._launch_ }
      bt3.on(:clicked) { z s3._launch_ }
    end
    app.config do
      add_parts master_screen, s2, s3
      add_screen_groups :tablet7, :phone_land, :tablet10,
        [master_screen, s2], [s3]
      add_screen_groups :tablet10_land, [master_screen, s2, s3]
    end
    app
  }
  as
end

def help
  puts %Q{
Usage: #{__FILE__} [APP_NAME]
  avaiable apps: #{apps.keys.collect{|a| a.to_s}.join(' ')}
  }
end

if ARGV.size<1
  help
else
  app_name = ARGV[0]
  app = apps[app_name.to_sym]
  if app
    build(app)
  else 
    puts "invalid app name: #{app_name}"
    help
  end
end
