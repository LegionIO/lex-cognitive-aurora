# frozen_string_literal: true

require 'legion/extensions/cognitive_aurora/version'
require 'legion/extensions/cognitive_aurora/helpers/constants'
require 'legion/extensions/cognitive_aurora/helpers/aurora_condition'
require 'legion/extensions/cognitive_aurora/helpers/aurora_event'
require 'legion/extensions/cognitive_aurora/helpers/aurora_engine'
require 'legion/extensions/cognitive_aurora/runners/conditions'
require 'legion/extensions/cognitive_aurora/runners/aurora'

module Legion
  module Extensions
    module CognitiveAurora
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
