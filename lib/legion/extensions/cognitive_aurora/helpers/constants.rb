# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        module Constants
          MAX_CONDITIONS        = 50
          MAX_EVENTS            = 200
          MIN_CONDITIONS_FOR_AURORA = 3
          BEAUTY_THRESHOLD      = 0.6
          CONVERGENCE_WINDOW    = 5
          RARITY_BASELINE       = 0.1
          BEAUTY_DECAY          = 0.08

          AURORA_DOMAINS = %i[
            insight
            creativity
            harmony
            transcendence
            flow
            resonance
            synthesis
            wonder
          ].freeze

          BEAUTY_LABELS = {
            0.0..0.2 => :nascent,
            0.2..0.4 => :emerging,
            0.4..0.6 => :vivid,
            0.6..0.8 => :radiant,
            0.8..1.0 => :transcendent
          }.freeze

          RARITY_LABELS = {
            0.0..0.2 => :common,
            0.2..0.4 => :uncommon,
            0.4..0.6 => :rare,
            0.6..0.8 => :exceptional,
            0.8..1.0 => :singular
          }.freeze

          INTENSITY_LABELS = {
            0.0..0.2 => :faint,
            0.2..0.4 => :soft,
            0.4..0.6 => :moderate,
            0.6..0.8 => :strong,
            0.8..1.0 => :blazing
          }.freeze

          module_function

          def label_for(labels_hash, value)
            clamped = value.clamp(0.0, 1.0)
            labels_hash.each do |range, label|
              return label if range.cover?(clamped)
            end
            labels_hash.values.last
          end
        end
      end
    end
  end
end
