require 'spec_helper'

describe Puppet::Type.type(:http) do
  describe "the type" do
    it "should have :name as its namevar" do
      expect(described_class.key_attributes).to eq([:name])
    end
  end

  describe "timeout parameter" do
    it "should validate that values are floats" do
      expect { described_class.new(:name => 'test', :timeout => 31.75) }.to_not raise_error
    end

    it "should raise error when values are not floats" do
      expect { described_class.new(:name => 'test', :timeout => 'foo') }.to raise_error(Puppet::ResourceError, /invalid value/)
    end
  end

  describe "ping_interval parameter" do
    it "should validate that values are floats" do
      expect { described_class.new(:name => 'test', :ping_interval => 0.5) }.to_not raise_error
    end

    it "should raise error when values are not floats" do
      expect { described_class.new(:name => 'test', :ping_interval => 'foo') }.to raise_error(Puppet::ResourceError, /invalid value/)
    end
  end
end
