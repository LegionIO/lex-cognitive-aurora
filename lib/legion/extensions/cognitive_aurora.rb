# frozen_string_literal: true

require 'securerandom'

require 'legion/extensions/cognitive_aurora/version'
require 'legion/extensions/cognitive_aurora/helpers/constants'
require 'legion/extensions/cognitive_aurora/helpers/aurora_event'
require 'legion/extensions/cognitive_aurora/helpers/spectral_band'
require 'legion/extensions/cognitive_aurora/helpers/aurora_engine'
require 'legion/extensions/cognitive_aurora/runners/cognitive_aurora'
require 'legion/extensions/cognitive_aurora/client'

module Legion
  module Extensions
    module CognitiveAurora
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
