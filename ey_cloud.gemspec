# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ey_cloud/version"

Gem::Specification.new do |s|
  s.name        = "ey_cloud"
  s.version     = EyCloud::VERSION
  s.authors     = ["Avrohom Katz"]
  s.email       = ["akatz@engineyard.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "ey_cloud"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "fog" 
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "ey_support_api"
  s.add_runtime_dependency "engineyard"
end
