require File.join(File.dirname(__FILE__), 'models', 'root_page.rb')
require File.join(File.dirname(__FILE__), 'models', 'renderable.rb')

class Storage

  attr_reader :config

  def initialize( config, lang )
    @config = config

    @lang = lang
    @lang_prefix = '.' + lang

    @layouts = {}
    @snippets = {}
  end

  def snippet( name )
    @snipetts[name.to_s] ||= find_renderable_file( :snippets, name.to_s ) || raise( "Snippet '#{name}' not found" )
  end

  def layout( name )
    @layouts[name.to_s] ||= find_renderable( :layouts,  name.to_s ) || raise( "Layout '#{name}' not found" )
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

  def find_renderable( type, name )
    if file = find_file( [config.directory( type )], name, config.renderable_exts )
      Models::Renderable.new( file, filter( File.extname( file ) ) )
    end
  end

  def find_page_file( dirs, slug )
    find_file( dirs, slug, config.page_exts )
  end

  def find_page_dirs( dirs, slug )
    find_files dirs, slug, ['']
  end

  def find_pages( dirs )
    find_files dirs, '*', config.page_exts + ['']
  end

  def find_page_parts( page_file )
    page_parts = {}
    page_file_base = File.basename( page_file, File.extname( page_file ) )
    glob_files File.dirname( page_file ), page_file_base + '*', config.renderable_exts do |file,base,ext|
      base_parts = base.split('.')

      if base_parts.shift == page_file_base # Remove base (slug or variable)
        if base_parts.size == 0 # There are no part name and language
          page_parts[ 'body' ] ||= Models::Renderable.new( file, filter( ext ) )
        elsif base_parts.size == 1 # There are no language or no part name
          page_parts[ base_parts[0] ] ||= Models::Renderable.new( file, filter( ext ) )
          page_parts[ 'body' ] ||= Models::Renderable.new( file, filter( ext ) ) if base_parts[1] == @lang
        else
          page_parts[ base_parts[0] ] ||= Models::Renderable.new( file, filter( ext ) ) if base_parts[1] == @lang
        end
      end
    end
    page_parts
  end

  private

  def filter( ext )
    config.filter( ext ) || raise( "Filter for '#{ext} not found" )
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
