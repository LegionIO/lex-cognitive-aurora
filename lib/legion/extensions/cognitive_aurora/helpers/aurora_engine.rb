# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        class AuroraEngine
          include Constants

          attr_reader :conditions, :events

          GOLDEN_RATIO = 1.6180339887498948482

          def initialize
            @conditions    = {}
            @events        = []
            @domain_counts = Hash.new(0)
          end

          def register_condition(subsystem:, metric:, threshold:, current_value: 0.0)
            prune_conditions if @conditions.size >= Constants::MAX_CONDITIONS
            cond = AuroraCondition.new(
              subsystem:     subsystem,
              metric:        metric,
              threshold:     threshold,
              current_value: current_value
            )
            @conditions[cond.condition_id] = cond
            cond
          end

          def update_condition(condition_id, current_value:)
            cond = @conditions[condition_id]
            return nil unless cond

            cond.update(current_value: current_value)
            cond
          end

          def satisfied_conditions
            @conditions.values.select(&:satisfied?)
          end

          def check_convergence
            satisfied = satisfied_conditions
            return nil if satisfied.size < Constants::MIN_CONDITIONS_FOR_AURORA

            intensity    = compute_intensity(satisfied)
            beauty       = compute_beauty_score(satisfied, intensity)
            return nil if beauty < Constants::BEAUTY_THRESHOLD

            domain       = select_domain(satisfied)
            rarity       = compute_rarity(satisfied)
            duration     = compute_duration(intensity)

            event = AuroraEvent.new(
              conditions_met: satisfied.map(&:condition_id),
              intensity:      intensity,
              beauty_score:   beauty,
              domain:         domain,
              duration_ticks: duration,
              rarity_score:   rarity
            )

            record_event(event)
            event
          end

          def peak_aurora
            return nil if @events.empty?

            @events.max_by(&:beauty_score)
          end

          def aurora_frequency(window: Constants::CONVERGENCE_WINDOW)
            recent = @events.last(window)
            recent.size.to_f / window
          end

          def golden_ratio_alignment(intensities)
            return 0.0 if intensities.size < 2

            sorted = intensities.sort.reverse
            ratios = sorted.each_cons(2).map { |a, b| b.zero? ? 0.0 : a / b }
            deviations = ratios.map { |r| (r - GOLDEN_RATIO).abs }
            mean_deviation = deviations.sum / deviations.size
            [1.0 - (mean_deviation / GOLDEN_RATIO), 0.0].max.round(10)
          end

          def aurora_report
            {
              condition_count:    @conditions.size,
              satisfied_count:    satisfied_conditions.size,
              event_count:        @events.size,
              peak_beauty:        peak_aurora&.beauty_score&.round(10) || 0.0,
              aurora_frequency:   aurora_frequency.round(10),
              domains_seen:       @domain_counts.keys,
              most_common_domain: most_common_domain
            }
          end

          private

          def compute_intensity(satisfied)
            return 0.0 if satisfied.empty?

            values = satisfied.map { |c| [c.current_value, 0.0].max }
            (values.sum / values.size).round(10)
          end

          def compute_beauty_score(satisfied, intensity)
            count        = satisfied.size
            subsystems   = satisfied.map(&:subsystem).uniq.size
            coverage     = (count.to_f / [Constants::MAX_CONDITIONS, 1].max).clamp(0.0, 1.0)
            diversity    = (subsystems.to_f / [count, 1].max).clamp(0.0, 1.0)
            intensities  = satisfied.map { |c| c.current_value }
            alignment    = golden_ratio_alignment(intensities)

            raw = (intensity * 0.4) + (coverage * 0.2) + (diversity * 0.2) + (alignment * 0.2)
            raw.clamp(0.0, 1.0).round(10)
          end

          def compute_rarity(satisfied)
            subsystems  = satisfied.map(&:subsystem).uniq
            seen_counts = subsystems.map { |s| @domain_counts.fetch(s.to_s, 0) }
            avg_seen    = seen_counts.empty? ? 0 : seen_counts.sum.to_f / seen_counts.size
            decay       = [1.0 - (avg_seen * Constants::RARITY_BASELINE), 0.0].max
            decay.clamp(0.0, 1.0).round(10)
          end

          def compute_duration(intensity)
            base = (intensity * 10).ceil
            [base, 1].max
          end

          def select_domain(satisfied)
            subsystems = satisfied.map { |c| c.subsystem.to_sym }
            match = Constants::AURORA_DOMAINS.find { |d| subsystems.include?(d) }
            match || Constants::AURORA_DOMAINS.sample
          end

          def record_event(event)
            @events << event
            @events.shift while @events.size > Constants::MAX_EVENTS
            @domain_counts[event.domain.to_s] += 1
          end

          def prune_conditions
            oldest = @conditions.min_by { |_, c| c.created_at }&.first
            @conditions.delete(oldest) if oldest
          end

          def most_common_domain
            return nil if @domain_counts.empty?

            @domain_counts.max_by { |_, v| v }&.first&.to_sym
          end
        end
      end
    end
  end
end
