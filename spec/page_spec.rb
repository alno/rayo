require File.dirname(__FILE__) + '/spec_helper'

describe Rayo::Models::Page do

  before :each do
    @config = Rayo::Config.new
    @config.content_dir = 'content'

    @storage = TestStorage.new @config
    @storage.file path( 'content', 'pages', 'test.yml' ), ''
    @storage.file path( 'content', 'pages', 'test.html' ), ''
    @storage.file path( 'content', 'pages', 'test2.en.yml' ), ''
    @storage.file path( 'content', 'pages', 'test2.ru.yml' ), ''
    @storage.file path( 'content', 'pages', 'test2.html' ), ''
    @storage.file path( 'content', 'pages', 'test3.en.yml' ), ''
    @storage.file path( 'content', 'pages', 'test3.en.html' ), ''
    @storage.file path( 'content', 'pages', '_test4.yml' ), ''
    @storage.file path( 'content', 'pages', '_test4.html' ), ''
    @storage.file path( 'content', 'pages', 'test.footer.html' ), ''
    @storage.file path( 'content', 'pages', 'users.yml' ), ''
    @storage.file path( 'content', 'pages', 'users', '%name.yml' ), ''
    @storage.dir  path( 'content', 'pages', 'users', 'alex' )
    @storage.file path( 'content', 'pages', '_404.yml' ), 'title: Not found'
    @storage.file path( 'content', 'pages', '_404.html' ), ''
  end

  context "'/'" do

    before { @root = @storage.root_page( 'en' ) }

    it { @root.descendant([]).should == @root }
    it { @root.path.should == [] }
    it { @root.should have(4).children }
    it { @root.children.each {|p| p.should_not be_nil } }
    it { @root.children.map(&:path).should == [['test3'],['test2'],['users'],['test']] }

  end

  context "'/test'" do

    before { @page = @storage.page(:en, ['test']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test'] }
    specify { @page.params.should == { 'path' => ['test'] } }
    specify { @page.file.should == path( 'content', 'pages', 'test.yml' ) }

    specify { @page.should have(0).children }
    specify { @page.parts('html').size.should == 2 }
    specify { @page.parts('html').should include 'body' }
    specify { @page.parts('html').should include 'footer' }

  end

  context "'/test2'" do

    before { @page = @storage.page(:en, ['test2']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test2'] }
    specify { @page.params.should == { 'path' => ['test2'] } }
    specify { @page.file.should == path( 'content', 'pages', 'test2.en.yml' ) }

    specify { @page.should have(0).children }
    specify { @page.parts('html').size.should == 1 }
    specify { @page.parts('html').should include 'body' }

  end

  context "'/test2' with lang 'ru'" do

    before { @page = @storage.page(:ru, ['test2']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test2'] }
    specify { @page.params.should == { 'path' => ['test2'] } }
    specify { @page.file.should == path( 'content', 'pages', 'test2.ru.yml' ) }

    specify { @page.should have(0).children }
    specify { @page.parts('html').size.should == 1 }
    specify { @page.parts('html').should include 'body' }

  end

  context "'/test3'" do

    before { @page = @storage.page(:en, ['test3']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test3'] }
    specify { @page.params.should == { 'path' => ['test3'] } }
    specify { @page.file.should == path( 'content', 'pages', 'test3.en.yml' ) }

    specify { @page.should have(0).children }
    specify { @page.parts('html').size.should == 1 }
    specify { @page.parts('html').should include 'body' }

  end

  context "'/test4'" do

    before { @page = @storage.page(:en, ['test4']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['test4'] }
    specify { @page.params.should == { 'path' => ['test4'] } }
    specify { @page.file.should == path( 'content', 'pages', '_test4.yml' ) }

    specify { @page.should have(0).children }
    specify { @page.parts('html').size.should == 1 }
    specify { @page.parts('html').should include 'body' }

  end

  context "'/users'" do

    before { @page = @storage.page(:en, ['users']) }

    specify { @page.should have(1).children }

  end

  context "'/users/alex'" do

    before { @page = @storage.page(:en, ['users','alex']) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['users','alex'] }
    specify { @page.params.should == { 'path' => ['users','alex'], 'name' => 'alex' } }
    specify { @page.file.should == path( 'content', 'pages', 'users', '%name.yml' ) }
    specify { @page.should have(0).children }

  end

  context "'/unknown_page'" do

    before { @page = @storage.status_page(:en, ['unknown_page'], 404) }

    specify { @page.should_not be_nil }
    specify { @page.path.should == ['unknown_page'] }
    specify { @page.params.should == { 'path' => ['unknown_page'] } }
    specify { @page.context.should == { 'status' => 404, 'title' => 'Not found' } }
    specify { @page.file.should == path( 'content', 'pages', '_404.yml' ) }
    specify { @page.should have(0).children }
    specify { @page.parts('html').size.should == 1 }
    specify { @page.parts('html').should include 'body' }

  end

end
