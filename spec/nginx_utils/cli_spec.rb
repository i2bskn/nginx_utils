# coding: utf-8

require "spec_helper"
require "stringio"

describe "NginxUtils::CLI" do
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end

  describe "#status" do
    let(:result) {
      {
        active_connections: 1,
        accepts: 4,
        handled: 5,
        requests: 51,
        reading: 1,
        writing: 3,
        waiting: 2
      }
    }

    before(:each) {NginxUtils::Status.should_receive(:get).and_return(result)}

    it "default output" do
      args = ["status"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("Active Connections: 1\nAccepts: 4 Handled: 5 Requests: 51\nReading: 1 Writing: 3 Waiting: 2\n")
    end

    it "only value output" do
      args = ["status", "--only_value"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("1\t4\t5\t51\t1\t3\t2\n")
    end
  end

  describe "#logrotate" do
    before(:each) do
      @rotate = double("lotate mock")
      @rotate.should_receive(:execute).and_return(true)
    end

    it "logrotate should be execute" do
      NginxUtils::Logrotate.should_receive(:new).and_return(@rotate)
      args = ["logrotate"]
      NginxUtils::CLI.start(args)
    end

    it "debug option" do
      options = {"debug" => true}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "-d"]
      NginxUtils::CLI.start(args)
    end

    it "script_log option" do
      options = {"script_log" => "/var/log/nginx_rotate.log"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "--script_log", "/var/log/nginx_rotate.log"]
      NginxUtils::CLI.start(args)
    end

    it "log_level option" do
      options = {"log_level" => "warn"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "--log_level", "warn"]
      NginxUtils::CLI.start(args)
    end

    it "root_dir option" do
      options = {"root_dir" => "/usr/local/nginx_other"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "--root_dir", "/usr/local/nginx_other"]
      NginxUtils::CLI.start(args)
    end

    it "target_logs option" do
      options = {"target_logs" => "*_log"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "--target_logs", "*_log"]
      NginxUtils::CLI.start(args)
    end

    it "retention option" do
      options = {"retention" => "30"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "--retention", "30"]
      NginxUtils::CLI.start(args)
    end

    it "pid_file option" do
      options = {"pid_file" => "/var/run/nginx.pid"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(@rotate)
      args = ["logrotate", "--pid_file", "/var/run/nginx.pid"]
      NginxUtils::CLI.start(args)
    end
  end
end
