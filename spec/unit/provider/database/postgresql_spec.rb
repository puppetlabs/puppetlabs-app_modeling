require 'spec_helper'
require 'postgres-pr/connection'

provider_class = Puppet::Type.type(:database).provider(:postgresql)

describe provider_class do
  describe "validate" do
    before do
      res = stub()
      res.stubs(:[]).with(:user).returns("foo")
      res.stubs(:[]).with(:host).returns("foo")
      res.stubs(:[]).with(:port).returns(1111)
      res.stubs(:[]).with(:password).returns("foo")
      res.stubs(:[]).with(:database).returns("foo")
      subject.stubs(:resource).returns(res)
    end

    it 'returns true if connection succeeds' do
      subject.stubs(:connect).returns(true)
      expect(subject.validate).to be true
    end

    it 'returns false if connection fails' do
      subject.stubs(:connect).raises(Exception)
      expect(subject.validate).to be false
    end
  end
end
