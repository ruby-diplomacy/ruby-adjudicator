Gem::Specification.new do |s|
  s.name        = "ruby-adjudicator"
  s.version     = "0.2.0"
  s.date        = "2013-06-13"
  s.summary     = "Diplomacy adjudicator"
  s.description = "A Diplomacy adjudicator written in ruby."
  s.authors     = ["NamelessOne"]
  s.email       = "unfortunate42@gmail.com"
  s.files       = Dir["{lib}/ruby-adjidicator.rb", "{lib}/**/*.rb", "{lib}/maps/*.yaml", "bin/*", "LICENSE", "*.md"]
  s.add_development_dependency "cucumber"
end
