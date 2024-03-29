# frozen_string_literal: true

require_relative 'lib/nina/version'

Gem::Specification.new do |spec|
  spec.name = 'nina'
  spec.version = Nina::VERSION
  spec.authors = ['Andrii Baran']
  spec.email = ['andriy.baran.v@gmail.com']

  spec.summary = 'DSL for simplifying complex objects compositions'
  spec.description = 'Reduce biolerplate code when you need to create complex OOD composition'
  spec.homepage = 'https://github.com/andriy-baran/nina'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/andriy-baran/Toritori/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  # spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'toritori', '0.2.1'
end
