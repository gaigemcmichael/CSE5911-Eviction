# -*- encoding: utf-8 -*-
# stub: activerecord-sqlserver-adapter 8.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "activerecord-sqlserver-adapter".freeze
  s.version = "8.0.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/issues", "changelog_uri" => "https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/blob/v8.0.2/CHANGELOG.md", "source_code_uri" => "https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/tree/v8.0.2" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ken Collins".freeze, "Anna Carey".freeze, "Will Bond".freeze, "Murray Steele".freeze, "Shawn Balestracci".freeze, "Joe Rafaniello".freeze, "Tom Ward".freeze, "Aidan Haran".freeze]
  s.date = "2025-01-08"
  s.description = "ActiveRecord SQL Server Adapter. SQL Server 2012 and upward.".freeze
  s.email = ["ken@metaskills.net".freeze, "will@wbond.net".freeze]
  s.homepage = "http://github.com/rails-sqlserver/activerecord-sqlserver-adapter".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2.0".freeze)
  s.rubygems_version = "3.5.21".freeze
  s.summary = "ActiveRecord SQL Server Adapter.".freeze

  s.installed_by_version = "3.5.23".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, ["~> 8.0.0".freeze])
  s.add_runtime_dependency(%q<tiny_tds>.freeze, [">= 0".freeze])
end
