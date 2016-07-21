require 'spec_helper'
require 'puppet/provider/app_modeling_monitor'

provider_class = Puppet::Provider::AppModelingMonitor

describe provider_class do
  describe "exists?" do
    before do
      res = stub()
      res.stubs(:[]).with(:timeout).returns(0.1)
      res.stubs(:[]).with(:ping_interval).returns(0.1)
      res.stubs(:tags).returns([])
      subject.stubs(:resource).returns(res)
    end

    it "returns true if validate returns true" do
      subject.stubs(:validate).returns(true)

      expect(subject.exists?).to be true
    end

    it "returns false if validate returns false" do
      subject.stubs(:validate).returns(false)

      expect(subject.exists?).to be false
    end

    it "returns true and skips validation if tags marked as producer" do
      subject.stubs(:resource).returns(stub(:tags => ["producer:foo"]))
      subject.expects(:validate).never

      expect(subject.exists?).to be true
    end
  end

  describe "create" do
    it "should always return an exception" do
      expect { subject.create }.to raise_error(Puppet::Error, "Test has failed")
    end
  end

  describe "validate" do
    it "should always return an exception" do
      expect { subject.validate }.to raise_error(Puppet::Error, /No validation method/)
    end
  end
end
