require File.join(File.dirname(__FILE__), 'models', 'root_page.rb')
require File.join(File.dirname(__FILE__), 'models', 'renderable.rb')

class Rayo::Storage

  attr_reader :config

  def initialize( config )
    @config = config

    @roots = {}
    @layouts = {}
    @snippets = {}
  end

  def snippet( lang, name, format )
    @snippets["#{lang}|#{name}|#{format}"] ||= find_renderable( :snippets, lang, name.to_s, format )
  end

  def layout( lang, name, format )
    @layouts["#{lang}|#{name}|#{format}"] ||= find_renderable( :layouts, lang, name.to_s, format )
  end

  # Retrieves root page for specific language
  #
  # @param [String,Symbol] page language
  # @return [Rayo::Models::RootPage] root page
  def root_page( lang )
    @roots[ lang.to_s ] ||= Rayo::Models::RootPage.new( self, lang.to_s )
  end

  # Retrieves page for specific language and path
  #
  # @param [String,Symbol] page language
  # @param [Array<String>] page path
  # @return [Rayo::Models::Page] page
  def page( lang, path )
    root_page( lang ).descendant( path )
  end

  # Retrieves status page for specific language and path
  #
  # @param [String,Symbol] page language
  # @param [Array<String>] page path
  # @return [Rayo::Models::StatusPage] status page
  def status_page( lang, path, status )
    Rayo::Models::StatusPage.new( self, root_page( lang ), path, status )
  end

  def find_renderable( type, lang, name, format )
    if file = find_file( [config.directory( type )], lang, name, config.format( format ).renderable_exts )
      renderable( file, format, File.extname( file ) )
    end
  end

  def find_page_file( dirs, lang, slug )
    find_file( dirs, lang, slug, config.page_exts, true )
  end

  def find_page_dirs( dirs, lang, slug )
    find_files( dirs, lang, slug, [''] )
  end

  def find_pages( dirs, lang )
    res = []
    glob_files dirs, lang, '*', config.page_exts + [''] do |file,base,ext|
      elems = base.split('.')
      elem_name = elems[0]
      elem_lang = elems[1]

      res << elem_name unless ['%','_'].include?( elem_name[0..0] ) || (dirs == ([ @config.directory :pages ]) && (elem_name == 'index')) || (elem_lang && elem_lang != lang)
    end
    res.uniq
  end

  def find_page_parts( page_file, lang, format )
    parts = {}
    page_file_base = File.basename( page_file ).split('.').first
    glob_files File.dirname( page_file ), lang, page_file_base + '*', config.format( format ).renderable_exts do |file,base,ext|
      elems = base.split('.')

      if elems.shift == page_file_base # Remove base (slug or variable)
        if elems.size == 0 # There are no part name and language
          parts[ 'body'   ] ||= renderable( file, format, ext )
        elsif elems.size == 1 # There are no language or no part name
          if elems[0] == lang
            parts[ 'body'   ] ||= renderable( file, format, ext )
          else
            parts[ elems[0] ] ||= renderable( file, format, ext )
          end
        else
          parts[ elems[0] ] ||= renderable( file, format, ext ) if elems[1] == lang
        end
      end
    end
    parts
  end

  def load( file )
    File.read( file )
  end

  private

  def renderable( file, format, ext )
    Rayo::Models::Renderable.new( self, file, format, config.format( format ).filter( ext[1..-1] ) || raise( "Filter for '#{ext} not found" ) )
  end

  # Find first file with given name (or variable) and extension from given set
  def find_file( dirs, lang, name, exts, hidden = false )
    glob_files( dirs, lang, name, exts, hidden ) { |file,base,ext| return file }
    nil
  end

  # Find files with given name (or variable) and extension from given set
  def find_files( dirs, lang, name, exts )
    results = []
    glob_files( dirs, lang, name, exts ) { |file,base,ext| results << file }
    results
  end

  def glob_files( dirs, lang, name, exts, hidden = false, &block )
    lang_prefix = "." + lang

    glob dirs, name + lang_prefix, //, exts, &block # Search with given name and language
    glob dirs, name, //, exts, &block # Search with given name without language

    if hidden
      glob dirs, '_' + name + lang_prefix, //, exts, &block # Search hidden with given name and language
      glob dirs, '_' + name, //, exts, &block # Search hidden with given name without language
    end

    glob dirs, '%*' + lang_prefix, /^%.+\.#{lang}$/, exts, &block # Search with variable and language
    glob dirs, '%*',  /^%.+$/, exts, &block # Search with variable without language
  end

  def glob( dirs, mask_wo_ext, base_regexp, exts )
    mask = mask_wo_ext + ext_mask( mask_wo_ext, exts )

    dirs.each do |dir|
      dir_glob File.join( dir, mask ) do |file|
        ext = File.extname( file )
        base = File.basename( file, ext )

        yield file, base, ext if exts.include?( ext ) && base =~ base_regexp
      end
    end
  end

  def dir_glob( mask, &block )
    Dir.glob mask, &block
  end

  def ext_mask( mask_wo_ext, exts )
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
