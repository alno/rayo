require 'sinatra/base'
require 'radius'

require 'lib/page'
require 'lib/root'

class Application < Sinatra::Base

  @@langs = ['ru','en']

  get '*/' do |path|
    redirect path # Remove trailing slashes
  end

  get '/*' do |path|
    path = path.split '/' # Split path into segments

    return redirect_to_lang path unless lang? path.first

    lang = path.shift # Determine language
    page = find_page( path ) # Find page by path

    if page
      page.render
    else
      [ 404, 'Page not found' ]
    end
  end

  def find_page( path )
    root = Root.new # Root page
    root.descendant( path ) || begin
      page404 = root.descendant( '404' )
      page404.params['path'] = path if page404
      page404
    end
  end

  def redirect_to_lang( path )
    redirect [@@langs.first, *path].join '/'
  end

  def lang?( lang )
    @@langs.include? lang
  end

end
