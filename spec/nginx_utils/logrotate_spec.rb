# coding: utf-8

require "spec_helper"

describe "NginxUtils::Logrotate" do
  let(:rotate) {NginxUtils::Logrotate.new}

  let!(:logger_mock) do
    logger = double("logger mock").as_null_object
    Logger.stub(:new).and_return(logger)
    logger
  end

  let!(:files) {["access.log", "error.log"]}
  let!(:time_now) {Time.now}
  let!(:default) do
    {
      debug: false,
      script_log: "/tmp/nginx_rotate.log",
      log_level: :debug,
      root_dir: "/usr/local/nginx",
      target_logs: "*.log",
      retention: 90,
      prefix: time_now.strftime("%Y%m%d%H%M%S"),
      pid_file: "/usr/local/nginx/logs/nginx.pid"
    }
  end

  describe "#initialize" do
    context "with default params" do
      let(:params) {rotate.instance_eval{@params}}
      let(:execute) {rotate.instance_eval{@execute}}

      it "@execute should be true" do
        expect(execute).to eq(true)
      end

      it "@logger should be created" do
        Logger.should_receive(:new).with(default[:script_log])
        rotate
      end

      it "@logger.level should be debug" do
        logger_mock.should_receive(:level=).with(Logger::DEBUG)
        rotate
      end

      it "@params[:root_dir] should be default install prefix of Nginx" do
        expect(params[:root_dir]).to eq(default[:root_dir])
      end

      it "@params[:target_logs] should be *.log" do
        expect(params[:target_logs]).to eq(default[:target_logs])
      end

      it "@rename_logs size should be number of target log files" do
        Dir.should_receive(:glob).exactly(2).times.and_return(files)
        expect(rotate.rename_logs).to eq(files)
      end

      it "@delete_logs size should be number of target log files" do
        Dir.should_receive(:glob).exactly(2).times.and_return(files)
        expect(rotate.delete_logs).to eq(files)
      end

      it "@params[:prefix] should be a some as time_now" do
        Time.stub(:now).and_return(time_now)
        expect(params[:prefix]).to eq(default[:prefix])
      end

      it "@params[:retention] should be 90 days" do
        expect(params[:retention]).to eq(default[:retention])
      end

      it "@params[:pid_file] should be /usr/local/nginx/logs/nginx.pid" do
        expect(params[:pid_file]).to eq(default[:pid_file])
      end

      it "@rename_logs should be created" do
        expect(rotate.rename_logs).not_to eq(nil)
      end

      it "@delete_logs should be created" do
        expect(rotate.delete_logs).not_to eq(nil)
      end
    end

    context "with debug" do
      let(:debug_rotate) {NginxUtils::Logrotate.new(debug: true)}
      let(:params) {debug_rotate.instance_eval{@params}}
      let(:execute) {debug_rotate.instance_eval{@execute}}

      it "@execute should be false" do
        expect(execute).to eq(false)
      end

      it "@logger should be created with STDOUT" do
        Logger.should_receive(:new).with(STDOUT)
        debug_rotate.logger
      end

      it "other parameters should be default" do
        logger_mock.should_receive(:level=).with(Logger::DEBUG)
        Time.stub(:now).and_return(time_now)
        expect(params[:root_dir]).to eq(default[:root_dir])
        expect(params[:target_logs]).to eq(default[:target_logs])
        expect(params[:prefix]).to eq(default[:prefix])
        expect(params[:retention]).to eq(default[:retention])
        expect(params[:pid_file]).to eq(default[:pid_file])
      end
    end

    context "with custom params" do
      it "@logger should be false if script_log is false" do
        rotate = NginxUtils::Logrotate.new(script_log: false)
        expect(rotate.logger).to eq(false)
      end

      it "@logger.level should be a specified level" do
        logger_mock.should_receive(:level=).with(Logger::WARN)
        NginxUtils::Logrotate.new(log_level: :warn)
      end

      it "@params[:root_dir] should be a specified parameter" do
        root_dir = "/var/log/nginx"
        rotate = NginxUtils::Logrotate.new(root_dir: root_dir)
        expect(rotate.instance_eval{@params[:root_dir]}).to eq(root_dir)
      end

      it "@params[:prefix] should be a specified parameter" do
        prefix = Time.now.strftime("%Y%m%d")
        rotate = NginxUtils::Logrotate.new(prefix: prefix)
        expect(rotate.instance_eval{@params[:prefix]}).to eq(prefix)
      end

      it "@params[:retention] should be a specified period" do
        retention = 30
        rotate = NginxUtils::Logrotate.new(retention: retention)
        expect(rotate.instance_eval{@params[:retention]}).to eq(retention)
      end

      it "@params[:pid_file] should be a specified parameter" do
        pid_file = "/var/run/nginx.pid"
        rotate = NginxUtils::Logrotate.new(pid_file: pid_file)
        expect(rotate.instance_eval{@params[:pid_file]}).to eq(pid_file)
      end
    end
  end

  describe "#config" do
    let(:params) {rotate.instance_eval{@params}}
    let(:execute) {rotate.instance_eval{@execute}}

    it "@execute should be a false if debug is true" do
      Logger.should_receive(:new).with(STDOUT)
      rotate.config debug: true
      expect(execute).to eq(false)
    end

    it "@execute should be a true if debug is false" do
      rotate = NginxUtils::Logrotate.new(debug: true)
      rotate.config debug: false
      expect(rotate.instance_eval{@execute}).to eq(true)
    end

    it "@logger should be a false if script_log is false" do
      rotate.config script_log: false
      expect(rotate.logger).to eq(false)
    end

    it "@logger.level should be a specified level" do
      logger_mock.should_receive(:level=).with(Logger::WARN)
      rotate.config log_level: :warn
    end

    it "@params[:root_dir] should be a specified parameter" do
      root_dir = "/var/log/nginx"
      rotate.config root_dir: root_dir
      expect(params[:root_dir]).to eq(root_dir)
    end

    it "@params[:target_logs] should be a specified parameter" do
      target_logs = "*_log"
      rotate.config target_logs: target_logs
      expect(params[:target_logs]).to eq(target_logs)
    end

    it "@params[:prefix] should be a specified parameter" do
      prefix = Time.now.strftime("%Y%m%d")
      rotate.config prefix: prefix
      expect(params[:prefix]).to eq(prefix)
    end

    it "@params[:retention] should be a specified period" do
      retention = 30
      rotate.config retention: retention
      expect(params[:retention]).to eq(retention)
    end

    it "@params[:pid_file] should be a specified parameter" do
      pid_file = "/var/run/nginx.pid"
      rotate.config pid_file: pid_file
      expect(params[:pid_file]).to eq(pid_file)
    end
  end

  describe "#rename" do
    before(:each) do
      Dir.should_receive(:glob).exactly(2).times.and_return(files)
      File.stub(:rename).and_return(true)
    end

    it "rename target logs" do
      File.should_receive(:rename).exactly(2).times
      rotate.rename
    end

    it "output log file" do
      logger_mock.should_receive(:debug).exactly(2).times
      rotate.rename
    end

    it "do not rename if a file with the same name exists" do
      File.stub(:exists?).and_return(true)
      File.should_not_receive(:rename)
      logger_mock.should_receive(:warn).exactly(2).times
      rotate.rename
    end

    it "do not rename if not executable" do
      File.should_not_receive(:rename)
      rotate.config debug: true
      rotate.rename
    end

    it "do not output log if script_log is false" do
      logger_mock.should_not_receive(:debug)
      rotate.config script_log: false
      rotate.rename
    end
  end

  describe "#delete" do
    before(:each) do
      Dir.should_receive(:glob).exactly(2).times.and_return(files)
      delete_time = Time.now - ((default[:retention] + 1) * 3600 * 24)
      File.stub(:stat).and_return(double("time mock", mtime: delete_time))
      File.stub(:unlink).and_return(true)
    end

    it "delete target logs" do
      File.should_receive(:unlink).exactly(2).times
      rotate.delete
    end

    it "output log file" do
      logger_mock.should_receive(:debug).exactly(2).times
      rotate.delete
    end

    it "do not delete if not executable" do
      File.should_not_receive(:unlink)
      rotate.config debug: true
      rotate.delete
    end

    it "do not output log if script_log is false" do
      logger_mock.should_not_receive(:debug)
      rotate.config script_log: false
      rotate.delete
    end
  end

  describe "#restart" do
    before(:each) do
      File.stub(:exists?).and_return(true)
      File.stub(:read).and_return("2000")
      Process.stub(:kill).and_return(1)
    end

    it "should execute reopen log" do
      Process.should_receive(:kill).and_return(1)
      rotate.restart
    end

    it "output success log" do
      logger_mock.should_receive(:info)
      rotate.restart
    end

    it "do not execute reopen log if not exists pid file" do
      File.stub(:exists?).and_return(false)
      Process.should_not_receive(:kill)
      rotate.restart
    end

    it "should output log if not exists pid file" do
      File.stub(:exists?).and_return(false)
      logger_mock.should_receive(:warn)
      rotate.restart
    end

    it "do not execute reopen log if not executable" do
      Process.should_not_receive(:kill)
      rotate.config debug: true
      rotate.restart
    end

    it "should generate an exception" do
      Process.should_receive(:kill).and_raise("error")
      logger_mock.should_receive(:error).exactly(2).times
      expect(proc{rotate.restart}).to raise_error("Nginx restart failed")
    end

    it "do not output log if script_log is false" do
      logger_mock.should_not_receive(:info)
      rotate.config script_log: false
      rotate.restart
    end
  end

  describe "#execute" do
    before(:each) do
      NginxUtils::Logrotate.any_instance.stub(:rename).and_return(true)
      NginxUtils::Logrotate.any_instance.stub(:delete).and_return(true)
      NginxUtils::Logrotate.any_instance.stub(:restart).and_return(true)
    end

    it "should call rename and delete and restart methods" do
      NginxUtils::Logrotate.any_instance.should_receive(:rename).and_return(true)
      NginxUtils::Logrotate.any_instance.should_receive(:delete).and_return(true)
      NginxUtils::Logrotate.any_instance.should_receive(:restart).and_return(true)
      rotate.execute
    end

    it "output log file" do
      logger_mock.should_receive(:info).exactly(2).times
      rotate.execute
    end

    it "do not output log if script_log is false" do
      logger_mock.should_not_receive(:info)
      rotate.config script_log: false
      rotate.execute
    end
  end  
end