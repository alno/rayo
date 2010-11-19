require File.dirname(__FILE__) + '/spec_helper'

describe "Multilingual application" do
  include Rack::Test::Methods

  def app
    @appclass ||= Class.new Rayo::Application do

      configure do |c|
        c.content_dir = 'content'
      end

      def create_storage( cfg )
        storage = TestStorage.new( cfg )
        storage.file path( 'content', 'layouts', 'base.html' ), "<html><title><r:title /></title><body><r:content inherit=\"true\" /></body></html>"
        storage.file path( 'content', 'layouts', 'base.xml' ), "<xml><r:content inherit=\"true\" /></xml>"
        storage.file path( 'content', 'snippets', 'test.html' ), "Test snippet"
        storage.file path( 'content', 'pages', 'index.yml' ), "title: Index Page\nlayout: base\n"
        storage.file path( 'content', 'pages', 'index.html' ), "Example content: <r:children:each><r:title /> </r:children:each>"
        storage.file path( 'content', 'pages', 'index.xml' ), "Example XML content: <r:children:each><r:title /> </r:children:each>"
        storage.file path( 'content', 'pages', 'test.yml' ), "title: Test Page\n"
        storage.file path( 'content', 'pages', 'test.html' ), "Test <r:snippet name=\"test\" />"
        storage.file path( 'content', 'pages', 'test.xml' ), "Test <r:snippet name=\"test\" format=\"html\" />"
        storage.file path( 'content', 'pages', 'users.yml' ), "title: Users\n"
        storage.file path( 'content', 'pages', 'users', '%name.yml' ), "title: <%=name%>\'s page\n"
        storage.file path( 'content', 'pages', 'users', 'special.yml' ), "title: Special page\n"
        storage.file path( 'content', 'pages', 'users', 'special.html' ), "Spec: <r:find url=\"/\"><r:children:each><r:title /> </r:children:each></r:find>"
        storage.file path( 'content', 'pages', 'users', '_hidden.yml' ), "title: Hidden page\n"
        storage
      end

    end
    @app ||= @appclass.new
  end

  it "should respond to /en" do
    get '/en'
    last_response.should be_ok
    last_response.body.should == '<html><title>Index Page</title><body>Example content: Users Test Page </body></html>'
  end

  it "should respond to /en.html" do
    get '/en.html'
    last_response.should be_ok
    last_response.body.should == '<html><title>Index Page</title><body>Example content: Users Test Page </body></html>'
  end

  it "should respond to /en.xml" do
    get '/en.xml'
    last_response.should be_ok
    last_response.body.should == '<xml>Example XML content: Users Test Page </xml>'
  end

  it "should respond to /en/test" do
    get '/en/test'
    last_response.should be_ok
    last_response.body.should == '<html><title>Test Page</title><body>Test Test snippet</body></html>'
  end

  it "should respond to /en/test.xml" do
    get '/en/test.xml'
    last_response.should be_ok
    last_response.body.should == '<xml>Test Test snippet</xml>'
  end

  it "should respond to /en/users" do
    get '/en/users'
    last_response.should be_ok
    last_response.body.should == '<html><title>Users</title><body>Example content: Special page </body></html>'
  end

  it "should respond to /en/users/alex" do
    get '/en/users/alex'
    last_response.should be_ok
    last_response.body.should == '<html><title>alex\'s page</title><body>Example content: </body></html>'
  end

  it "should respond to /en/users/special" do
    get '/en/users/special'
    last_response.should be_ok
    last_response.body.should == '<html><title>Special page</title><body>Spec: Users Test Page </body></html>'
  end

  it "should respond to /en/users/hidden" do
    get '/en/users/hidden'
    last_response.should be_ok
    last_response.body.should == '<html><title>Hidden page</title><body>Example content: </body></html>'
  end

  it "should redirect from / to /en" do
    get '/'
    last_response.should be_redirect
    last_response.location.should == '/en'
  end

  it "should redirect /en/ to /en" do
    get '/en/'
    last_response.should be_redirect
    last_response.location.should == '/en'
  end

  it "should redirect from /test to /en/test" do
    get '/test'
    last_response.should be_redirect
    last_response.location.should == '/en/test'
  end

  it "should redirect from /test/ to /en/test" do
    get '/test/'
    last_response.should be_redirect
    last_response.location.should == '/en/test'
  end

  it "should redirect from /en/test/ to /en/test" do
    get '/en/test/'
    last_response.should be_redirect
    last_response.location.should == '/en/test'
  end

  it "should redirect from /test/ttt to /en/test/ttt" do
    get '/test/ttt'
    last_response.should be_redirect
    last_response.location.should == '/en/test/ttt'
  end

end
