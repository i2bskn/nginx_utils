# NginxUtils

[![Gem Version](https://badge.fury.io/rb/nginx_utils.png)](http://badge.fury.io/rb/nginx_utils)
[![Build Status](https://travis-ci.org/i2bskn/nginx_utils.png?branch=master)](https://travis-ci.org/i2bskn/nginx_utils)
[![Coverage Status](https://coveralls.io/repos/i2bskn/nginx_utils/badge.png?branch=master)](https://coveralls.io/r/i2bskn/nginx_utils?branch=master)
[![Code Climate](https://codeclimate.com/github/i2bskn/nginx_utils.png)](https://codeclimate.com/github/i2bskn/nginx_utils)


Nginx utilities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nginx_utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nginx_utils

## Usage

From console:

    $ nginx_utils [status|logrotate|create_vhost] [options]
    Commands:
    nginx_utils create_vhost [OPTIONS]  # Create vhost config
    nginx_utils help [COMMAND]          # Describe available commands or one specific command
    nginx_utils logrotate [OPTIONS]     # Nginx logrotate
    nginx_utils status example.com      # Print status of Nginx

    $ nginx_utils status
    Active Connections: 1
    Accepts: 4 Handled: 5 Requests: 51
    Reading: 1 Writing: 3 Waiting: 2

    $ nginx_utils logrotate

    $ nginx_utils create_vhost -T unicorn -D /usr/local/rails/app/tmp/unicorn.sock -n rails.example.com --only_https

From ruby:

```ruby
require 'nginx_utils'
```

### Logrotate

Logs of rename target: `Dir.glob "#{root_dir}/**/#{target_logs}"`
Logs of delete target: `Dir.glob "#{root_dir}/**/#{target_logs}.*"`

```ruby
# Following parameters are default.
params = {
  debug: false,
  script_log: "/tmp/nginx_rotate.log",
  log_level: :debug,
  root_dir: "/usr/local/nginx",
  target_logs: "*.log",
  prefix: Time.now.strftime("%Y%m%d%H%M%S"),
  retention: 90,
  pid_file: "/usr/local/nginx/logs/nginx.pid"
}

rotate = NginxUtils::Logrotate.new(params)
# == Configure
# rotate.config log_level: :worn

# == Accessor
# rotate.logger.formatter = proc { |severity, datetime, progname, msg|
#   "#{datetime}: #{msg}\n"
# }
# rotate.rename_logs << add_rename_log
# rotate.delete_logs << add_delete_log

rotate.execute
```

Options that can be specified:

* `:debug` => `true` or `false`. If `:debug` is true, it is not execute.
* `:script_log` => `"/path/to/nginx_rotate.log"`. If `:script` is false, do not output logs.
* `:log_level` => `:debug` or `:info` or `:warn` or `:error` or `:fatal`.
* `:root_dir` => `"/path/to/nginx"`. Root directory of Nginx.
* `:target_logs` => `"*.log"`. Specify logs of target.
* `:prefix` => `Time.now.strftime("%Y%m%d%H%M%S")`. Prefix use to rename.
* `:retention` => `90`. Specify in days the retention period of log.
* `:pid_file` => `"/path/to/nginx.pid"`. Use to restart Nginx.

for cron:

e.g.

```
3 19 * * * /usr/local/bin/nginx_utils logrotate
```

### Status

Require **HttpStubStatusModule**.

```ruby
# http://localhost/nginx_status
NginxUtils::Status.get # => {active_connection: 1, accepts: 4, handled: 5, requests: 51, reading: 1, writing: 3, waiting: 2}

# Apache like
# http://example.com/server-status
NginxUtils::Status.get(host: "example.com", path: "/server-status")
```

### Logreader

LTSV:

The default format is `:ltsv`.

```ruby
log_file = "/path/to/nginx/logs/access.log.ltsv"
reader = NginxUtils::Logreader.new(log_file)
reader.each do |line|
  p line # => {time: "2013-05-19T08:13:14+00:00", host: "192.168.1.10", ...}
end
```

Combined:

```ruby
log_file = "/path/to/nginx/logs/access.log.combined"
reader = NginxUtils::Logreader.new(log_file, format: :combined)
reader.each {|line| p line} # => {:remote_addr=>"x.x.x.x", :remote_user=>"-", :time_local=>"19/May/2013:23:14:04 +0900", :request=>"GET / HTTP/1.1", :status=>"200", :body_bytes_sent=>"564", :http_referer=>"-", :http_user_agent=>"-"}
```

Custom:

```ruby
log_file = "/path/to/nginx/logs/access.log.combined"
parser = /\[(.*)\]\s"(.*?)"/
reader = NginxUtils::Logreader.new(log_file, parser: parser)
reader.each {|line| p line.first} #=> ["19/May/2013:23:13:52 +0900", "GET / HTTP/1.1"]
```

Options that can be specified:

* `:format` => `:ltsv` or `:combined`. If parser is specified, format is automatically `:custom`.
* `:parser` => Parse with `String#scan`. Specified in Regexp.

### VirtualHost

```ruby
vhost = NginxUtils::VirtualHost.new(
  vhost_type: :passenger,
  server_name: "sinatra.example.com",
  root: "/usr/local/sinatra/app/public",
  only_https: true
)

puts vhost.config
```

Options that can be specified:

* `:vhost_type` => `:unicorn` or `:passenger` or `:proxy` or `:normal`. `:normal` is default.
* `:destination` => IP address and port or UNIX domain socket path.
* `:prefix` => Root directory of Nginx.
* `:server_name` => Server name of virtual host.
* `:root` => Document root directory path.
* `:index` => Index files. `["index.html", "index.htm"].join(" ")` is default.
* `:auth_basic` => Basic realm. `nil` is default.
* `:auth_basic_user_file` => htpasswd file path.
* `:http` => Enable http block. default is true.
* `:https` => Enable https block. default is true.
* `:ssl_certificate` => Certigicate file path.
* `:ssl_certificate_key` => Certificate key file path.
* `:log_dir` => Log directory path.
* `:access_log_format` => Log format of access log. `:ltsv` is default.
* `:error_log_level` => Log level of error log. `:info` is default.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request