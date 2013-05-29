# coding: utf-8

require "spec_helper"

describe "NginxUtils::Status" do
  let(:body) {"Active connections: 1 \nserver accepts handled requests\n 4 5 51 \nReading: 1 Writing: 3 Waiting: 2 \n"}
  let(:status) {{active_connections: 1, accepts: 4, handled: 5, requests: 51, reading: 1, writing: 3, waiting: 2}}

  describe ".get" do
    before {NginxUtils::Status.stub(:parse).and_return(nil)}

    it "should get status" do
      response = double("http response mock", body: body)
      Net::HTTP.should_receive(:start).and_return(response)
      expect(proc{NginxUtils::Status.get}).not_to raise_error
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