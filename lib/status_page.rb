require File.join(File.dirname(__FILE__), 'page.rb')

class StatusPage < Page

  def initialize( root, path, status )
    super( root, root, status.to_s, path )

    @status = status
  end

  def context
    return @context if @context

    @context = { 'status' => @status }
    @context.merge! load_context( file + '.yml' ) if file
    @context
  end

  def params
    { 'path' => path }
  end

  def render
    "#{slug}|#{path.inspect}|#{file}|#{directories.inspect}|#{params.inspect}|#{context.inspect}|#{parts.files.inspect}" + parts['content']
  end

end
