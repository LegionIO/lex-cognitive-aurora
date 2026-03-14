# frozen_string_literal: true

require 'legion/extensions/cognitive_aurora/client'

RSpec.describe Legion::Extensions::CognitiveAurora::Runners::Conditions do
  let(:engine) { Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new }
  let(:client) { Legion::Extensions::CognitiveAurora::Client.new }

  describe '#register_condition' do
    it 'returns success: true with condition_id' do
      result = client.register_condition(subsystem: :emotion, metric: :valence, threshold: 0.7, engine: engine)
      expect(result[:success]).to be true
      expect(result[:condition_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'reflects satisfaction status' do
      result = client.register_condition(
        subsystem:     :trust,
        metric:        :score,
        threshold:     0.5,
        current_value: 0.9,
        engine:        engine
      )
      expect(result[:satisfied]).to be true
    end

    it 'registers unsatisfied condition' do
      result = client.register_condition(
        subsystem:     :memory,
        metric:        :strength,
        threshold:     0.8,
        current_value: 0.2,
        engine:        engine
      )
      expect(result[:satisfied]).to be false
    end
  end

  describe '#update_condition' do
    it 'updates and returns success' do
      reg = client.register_condition(subsystem: :x, metric: :y, threshold: 0.5, engine: engine)
      result = client.update_condition(condition_id: reg[:condition_id], current_value: 0.9, engine: engine)
      expect(result[:success]).to be true
      expect(result[:satisfied]).to be true
    end

    it 'returns failure for unknown id' do
      result = client.update_condition(condition_id: 'bad-id', current_value: 0.5, engine: engine)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:not_found)
    end
  end

  describe '#list_conditions' do
    it 'returns empty list initially' do
      result = client.list_conditions(engine: engine)
      expect(result[:count]).to eq(0)
      expect(result[:conditions]).to be_empty
    end

    it 'returns all registered conditions' do
      client.register_condition(subsystem: :a, metric: :x, threshold: 0.5, engine: engine)
      client.register_condition(subsystem: :b, metric: :y, threshold: 0.6, engine: engine)
      result = client.list_conditions(engine: engine)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#satisfied_conditions' do
    it 'returns only satisfied conditions' do
      client.register_condition(subsystem: :a, metric: :x, threshold: 0.8, current_value: 0.3, engine: engine)
      client.register_condition(subsystem: :b, metric: :y, threshold: 0.5, current_value: 0.9, engine: engine)
      result = client.satisfied_conditions(engine: engine)
      expect(result[:count]).to eq(1)
    end
  end
end
