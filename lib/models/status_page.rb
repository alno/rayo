require File.join(File.dirname(__FILE__), 'page.rb')

class Models::StatusPage < Models::Page

  def initialize( storage, root, path, status )
    super( storage, root, path )

    @status = status
  end

  def directories
    []
  end

  def file
    @file ||= @storage.find_page_file( @parent.directories, @status.to_s )
  end

  def context
    return @context if @context

    @context = @parent ? @parent.context.merge({ 'status' => @status }) : { 'status' => @status }
    @context.merge! load_context( file + '.yml' ) if file
    @context
  end

  def params
    { 'path' => path }
  end

end
