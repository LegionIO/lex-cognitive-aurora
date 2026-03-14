# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::AuroraCondition do
  subject(:condition) do
    described_class.new(subsystem: :emotion, metric: :valence, threshold: 0.7, current_value: 0.5)
  end

  describe '#initialize' do
    it 'assigns a uuid condition_id' do
      expect(condition.condition_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores subsystem' do
      expect(condition.subsystem).to eq(:emotion)
    end

    it 'stores metric' do
      expect(condition.metric).to eq(:valence)
    end

    it 'clamps threshold to [0, 1]' do
      cond = described_class.new(subsystem: :x, metric: :y, threshold: 2.5)
      expect(cond.threshold).to eq(1.0)
    end

    it 'clamps current_value to [0, 1]' do
      cond = described_class.new(subsystem: :x, metric: :y, threshold: 0.5, current_value: -1.0)
      expect(cond.current_value).to eq(0.0)
    end
  end

  describe '#satisfied?' do
    it 'returns false when current_value < threshold' do
      expect(condition.satisfied?).to be false
    end

    it 'returns true when current_value >= threshold' do
      condition.update(current_value: 0.8)
      expect(condition.satisfied?).to be true
    end

    it 'returns true at exact threshold' do
      condition.update(current_value: 0.7)
      expect(condition.satisfied?).to be true
    end
  end

  describe '#update' do
    it 'updates current_value' do
      condition.update(current_value: 0.9)
      expect(condition.current_value).to eq(0.9)
    end

    it 'clamps updated value to [0, 1]' do
      condition.update(current_value: 5.0)
      expect(condition.current_value).to eq(1.0)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all keys' do
      h = condition.to_h
      expect(h.keys).to include(:condition_id, :subsystem, :metric, :threshold, :current_value, :satisfied, :created_at)
    end

    it 'rounds float values to 10 places' do
      h = condition.to_h
      expect(h[:threshold]).to eq(0.7)
      expect(h[:current_value]).to eq(0.5)
    end
  end
end
