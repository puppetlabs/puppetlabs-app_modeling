require 'spec_helper'
require 'webmock/rspec'

provider_class = Puppet::Type.type(:http).provider(:http)

describe provider_class do
  describe "validate" do
    def stub_settings(ip, host, port = 80, ssl = false, base_path = "/")
      res = stub()
      res.stubs(:[]).with(:ip).returns(ip)
      res.stubs(:[]).with(:host).returns(host)
      res.stubs(:[]).with(:port).returns(port)
      res.stubs(:[]).with(:ssl).returns(ssl)
      res.stubs(:[]).with(:status_codes).returns([200])
      res.stubs(:[]).with(:base_path).returns(base_path)
      subject.stubs(:resource).returns(res)
    end

    it 'returns true if connection succeeds' do
      uri = "http://myservice.com"
      stub_settings('1.1.1.1', 'myservice.com', 80)
      stub_request(:get, "http://1.1.1.1/").
        with(:headers => {"Host" => "myservice.com"}).
        to_return(:status => 200)
      expect(subject.validate).to be true
    end

    it 'returns true if an SSL connection succeeds' do
      uri = "https://myservice.com"
      stub_settings('1.1.1.1', 'myservice.com', 443, true)
      stub_request(:get, "https://1.1.1.1/").
        with(:headers => {"Host" => "myservice.com"}).
        to_return(:status => 200)
      expect(subject.validate).to be true
    end

    it 'returns true if a connection with a path succeeds' do
      uri = "http://myservice.com"
      stub_settings('1.1.1.1', 'myservice.com', 80, false, '/foobar')
      stub_request(:get, "http://1.1.1.1/foobar").
        with(:headers => {"Host" => "myservice.com"}).
        to_return(:status => 200)
      expect(subject.validate).to be true
    end

    it 'returns false and issues an appropriate notice if status code does not match' do
      uri = 'http://wrongserver.com:8081/'
      stub_settings('1.1.1.1', 'wrongserver.com', 8081)
      stub_request(:get, "http://1.1.1.1:8081/").
        with(:headers => {"Host" => "wrongserver.com:8081"}).
        to_return(:status => 404)
      Puppet.expects(:notice).with(regexp_matches(/Unable to connect to service/))
      expect(subject.validate).to be false
    end

    it 'returns false and issues an appropriate notice if an exception is thrown' do
      uri = 'http://myservice.com:8080/'
      stub_settings('1.1.1.1', 'myservice.com', 8080)
      stub_request(:get, "http://1.1.1.1:8080/").
        with(:headers => {"Host" => "myservice.com:8080"}).
        to_raise(Errno::ECONNREFUSED, "Connection refused")
      Puppet.expects(:notice).with(regexp_matches(/Unable to connect to service/))
      expect(subject.validate).to be false
    end

    it 'returns false and issues an appropriate notice if an exception is thrown' do
      uri = 'http://myservice.com:8080/'
      stub_settings('1.1.1.1', 'myservice.com', 8080)
      stub_request(:get, "http://1.1.1.1:8080/").
        with(:headers => {"Host" => "myservice.com:8080"}).
        to_raise(Errno::ECONNREFUSED, "Connection refused")
      Puppet.expects(:notice).with(regexp_matches(/Unable to connect to service/))
      expect(subject.validate).to be false
    end
  end
end
