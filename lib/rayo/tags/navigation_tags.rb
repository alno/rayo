module Rayo::Tags::NavigationTags

  include Rayo::Taggable

  tag 'find' do |tag|
    if page = tag.locals.page.relative( tag.attr['url'] )
      tag.locals.page = page
      tag.expand
    else
      error "No page '#{url}' found"
    end
  end

  tag 'children' do |tag|
    children = tag.locals.page.children

    [ tag.attr['level'].to_i - 1, 0 ].max.times do
      children = children.map{ |p| p.children }.flatten
    end

    tag.locals.children = children
    tag.expand
  end

  tag 'children:count' do |tag|
    prepare_children( tag ).size
  end

  tag 'children:first' do |tag|
    if first = prepare_children( tag ).first
      tag.locals.page = first
      tag.expand
    end
  end

  tag 'children:last' do |tag|
    if last = prepare_children( tag ).last
      tag.locals.page = last
      tag.expand
    end
  end

  tag 'children:each' do |tag|
    result = ""
    children = prepare_children( tag )

    children.each_with_index do |item, i|
      tag.locals.child = item
      tag.locals.page = item
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == children.size - 1

      result << tag.expand
    end
    result
  end

  tag 'related' do |tag|
    tag.locals.relation = tag.locals.page['relations'][tag.attr['rel']]
    tag.expand
  end

  tag 'related:count' do |tag|
    tag.locals.relation.size
  end

  tag 'related:first' do |tag|
    if first = tag.locals.relation.first
      tag.locals.page = tag.locals.page.relative first
      tag.expand
    end
  end

  tag 'related:last' do |tag|
    if last = tag.locals.relation.last
      tag.locals.page = tag.locals.page.relative last
      tag.expand
    end
  end

  tag 'related:each' do |tag|
    result = ''

    relation = tag.locals.relation
    relation.each_with_index do |item, i|
      tag.locals.page = tag.locals.page.relative item
      tag.locals.first_related = i == 0
      tag.locals.last_related = i == relation.size - 1

      result << tag.expand
    end
    result
  end

  private

  def prepare_children( tag )
    children = tag.locals.children

    if by = tag.attr['by']
      if tag.attr['order'] == 'desc'
        children = children.sort {|a,b| b[by] <=> a[by] }
      else
        children = children.sort {|a,b| a[by] <=> b[by] }
      end
    end

    children = children[0..(tag.attr['limit'].to_i - 1)] if tag.attr['limit']
    children
  end

end
