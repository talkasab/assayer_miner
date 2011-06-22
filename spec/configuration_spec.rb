require 'spec_helper'

module ScenarioExtractor
  describe "configuration" do
    describe "QPID object" do
      subject { ScenarioExtractor.qpid }
      it { should_not be_nil }
      its(:user) { should == CONFIG_OPTS['user'] }
    end
  end
end
