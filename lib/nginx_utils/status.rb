# coding: utf-8

module NginxUtils
  module Status
    class << self
      def get(options={})
        host = options[:host] || "localhost"
        port = options[:port] || 80
        path = options[:path] || "/nginx_status"

        req = Net::HTTP::Get.new(path)
        res = Net::HTTP.start(host, port){|http| http.request(req)}
        parse res
      end

      private
      def parse(response)
          status = response.body.split("\n")
          formexp(status[0], status[2].split, status[3].split)
        rescue
          raise "Parse error"
      end

      def formexp(ac_line, server_line, rww_line)
        {
          active_connections: ac_line.split(":")[1].to_i,
          accepts: server_line[0].to_i,
          handled: server_line[1].to_i,
          requests: server_line[2].to_i,
          reading: rww_line[1].to_i,
          writing: rww_line[3].to_i,
          waiting: rww_line[5].to_i
        }
      end
    end
  end
end