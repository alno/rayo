require 'sinatra/base'

require File.join(File.dirname(__FILE__), 'storage.rb')
require File.join(File.dirname(__FILE__), 'config.rb')

class Rayo::Application < Sinatra::Base

  class << self

    attr_accessor :config

    # Configure application
    def configure
      yield @config ||= Rayo::Config.new
    end

  end

  def config
    self.class.config
  end

  get '/' do
    redirect_to_lang '' # Root page
  end

  get '*/' do |path|
    redirect path # Remove trailing slashes
  end

  get '/*' do |path|
    path = path.split '/' # Split path into segments

    return redirect_to_lang path unless config.languages.include? path.first

    lang = path.shift # Determine language
    storage = create_storage( lang ) # Page storage
    page = storage.page( path ) # Find page by path
    page = storage.status_page( path, 404 ) unless page && page.file # Render 404 page if there are no page, or there are no file

    [ page[:status], page.render ] # Return page status and content
  end

  private

  def create_storage( lang )
    Rayo::Storage.new( config, lang )
  end

  def select_language
    config.languages.first
  end

  def redirect_to_lang( path )
    redirect [select_language, *path].join '/'
  end

end
