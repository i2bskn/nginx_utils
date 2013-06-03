# coding: utf-8

require "spec_helper"

describe "NginxUtils::Logreader" do
  let!(:io_mock) do
    io = double("io mock").as_null_object
    File.stub(:open).and_return(io)
    io
  end

  let(:access_log) {"/usr/local/nginx/logs/access.log"}
  let(:parser) {/([0-9.]+)\s-\s([^\s]+)\s\[(.*?)\]\s"(.*?)"\s([0-9]+)\s([0-9]+)\s"(.*?)"\s"(.*?)".*/}
  let(:reader) {NginxUtils::Logreader.new(access_log)}

  describe "#initialize" do
    context "with default parameters" do
      it "specified file should be opened" do
        File.should_receive(:open).with(access_log)
        reader
      end

      it "default format should be ltsv" do
        expect(reader.instance_eval{@format}).to eq(:ltsv)
      end

      it "default parser should be nil" do
        expect(reader.instance_eval{@parser}).to be_nil
      end
    end

    context "with custom parameters" do
      it "format should be specified parameter" do
        reader = NginxUtils::Logreader.new(access_log, format: :combined)
        expect(reader.instance_eval{@format}).to eq(:combined)
      end

      it "parser should be specified parameter" do
        reader = NginxUtils::Logreader.new(access_log, parser: parser)
        expect(reader.instance_eval{@parser}).to eq(parser)
      end

      it "format should be :custom if specified parser" do
        reader = NginxUtils::Logreader.new(access_log, parser: parser)
        expect(reader.instance_eval{@format}).to eq(:custom)
      end

      it "should create exception if parser is not Regexp instance" do
        expect(
          proc {
            NginxUtils::Logreader.new(access_log, parser: "invalid parser")
          }
        ).to raise_error("invalid argument")
      end
    end
  end

  describe "#each" do
    it "call parse method" do
      io_mock.stub(:each).and_yield("log line\n")
      NginxUtils::Logreader.any_instance.should_receive(:parse)
      reader.each {|line| line}
    end
  end

  describe "#parse" do
    let(:ltsv_line) {"time:2013-05-19T08:13:14+00:00\thost:192.168.1.10\txff:-\tmethod:GET\tpath:/\tstatus:200\tua:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31\treq_size:124\treq_time:0.007\tres_size:239\tbody_size:11\tapp_time:-\n"}
    let(:combined_line) {"192.168.1.10 - - [19/May/2013:23:14:04 +0900] \"GET / HTTP/1.1\" 200 239 \"-\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31\"\n"}

    it "ltsv format log" do
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
      expect(reader.send(:parse, ltsv_line.chomp)).to eq(ltsv_hash)
    end

    it "combined format log" do
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
      reader = NginxUtils::Logreader.new(access_log, format: :combined)
      expect(reader.send(:parse, combined_line.chomp)).to eq(combined_hash)
    end

    it "return unknown log if parse error" do
      unknown_line = "unknown log"
      reader = NginxUtils::Logreader.new(access_log, format: :combined)
      expect(reader.send(:parse, unknown_line)).to eq({unknown: unknown_line})
    end

    it "custom format parser" do
      custom_hash = [
        [
          "192.168.1.10",
          "-",
          "19/May/2013:23:14:04 +0900",
          "GET / HTTP/1.1",
          "200",
          "239",
          "-",
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31"
        ]
      ]
      reader = NginxUtils::Logreader.new(access_log, parser: parser)
      expect(reader.send(:parse, combined_line.chomp)).to eq(custom_hash)
    end

    it "create exception if unknown format" do
      reader = NginxUtils::Logreader.new(access_log, format: :unknown)
      expect(proc{reader.send(:parse, combined_line.chomp)}).to raise_error("format error")
    end
  end
end