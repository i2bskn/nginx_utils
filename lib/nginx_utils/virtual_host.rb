# coding: utf-8

module NginxUtils
  class VirtualHost
    attr_accessor :vhost_type, :destination, :http, :https, :prefix, :server_name, :root, :index, :log_dir, :access_log_format, :error_log_level, :auth_basic, :auth_basic_user_file, :ssl_certificate, :ssl_certificate_key

    def initialize(options={})
      options = options.inject({}){|r,(k,v)| r.store(k.to_sym, v); r}
      set_vhost_type(options)
      set_common_params(options)
      set_protocols(options)
      set_log_params(options)
    end

    def set_vhost_type(options)
      # Arguments: vhost_type, destination in options
      if options[:vhost_type].nil?
        @vhost_type = :normal
      else
        case options[:vhost_type].to_sym
        when :unicorn then
          @vhost_type = :unicorn
          @destination = options[:destination] || "127.0.0.1:8080"
        when :proxy then
          @vhost_type = :proxy
          @destination = options[:destination] || "127.0.0.1:8080"
        when :passenger then
          @vhost_type = :passenger
        else
          @vhost_type = :normal
        end
      end

      if @destination =~ /\.sock$/ && @destination !~ /^unix:/
        @destination = "unix:#{@destination}"
      end
    end

    def set_common_params(options)
      # Arguments: prefix, server_name, root, index, auth_basic, auth_basic_user_file in options
      @prefix = options[:prefix] || "/usr/local/nginx"
      @server_name = options[:server_name] || "example.com"
      @root = options[:root] || File.join(@prefix, "vhosts", @server_name, "html")
      @index = options[:index] || ["index.html", "index.htm"].join(" ")
      @auth_basic = options[:auth_basic]
      if @auth_basic
        @auth_basic_user_file = options[:auth_basic_user_file] || File.join(@prefix, "vhosts", @server_name, "etc", "users")
      end
    end

    def set_protocols(options)
      # Arguments: http, https, ssl_certificate, ssl_certificate_key in options
      @http = options[:http].nil? ? true : options[:http]
      @https = options[:https].nil? ? true : options[:https]
      @http = false if options[:only_https]
      @https = false if options[:only_http]
      if @https
        @ssl_certificate = options[:ssl_certificate] || File.join(@prefix, "vhosts", @server_name, "ssl.crt", "server.crt")
        @ssl_certificate_key = options[:ssl_certificate_key] || File.join(@prefix, "vhosts", @server_name, "ssl.key", "server.key")
      end
    end

    def set_log_params(options)
      # Arguments: log_dir, access_log_format, error_log_level in options
      @log_dir = options[:log_dir] || File.join(@prefix, "vhosts", @server_name, "logs")
      @access_log_format = options[:access_log_format] || :ltsv
      @error_log_level = options[:error_log_level] || :info
    end

    def config
      content = open(File.expand_path("../../../template/virtual_host.erb", __FILE__)).read
      ERB.new(content).result(binding).gsub(/^\s+$/, "").gsub(/\n+/, "\n")
    end
  end
end