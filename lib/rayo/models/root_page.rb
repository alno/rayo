require File.join(File.dirname(__FILE__), 'page.rb')
require File.join(File.dirname(__FILE__), 'status_page.rb')

class Rayo::Models::RootPage < Rayo::Models::Page

  def initialize( storage, lang, format )
    super( storage, nil, lang, [], format )
  end

  def directories
    [ @storage.config.directory :pages ]
  end

  def file
    @file ||= @storage.find_page_file( directories, @lang, 'index', @format )
  end

  def params
    @params ||= { 'path' => path }
  end

end
