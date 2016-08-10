require 'spec_helper'

provider_class = Puppet::Type.type(:database).provider(:tcp)

describe provider_class do
  describe "validate" do
    before do
      res = stub()
      res.stubs(:[]).with(:host).returns("127.0.0.1")
      res.stubs(:[]).with(:port).returns(1111)
      subject.stubs(:resource).returns(res)
    end

    it 'returns true if connection succeeds' do
      sock = stub()
      sock.stubs(:close)
      TCPSocket.stubs(:new).returns(sock)
      expect(subject.validate).to be true
    end

    it 'returns false if connection fails' do
      sock = stub()
      sock.stubs(:close).raises(Errno::ECONNREFUSED)
      TCPSocket.stubs(:new).returns(sock)
      expect(subject.validate).to be false
    end
  end
end
