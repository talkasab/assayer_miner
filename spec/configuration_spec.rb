require 'spec_helper'

module AssayerMiner
  describe "configuration" do
    describe "QPID object" do
      subject { AssayerMiner.qpid }
      it { should_not be_nil }
      its(:user) { should == CONFIG_OPTS[:qpid][:user] }
    end
  end
end
