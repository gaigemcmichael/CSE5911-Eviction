# -*- encoding: utf-8 -*-
# stub: docx_templater 0.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "docx_templater".freeze
  s.version = "0.2.3".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Paul Smith".freeze, "Michael Ries".freeze]
  s.date = "2013-11-09"
  s.description = "Uses a .docx file with keyword tags within '||' as a template. This gem will then open the .docx and replace those tags with dynamically defined content.".freeze
  s.email = "pauls@basecampops.com".freeze
  s.homepage = "http://rubygems.org/gems/docx_templater".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.0.6".freeze
  s.summary = "Uses a .docx as a template and replaces 'tags' within || with other content".freeze

  s.installed_by_version = "3.5.23".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubyzip>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<htmlentities>.freeze, ["~> 4.3.1".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.1".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14".freeze])
end
