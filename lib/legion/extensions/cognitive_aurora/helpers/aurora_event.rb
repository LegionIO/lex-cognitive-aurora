# frozen_string_literal: true

require 'securerandom'
require 'time'

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        class AuroraEvent
          include Constants

          attr_reader :id, :aurora_type, :domain, :contributing_subsystems, :harmony_score, :created_at
          attr_accessor :luminosity

          def initialize(aurora_type:, domain:, contributing_subsystems:, luminosity:, harmony_score:)
            @id                     = SecureRandom.uuid
            @aurora_type            = aurora_type
            @domain                 = domain
            @contributing_subsystems = Array(contributing_subsystems).map(&:to_sym)
            @luminosity             = luminosity.clamp(0.0, 1.0)
            @harmony_score          = harmony_score.clamp(0.0, 1.0)
            @created_at             = Time.now.utc
          end

          def fade!
            @luminosity = (@luminosity - LUMINOSITY_DECAY).round(10).clamp(0.0, 1.0)
          end

          def brilliant?
            @luminosity > BRILLIANCE_THRESHOLD
          end

          def faint?
            @luminosity < FAINT_THRESHOLD
          end

          def harmonious?
            @harmony_score > HARMONY_THRESHOLD
          end

          def multi_source?
            @contributing_subsystems.size > 2
          end

          def spectral_color
            index = (@luminosity * (SPECTRAL_COLORS.size - 1)).round
            SPECTRAL_COLORS[index.clamp(0, SPECTRAL_COLORS.size - 1)]
          end

          def luminosity_label
            Constants.label_for(@luminosity, LUMINOSITY_LABELS)
          end

          def harmony_label
            Constants.label_for(@harmony_score, HARMONY_LABELS)
          end

          def to_h
            {
              id:                      @id,
              aurora_type:             @aurora_type,
              domain:                  @domain,
              contributing_subsystems: @contributing_subsystems,
              luminosity:              @luminosity,
              harmony_score:           @harmony_score,
              spectral_color:          spectral_color,
              luminosity_label:        luminosity_label,
              harmony_label:           harmony_label,
              brilliant:               brilliant?,
              faint:                   faint?,
              harmonious:              harmonious?,
              multi_source:            multi_source?,
              created_at:              @created_at.iso8601
            }
          end
        end
      end
    end
  end
end
