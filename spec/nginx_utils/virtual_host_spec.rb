# coding: utf-8

require "spec_helper"

describe NginxUtils::VirtualHost do
  describe "#initialize" do
    after {NginxUtils::VirtualHost.new}

    it "set_vhost_type method should be called" do
      NginxUtils::VirtualHost.any_instance.should_receive(:set_vhost_type)
    end

    it "set_common_params method should be called" do
      NginxUtils::VirtualHost.any_instance.should_receive(:set_common_params)
      NginxUtils::VirtualHost.any_instance.stub(:set_protocols).and_return(true)
      NginxUtils::VirtualHost.any_instance.stub(:set_log_params).and_return(true)
    end

    it "set_protocols method should be called" do
      NginxUtils::VirtualHost.any_instance.should_receive(:set_protocols)
    end

    it "set_log_params method should be called" do
      NginxUtils::VirtualHost.any_instance.should_receive(:set_log_params)
    end
  end

  describe "#set_vhost_type" do
    context "with default params" do
      its(:vhost_type){should eq(:normal)}
      its(:destination){should be_nil}
    end

    context "with custom params" do
      it "vhost_type should be a unicorn" do
        vhost = NginxUtils::VirtualHost.new(vhost_type: :unicorn)
        expect(vhost.vhost_type).to eq(:unicorn)
        expect(vhost.destination).to eq("127.0.0.1:8080")
      end

      it "vhost_type should be a proxy" do
        vhost = NginxUtils::VirtualHost.new(vhost_type: :proxy)
        expect(vhost.vhost_type).to eq(:proxy)
        expect(vhost.destination).to eq("127.0.0.1:8080")
      end

      it "vhost_type should be a passenger" do
        vhost = NginxUtils::VirtualHost.new(vhost_type: :passenger)
        expect(vhost.vhost_type).to eq(:passenger)
        expect(vhost.destination).to be_nil
      end

      it "vhost_type should be a normal if unknown param" do
        vhost = NginxUtils::VirtualHost.new(vhost_type: :unknown)
        expect(vhost.vhost_type).to eq(:normal)
        expect(vhost.destination).to be_nil
      end

      it "destination should be specified unix domain socket" do
        vhost = NginxUtils::VirtualHost.new(vhost_type: :unicorn, destination: "/usr/local/rails/app/tmp/unicorn.sock")
        expect(vhost.destination).to eq("unix:/usr/local/rails/app/tmp/unicorn.sock")
      end

      it "destination should be specified ip address and port" do
        vhost = NginxUtils::VirtualHost.new(vhost_type: :unicorn, destination: "127.0.0.1:3000")
        expect(vhost.destination).to eq("127.0.0.1:3000")
      end
    end
  end

  describe "#set_common_params" do
    context "with default params" do
      its(:prefix){should eq("/usr/local/nginx")}
      its(:server_name){should eq("example.com")}
      its(:root){should eq("/usr/local/nginx/vhosts/example.com/html")}
      its(:index){should eq("index.html index.htm")}
      its(:auth_basic){should be_nil}
      its(:auth_basic_user_file){should be_nil}
    end

    context "with custom params" do
      it "prefix should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(prefix: "/opt/nginx")
        expect(vhost.prefix).to eq("/opt/nginx")
        expect(vhost.root).to match(/^\/opt\/nginx/)
      end

      it "server_name should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(server_name: "nginx_utils.example.com")
        expect(vhost.server_name).to eq("nginx_utils.example.com")
      end

      it "root should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(root: "/var/lib/nginx/www")
        expect(vhost.root).to eq("/var/lib/nginx/www")
      end

      it "index should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(index: "index.rb")
        expect(vhost.index).to eq("index.rb")
      end

      it "auth_basic should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(auth_basic: "Auth")
        expect(vhost.auth_basic).to eq("Auth")
      end

      it "auth_basic_user_file should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(auth_basic: "Auth", auth_basic_user_file: "/var/lib/nginx/users")
        expect(vhost.auth_basic_user_file).to eq("/var/lib/nginx/users")
      end
    end
  end

  describe "#set_protocols" do
    context "with default params" do
      its(:http){should be_true}
      its(:https){should be_true}
      its(:ssl_certificate){should eq("/usr/local/nginx/vhosts/example.com/ssl.crt/server.crt")}
      its(:ssl_certificate_key){should eq("/usr/local/nginx/vhosts/example.com/ssl.key/server.key")}
    end

    context "with custom params" do
      it "http should be a false" do
        vhost = NginxUtils::VirtualHost.new(http: false)
        expect(vhost.http).to be_false
      end

      it "https should be a false" do
        vhost = NginxUtils::VirtualHost.new(https: false)
        expect(vhost.https).to be_false
      end

      it "ssl_certificate should be a nil if https is false" do
        vhost = NginxUtils::VirtualHost.new(https: false)
        expect(vhost.ssl_certificate).to be_nil
      end

      it "ssl_certificate_key should be a nil if https is false" do
        vhost = NginxUtils::VirtualHost.new(https: false)
        expect(vhost.ssl_certificate_key).to be_nil
      end

      it "https should be a false if specified only_http" do
        vhost = NginxUtils::VirtualHost.new(only_http: true)
        expect(vhost.https).to be_false
      end

      it "http should be a false if specified only_https" do
        vhost = NginxUtils::VirtualHost.new(only_https: true)
        expect(vhost.http).to be_false
      end
    end
  end

  describe "#set_log_params" do
    context "with default params" do
      its(:log_dir){should eq("/usr/local/nginx/vhosts/example.com/logs")}
      its(:access_log_format){should eq(:ltsv)}
      its(:error_log_level){should eq(:info)}
    end

    context "with custom params" do
      it "log_dir should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(log_dir: "/var/log")
        expect(vhost.log_dir).to eq("/var/log")
      end

      it "access_log_format should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(access_log_format: "combined")
        expect(vhost.access_log_format).to eq("combined")
      end

      it "error_log_level should be a specified parameter" do
        vhost = NginxUtils::VirtualHost.new(error_log_level: "error")
        expect(vhost.error_log_level).to eq("error")
      end
    end
  end

  describe "#config" do
    subject {
      virtual_host = NginxUtils::VirtualHost.new(
        vhost_type: :unicorn,
        destination: "/usr/local/rails/app/tmp/unicorn.sock",
        prefix: "/opt/nginx",
        server_name: "nginx_utils.example.com",
        index: "index.rb",
        log_dir: "/var/log",
        access_log_format: "combined",
        error_log_level: "error",
        auth_basic: "Auth"
      )
      virtual_host.config
    }

    it "upstream block should be defined" do
      should match(/upstream backend-unicorn/)
    end

    it "http block should be defined" do
      should match(/listen 80;/)
    end

    it "https block should be defined" do
      should match(/listen 443 ssl;/)
    end

    it "unix domain socket should be defined" do
      should match(/server unix:\/usr\/local\/rails\/app\/tmp\/unicorn\.sock;/)
    end

    it "server_name should be defined" do
      should match(/server_name nginx_utils.example.com;/)
    end

    it "index should be defined" do
      should match(/index index.rb;/)
    end

    it "access_log should be defined" do
      should match(/access_log \/var\/log\/access.log combined;/)
    end

    it "error_log should be defined" do
      should match(/error_log \/var\/log\/error.log error;/)
    end

    it "auth_basic should be defined" do
      should match(/auth_basic "Auth";/)
    end

    it "auth_basic_user_file should be defined" do
      should match(/auth_basic_user_file \/opt\/nginx\/vhosts\/nginx_utils\.example\.com\/etc\/users;/)
    end

    it "try_files should be defined" do
      should match(/try_files/)
    end

    it "proxy_pass should be defined" do
      should match(/proxy_pass http:\/\/backend-unicorn;/)
    end
  end
end