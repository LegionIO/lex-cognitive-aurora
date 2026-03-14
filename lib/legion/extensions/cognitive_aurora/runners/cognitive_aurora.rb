# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Runners
        module CognitiveAurora
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def detect_aurora(type: :emergent, domain: :perception, contributing_subsystems: [],
                            luminosity: Helpers::Constants::DEFAULT_LUMINOSITY,
                            harmony_score: 0.5, engine: nil, **)
            target_engine = engine || default_engine
            event = target_engine.detect_aurora(
              type:                    type,
              domain:                  domain,
              contributing_subsystems: contributing_subsystems,
              luminosity:              luminosity,
              harmony_score:           harmony_score
            )

            Legion::Logging.debug "[cognitive_aurora] detected aurora: type=#{type} domain=#{domain} " \
                                  "luminosity=#{luminosity.round(2)} harmony=#{harmony_score.round(2)} " \
                                  "id=#{event.id}"

            { success: true, event: event.to_h }
          rescue StandardError => e
            Legion::Logging.error "[cognitive_aurora] detect_aurora failed: #{e.message}"
            { success: false, error: e.message }
          end

          def fade_all(engine: nil, **)
            target_engine = engine || default_engine
            before_count = target_engine.brilliant_events.size
            target_engine.fade_all!
            after_count = target_engine.brilliant_events.size

            Legion::Logging.debug "[cognitive_aurora] fade_all: brilliant #{before_count} -> #{after_count}"
            { success: true, faded: true, brilliant_before: before_count, brilliant_after: after_count }
          rescue StandardError => e
            Legion::Logging.error "[cognitive_aurora] fade_all failed: #{e.message}"
            { success: false, error: e.message }
          end

          def list_brilliant(limit: 10, engine: nil, **)
            target_engine = engine || default_engine
            events = target_engine.most_brilliant(limit: limit)

            Legion::Logging.debug "[cognitive_aurora] list_brilliant: found #{events.size} events (limit=#{limit})"
            { success: true, events: events.map(&:to_h), count: events.size }
          rescue StandardError => e
            Legion::Logging.error "[cognitive_aurora] list_brilliant failed: #{e.message}"
            { success: false, error: e.message }
          end

          def aurora_status(engine: nil, **)
            target_engine = engine || default_engine
            report = target_engine.aurora_report

            Legion::Logging.debug "[cognitive_aurora] status: total=#{report[:total_events]} " \
                                  "luminosity=#{report[:overall_luminosity].round(2)} " \
                                  "harmony=#{report[:overall_harmony].round(2)}"

            { success: true, report: report }
          rescue StandardError => e
            Legion::Logging.error "[cognitive_aurora] aurora_status failed: #{e.message}"
            { success: false, error: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::AuroraEngine.new
          end
        end
      end
    end
  end
end
