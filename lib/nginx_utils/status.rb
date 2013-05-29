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
          formexp([
            status[0].split(":")[1],
            status[2].split,
            status[3].split.select{|i| /^[0-9]*$/ =~ i}
          ].flatten)
        rescue
          raise "Parse error"
      end

      def formexp(args)
        {
          active_connections: args[0].to_i,
          accepts: args[1].to_i,
          handled: args[2].to_i,
          requests: args[3].to_i,
          reading: args[4].to_i,
          writing: args[5].to_i,
          waiting: args[6].to_i
        }
      end
    end
  end
end