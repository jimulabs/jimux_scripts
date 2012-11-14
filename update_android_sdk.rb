#!/usr/bin/env ruby
require 'optparse'

BUILT_IN_FILTERS=%w[add-on doc extra platform platform-tool sample source system-image tool]
def update(sdk_home, filter_strings)
  puts "sdk_home=#{sdk_home}, filters=#{filter_strings}"
  list_sdk = `#{sdk_home}/tools/android list sdk`
  puts list_sdk
  filters = filters_for(list_sdk, filter_strings)
  cmd = "#{cmd_android_update(sdk_home, filters)}"
  puts cmd
  exec(cmd)
end

def cmd_android_update(sdk_home, filters)
  fs = filters.collect{|f| f.filter_to_send}.join(',')
  cmd = "#{sdk_home}/tools/android update sdk --no-ui --filter #{fs}"
end

Filter = Struct.new(:filter_to_send, :description)

def filters_for(avail_sdk_lines, *filter_strings)
  filter_strings = filter_strings.flatten
  avail_sdk_lines = avail_sdk_lines.lines if avail_sdk_lines.kind_of?(String)
  ufilters = unified_filter_strings(filter_strings)
  line_regex = /^\s*(\d+)-\s+\w+/  
  sdks_to_install = avail_sdk_lines.inject([]) do |a,l|
    if l=~line_regex && ufilters.any? {|f| f.kind_of?(Regexp) && l=~f}
      a << Filter.new(l[line_regex, 1], l)
    end
    a
  end
  results = sdks_to_install | ufilters.select {|f| f.kind_of?(String)}.collect do |f|
    Filter.new(f, nil)
  end
end

def unified_filter_strings(filter_strings)
  ufilters = filter_strings.collect do |f|
    if BUILT_IN_FILTERS.include?(f)
      f
    elsif f=~/^(android|google-api)-(\d+)(-(\d+))?$/
      api_from = $2.to_i
      api_to = $4.nil? ? api_from : $4.to_i
      api_range = api_from<api_to ? api_from..api_to : api_to..api_from
      api_range.collect do |api_no|
        $1=='android' ? /SDK Platform Android [\d\.]+, API #{api_no}/ :
          /Google APIs, Android API #{api_no}/
      end
    else
      /#{f}/
    end
  end.flatten.compact
end

options = {}
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: #{File.basename(__FILE__)} --sdk-home <SDK_HOME> --filters <filters>"
  opt.on("-s","--sdk-home SDK_HOME","The directory for the Android sdk") do |sdk_home|
    options[:sdk_home] = sdk_home
  end

  filter_help = %q{Comma separated list of filters.  Example: --filters android-8-17,google-api-17,"Google Admob"
     Available filters: 
       - android-<from>[-<to>]  Examples: android-17, android-8-17
       - google-api-<from>[-<to>]  Examples: google-api-8, google-api-8-17
       - <Any string that could appear in the list returned by 'android list sdk'>
  }
  opt.on("-f", "--filter FILTERS", Array, filter_help) do |filters|
    options[:filters] = filters
  end

  opt.on("-h","--help","help") do
    puts opt_parser
  end
end

opt_parser.parse!

puts "sdk_home=#{options[:sdk_home]}, filters=#{options[:filters]}"
if options[:sdk_home].nil? || options[:filters].nil?
  puts opt_parser
else
  update(options[:sdk_home], options[:filters])
end
