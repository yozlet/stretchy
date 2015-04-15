# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stretchy/version'

Gem::Specification.new do |spec|
  spec.name          = "stretchy"
  spec.version       = Stretchy::VERSION
  spec.authors       = ["agius"]
  spec.email         = ["andrew@atevans.com"]

  spec.summary       = %q{Query builder for Elasticsearch}
  spec.description   = %q{Build queries for Elasticsearch with a chainable interface like ActiveRecord's.}
  spec.homepage      = "https://github.com/hired/stretchy"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_dependency "elasticsearch",  "~> 1.0"
  spec.add_dependency "excon",          "~> 0.45"

  spec.add_development_dependency "bundler",  "~> 1.8"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "rspec",    "~> 3.2"
  spec.add_development_dependency "fuubar",   "~> 2.0"
end
