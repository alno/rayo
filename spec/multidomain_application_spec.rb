require File.dirname(__FILE__) + '/spec_helper'

describe "Multidomain application" do
  include Rack::Test::Methods

  def app
    @appclass ||= Class.new Rayo::Application do

      configure do |c|
        c.content_dir = 'content'

        c.add_domain 'first.example.com'
        c.add_domain 'second.example.com', /^(www\.)?second\.example\.com$/
      end

      def create_storage( cfg )
        storage = TestStorage.new( cfg )
        storage.file path( 'content', 'layouts', 'base.html' ), "<html><title><r:title /></title><body><r:content inherit=\"true\" /></body></html>"
        storage.file path( 'content', 'snippets', 'test.html' ), "Test snippet"
        storage.file path( 'content', 'pages', 'first.example.com', 'index.yml' ), "title: Index Page\nlayout: base\n"
        storage.file path( 'content', 'pages', 'first.example.com', 'index.html' ), "Example content: <r:children:each><r:title /> </r:children:each>"
        storage.file path( 'content', 'pages', 'first.example.com', 'test.yml' ), "title: Test Page\n"
        storage.file path( 'content', 'pages', 'first.example.com', 'test.html' ), "Test <r:snippet name=\"test\" />"
        storage.file path( 'content', 'pages', 'second.example.com', 'users.yml' ), "title: Users\n"
        storage.file path( 'content', 'pages', 'second.example.com', 'index.yml' ), "title: Index Page\nlayout: base\n"
        storage.file path( 'content', 'pages', 'second.example.com', 'index.html' ), "Example content: <r:children:each><r:title /> </r:children:each>"
        storage
      end

    end
    @app ||= @appclass.new
  end

  context "on first.example.com" do

    it "should respond to /en" do
      get 'http://first.example.com/en'
      last_response.should be_ok
      last_response.body.should == '<html><title>Index Page</title><body>Example content: Test Page </body></html>'
    end

    it "should respond to /en/test" do
      get 'http://first.example.com/en/test'
      last_response.should be_ok
      last_response.body.should == '<html><title>Test Page</title><body>Test Test snippet</body></html>'
    end

    it "should respond to /en/users" do
      get 'http://first.example.com/en/users'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

  end

  context "on www.first.example.com" do

    it "should respond to /en/test" do
      get 'http://www.first.example.com/en/test'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

    it "should respond to /en/users" do
      get 'http://www.first.example.com/en/users'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

  end

  context "on second.example.com" do

    it "should respond to /en/users" do
      get 'http://second.example.com/en/users'
      last_response.should be_ok
      last_response.body.should == '<html><title>Users</title><body>Example content: </body></html>'
    end

    it "should not respond to /en/test" do
      get 'http://second.example.com/en/test'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

  end

  context "on www.second.example.com" do

    it "should respond to /en/users" do
      get 'http://www.second.example.com/en/users'
      last_response.should be_ok
      last_response.body.should == '<html><title>Users</title><body>Example content: </body></html>'
    end

    it "should not respond to /en/test" do
      get 'http://www.second.example.com/en/test'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

  end

  context "on example.org" do

    it "should not respond to /en" do
      get 'http://example.org/en'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

    it "should not respond to /en/test" do
      get 'http://example.org/en/test'
      last_response.should_not be_ok
      last_response.status.should == 404
    end

  end

end
