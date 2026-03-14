# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        class AuroraEvent
          EPHEMERAL = true

          attr_reader :event_id, :conditions_met, :intensity, :beauty_score,
                      :domain, :duration_ticks, :created_at, :rarity_score

          def initialize(conditions_met:, intensity:, beauty_score:, domain:,
                         duration_ticks:, rarity_score: 0.0)
            @event_id       = SecureRandom.uuid
            @conditions_met = conditions_met
            @intensity      = intensity.clamp(0.0, 1.0)
            @beauty_score   = beauty_score.clamp(0.0, 1.0)
            @domain         = domain
            @duration_ticks = duration_ticks
            @rarity_score   = rarity_score.clamp(0.0, 1.0)
            @created_at     = Time.now.utc
          end

          def ephemeral?
            EPHEMERAL
          end

          def to_h
            {
              event_id:       @event_id,
              conditions_met: @conditions_met,
              intensity:      @intensity.round(10),
              beauty_score:   @beauty_score.round(10),
              domain:         @domain,
              duration_ticks: @duration_ticks,
              rarity_score:   @rarity_score.round(10),
              ephemeral:      EPHEMERAL,
              created_at:     @created_at
            }
          end
        end
      end
    end
  end
end
