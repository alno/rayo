require 'radius'

class PageParts

  def initialize( page )
    @page = page
    @results = {}
  end

  def files
    return @files if @files

    @files = @page.parent ? @page.parent.parts.files.clone : {}
    @files.merge! @page.root.storage.find_page_part_files( @page.file ) if @page.file
    @files
  end

  def []( key )
    key = key.to_s

    return @results[key] if @results.include? key

    file = @files[ key.to_s ]

    return @results[key] = nil unless file

    content = File.read( file )

    if content
      @results[key] = parser.parse( content )
    else
      @results[key] = nil
    end
  end

  private

  def parser
    @parser ||= Radius::Parser.new( context, :tag_prefix => 'r' )
  end

  def context
    @context ||= Radius::Context.new do |c|
      c.define_tag 'hello' do
        'Hello world'
      end
      c.define_tag 'repeat' do |tag|
        number = (tag.attr['times'] || '1').to_i
        result = ''
        number.times { result << tag.expand }
        result
      end
    end
  end

end
