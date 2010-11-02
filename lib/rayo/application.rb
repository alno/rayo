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

  get '/*' do |path|
    path = path.split '/' # Split path into segments

    empty_segments_found = path.reject! {|e| e.empty? } # Clear path and detect empty segments

    return redirect_to_lang path unless config.languages.include? path.first
    return redirect '/' + path.join('/') if empty_segments_found

    lang = path.shift # Determine language
    storage = create_storage # Page storage
    page = storage.page( lang, path ) # Find page by path
    page = storage.status_page( lang, path, 404 ) unless page && page.file # Render 404 page if there are no page, or there are no file

    [ page[:status], page.render ] # Return page status and content
  end

  private

  def create_storage
    Rayo::Storage.new( config )
  end

  def select_language
    config.languages.first
  end

  def redirect_to_lang( path )
    redirect '/' + [ select_language, *path].join('/')
  end

end
