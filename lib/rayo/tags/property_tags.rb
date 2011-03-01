module Rayo::Tags::PropertyTags

  include Rayo::Taggable

  tag 'title' do |tag|
    tag.locals.page.context['title']
  end

  tag 'description' do |tag|
    tag.locals.page.context['description']
  end

  tag 'value' do |tag|
    tag.locals.page[tag.attr['name']]
  end

  tag 'path' do |tag|
    basepath = tag.globals.page.path
    path = tag.locals.page.path

    if basepath.empty?
      [tag.locals.page.lang, *path].join('/')
    else
      basepath = basepath[0..-2]

      i = 0
      while i < path.size && i < basepath.size && path[i] == basepath[i] do
        i = i + 1
      end

      './' + ('../' * (basepath.size - i)) + path[i..-1].join('/')
    end
  end

  tag 'url' do |tag|
    u = "/#{tag.attr['lang'] || tag.locals.page.lang}/#{tag.locals.page.path.join('/')}"
    u << ".#{tag.globals.format}" if tag.globals.format != tag.globals.config.default_format
    u
  end

  tag 'link' do |tag|
    "<a href=\"#{send 'tag:path', tag}\">#{tag.single? ? send( 'tag:title', tag ) : tag.expand}</a>"
  end

  tag 'if_lang' do |tag|
    if_matches( tag.locals.page.lang, tag ) ? tag.expand : ''
  end

  tag 'unless_lang' do |tag|
    if_matches( tag.locals.page.lang, tag ) ? '' : tag.expand
  end

  tag 'if_url' do |tag|
    if_matches( tag.locals.page.path.join('/'), tag ) ? tag.expand : ''
  end

  tag 'unless_url' do |tag|
    if_matches( tag.locals.page.path.join('/'), tag ) ? '' : tag.expand
  end

  tag 'if_domain' do |tag|
    (tag.locals.page.storage.config.respond_to?(:name) && if_matches( tag.locals.page.storage.config.name, tag )) ? tag.expand : ''
  end

  tag 'unless_domain' do |tag|
    (tag.locals.page.storage.config.respond_to?(:name) && if_matches( tag.locals.page.storage.config.name, tag )) ? '' : tag.expand
  end

  tag 'date' do |tag|
    date_for( tag ).strftime( tag.attr['format'] || '%A, %B %d, %Y' )
  end

  tag 'rfc1123_date' do |tag|
    CGI.rfc1123_date( date_for( tag ) )
  end

  private

  def date_for( tag )
    if tag.attr['for'] == 'now'
      Time.now
    elsif tag.attr['for']
      tag.locals.page[tag.attr['for']]
    else
      tag.locals.page['published_at']
    end
  end

  def if_matches( prop, tag )
    prop =~ Regexp.new( tag.attr['matches'] )
  end

end
