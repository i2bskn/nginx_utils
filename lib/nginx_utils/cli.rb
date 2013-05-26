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
        puts "Active Connections: #{result[:active_connection]}"
        puts "Accepts: #{result[:accepts]} Handled: #{result[:handled]} Requests: #{result[:requests]}"
        puts "Reading: #{result[:reading]} Writing: #{result[:writing]} Waiting: #{result[:waiting]}"
      end
    end

    desc "logrotate -d", "Nginx logrotate"
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
  end
end