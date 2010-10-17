require 'sinatra/base'

module Tags

end

module Models

end

require File.join(File.dirname(__FILE__), 'storage.rb')
require File.join(File.dirname(__FILE__), 'config.rb')

class Application < Sinatra::Base

  def initialize
    super
    @config = CmsConfig.new
  end

  get '/' do
    redirect_to_lang '' # Root page
  end

  get '*/' do |path|
    redirect path # Remove trailing slashes
  end

  get '/*' do |path|
    path = path.split '/' # Split path into segments

    return redirect_to_lang path unless lang? path.first

    lang = path.shift # Determine language
    storage = Storage.new( @config, lang ) # Page storage
    page = storage.page( path ) # Find page by path
    page = storage.status_page( path, 404 ) unless page && page.file # Render 404 page if there are no page, or there are no file

    [ page[:status], page.render ] # Return page status and content
  end

  def redirect_to_lang( path )
    redirect [@config.languages.first, *path].join '/'
  end

  def lang?( lang )
    @config.languages.include? lang
  end

end
