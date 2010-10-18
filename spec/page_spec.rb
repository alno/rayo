require File.dirname(__FILE__) + '/spec_helper'

describe Rayo::Models::Page do

  before :each do
    @config = Rayo::Config.new
    @config.content_dir = 'content'

    @storage = TestStorage.new @config, 'en'
    @storage.file path( 'content', 'pages', 'test.yml' ), ''
    @storage.file path( 'content', 'pages', 'users.yml' ), ''
    @storage.file path( 'content', 'pages', 'users', '%name.yml' ), ''

    @root = @storage.root_page
  end

  context "'/'" do

    it { @root.descendant([]).should == @root }
    it { @root.path.should == [] }
    it { @root.should have(2).children }

  end

  context "'/test'" do

    before { @page = @root.descendant(['test']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test'] }
    specify { @page.params.should == { 'path' => ['test'] } }
    specify { @page.file.should == path( 'content', 'pages', 'test.yml' ) }
  end

  context "'/users'" do

    before { @page = @root.descendant(['users']) }

    specify { @page.should have(0).children }

  end

  context "'/users/alex'" do

    before { @page = @root.descendant(['users','alex']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['users','alex'] }
    specify { @page.params.should == { 'path' => ['users','alex'], 'name' => 'alex' } }
    specify { @page.file.should == path( 'content', 'pages', 'users', '%name.yml' ) }
    specify { @page.should have(0).children }

  end

end
