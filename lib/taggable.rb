module Taggable

  module ClassMethods

    def tag( name, &block )
      define_method("tag:#{name}", &block)
    end

  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end
