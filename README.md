# NginxUtils

TODO: Write a gem description

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

Nginx log rotate:

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
