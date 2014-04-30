Gem::Specification.new do |s|
  s.name        = 'rcov-cobertura'
  s.version     = '1.0.0git'
  s.date        = '2014-05-29'
  s.summary     = 'Convert rcov reports to Cobertura reports'
  s.description = <<-'end'
A formatter for rcov.  Generates Cobertura-compatible XML files.
end
  s.authors     = ["Rohan McGovern"]
  s.email       = 'rohan@mcgovern.id.au'
  s.files       = Dir[
    "lib/*.rb",
    "lib/rcov/*.rb",
    "lib/rcov/cobertura/*.{rb,erb}"
  ]
  s.homepage    =
    'http://rubygems.org/gems/rcov-cobertura'
  s.license       = 'MIT'

  s.add_development_dependency 'mocha', '~> 1.0.0'
  s.test_files = Dir["test/*_test.rb"]
end
