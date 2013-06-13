# coding: utf-8

module NginxUtils
  class VirtualHost
    attr_accessor :vhost_type, :destination, :http, :https, :prefix, :server_name, :root, :index, :log_dir, :access_log_format, :error_log_format, :auth_basic, :auth_basic_user_file, :ssl_certificate, :ssl_certificate_key

    def initialize(options={})
      @vhost_type = options[:vhost_type] || :normal
      @destination = options[:destination] || "127.0.0.1:8080"
      @http = options[:http].nil? ? true : options[:http]
      @https = options[:https].nil? ? true : options[:https]
      @prefix = options[:prefix] || "/usr/local/nginx"
      @server_name = options[:server_name] || "example.com"
      @root = options[:root] || File.join(@prefix, "vhosts", @server_name, "html")
      @index = options[:index] || ["index.html", "index.htm"].join(" ")
      @log_dir = options[:log_dir] || File.expand_path("../logs", @root)
      @access_log_format = options[:access_log_format] || :ltsv
      @error_log_format = options[:error_log_format] || :info
      @auth_basic = options[:auth_basic]
      @auth_basic_user_file = File.expand_path("../etc/users", @root)
      @ssl_certificate = options[:ssl_certificate] || File.expand_path("../ssl.crt/server.crt", @root)
      @ssl_certificate_key = options[:ssl_certificate_key] || File.expand_path("../ssl.key/server.key", @root)
    end

    def config
      content = open(File.expand_path("../../../template/virtual_host.erb", __FILE__)).read
      ERB.new(content).result(binding).gsub(/^\s+$/, "").gsub(/\n+/, "\n")
    end
  end
end