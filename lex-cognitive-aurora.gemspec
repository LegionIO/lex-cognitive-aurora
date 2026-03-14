# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_aurora/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-aurora'
  spec.version       = Legion::Extensions::CognitiveAurora::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Aurora'
  spec.description   = 'Emergent beauty and cognitive aurora detection for LegionIO agents'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-aurora/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.read.split("\x0").reject { |f| f.start_with?('spec/') }
  end + Dir.glob('spec/**/*', base: __dir__)
  spec.require_paths = ['lib']
end
