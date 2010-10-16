require File.join(File.dirname(__FILE__), 'page.rb')
require File.join(File.dirname(__FILE__), 'status_page.rb')

class RootPage < Page

  attr_reader :storage

  def initialize( storage )
    super( self, nil, nil, [] )

    @storage = storage
  end

  def directories
    [ File.join( File.dirname(__FILE__), '..', 'content' ) ]
  end

  def file
    @file ||= storage.find_page_file( directories, 'index' )
  end

  def status_page( path, status )
    StatusPage.new( self, path, status )
  end

  def params
    @params ||= { 'path' => path }
  end

end
