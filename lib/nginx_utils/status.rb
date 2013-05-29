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
        parse res.body.split("\n").map{|l| l.split}
      end

      private
      def parse(spbody)
          formexp([
            spbody[0].last,
            spbody[2],
            spbody[3].select{|i| /^[0-9]*$/ =~ i}
          ].flatten.map{|i| i.to_i})
        rescue
          raise "Parse error"
      end

      def formexp(args)
        {
          active_connections: args[0],
          accepts: args[1],
          handled: args[2],
          requests: args[3],
          reading: args[4],
          writing: args[5],
          waiting: args[6]
        }
      end
    end
  end
end