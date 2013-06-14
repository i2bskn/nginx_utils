# coding: utf-8

module NginxUtils
  class CLI < Thor
    desc "status example.com", "Print status of Nginx"
    long_desc <<-LONGDESC
    `status` to view the status of Nginx.
    LONGDESC
    option :only_value, type: :boolean, desc: "print status value only."
    def status(host="localhost")
      result = NginxUtils::Status.get host: host
      if options[:only_value]
        puts result.values.join("\t")
      else
        puts "Active Connections: #{result[:active_connections]}"
        puts "Accepts: #{result[:accepts]} Handled: #{result[:handled]} Requests: #{result[:requests]}"
        puts "Reading: #{result[:reading]} Writing: #{result[:writing]} Waiting: #{result[:waiting]}"
      end
    end

    desc "logrotate [OPTIONS]", "Nginx logrotate"
    long_desc <<-LONGDESC
    `logrotate` will log rotation of Nginx.
    LONGDESC
    option :debug, type: :boolean, aliases: "-d", desc: "Debug mode. Run only log output to STDOUT."
    option :script_log, desc: "Log file for script."
    option :log_level, desc: "Log level of script log."
    option :root_dir, desc: "Root directory of Nginx."
    option :target_logs, desc: "Specify logs of target."
    option :retention, desc: "Specify in days the retention period of log."
    option :pid_file, desc: "PID file of Nginx"
    def logrotate
      NginxUtils::Logrotate.new(options).execute
    end

    desc "create_vhost [OPTIONS]", "Create vhost config"
    long_desc <<-LONGDESC
    `create_vhost` will create vhost configuration.
    LONGDESC
    option :vhost_type, aliases: "-T", desc: "virtualhost type. default is normal. [normal|unicorn|passenger|proxy]"
    option :destination, aliases: "-D", desc: "proxy destination. path of the socket file or ip address and port"
    option :prefix, aliases: "-p", desc: "nginx root directory."
    option :server_name, aliases: "-n", desc: "server name of vhosts."
    option :root, aliases: "-d", desc: "document root path."
    option :index, aliases: "-i", desc: "index files."
    option :auth_basic, aliases: "-r", desc: "authentication realm."
    option :auth_basic_user_file, aliases: "-u", desc: "user file of basic auth."
    option :only_http, type: :boolean, desc: "disable https block."
    option :only_https, type: :boolean, desc: "disable http block."
    option :ssl_certificate, desc: "certificate file."
    option :ssl_certificate_key, desc: "certificate key file."
    option :log_dir, desc: "log directory path of virtual host."
    option :access_log_format, desc: "access log format."
    option :error_log_level, desc: "error log level."
    def create_vhost
      vhost = NginxUtils::VirtualHost.new(options)
      puts vhost.config
    end
  end
end