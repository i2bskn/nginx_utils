# coding: utf-8

require "spec_helper"

describe NginxUtils::Status do
  let(:body) {"Active connections: 1 \nserver accepts handled requests\n 4 5 51 \nReading: 1 Writing: 3 Waiting: 2 \n"}
  let(:status) {{active_connections: 1, accepts: 4, handled: 5, requests: 51, reading: 1, writing: 3, waiting: 2}}

  describe ".get" do
    let(:response) {double("http response mock", body: body)}
    before {NginxUtils::Status.stub(:parse).and_return(nil)}

    it "should get status" do
      Net::HTTP.should_receive(:start).and_return(response)
      expect(proc{NginxUtils::Status.get}).not_to raise_error
    end

    it "should default params if not specified" do
      req = Net::HTTP::Get.new("/nginx_status")
      Net::HTTP::Get.should_receive(:new).with("/nginx_status").and_return(req)
      Net::HTTP.should_receive(:start).with("localhost", 80).and_return(response)
      expect(proc{NginxUtils::Status.get}).not_to raise_error
    end

    it "should specified host" do
      Net::HTTP.should_receive(:start).with("example.com", 80).and_return(response)
      expect(proc{NginxUtils::Status.get(host: "example.com")}).not_to raise_error
    end

    it "should specified port" do
      Net::HTTP.should_receive(:start).with("localhost", 8080).and_return(response)
      expect(proc{NginxUtils::Status.get(port: 8080)}).not_to raise_error
    end

    it "should specified path" do
      req = Net::HTTP::Get.new("/nginx-status")
      Net::HTTP::Get.should_receive(:new).with("/nginx-status").and_return(req)
      Net::HTTP.should_receive(:start).and_return(response)
      expect(proc{NginxUtils::Status.get(path: "/nginx-status")}).not_to raise_error
    end
  end

  describe ".parse" do
    it "should return status hash" do
      spbody = body.split("\n").map{|l| l.split}
      expect(NginxUtils::Status.send(:parse, spbody)).to eq(status)
    end

    it "should generate an exception if parse failed" do
      spbody = "invalid content".split("\n").map{|l| l.split}
      expect(proc{NginxUtils::Status.send(:parse, spbody)}).to raise_error(RuntimeError, "Parse error")
    end
  end

  describe ".formexp" do
    it "should return status hash with format" do
      args = [1, 4, 5, 51, 1, 3, 2]
      expect(NginxUtils::Status.send(:formexp, args)).to eq(status)
    end
  end
end