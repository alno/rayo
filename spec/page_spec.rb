require File.dirname(__FILE__) + '/spec_helper'

describe Page do

  class TestRoot < Root

    def file
      'index.part'
    end

    def directories
      [ 'content' ]
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
    @root = TestRoot.new
  end

  it "should find root page" do
    @root.descendant([]).should_not be_nil
    @root.descendant([]).path.should == []
  end

  it "should find nested page" do
    page = @root.descendant(['test'])
    page.should_not be_nil
    page.path.should == ['test']
    page.slug.should == 'test'
    page.params.should == {}
  end

  it "should find page with param" do
    page = @root.descendant(['users','alex'])
    page.should_not be_nil
    page.path.should == ['users','alex']
    page.slug.should == 'alex'
    page.params.should == { 'name' => 'alex' }
  end

end
