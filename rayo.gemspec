require File.expand_path("../lib/rayo/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "rayo"
  s.version = Rayo::VERSION::STRING
  s.platform = Gem::Platform::RUBY
  s.authors = ["Alexey Noskov"]
  s.email = ["alexey.noskov@gmail.com"]
  s.homepage = "http://github.com/alno/rayo"
  s.summary = "Lightweight CMS based on Sinatra and Radius"
  s.description = "Lightweight CMS based on Sinatra framework, where data are stored in file system (and so may be Git-powered) and enhanced using Radius gem."

  s.required_rubygems_version = ">= 1.3.6"

  # Gem dependencies
  s.add_dependency "erubis"
  s.add_dependency "radius"
  s.add_dependency "sinatra", ">=1.0"

  # Development dependencies
  s.add_development_dependency "rspec", ">=2.0"
  s.add_development_dependency "rack-test"

  # Gem files
  s.files = Dir["lib/**/*.rb", "bin/*", "MIT-LICENSE", "README.rdoc"]
  s.extra_rdoc_files = [ "README.rdoc", "MIT-LICENSE"]
  s.require_path = 'lib'

  # Gem executables
  # s.executables = ["newgem"]

  # Info
  s.has_rdoc = true
  s.homepage = "http://github.com/alno/rayo"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rayo CMS", "--main", "README.rdoc"]

end
