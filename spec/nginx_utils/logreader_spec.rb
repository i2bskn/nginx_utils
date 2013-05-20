# coding: utf-8

require "spec_helper"

describe NginxUtils do
  include FakeFS::SpecHelpers

  def create_log(format)
    log_dir = "/tmp"
    FileUtils.mkdir_p log_dir

    case format
    when :ltsv then
      line = "time:2013-05-19T08:13:14+00:00\thost:192.168.1.10\txff:-\tmethod:GET\tpath:/\tstatus:200\tua:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31\treq_size:124\treq_time:0.007\tres_size:239\tbody_size:11\tapp_time:-\n"
    when :combined then
      line = "192.168.1.10 - - [19/May/2013:23:14:04 +0900] \"GET / HTTP/1.1\" 200 239 \"-\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31\"\n"
    else raise "format error"
    end

    File.open(File.join(log_dir, "access.log"), "w") do |f|
      3.times {f.write line}
    end
  end

  before(:each) do
    @log_file = "/tmp/access.log"
    @parser = /([0-9.]+)\s-\s([^\s]+)\s\[(.*?)\]\s"(.*?)"\s([0-9]+)\s([0-9]+)\s"(.*?)"\s"(.*?)"\s"(.*)".*/
  end

  describe "Logreader" do
    describe "#initialize" do
      context "with default parameters" do
        before(:each) do
          create_log(:ltsv)
          @reader = NginxUtils::Logreader.new(@log_file)
        end

        it "specified file should be opened" do
          expect(@reader.instance_eval{@log}.path).to eq(@log_file)
        end

        it "default format should be ltsv" do
          expect(@reader.instance_eval{@format}).to eq(:ltsv)
        end

        it "default parser should be nil" do
          expect(@reader.instance_eval{@parser}).to eq(nil)
        end
      end

      context "with custom parameters" do
        before(:each) do
          create_log(:combined)
        end

        it "format should be specified parameter" do
          reader = NginxUtils::Logreader.new(@log_file, format: :combined)
          expect(reader.instance_eval{@format}).to eq(:combined)
        end

        it "parser should be specified parameter" do
          reader = NginxUtils::Logreader.new(@log_file, parser: @parser)
          expect(reader.instance_eval{@parser}).to eq(@parser)
        end

        it "format should be :custom if specified parser" do
          reader = NginxUtils::Logreader.new(@log_file, parser: @parser)
          expect(reader.instance_eval{@format}).to eq(:custom)
        end

        it "should create exception if parser is not Regexp instance" do
          expect(proc{NginxUtils::Logreader.new(@log_file, parser: "invalid parser")}).to raise_error("invalid argument")
        end
      end
    end

    describe "#each" do
      context "with ltsv log" do
        it "return ltsv hash" do
          create_log(:ltsv)
          reader = NginxUtils::Logreader.new(@log_file)
          ltsv_hash = {
            time: "2013-05-19T08:13:14+00:00",
            host: "192.168.1.10",
            xff:"-",
            method: "GET",
            path: "/",
            status: "200",
            ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31",
            req_size: "124",
            req_time: "0.007",
            res_size: "239",
            body_size: "11",
            app_time: "-"
          }
          reader.each {|line| expect(line).to eq(ltsv_hash)}
        end
      end

      context "with combined log" do
        it "return combined hash" do
          create_log(:combined)
          reader = NginxUtils::Logreader.new(@log_file, format: :combined)
          combined_hash = {
            remote_addr: "192.168.1.10",
            remote_user: "-",
            time_local: "19/May/2013:23:14:04 +0900",
            request: "GET / HTTP/1.1",
            status: "200",
            body_bytes_sent: "239",
            http_referer: "-",
            http_user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31"
          }
          reader.each {|line| expect(line).to eq(combined_hash)}
        end

        it "return unknown log if parse error" do
          create_log(:combined)
          File.open(@log_file, "w") {|f| f.write "unknown log"}
          reader = NginxUtils::Logreader.new(@log_file, format: :combined)
          reader.each {|line| expect(line).to eq({unknown: "unknown log"})}
        end
      end
    end
  end
end