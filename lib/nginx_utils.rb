# coding: utf-8

require "nginx_utils/version"
require "logger"

module NginxUtils
  class Logrotate
    attr_accessor :logger, :rename_logs, :delete_logs

    def initialize(options={})
      # Debug
      #   debug: false => Not execute. Only output of logs to STDOUT.
      #   debug: true => Execute rotate logs Nginx. (default)
      if options[:debug]
        debug
      else
        @execute = true

        # Script log file
        #   not specified => /tmp/nginx_rotate.log (default)
        #   script_log: false => Not output of logs.
        #   script_log: "/path/to/nginx_rotate.log" => /path/to/nginx_rotate.log
        #   script_log: STDOUT => STDOUT
        set_logger options[:script_log]

        # Script log level
        #   not specified => Logger::DEBUG (default)
        #   log_level: [:fatal|:error|:info|:warn]
        set_log_level options[:log_level]
      end

      # Target logs
      # Log of rename target is "#{root_dir}/**/#{target_logs}"
      # Log of delete target is "#{root_dir}/**/#{target_logs}.*"
      # Default parameters are as follows:
      #   - root_dir => /usr/local/nginx
      #   - target_logs => *.log
      @root_dir = options[:root_dir] || "/usr/local/nginx"
      @target_logs = options[:target_logs] || "*.log"
      @rename_logs = Dir.glob(File.join(@root_dir, "**", @target_logs))
      @delete_logs = Dir.glob(File.join(@root_dir, "**", "#{@target_logs}.*"))

      # Rename prefix
      # Log of rename target to add the prefix.
      # File name of the renamed after: "#{filename}.#{prefix}"
      # Current time default. (YYYYmmddHHMMSS)
      @prefix = options[:prefix] || Time.now.strftime("%Y%m%d%H%M%S")

      # Retention period
      # Delete log last modification time has passed the retention period.
      # Specified unit of day.
      dates = options[:retention] || 90
      @retention = Time.now - (dates.to_i * 3600 * 24)

      # PID file of Nginx
      # The default is "#{root_dir}/logs/nginx.pid".
      @pid_file = options[:pid_file] || File.join(@root_dir, "logs", "nginx.pid")
    end

    def config(options={})
      # Debug
      unless options[:debug].nil?
        if options[:debug]
          debug
        else
          debug false
        end
      end

      # Script log file
      unless options[:script_log].nil?
        set_logger options[:script_log]
      end

      # Script log level
      unless options[:log_level].nil?
        set_log_level options[:log_level]
      end

      # Target logs
      reglog = false
      unless options[:root_dir].nil?
        @root_dir = options[:root_dir]
        reglob = true
      end

      unless options[:target_logs].nil?
        @target_logs = options[:target_logs]
        reglob = true
      end

      if reglob
        @rename_logs = Dir.glob(File.join(@root_dir, "**", @target_logs))
        @delete_logs = Dir.glob(File.join(@root_dir, "**", "#{@target_logs}.*"))
      end

      # Rename prefix
      unless options[:prefix].nil?
        @prefix = options[:prefix]
      end

      # Retention period
      unless options[:retention].nil?
        @retention = Time.now - (options[:retention].to_i * 3600 * 24)
      end

      # PID file of Nginx
      unless options[:pid_file].nil?
        @pid_file = options[:pid_file]
      end
    end

    def rename
      @rename_logs.each do |log|
        after = "#{log}.#{@prefix}"
        if File.exists? after
          @logger.warn "File already exists: #{after}" if @logger
        else
          File.rename(log, after) if @execute
          @logger.debug "Rename log file: #{log} to #{after}" if @logger
        end
      end
    end

    def delete
      @delete_logs.each do |log|
        if File.stat(log).mtime < @retention
          File.unlink(log) if @execute
          @logger.debug "Delete log file: #{log}" if @logger
        end
      end
    end

    def restart
      if File.exists? @pid_file
        cmd = "kill -USR1 `cat #{@pid_file}`"
        @logger.debug "Nginx restart command: #{cmd}" if @logger
        if @execute
          if system(cmd)
            @logger.info "Nginx restart is successfully!" if @logger
          else
            @logger.error "Nginx restart failed!" if @logger
            raise "Nginx restart failed!" if @logger == false
          end
        end
      else
        @logger.warn "Pid file is not found. not restart nginx. (#{@pid_file})" if @logger
      end
    end

    def execute
      @logger.info "Nginx logrotate is started!" if @logger
      rename
      delete
      @logger.info "Nginx logrotate is successfully!" if @logger
      restart
    end

    private
    def debug(set=true)
      if set
        @execute = false
        @logger = Logger.new(STDOUT)
      else
        @execute = true
      end
    end

    def set_logger(log)
      case log
      when nil then @logger = Logger.new("/tmp/nginx_rotate.log")
      when false then @logger = false
      else @logger = Logger.new(log)
      end
    end

    def set_log_level(level)
      if @logger
        case level
        when :fatal then @logger.level = Logger::FATAL
        when :error then @logger.level = Logger::ERROR
        when :warn then @logger.level = Logger::WARN
        when :info then @logger.level = Logger::INFO
        when :debug then @logger.level = Logger::DEBUG
        else @logger.level = Logger::DEBUG
        end
      end
    end
  end
end
