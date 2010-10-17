require File.expand_path("../lib/rayo/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "rayo"
  s.version = Rayo::VERSION::STRING
  s.platform = Gem::Platform::RUBY
  s.authors = ["Alexey Noskov"]
  s.email = ["alexey.noskov@gmail.com"]
  s.homepage = "http://github.com/alno/rayo"
  s.summary = "Lightweight CMS based on Sinatra and Radius"
  s.description = "It's lightweight CMS based on Sinatra framework, where data are stored in file system (so you may use Git power) and enhanced Radius gem."

  s.required_rubygems_version = ">= 1.3.6"

  # Gem dependencies
  s.add_dependency "erubis"
  s.add_dependency "radius"
  s.add_dependency "sinatra", ">=1.0"

  # If you need to check in files that aren't .rb files, add them here
  s.files = Dir["{lib}/**/*.rb", "bin/*", "LICENSE"]
  s.require_path = 'lib'

  # If you need an executable, add it here
  # s.executables = ["newgem"]

end
