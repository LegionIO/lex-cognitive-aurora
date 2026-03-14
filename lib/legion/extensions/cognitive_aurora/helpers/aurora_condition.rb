# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveAurora
      module Helpers
        class AuroraCondition
          attr_reader :condition_id, :subsystem, :metric, :threshold, :current_value, :created_at

          def initialize(subsystem:, metric:, threshold:, current_value: 0.0)
            @condition_id  = SecureRandom.uuid
            @subsystem     = subsystem
            @metric        = metric
            @threshold     = threshold.clamp(0.0, 1.0)
            @current_value = current_value.clamp(0.0, 1.0)
            @created_at    = Time.now.utc
          end

          def update(current_value:)
            @current_value = current_value.clamp(0.0, 1.0)
          end

          def satisfied?
            @current_value >= @threshold
          end

          def to_h
            {
              condition_id:  @condition_id,
              subsystem:     @subsystem,
              metric:        @metric,
              threshold:     @threshold.round(10),
              current_value: @current_value.round(10),
              satisfied:     satisfied?,
              created_at:    @created_at
            }
          end
        end
      end
    end
  end
end
