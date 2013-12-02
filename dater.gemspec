# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dater/version'

Gem::Specification.new do |spec|
  spec.name          = "dater"
  spec.version       = Dater::VERSION
  spec.authors       = ["Roman Rodriguez"]
  spec.email         = ["roman.g.rodriguez@gmail.com"]
  spec.description   = %q{This gem aims to help you with dates treatment, specially in regression test where you have to use future dates}
  spec.summary       = %q{Converts periods of time expresed in literal mode to a formatted date from the date of today}
  spec.homepage      = "http://romantestdev.github.io/dater/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
