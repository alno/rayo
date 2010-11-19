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

  get '/*' do |url|
    if cfg = config.domain( request.host ) # Config for current host
      redir, lang, path, format = analyze_path url # Analyze path

      redirect_to_page( lang || select_language, path, format ) if redir # Redirect

      storage = create_storage( cfg ) # Page storage

      page = storage.page( lang, path ) # Find page by path
      page = storage.status_page( lang, path, 404 ) unless page && page.file # Render 404 page if there are no page, or there are no file

      [ page[:status], page.render( format || config.default_format ) ] # Return page status and content
    else
      domain_not_found
    end
  end

  private

  def domain_not_found
    [ 404, "Page not found" ]
  end

  def analyze_path( p )
    path = p.split '/' # Split path into segments
    redir = path.reject! {|e| e.empty? } # Clear path and detect empty segments
    redir ||= p[-1..-1] == '/'

    unless path.empty? # If path non-empty
      if m = path.last.match( /^(.*)\.([^.]+)$/ ) # Detect format
        format = m[2]
        path[-1] = m[1]
      end

      lang = path.shift if config.languages.include? path.first # Detect language
    end

    [redir || lang.nil?, lang, path, format]
  end

  def redirect_to_page( lang, path, format )
    url = '/' + [ lang || select_language, *path ].join('/')
    url << '.' + format if format

    redirect url
  end

  def create_storage( cfg )
    Rayo::Storage.new( cfg )
  end

  def select_language
    config.languages.first
  end

end
