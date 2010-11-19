require File.dirname(__FILE__) + '/spec_helper'

describe 'Rayo filters' do

  ['html','xml','abracadabra'].each do |name|
    context "in #{name} format" do

      subject { Rayo::Config::Format.new name }

      it { subject.filter(name).should_not be_nil }
      it { subject.filter(name).call('Content').should == 'Content' }

    end
  end

  context "in config" do

    let(:config) { Rayo::Config.new }

    it "should have default format" do
      config.format.should_not be_nil
    end

    it "should have default format" do
      config.format.name.should == 'html'
    end

    it "should have html filter" do
      config.filter(:html).should_not be_nil
    end

    it "should have html filter which does nothing" do
      config.filter('html').call('Some string').should == 'Some string'
    end

  end

end
