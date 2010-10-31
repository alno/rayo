require File.dirname(__FILE__) + '/spec_helper'

describe Rayo::Models::Page do

  before :each do
    @config = Rayo::Config.new
    @config.content_dir = 'content'

    @storage = TestStorage.new @config, 'en'
    @storage.file path( 'content', 'pages', 'test.yml' ), ''
    @storage.file path( 'content', 'pages', 'test.html' ), ''
    @storage.file path( 'content', 'pages', 'test.footer.html' ), ''
    @storage.file path( 'content', 'pages', 'users.yml' ), ''
    @storage.file path( 'content', 'pages', 'users', '%name.yml' ), ''
    @storage.file path( 'content', 'pages', '404.yml' ), 'title: Not found'
    @storage.file path( 'content', 'pages', '404.html' ), ''

    @root = @storage.root_page
  end

  context "'/'" do

    it { @root.descendant([]).should == @root }
    it { @root.path.should == [] }
    it { @root.should have(2).children }
    it { @root.children.each {|p| p.should_not be_nil } }

  end

  context "'/test'" do

    before { @page = @root.descendant(['test']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test'] }
    specify { @page.params.should == { 'path' => ['test'] } }
    specify { @page.file.should == path( 'content', 'pages', 'test.yml' ) }

    specify { @page.should have(0).children }
    specify { @page.should have(2).parts }
    specify { @page.parts.should include 'body' }
    specify { @page.parts.should include 'footer' }

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

  context "'/unknown_page'" do

    before { @page = @storage.status_page(['unknown_page'],404) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['unknown_page'] }
    specify { @page.params.should == { 'path' => ['unknown_page'] } }
    specify { @page.context.should == { 'status' => 404, 'title' => 'Not found' } }
    specify { @page.file.should == path( 'content', 'pages', '404.yml' ) }
    specify { @page.should have(0).children }
    specify { @page.should have(1).parts }
    specify { @page.parts.should include 'body' }

  end

end
