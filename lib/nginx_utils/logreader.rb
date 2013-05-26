# coding: utf-8

module NginxUtils
  class Logreader
    include Enumerable

    def initialize(log, options={})
      @log = File.open(log)

      if options[:parser]
        if options[:parser].is_a? Regexp
          @format = :custom
          @parser = options[:parser]
        else
          raise ArgumentError, "invalid argument"
        end
      else
        @format = options[:format] || :ltsv
      end
    end

    def each
      @log.each do |line|
        yield parse(line.chomp)
      end
    end

    private
    def parse(line)
      case @format.to_sym
      when :ltsv then
        row = line.split("\t").map do |f|
          c = f.split(":")
          if c == 2
            [c[0].to_sym, c[1]]
          else
            [c[0].to_sym, c[1..-1].join(":")]
          end
        end
        Hash[row]
      when :combined then
        if /([0-9.]+)\s-\s([^\s]+)\s\[(.*?)\]\s"(.*?)"\s([0-9]+)\s([0-9]+)\s"(.*?)"\s"(.*?)".*/ =~ line
          {
            remote_addr: $1,
            remote_user: $2,
            time_local: $3,
            request: $4,
            status: $5,
            body_bytes_sent: $6,
            http_referer: $7,
            http_user_agent: $8
          }
        else
          {unknown: line}
        end
      when :custom then
        line.scan @parser
      else
        raise "format error"
      end
    end
  end
end