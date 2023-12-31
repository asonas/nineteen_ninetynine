# frozen_string_literal: true

require_relative "lib/nineteen_ninetynine/version"

Gem::Specification.new do |spec|
  spec.name = "nineteen_ninetynine"
  spec.version = NineteenNinetynine::VERSION
  spec.authors = ["Yuya Fujiwara"]
  spec.email = ["hzw1258@gmail.com"]

  spec.summary = "nineteen_ninetynine is nostr client"
  spec.description = "nineteen_ninetynine is nostr client"
  spec.homepage = "https://ason.as"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/asonas/nineteen_ninetynine"
  spec.metadata["changelog_uri"] = "https://github.com/asonas/nineteen_ninetynine"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "eventmachine"
  spec.add_dependency "bech32"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
