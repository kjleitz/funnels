$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "funnels/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "funnels"
  s.version     = Funnels::VERSION
  s.authors     = ["Keegan Leitz"]
  s.email       = ["keegan@openbay.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Funnels."
  s.description = "TODO: Description of Funnels."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end
