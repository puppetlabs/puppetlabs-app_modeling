require 'spec_helper'

describe Puppet::Type.type(:http) do
  describe "parameters" do
    it "should have :name as its namevar" do
      expect(described_class.key_attributes).to eq([:name])
    end
  end
end
