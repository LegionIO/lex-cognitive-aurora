# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        class AuroraEngine
          include Constants

          def initialize
            @events       = []
            @spectral_bands = {}
          end

          def detect_aurora(type:, domain:, contributing_subsystems:, luminosity:, harmony_score:)
            event = AuroraEvent.new(
              aurora_type:             type,
              domain:                  domain,
              contributing_subsystems: contributing_subsystems,
              luminosity:              luminosity,
              harmony_score:           harmony_score
            )

            prune_events if @events.size >= MAX_EVENTS

            @events << event
            register_in_band(event)
            event
          end

          def fade_all!
            @events.each(&:fade!)
          end

          def brilliant_events
            @events.select(&:brilliant?)
          end

          def harmonious_events
            @events.select(&:harmonious?)
          end

          def events_by_domain(domain)
            @events.select { |e| e.domain == domain.to_sym }
          end

          def events_by_type(type)
            @events.select { |e| e.aurora_type == type.to_sym }
          end

          def spectral_distribution
            AURORA_TYPES.each_with_object({}) do |type, dist|
              band = @spectral_bands[type]
              dist[type] = band ? band.intensity : 0.0
            end
          end

          def overall_luminosity
            return 0.0 if @events.empty?

            total = @events.sum(&:luminosity).round(10)
            (total / @events.size).round(10)
          end

          def overall_harmony
            return 0.0 if @events.empty?

            total = @events.sum(&:harmony_score).round(10)
            (total / @events.size).round(10)
          end

          def aurora_frequency
            @events.size
          end

          def most_brilliant(limit: 5)
            @events.sort_by { |e| -e.luminosity }.first(limit)
          end

          def active_bands
            @spectral_bands.values.select(&:active?)
          end

          def aurora_report
            {
              total_events:         @events.size,
              overall_luminosity:   overall_luminosity,
              overall_harmony:      overall_harmony,
              brilliant_count:      brilliant_events.size,
              harmonious_count:     harmonious_events.size,
              active_band_count:    active_bands.size,
              spectral_distribution: spectral_distribution,
              luminosity_label:     Constants.label_for(overall_luminosity, LUMINOSITY_LABELS),
              harmony_label:        Constants.label_for(overall_harmony, HARMONY_LABELS)
            }
          end

          def events
            @events.dup
          end

          private

          def register_in_band(event)
            type = event.aurora_type
            @spectral_bands[type] ||= SpectralBand.new(aurora_type: type)
            @spectral_bands[type].add_event(event)
          end

          def prune_events
            faint = @events.select(&:faint?)
            to_remove = faint.size.positive? ? faint : [@events.first]
            to_remove.each { |e| @events.delete(e) }
          end
        end
      end
    end
  end
end
