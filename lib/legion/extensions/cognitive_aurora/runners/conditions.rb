# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAurora
      module Runners
        module Conditions
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_condition(subsystem:, metric:, threshold:, current_value: 0.0, engine: nil, **)
            eng  = engine || aurora_engine
            cond = eng.register_condition(
              subsystem:     subsystem,
              metric:        metric,
              threshold:     threshold,
              current_value: current_value
            )

            Legion::Logging.debug "[aurora] registered condition subsystem=#{subsystem} metric=#{metric} " \
                                  "threshold=#{threshold} id=#{cond.condition_id[0..7]}"

            {
              success:      true,
              condition_id: cond.condition_id,
              subsystem:    subsystem,
              metric:       metric,
              threshold:    threshold,
              satisfied:    cond.satisfied?
            }
          end

          def update_condition(condition_id:, current_value:, engine: nil, **)
            eng  = engine || aurora_engine
            cond = eng.update_condition(condition_id, current_value: current_value)

            unless cond
              Legion::Logging.debug "[aurora] update_condition not found id=#{condition_id[0..7]}"
              return { success: false, reason: :not_found }
            end

            Legion::Logging.debug "[aurora] updated condition id=#{condition_id[0..7]} " \
                                  "value=#{current_value} satisfied=#{cond.satisfied?}"

            {
              success:      true,
              condition_id: condition_id,
              current_value: cond.current_value,
              satisfied:    cond.satisfied?
            }
          end

          def list_conditions(engine: nil, **)
            eng        = engine || aurora_engine
            conditions = eng.conditions.values.map(&:to_h)

            Legion::Logging.debug "[aurora] list_conditions count=#{conditions.size}"
            { success: true, conditions: conditions, count: conditions.size }
          end

          def satisfied_conditions(engine: nil, **)
            eng        = engine || aurora_engine
            conditions = eng.satisfied_conditions.map(&:to_h)

            Legion::Logging.debug "[aurora] satisfied_conditions count=#{conditions.size}"
            { success: true, conditions: conditions, count: conditions.size }
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
