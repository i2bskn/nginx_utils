# coding: utf-8

module NginxUtils
  class Logrotate
    attr_accessor :logger
    attr_accessor :rename_logs
    attr_accessor :delete_logs

    def initialize(options={})
      configure(options)
    end

    def config(options={})
      configure(options)
    end

    def rename
      @rename_logs.each do |log|
        after = "#{log}.#{@params[:prefix]}"
        if File.exists? after
          @logger.warn "File already exists: #{after}" if @logger
        else
          File.rename(log, after) if @execute
          @logger.debug "Rename log file: #{log} to #{after}" if @logger
        end
      end
    end

    def delete
      retention_time = Time.now - (@params[:retention].to_i * 3600 * 24)

      @delete_logs.each do |log|
        if File.stat(log).mtime < retention_time
          File.unlink(log) if @execute
          @logger.debug "Delete log file: #{log}" if @logger
        end
      end
    end

    def restart
      if File.exists? @params[:pid_file]
        if @execute
          begin
            Process.kill(:USR1, File.read(@params[:pid_file]).to_i)
            @logger.info "Nginx restart is successfully" if @logger
          rescue => e
            @logger.error "Nginx restart failed" if @logger
            @logger.error e if @logger
            raise "Nginx restart failed"
          end
        end
      else
        @logger.warn "Pid file is not found. Do not restart nginx." if @logger
      end
    end

    def execute
      @logger.info "Execute Nginx logrotate" if @logger
      rename
      delete
      @logger.info "Nginx logrotate is successfully" if @logger
      restart
    end

    private
    def configure(options)
      options = options.inject({}){|r,(k,v)| r.store(k.to_sym, v); r}
      if @params.nil?
        first = true
        @params = default_params.merge(options)
        flags = @params.keys
        flags.delete(:script_log) if options[:debug] && options[:script_log].nil?
      else
        first = false
        flags = options.select{|k,v| @params[k] != v}.keys
        @params.merge!(options)
      end

      reglob = false

      flags.each do |key|
        case key
        when :debug then config_debug
        when :script_log then config_logger
        when :log_level then config_loglevel
        when :root_dir then reglob = true
        when :target_logs then reglob = true
        end
      end

      reglob_logs if reglob
    end

    def default_params
      {
        debug: false,
        script_log: "/tmp/nginx_rotate.log",
        log_level: :debug,
        root_dir: "/usr/local/nginx",
        target_logs: "*.log",
        prefix: Time.now.strftime("%Y%m%d%H%M%S"),
        retention: 90,
        pid_file: "/usr/local/nginx/logs/nginx.pid"
      }
    end

    def config_debug
      if @params[:debug]
        @execute = false
        @logger = Logger.new(STDOUT)
      else
        @execute = true
      end
    end

    def config_logger
      if @params[:script_log] == false
        @logger = false
      else
        @logger = Logger.new(@params[:script_log])
      end
    end

    def config_loglevel
      if @logger
        case @params[:log_level]
        when :fatal then @logger.level = Logger::FATAL
        when :error then @logger.level = Logger::ERROR
        when :warn then @logger.level = Logger::WARN
        when :info then @logger.level = Logger::INFO
        when :debug then @logger.level = Logger::DEBUG
        else @logger.level = Logger::DEBUG
        end
      end
    end

    def reglob_logs
      @rename_logs = Dir.glob(File.join(@params[:root_dir], "**", @params[:target_logs]))
      @delete_logs = Dir.glob(File.join(@params[:root_dir], "**", "#{@params[:target_logs]}.*"))
    end
  end
end