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

      def parse(response)
        begin
          status = response.body.split("\n")
          server = status[2].split.map{|i| i.to_i}
          rww = status[3].split.select{|i| /^[0-9]+$/ =~ i}.map{|i| i.to_i}
          {
            active_connections: status[0].split(":").last.gsub(/\s/, "").to_i,
            accepts: server[0],
            handled: server[1],
            requests: server[2],
            reading: rww[0],
            writing: rww[1],
            waiting: rww[2]
          }
        rescue
          raise "Parse error"
        end
      end
    end
  end
end