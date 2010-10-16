require 'sinatra/base'

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
    root = Root.new # Root page
    page = root.descendant( path ) # Find page by path

    [ page[:status], page.render ] # Return page status and content
  end

  def redirect_to_lang( path )
    redirect [@@langs.first, *path].join '/'
  end

  def lang?( lang )
    @@langs.include? lang
  end

end
