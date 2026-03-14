# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        class SpectralBand
          include Constants

          attr_reader :id, :aurora_type, :events

          def initialize(aurora_type:)
            @id          = SecureRandom.uuid
            @aurora_type = aurora_type
            @events      = []
          end

          def add_event(event)
            @events << event
          end

          def intensity
            return 0.0 if @events.empty?

            total = @events.sum(&:luminosity).round(10)
            (total / @events.size).round(10)
          end

          def average_harmony
            return 0.0 if @events.empty?

            total = @events.sum(&:harmony_score).round(10)
            (total / @events.size).round(10)
          end

          def dominant_color
            return SPECTRAL_COLORS.first if @events.empty?

            color_counts = Hash.new(0)
            @events.each { |e| color_counts[e.spectral_color] += 1 }
            color_counts.max_by { |_, count| count }&.first || SPECTRAL_COLORS.first
          end

          def active?
            @events.any? { |e| !e.faint? }
          end

          def bandwidth
            return (0.0..0.0) if @events.empty?

            luminosities = @events.map(&:luminosity)
            (luminosities.min..luminosities.max)
          end

          def event_count
            @events.size
          end

          def to_h
            {
              id:              @id,
              aurora_type:     @aurora_type,
              event_count:     event_count,
              intensity:       intensity,
              average_harmony: average_harmony,
              dominant_color:  dominant_color,
              active:          active?,
              bandwidth:       { min: bandwidth.min, max: bandwidth.max }
            }
          end
        end
      end
    end
  end
end
