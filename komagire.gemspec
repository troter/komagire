# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'komagire/version'

Gem::Specification.new do |spec|
  spec.name          = "komagire"
  spec.version       = Komagire::VERSION
  spec.authors       = ["Takumi IINO"]
  spec.email         = ["trot.thunder@gmail.com"]

  spec.summary       = %q{Compose an object from comma separated keys.}
  spec.description   = %q{Compose an object from comma separated keys.}
  spec.homepage      = "https://github.com/troter/komagire"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency "activesupport", ">= 4.0", "< 5.2"
  spec.add_runtime_dependency "activerecord", ">= 4.0", "< 5.2"
  spec.add_development_dependency "active_hash"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"

  spec.add_development_dependency 'coveralls'
end
