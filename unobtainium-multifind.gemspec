# coding: utf-8
#
# unobtainium-multifind
# https://github.com/jfinkhaeuser/unobtainium-multifind
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-multifind contributors.
# All rights reserved.
#

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unobtainium-multifind/version'

# rubocop:disable Style/UnneededPercentQ, Style/ExtraSpacing
# rubocop:disable Style/SpaceAroundOperators
Gem::Specification.new do |spec|
  spec.name          = "unobtainium-multifind"
  spec.version       = Unobtainium::MultiFind::VERSION
  spec.authors       = ["Jens Finkhaeuser"]
  spec.email         = ["jens@finkhaeuser.de"]
  spec.description   = %q(
    This gem provides a driver module for unobtainium allowing for more easily
    finding (one of) multiple elements.

    It requires a driver implementing the Selenium API, specifically the
    #find_element method.
  )
  spec.summary       = %q(
    This gem provides a driver module for unobtainium allowing for more easily
    finding (one of) multiple elements.
  )
  spec.homepage      = "https://github.com/jfinkhaeuser/unobtainium-multifind"
  spec.license       = "MITNFA"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.requirements  = "Unobtainium driver implementing the Selenium API"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rubocop", "~> 0.39"
  spec.add_development_dependency "rake", "~> 11.1"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "phantomjs"

  spec.add_dependency "unobtainium", "~> 0.4"
end
# rubocop:enable Style/SpaceAroundOperators
# rubocop:enable Style/UnneededPercentQ, Style/ExtraSpacing
