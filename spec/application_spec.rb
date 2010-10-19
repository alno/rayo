require File.dirname(__FILE__) + '/spec_helper'

describe "Multilingual application" do
  include Rack::Test::Methods

  def app
    @appclass ||= Class.new Rayo::Application do

      configure do |c|
        c.content_dir = 'content'
      end

      def create_storage( lang )
        storage = TestStorage.new config, 'en'
        storage.file path( 'content', 'layouts', 'base.html' ), "<html><title><r:title /></title><body><r:content inherit=\"true\" /></body></html>"
        storage.file path( 'content', 'snippets', 'test.html' ), "Test snippet"
        storage.file path( 'content', 'pages', 'index.yml' ), "title: Index Page\nlayout: base\n"
        storage.file path( 'content', 'pages', 'index.html' ), "Example content: <r:children:each><r:title /> </r:children:each>"
        storage.file path( 'content', 'pages', 'test.yml' ), "title: Test Page\n"
        storage.file path( 'content', 'pages', 'test.html' ), "Test <r:snippet name=\"test\" />"
        storage.file path( 'content', 'pages', 'users.yml' ), "title: Users\n"
        storage.file path( 'content', 'pages', 'users', '%name.yml' ), "title: <%=name%>\'s page\n"
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

  it "should respond to /en/test" do
    get '/en/test'
    last_response.should be_ok
    last_response.body.should == '<html><title>Test Page</title><body>Test Test snippet</body></html>'
  end

  it "should respond to /en/users" do
    get '/en/users'
    last_response.should be_ok
    last_response.body.should == '<html><title>Users</title><body>Example content: </body></html>'
  end

  it "should respond to /en/users" do
    get '/en/users/alex'
    last_response.should be_ok
    last_response.body.should == '<html><title>alex\'s page</title><body>Example content: </body></html>'
  end

  it "should redirect from / to /en" do
    get '/'
    last_response.should be_redirect
    last_response.location.should == 'en'
  end

  it "should redirect from /test to /en/test" do
    get '/test'
    last_response.should be_redirect
    last_response.location.should == 'en/test'
  end

end
