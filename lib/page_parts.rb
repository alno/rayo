require 'radius'

require File.join(File.dirname(__FILE__), 'page_context.rb')

class PageParts

  def initialize( page )
    @page = page
    @results = {}
  end

  def files
    @files || begin
      @files = @page.parent ? @page.parent.parts.files.clone : {}
      @files.merge! @page.storage.find_page_part_files( @page.file ) if @page.file
      @files
    end
  end

  def []( key )
    key = key.to_s

    return @results[key] if @results.include? key

    file = files[ key.to_s ]

    return @results[key] = nil unless file

    content = File.read( file )

    if content
      @results[key] = parser.parse( content )
    else
      @results[key] = nil
    end
  end

  def parser
    @parser ||= Radius::Parser.new( context, :tag_prefix => 'r' )
  end

  def context
    @context ||= PageContext.new( @page )
  end

end
