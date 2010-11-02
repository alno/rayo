module Rayo::Tags::ContentTags

  include Rayo::Taggable

  tag 'content' do |tag|
    if part = find_part( tag )
      part.render( tag.globals.page.parser )
    else
      error "No part '#{tag.attr['part'] || 'body'}' found for page '#{tag.locals.page.path.join('/')}'"
    end
  end

  tag 'if_content' do |tag|
    find_part( tag ) && tag.expand || ''
  end

  tag 'content_for_layout' do |tag|
    tag.globals.content_stack ||= [] # Prepare the stacks
    tag.globals.content_stack.pop || send( 'tag:content', tag )
  end

  tag 'layout' do |tag|
    if name = tag.attr['name'].strip
      tag.globals.layout_stack ||= [] # Prepare layout stack
      tag.globals.content_stack ||= [] # Prepare content stack

      if layout = tag.globals.storage.layout( tag.globals.page.lang, name )
        tag.globals.layout_stack << name # Track this layout on the stack
        tag.globals.content_stack << tag.expand # Save contents of inside_layout for later insertion

        layout.render( tag.globals.page.parser )
      else
        error "Parent layout '#{name.strip}' not found for 'layout' tag"
      end
    else
      error "'layout' tag must contain a 'name' attribute"
    end
  end

  tag 'snippet' do |tag|
    snippet_name = tag.attr['name']
    snippet = tag.globals.storage.snippet( tag.globals.page.lang, snippet_name )

    if snippet
      snippet.render( tag.globals.page.parser )
    else
      error "No snippet '#{snippet_name}' found"
    end
  end

  private

  def find_part( tag )
    tag.locals.page.find_part( tag.attr['part'] || 'body', tag.attr['inherit'] == 'true' )
  end

end
