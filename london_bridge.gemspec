Gem::Specification.new do |s|
  s.name = "london_bridge"
  s.version = "0.1.0"
  s.license = "MIT"
  s.summary = "The london_bridge is lexing markdown, parsing markdown, rendering markdown"
  s.homepage = "https://github.com/hanachin/london_bridge"
  s.authors = ["Seiei Miyagi"]
  s.email = "hanachin@gmail.com"
  s.files = `git ls-files`.split(/\R/)
  s.executables = s.files.grep(/^exe/)

  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
