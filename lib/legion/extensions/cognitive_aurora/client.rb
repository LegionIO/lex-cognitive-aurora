# frozen_string_literal: true

require 'legion/extensions/cognitive_aurora/helpers/constants'
require 'legion/extensions/cognitive_aurora/helpers/aurora_condition'
require 'legion/extensions/cognitive_aurora/helpers/aurora_event'
require 'legion/extensions/cognitive_aurora/helpers/aurora_engine'
require 'legion/extensions/cognitive_aurora/runners/conditions'
require 'legion/extensions/cognitive_aurora/runners/aurora'

module Legion
  module Extensions
    module CognitiveAurora
      class Client
        include Runners::Conditions
        include Runners::Aurora

        def initialize(**)
          @aurora_engine = Helpers::AuroraEngine.new
        end

        private

        attr_reader :aurora_engine
      end
    end
  end
end
