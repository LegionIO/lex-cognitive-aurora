# frozen_string_literal: true

require 'legion/extensions/cognitive_aurora/helpers/constants'
require 'legion/extensions/cognitive_aurora/helpers/aurora_event'
require 'legion/extensions/cognitive_aurora/helpers/spectral_band'
require 'legion/extensions/cognitive_aurora/helpers/aurora_engine'
require 'legion/extensions/cognitive_aurora/runners/cognitive_aurora'

module Legion
  module Extensions
    module CognitiveAurora
      class Client
        include Runners::CognitiveAurora

        def initialize(**)
          @default_engine = Helpers::AuroraEngine.new
        end
      end
    end
  end
end
