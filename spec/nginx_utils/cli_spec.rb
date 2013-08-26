# coding: utf-8

require "spec_helper"

describe NginxUtils::CLI do
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

    before {NginxUtils::Status.should_receive(:get).and_return(result)}

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
    let!(:rotate) {
      rotate = double("lotate mock")
      rotate.should_receive(:execute).and_return(true)
      rotate
    }

    it "logrotate should be execute" do
      NginxUtils::Logrotate.should_receive(:new).and_return(rotate)
      args = ["logrotate"]
      NginxUtils::CLI.start(args)
    end

    it "debug option" do
      options = {"debug" => true}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "-d"]
      NginxUtils::CLI.start(args)
    end

    it "script_log option" do
      options = {"script_log" => "/var/log/nginx_rotate.log"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "--script_log", "/var/log/nginx_rotate.log"]
      NginxUtils::CLI.start(args)
    end

    it "log_level option" do
      options = {"log_level" => "warn"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "--log_level", "warn"]
      NginxUtils::CLI.start(args)
    end

    it "root_dir option" do
      options = {"root_dir" => "/usr/local/nginx_other"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "--root_dir", "/usr/local/nginx_other"]
      NginxUtils::CLI.start(args)
    end

    it "target_logs option" do
      options = {"target_logs" => "*_log"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "--target_logs", "*_log"]
      NginxUtils::CLI.start(args)
    end

    it "retention option" do
      options = {"retention" => "30"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "--retention", "30"]
      NginxUtils::CLI.start(args)
    end

    it "pid_file option" do
      options = {"pid_file" => "/var/run/nginx.pid"}
      NginxUtils::Logrotate.should_receive(:new).with(options).and_return(rotate)
      args = ["logrotate", "--pid_file", "/var/run/nginx.pid"]
      NginxUtils::CLI.start(args)
    end
  end

  describe "#create_vhost" do
    let!(:vhost) {
      vhost_mock = double("vhost mock")
      vhost_mock.should_receive(:config).and_return("virtual host configuration")
      vhost_mock
    }

    it "output for stdout" do
      NginxUtils::VirtualHost.should_receive(:new).and_return(vhost)
      args = ["create_vhost"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "vhost_type option" do
      options = {"vhost_type" => "unicorn"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-T", "unicorn"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "destination option" do
      options = {"destination" => "/usr/local/rails/app/tmp/unicorn.sock"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-D", "/usr/local/rails/app/tmp/unicorn.sock"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "prefix option" do
      options = {"prefix" => "/opt/nginx"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-p", "/opt/nginx"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "server_name option" do
      options = {"server_name" => "nginx_utils.example.com"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-n", "nginx_utils.example.com"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "root option" do
      options = {"root" => "/var/lib/nginx/www"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-d", "/var/lib/nginx/www"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "index option" do
      options = {"index" => "index.rb"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-i", "index.rb"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "auth_basic option" do
      options = {"auth_basic" => "Auth"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-r", "Auth"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "auth_basic_user_file option" do
      options = {"auth_basic_user_file" => "/var/lib/nginx/user"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "-u", "/var/lib/nginx/user"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "only_http option" do
      options = {"only_http" => true}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--only_http"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "only_https option" do
      options = {"only_https" => true}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--only_https"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "ssl_certificate option" do
      options = {"ssl_certificate" => "/var/lib/nginx/vhosts/example.com/ssl.crt/server.crt"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--ssl_certificate", "/var/lib/nginx/vhosts/example.com/ssl.crt/server.crt"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "ssl_certificate_key option" do
      options = {"ssl_certificate_key" => "/var/lib/nginx/vhosts/example.com/ssl.key/server.key"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--ssl_certificate_key", "/var/lib/nginx/vhosts/example.com/ssl.key/server.key"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "log_dir option" do
      options = {"log_dir" => "/var/log"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--log_dir", "/var/log"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "access_log_format option" do
      options = {"access_log_format" => "combined"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--access_log_format", "combined"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end

    it "error_log_level option" do
      options = {"error_log_level" => "error"}
      NginxUtils::VirtualHost.should_receive(:new).with(options).and_return(vhost)
      args = ["create_vhost", "--error_log_level", "error"]
      expect(
        capture(:stdout) {
          NginxUtils::CLI.start(args)
        }
      ).to eq("virtual host configuration\n")
    end
  end
end
