# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        module Constants
          MAX_EVENTS  = 300
          MAX_BANDS   = 50

          DEFAULT_LUMINOSITY = 0.5
          LUMINOSITY_DECAY   = 0.03
          LUMINOSITY_BOOST   = 0.1

          HARMONY_THRESHOLD = 0.7
          BRILLIANCE_THRESHOLD = 0.8
          FAINT_THRESHOLD = 0.2

          AURORA_TYPES = %i[
            harmonic
            resonant
            cascading
            convergent
            emergent
            serendipitous
            synchronous
            prismatic
          ].freeze

          SPECTRAL_COLORS = %i[
            violet
            indigo
            blue
            green
            yellow
            orange
            red
            ultraviolet
          ].freeze

          DOMAINS = %i[
            memory
            emotion
            prediction
            identity
            trust
            consent
            governance
            perception
          ].freeze

          LUMINOSITY_LABELS = {
            (0.0...0.2) => :faint,
            (0.2...0.4) => :dim,
            (0.4...0.6) => :moderate,
            (0.6...0.8) => :bright,
            (0.8..1.0)  => :brilliant
          }.freeze

          HARMONY_LABELS = {
            (0.0...0.3) => :discordant,
            (0.3...0.5) => :unsettled,
            (0.5...0.7) => :resonating,
            (0.7...0.9) => :harmonious,
            (0.9..1.0)  => :perfect
          }.freeze

          BRILLIANCE_LABELS = {
            (0.0...0.25) => :nascent,
            (0.25...0.5) => :emerging,
            (0.5...0.75) => :radiant,
            (0.75..1.0)  => :transcendent
          }.freeze

          module_function

          def label_for(value, label_map)
            label_map.each do |range, label|
              return label if range.cover?(value)
            end
            label_map.values.last
          end
        end
      end
    end
  end
end
