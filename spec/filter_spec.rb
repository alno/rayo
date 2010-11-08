require File.dirname(__FILE__) + '/spec_helper'

describe 'Rayo filters' do
  
  before do
    @config = Rayo::Config.new
  end
  
  it "should have html filter" do
    @config.filter('.html').should_not be_nil
  end
  
  it "should have html filter which does nothing" do
    @config.filter('.html').call('Some string').should == 'Some string'
  end
  
end