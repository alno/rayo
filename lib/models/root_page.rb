require File.join(File.dirname(__FILE__), 'page.rb')
require File.join(File.dirname(__FILE__), 'status_page.rb')

class Models::RootPage < Models::Page

  def initialize( storage )
    super( storage, nil, [] )
  end

  def directories
    [ @storage.config.directory :pages ]
  end

  def file
    @file ||= @storage.find_page_file( directories, 'index' )
  end

  def params
    @params ||= { 'path' => path }
  end

end
