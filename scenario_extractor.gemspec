# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scenario_extractor/version"

Gem::Specification.new do |s|
  s.name        = "scenario_extractor"
  s.version     = ScenarioExtractor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tarik Alkasab"]
  s.email       = ["talkasab@partners.org"]
  s.homepage    = "https://github.com/talkasab/scenario_extractor"
  s.summary     = %q{Extracts medical record information and packages as an XML file.}
  s.description = 
    %q{Given a patient and medical record item identifier, the scenario extractor tool
      will find associated preceding and following medical record items, anonymize them,
      and package them for use in the assayer tool.}

  s.add_dependency("qpid", ["~> 0.1.2"])
  s.add_dependency("builder")
  s.add_dependency("i18n")
  s.add_dependency("activesupport")
  s.add_dependency("tiny_tds")
  s.add_dependency("uuidtools")
  s.add_development_dependency("rspec", "~>2.6")
  s.add_development_dependency("wirble")
  s.add_development_dependency("wirb")
  s.add_development_dependency("awesome_print")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
