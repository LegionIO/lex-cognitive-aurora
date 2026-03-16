# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_aurora/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-aurora'
  spec.version       = Legion::Extensions::CognitiveAurora::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Aurora'
  spec.description   = 'Emergent beauty and aesthetic pattern detection for the LegionIO ' \
                       'cognitive architecture — detects moments of harmony, elegance, and ' \
                       'resonance across cognitive subsystems'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-aurora'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-aurora/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{\A(?:test|spec|features)/})
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
