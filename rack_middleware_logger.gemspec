# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack_middleware_logger/version'

Gem::Specification.new do |gem|
  gem.name          = "rack_middleware_logger"
  gem.version       = RackMiddlewareLogger::VERSION
  gem.authors       = ["Hanfei Shen"]
  gem.email         = ["qqshfox@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'rails'
end
