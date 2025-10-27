# -*- encoding: utf-8 -*-
# stub: tiny_tds 3.1.0 ruby lib
# stub: ext/tiny_tds/extconf.rb

Gem::Specification.new do |s|
  s.name = "tiny_tds".freeze
  s.version = "3.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "msys2_mingw_dependencies" => "freetds" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ken Collins".freeze, "Erik Bryn".freeze, "Will Bond".freeze]
  s.date = "2025-01-02"
  s.description = "TinyTDS - A modern, simple and fast FreeTDS library for Ruby using DB-Library. Developed for the ActiveRecord SQL Server adapter.".freeze
  s.email = ["ken@metaskills.net".freeze, "will@wbond.net".freeze]
  s.executables = ["defncopy-ttds".freeze, "tsql-ttds".freeze]
  s.extensions = ["ext/tiny_tds/extconf.rb".freeze]
  s.files = ["bin/defncopy-ttds".freeze, "bin/tsql-ttds".freeze, "ext/tiny_tds/extconf.rb".freeze]
  s.homepage = "http://github.com/rails-sqlserver/tiny_tds".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "TinyTDS - A modern, simple and fast FreeTDS library for Ruby using DB-Library.".freeze

  s.installed_by_version = "3.5.23".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<bigdecimal>.freeze, ["~> 3".freeze])
  s.add_development_dependency(%q<mini_portile2>.freeze, ["~> 2.5.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.0".freeze])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.2".freeze])
  s.add_development_dependency(%q<rake-compiler-dock>.freeze, ["~> 1.7.0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.25".freeze])
  s.add_development_dependency(%q<minitest-reporters>.freeze, ["~> 1.6.1".freeze])
  s.add_development_dependency(%q<connection_pool>.freeze, ["~> 2.2.0".freeze])
  s.add_development_dependency(%q<toxiproxy>.freeze, ["~> 2.0.0".freeze])
end
