# NginxUtils

[![Build Status](https://travis-ci.org/i2bskn/nginx_utils.png?branch=master)](https://travis-ci.org/i2bskn/nginx_utils)

Nginx utilities.

## Installation

Add this line to your application's Gemfile:

    gem 'nginx_utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nginx_utils

## Usage

```
require 'nginx_utils'
```

Logrotate:

```
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
rotate.execute
```

Status:

```
p NginxUtils::Status.get # => {active_connection: 1, accepts: 4, handled: 5, requests: 51, reading: 1, writing: 3, waiting: 2}
```

Logreader:

```
reader = NginxUtils::Logreader.new("/path/to/nginx/logs/access.log")
reader.each do |line|
  p line # => {time: "2013-05-19T08:13:14+00:00", host: "192.168.1.10", ...}
end
```

Options that can be specified:

* :format => :ltsv or :combined
* :parser => Parse with scan method. Specified in Regexp.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
