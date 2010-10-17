require File.join(File.dirname(__FILE__), 'models', 'root_page.rb')
require File.join(File.dirname(__FILE__), 'models', 'renderable.rb')

require File.join(File.dirname(__FILE__), 'taggable.rb')
require File.join(File.dirname(__FILE__), 'tags/property_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/content_tags.rb')
require File.join(File.dirname(__FILE__), 'tags/navigation_tags.rb')

class Storage

  def initialize( lang )
    @lang = lang
    @lang_prefix = '.' + lang

    @layouts = {}
    @snippets = {}

    @tagger = Object.new
    @tagger.extend Taggable

    add_tag_library! Tags::PropertyTags
    add_tag_library! Tags::ContentTags
    add_tag_library! Tags::NavigationTags
  end

  def add_tag_library!( tag_module )
    @tagger.extend tag_module
  end

  def tagger
    @tagger.clone
  end

  def snippet( name )
    @snipetts[name.to_s] ||= Models::Renderable.new( find_renderable_file( :snippets, name.to_s ) || raise( "Snippet '#{name}' not found" ) )
  end

  def layout( name )
    @layouts[name.to_s] ||= Models::Renderable.new( find_renderable_file( :layouts,  name.to_s ) || raise( "Layout '#{name}' not found" ) )
  end

  def directory( content_type )
    File.join( File.dirname(__FILE__), '..', 'content', content_type.to_s )
  end

  def root_page
    @root_page ||= Models::RootPage.new( self )
  end

  def page( path )
    root_page.descendant( path )
  end

  def status_page( path, status )
    Models::StatusPage.new( self, root_page, path, status )
  end

  def find_renderable_file( type, name )
    find_file [directory( type )], name, renderable_exts
  end

  def find_page_file( dirs, slug )
    find_file dirs, slug, page_exts
  end

  def find_page_dirs( dirs, slug )
    find_files dirs, slug, ['']
  end

  def find_pages( dirs )
    find_files dirs, '*', page_exts + ['']
  end

  def find_page_parts( page_file )
    page_parts = {}
    page_file_base = File.basename( page_file, File.extname( page_file ) )
    glob_files File.dirname( page_file ), page_file_base + '*', renderable_exts do |file,base,ext|
      base_parts = base.split('.')

      if base_parts.shift == page_file_base # Remove base (slug or variable)
        if base_parts.size == 0 # There are no part name and language
          page_parts[ 'body' ] ||= Models::Renderable.new( file )
        elsif base_parts.size == 1 # There are no language or no part name
          page_parts[ base_parts[0] ] ||= Models::Renderable.new( file )
          page_parts[ 'body' ] ||= Models::Renderable.new( file ) if base_parts[1] == @lang
        else
          page_parts[ base_parts[0] ] ||= Models::Renderable.new( file ) if base_parts[1] == @lang
        end
      end
    end
    page_parts
  end

  private

  def page_exts
    ['.yml']
  end

  def renderable_exts
    ['.html']
  end

  # Find first file with given name (or variable) and extension from given set
  def find_file( dirs, name, exts )
    glob_files( dirs, name, exts ) { |file,base,ext| return file }
    nil
  end

  # Find files with given name (or variable) and extension from given set
  def find_files( dirs, name, exts )
    results = []
    glob_files( dirs, name, exts ) { |file,base,ext| results << file }
    results
  end

  def glob_files( dirs, name, exts, &block )
    glob dirs, name + @lang_prefix, //, exts, &block # Search with given name and language
    glob dirs, name, //, exts, &block # Search with given name without language
    glob dirs, '%*' + @lang_prefix, /^%.+\.#{@lang}$/, exts, &block # Search with variable and language
    glob dirs, '%*',  /^%.+$/, exts, &block # Search with variable without language
  end

  def glob( dirs, mask_wo_ext, base_regexp, exts )
    mask = mask_wo_ext + ext_mask( exts )

    dirs.each do |dir|
      Dir.glob File.join( dir, mask ) do |file|
        ext = File.extname( file )
        base = File.basename( file, ext )

        yield file, base, ext if exts.include?( ext ) && base =~ base_regexp
      end
    end
  end

  def ext_mask( exts )
    if exts.size == 1 # Only one extension
      exts.first # Use it in mask
    elsif !exts.include? '' # No empty extension
      '.*' # Use any extension mask
    elsif mask_wo_ext[-1..-1] == '*' # Mask ends with star
      '' # No need for another star
    else
      '*' # Any prefix
    end
  end

end
