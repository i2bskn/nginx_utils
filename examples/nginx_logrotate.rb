#!/usr/bin/env ruby
# coding: utf-8

require "optparse"

begin
  require "nginx_utils"
rescue LoadError => e
  puts e
  exit 1
end

# Option parse
options = {}

opt = OptionParser.new
Version = "0.0.1"
opt.on("-d", "--[no-]debug", "Debug mode. Run only log output to STDOUT.") {|v| options[:debug] = v}
opt.on("--script_log=VAL", "Log file for script.") {|v| options[:script_log] = v}
opt.on("--log_level=VAL", "Log level of script log.") {|v| options[:log_level] = v.to_sym}
opt.on("--root_dir=VAL", "Root directory of Nginx.") {|v| options[:root_dir] = v}
opt.on("--target_logs=VAL", "Specify logs of target.") {|v| options[:target_logs] = v}
opt.on("--retention=VAL", "Specify in days the retention period of log.") {|v| options[:retention] = v.to_i}
opt.on("--pid_file=VAL", "PID file of Nginx") {|v| options[:pid_file] = v}

opt.parse! ARGV

rotate = NginxUtils::Logrotate.new(options)
rotate.execute
