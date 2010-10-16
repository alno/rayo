require 'sinatra/base'

require File.join(File.dirname(__FILE__), 'root_page.rb')
require File.join(File.dirname(__FILE__), 'storage.rb')

class Application < Sinatra::Base

  @@langs = ['ru','en']

  get '*/' do |path|
    redirect path # Remove trailing slashes
  end

  get '/*' do |path|
    path = path.split '/' # Split path into segments

    return redirect_to_lang path unless lang? path.first

    lang = path.shift # Determine language
    root = RootPage.new( Storage.new ) # Root page
    page = root.descendant( path ) # Find page by path
    page = root.status_page( path, 404 ) unless page && page.file # Render 404 page if there are no page, or there are no file

    [ page[:status], page.render ] # Return page status and content
  end

  def redirect_to_lang( path )
    redirect [@@langs.first, *path].join '/'
  end

  def lang?( lang )
    @@langs.include? lang
  end

end
