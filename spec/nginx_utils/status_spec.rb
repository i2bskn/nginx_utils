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
      response = double("http response mock", body: body)
      expect(NginxUtils::Status.send(:parse, response)).to eq(status)
    end

    it "should generate an exception if parse failed" do
      response = double("http response mock", body: "invalid content")
      expect(proc{NginxUtils::Status.send(:parse, response)}).to raise_error(RuntimeError, "Parse error")
    end
  end

  describe ".formexp" do
    it "should return status hash with format" do
      args = body.split("\n")
      expect(NginxUtils::Status.send(:formexp, args[0], args[2].split, args[3].split)).to eq(status)
    end
  end
end