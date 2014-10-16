# coding: utf-8
require File.expand_path('../lib/humorous_log_formatter/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "humorous_log_formatter"
  spec.version       = HumorousLogFormatter::VERSION
  spec.authors       = ["Peter Boling"]
  spec.email         = ["peter.boling@gmail.com"]
  spec.summary       = %q{Humorous Log Levels and Color For Rails.}
  spec.description   = %q{Humorous Log Levels and Color For Rails.  Customizable!}
  spec.homepage      = "https://github.com/pboling/humorous_log_formatter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  # Development Dependencies
  spec.add_development_dependency(%q<rails>, ["> 3"])
  spec.add_development_dependency(%q<activesupport>, ["> 3"])

end
