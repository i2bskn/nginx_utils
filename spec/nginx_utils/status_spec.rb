# coding: utf-8

require "spec_helper"

describe NginxUtils do
  describe "Status" do
    describe ".get" do
      it "should get status" do
        body = "Active connections: 1 \nserver accepts handled requests\n 4 5 51 \nReading: 1 Writing: 3 Waiting: 2 \n"
        status = {active_connection: 1, accepts: 4, handled: 5, requests: 51, reading: 1, writing: 3, waiting: 2}
        response = OpenStruct.new(body: body)
        Net::HTTP.should_receive(:start).and_return(response)
        expect(NginxUtils::Status.get).to eq(status)
      end

      it "should generate an exception if status get fails" do
        res = OpenStruct.new(body: "invalid content")
        Net::HTTP.should_receive(:start).and_return(res)
        expect(proc{NginxUtils::Status.get}).to raise_error("Nginx status get failed")
      end
    end
  end
end