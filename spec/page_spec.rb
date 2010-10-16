require File.dirname(__FILE__) + '/spec_helper'

describe Page do

  class TestRoot < RootPage

    def file
      'index.part'
    end

  end

  class TestStorage < Storage

    def root_page
      @root_page ||= TestRoot.new( self )
    end

    def directory( content_type )
      'content'
    end

    def find_page_file( dirs, slug )
      p = dirs.first + '/' + slug

      case p
        when File.join( 'content', 'test' ) then File.join( 'content', 'test' )
        when File.join( 'content', 'users' ) then File.join( 'content', 'users' )
        when File.join( 'content', 'users', 'alex' ) then File.join( 'content', 'users', '%name' )
      end
    end

    def find_page_dirs( dirs, slug )
      p = dirs.first + '/' + slug

      case p
        when File.join( 'content', 'test' ) then [ File.join( 'content', 'test' ) ]
        when File.join( 'content', 'users' ) then [ File.join( 'content', 'users' ) ]
        when File.join( 'content', 'users', 'alex' ) then [ File.join( 'content', 'users', '%name' ) ]
        else []
      end
    end

  end

  before :each do
    @root = TestStorage.new.root_page
  end

  it "should find root page" do
    @root.descendant([]).should_not be_nil
    @root.descendant([]).path.should == []
  end

  it "should find nested page" do
    page = @root.descendant(['test'])
    page.should_not be_nil
    page.path.should == ['test']
    page.params.should == { 'path' => ['test'] }
  end

  it "should find page with param" do
    page = @root.descendant(['users','alex'])
    page.should_not be_nil
    page.path.should == ['users','alex']
    page.params.should == { 'path' => ['users','alex'], 'name' => 'alex' }
  end

end
