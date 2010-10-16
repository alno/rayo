require File.join(File.dirname(__FILE__), 'page.rb')

class StatusPage < Page

  def initialize( status )
    super()

    @status = status

    self.slug = status.to_s
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
