# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Runners
        module Aurora
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def check_aurora(engine: nil, **)
            eng   = engine || aurora_engine
            event = eng.check_convergence

            unless event
              Legion::Logging.debug '[aurora] check_aurora: no convergence'
              return { success: true, aurora_detected: false }
            end

            beauty_label    = Helpers::Constants.label_for(Helpers::Constants::BEAUTY_LABELS, event.beauty_score)
            rarity_label    = Helpers::Constants.label_for(Helpers::Constants::RARITY_LABELS, event.rarity_score)
            intensity_label = Helpers::Constants.label_for(Helpers::Constants::INTENSITY_LABELS, event.intensity)

            Legion::Logging.info "[aurora] AURORA DETECTED domain=#{event.domain} beauty=#{event.beauty_score.round(2)} " \
                                 "rarity=#{rarity_label} intensity=#{intensity_label} id=#{event.event_id[0..7]}"

            {
              success:         true,
              aurora_detected: true,
              event_id:        event.event_id,
              domain:          event.domain,
              intensity:       event.intensity,
              beauty_score:    event.beauty_score,
              beauty_label:    beauty_label,
              rarity_score:    event.rarity_score,
              rarity_label:    rarity_label,
              intensity_label: intensity_label,
              duration_ticks:  event.duration_ticks,
              conditions_met:  event.conditions_met,
              ephemeral:       event.ephemeral?
            }
          end

          def aurora_report(engine: nil, **)
            eng    = engine || aurora_engine
            report = eng.aurora_report

            Legion::Logging.debug "[aurora] aurora_report events=#{report[:event_count]} " \
                                  "peak_beauty=#{report[:peak_beauty]}"

            { success: true }.merge(report)
          end

          def peak_aurora(engine: nil, **)
            eng   = engine || aurora_engine
            event = eng.peak_aurora

            unless event
              Legion::Logging.debug '[aurora] peak_aurora: no events recorded'
              return { success: true, found: false }
            end

            Legion::Logging.debug "[aurora] peak_aurora id=#{event.event_id[0..7]} beauty=#{event.beauty_score.round(2)}"

            { success: true, found: true, event: event.to_h }
          end

          def aurora_frequency(window: Helpers::Constants::CONVERGENCE_WINDOW, engine: nil, **)
            eng  = engine || aurora_engine
            freq = eng.aurora_frequency(window: window)

            Legion::Logging.debug "[aurora] aurora_frequency window=#{window} freq=#{freq.round(4)}"
            { success: true, frequency: freq, window: window }
          end

          def golden_ratio_alignment(intensities:, engine: nil, **)
            eng       = engine || aurora_engine
            alignment = eng.golden_ratio_alignment(intensities)

            Legion::Logging.debug "[aurora] golden_ratio_alignment score=#{alignment.round(4)} count=#{intensities.size}"
            { success: true, alignment: alignment, count: intensities.size }
          end

          def rarity_score(engine: nil, **)
            eng   = engine || aurora_engine
            event = eng.peak_aurora
            score = event ? event.rarity_score : 0.0
            label = Helpers::Constants.label_for(Helpers::Constants::RARITY_LABELS, score)

            Legion::Logging.debug "[aurora] rarity_score score=#{score.round(4)} label=#{label}"
            { success: true, rarity_score: score, rarity_label: label }
          end

          private

          def aurora_engine
            @aurora_engine ||= Helpers::AuroraEngine.new
          end
        end
      end
    end
  end
end
