# coding: utf-8

require "spec_helper"

describe NginxUtils do
  include FakeFS::SpecHelpers

  def create_files
    root_dir = "/usr/local/nginx/logs"
    FileUtils.mkdir_p root_dir
    FileUtils.mkdir_p "/tmp"
    not_del = Time.now - (89 * 3600 * 24)
    do_del = Time.now - (91 * 3600 * 24)
    not_del_file = "access.log.#{not_del.strftime('%Y%m%d%H%M%S')}"
    do_del_file = "access.log.#{do_del.strftime('%Y%m%d%H%M%S')}"
    [
      "access.log",
      "error.log",
      "nginx.pid",
      not_del_file,
      do_del_file
    ].each{|f| File.open(File.join(root_dir, f), "w").close}
    File.utime(not_del, not_del, File.join(root_dir, not_del_file))
    File.utime(do_del, do_del, File.join(root_dir, do_del_file))
    {
      not_del_file: File.join(root_dir, not_del_file),
      do_del_file: File.join(root_dir, do_del_file)
    }
  end

  def log_lines
    File.open("/tmp/nginx_rotate.log").read.split("\n")
  end

  before(:each) do
    @created = create_files
    @script_log = File.open("/tmp/nginx_rotate.log", "a")
  end

  describe "Logrotate" do
    describe "#initialize" do
      before(:each) do
        @time_now = Time.now
        Time.stub(:now).and_return(@time_now)
        @rotate = NginxUtils::Logrotate.new(script_log: @script_log)
      end

      context "with default params" do
        it "@execute should be true" do
          expect(@rotate.instance_eval{@execute}).to eq(true)
        end

        it "@logger should be a instance of Logger class" do
          expect(@rotate.instance_eval{@logger}.is_a? Logger).to eq(true)
        end

        it "@logger.level should be debug(0)" do
          expect(@rotate.instance_eval{@logger}.level).to eq(Logger::DEBUG)
        end

        it "@root_dir should be default install prefix of Nginx" do
          expect(@rotate.instance_eval{@root_dir}).to eq("/usr/local/nginx")
        end

        it "@target logs should be *.log" do
          expect(@rotate.instance_eval{@target_logs}).to eq("*.log")
        end

        it "@rename_logs size should be 2" do
          expect(@rotate.instance_eval{@rename_logs}.size).to eq(2)
        end

        it "@delete_logs size should be 2" do
          expect(@rotate.instance_eval{@delete_logs}.size).to eq(2)
        end

        it "@prefix should be a some as @time_now" do
          expect(@rotate.instance_eval{@prefix}).to eq(@time_now.strftime("%Y%m%d%H%M%S"))
        end

        it "@retention should be 90 days" do
          expect(@rotate.instance_eval{@retention}).to eq(@time_now - (90 * 3600 * 24))
        end

        it "@pid_file should be /usr/local/nginx/logs/nginx.pid" do
          expect(@rotate.instance_eval{@pid_file}).to eq("/usr/local/nginx/logs/nginx.pid")
        end

        it "@rename_logs should be created" do
          expect(@rotate.instance_eval{@rename_logs}).not_to eq(nil)
        end

        it "@delete_logs should be created" do
          expect(@rotate.instance_eval{@delete_logs}).not_to eq(nil)
        end
      end

      context "with debug" do
        before(:each) do
          @rotate = NginxUtils::Logrotate.new(debug: true, script_log: @script_log)
        end

        it "@execute should be false" do
          expect(@rotate.instance_eval{@execute}).to eq(false)
        end

        it "@logger should be a instance of Logger class" do
          expect(@rotate.instance_eval{@logger}.is_a? Logger).to eq(true)
        end

        it "other parameters should be default" do
          expect(@rotate.instance_eval{@logger}.level).to eq(Logger::DEBUG)
          expect(@rotate.instance_eval{@root_dir}).to eq("/usr/local/nginx")
          expect(@rotate.instance_eval{@target_logs}).to eq("*.log")
          expect(@rotate.instance_eval{@prefix}).to eq(@time_now.strftime("%Y%m%d%H%M%S"))
          expect(@rotate.instance_eval{@retention}).to eq(@time_now - (90 * 3600 * 24))
          expect(@rotate.instance_eval{@pid_file}).to eq("/usr/local/nginx/logs/nginx.pid")
        end
      end

      context "with custom params" do
        it "@logger should be false if script_log is false" do
          rotate = NginxUtils::Logrotate.new(script_log: false)
          expect(rotate.instance_eval{@logger}).to eq(false)
        end

        it "@logger.level should be a specified level" do
          rotate = NginxUtils::Logrotate.new(log_level: :warn, script_log: @script_log)
          expect(rotate.instance_eval{@logger}.level).to eq(Logger::WARN)
        end

        it "@root_dir should be a specified parameter" do
          rotate = NginxUtils::Logrotate.new(root_dir: "/var/log/nginx", script_log: @script_log)
          expect(rotate.instance_eval{@root_dir}).to eq("/var/log/nginx")
        end

        it "@prefix should be a specified parameter" do
          rotate = NginxUtils::Logrotate.new(prefix: "20130518", script_log: @script_log)
          expect(rotate.instance_eval{@prefix}).to eq("20130518")
        end

        it "@retention should be a specified period" do
          rotate = NginxUtils::Logrotate.new(retention: 30, script_log: @script_log)
          expect(rotate.instance_eval{@retention}).to eq(@time_now - (30 * 3600 * 24))
        end

        it "@pid_file should be a specified parameter" do
          rotate = NginxUtils::Logrotate.new(pid_file: "/var/run/nginx.pid", script_log: @script_log)
          expect(rotate.instance_eval{@pid_file}).to eq("/var/run/nginx.pid")
        end
      end
    end

    describe "#config" do
      before(:each) do
        @time_now = Time.now
        Time.stub(:now).and_return(@time_now)
        @rotate = NginxUtils::Logrotate.new(script_log: @script_log)
      end

      it "@execute should be a false if debug is true" do
        old_execute = @rotate.instance_eval{@execute}
        @rotate.config debug: true
        expect(@rotate.instance_eval{@execute}).to eq(false)
        expect(@rotate.instance_eval{@execute}).not_to eq(old_execute)
      end

      it "@execute should be a true if debug is false" do
        rotate = NginxUtils::Logrotate.new(debug: true)
        old_execute = rotate.instance_eval{@execute}
        rotate.config debug: false
        expect(rotate.instance_eval{@execute}).to eq(true)
        expect(rotate.instance_eval{@execute}).not_to eq(old_execute)
      end

      it "@logger should be a false if script_log is false" do
        old_logger = @rotate.instance_eval{@logger}
        @rotate.config script_log: false
        expect(@rotate.instance_eval{@logger}).to eq(false)
        expect(@rotate.instance_eval{@logger}).not_to eq(old_logger)
      end

      it "@logger.level should be a specified level" do
        old_level = @rotate.instance_eval{@logger}.level
        @rotate.config log_level: :warn
        expect(@rotate.instance_eval{@logger}.level).to eq(Logger::WARN)
        expect(@rotate.instance_eval{@logger}.level).not_to eq(old_level)
      end

      it "@root_dir should be a specified parameter" do
        old_root_dir = @rotate.instance_eval{@root_dir}
        @rotate.config root_dir: "/var/log/nginx"
        expect(@rotate.instance_eval{@root_dir}).to eq("/var/log/nginx")
        expect(@rotate.instance_eval{@root_dir}).not_to eq(old_root_dir)
      end

      it "@target_logs should be a specified parameter" do
        old_target_logs = @rotate.instance_eval{@target_logs}
        @rotate.config target_logs: "*_log"
        expect(@rotate.instance_eval{@target_logs}).to eq("*_log")
        expect(@rotate.instance_eval{@target_logs}).not_to eq(old_target_logs)
      end

      it "@prefix should be a specified parameter" do
        old_prefix = @rotate.instance_eval{@prefix}
        @rotate.config prefix: "20130518"
        expect(@rotate.instance_eval{@prefix}).to eq("20130518")
        expect(@rotate.instance_eval{@prefix}).not_to eq(old_prefix)
      end

      it "@retention should be a specified period" do
        old_retention = @rotate.instance_eval{@retention}
        @rotate.config retention: 30
        expect(@rotate.instance_eval{@retention}).to eq(@time_now - (30 * 3600 * 24))
        expect(@rotate.instance_eval{@retention}).not_to eq(old_retention)
      end

      it "@pid_file should be a specified parameter" do
        old_pid_file = @rotate.instance_eval{@pid_file}
        @rotate.config pid_file: "/var/run/nginx.pid"
        expect(@rotate.instance_eval{@pid_file}).to eq("/var/run/nginx.pid")
        expect(@rotate.instance_eval{@pid_file}).not_to eq(old_pid_file)
      end
    end

    describe "#rename" do
      before(:each) do
        @prefix = Time.now.strftime('%Y%m%d%H%M%S')
        @rotate = NginxUtils::Logrotate.new(script_log: @script_log, prefix: @prefix)
      end

      it "rename target logs" do
        @rotate.rename
        @rotate.rename_logs.each do |log|
          expect(File.exists? log).to eq(false)
          expect(File.exists? "#{log}.#{@prefix}").to eq(true)
        end
      end

      it "output log file" do
        @rotate.rename
        expect(log_lines.size).to eq(@rotate.rename_logs.size)
        expect(log_lines.select{|l| /Rename log file/ =~ l}.size).to eq(@rotate.rename_logs.size)
      end

      it "do not rename if a file with the same name exists" do
        File.open("#{@rotate.rename_logs.first}.#{@prefix}", "w").close
        @rotate.rename
        expect(File.exists? @rotate.rename_logs.first).to eq(true)
        expect(log_lines.select{|line| /File already exists/ =~ line}.size).to eq(1)
      end

      it "do not rename if not executable" do
        @rotate.config debug: true, script_log: false
        @rotate.rename
        @rotate.rename_logs.each do |log|
          expect(File.exists? log).to eq(true)
          expect(File.exists? "#{log}.#{@prefix}").to eq(false)
        end
      end

      it "do not output log if script_log is false" do
        @rotate.config script_log: false
        @rotate.rename
        expect(log_lines.size).to eq(0)
      end
    end

    describe "#delete" do
      before(:each) do
        @rotate = NginxUtils::Logrotate.new(script_log: @script_log)
      end

      it "delete target logs" do
        @rotate.delete
        expect(File.exists? @created[:do_del_file]).to eq(false)
        expect(File.exists? @created[:not_del_file]).to eq(true)
      end

      it "output log file" do
        @rotate.delete
        expect(log_lines.size).to eq(1)
      end

      it "do not delete if not executable" do
        File.should_not_receive(:unlink)
        @rotate.config debug: true, script_log: false
        @rotate.delete
      end

      it "do not output log if script_log is false" do
        @rotate.config script_log: false
        @rotate.delete
        expect(log_lines.size).to eq(0)
      end
    end

    describe "#restart" do
      before(:each) do
        Object.any_instance.stub(:system).and_return(true)
        @rotate = NginxUtils::Logrotate.new(script_log: @script_log)
      end

      it "should execute command" do
        Object.any_instance.should_receive(:system).and_return(true)
        @rotate.restart
      end

      it "output success log" do
        @rotate.restart
        expect(log_lines.select{|l| /Nginx restart command/ =~ l}.size).to eq(1)
        expect(log_lines.select{|l| /Nginx restart is successfully/ =~ l}.size).to eq(1)
      end

      it "do not execute command if not exists pid file" do
        Object.any_instance.should_not_receive(:system)
        File.stub(:exists?).and_return(false)
        @rotate.restart
      end

      it "should output log if not exists pid file" do
        File.stub(:exists?).and_return(false)
        @rotate.restart
        expect(log_lines.select{|l| /Pid file is not found/ =~ l}.size).to eq(1)
      end

      it "do not execute commando if not executable" do
        Object.any_instance.should_not_receive(:system)
        @rotate.config debug: true, script_log: false
        @rotate.restart
      end

      it "should outputs error log if it fails" do
        Object.any_instance.should_receive(:system).and_return(false)
        @rotate.restart
        expect(log_lines.select{|l| /Nginx restart failed/ =~ l}.size).to eq(1)
      end

      it "should generate an exception if it fails" do
        Object.any_instance.should_receive(:system).and_return(false)
        @rotate.config script_log: false
        expect(proc{@rotate.restart}).to raise_error("Nginx restart failed")
      end

      it "do not output log if script_log is false" do
        @rotate.config script_log: false
        @rotate.restart
        expect(log_lines.size).to eq(0)
      end
    end

    describe "#execute" do
      before(:each) do
        NginxUtils::Logrotate.any_instance.stub(:rename).and_return(true)
        NginxUtils::Logrotate.any_instance.stub(:delete).and_return(true)
        NginxUtils::Logrotate.any_instance.stub(:restart).and_return(true)
        @rotate = NginxUtils::Logrotate.new(script_log: @script_log)
      end

      it "should call rename and delete and restart methods" do
        NginxUtils::Logrotate.any_instance.should_receive(:rename).and_return(true)
        NginxUtils::Logrotate.any_instance.should_receive(:delete).and_return(true)
        NginxUtils::Logrotate.any_instance.should_receive(:restart).and_return(true)
        @rotate.execute
      end

      it "output log file" do
        @rotate.execute
        expect(log_lines.select{|l| /Execute Nginx logrotate/ =~ l}.size).to eq(1)
        expect(log_lines.select{|l| /Nginx logrotate is successfully/ =~ l}.size).to eq(1)
        expect(log_lines.size).to eq(2)
      end

      it "do not output log if script_log is false" do
        @rotate.config script_log: false
        @rotate.execute
        expect(log_lines.size).to eq(0)
      end
    end
  end
end
