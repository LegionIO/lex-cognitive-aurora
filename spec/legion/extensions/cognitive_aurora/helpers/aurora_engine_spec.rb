# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine do
  subject(:engine) { described_class.new }

  def add_satisfied_conditions(count, engine, base_value: 0.9)
    count.times do |i|
      engine.register_condition(
        subsystem:     "subsystem_#{i}".to_sym,
        metric:        :intensity,
        threshold:     0.5,
        current_value: base_value
      )
    end
  end

  describe '#register_condition' do
    it 'stores a condition and returns it' do
      cond = engine.register_condition(subsystem: :emotion, metric: :valence, threshold: 0.7)
      expect(engine.conditions).to have_key(cond.condition_id)
    end

    it 'returns an AuroraCondition' do
      cond = engine.register_condition(subsystem: :memory, metric: :strength, threshold: 0.5)
      expect(cond).to be_a(Legion::Extensions::CognitiveAurora::Helpers::AuroraCondition)
    end
  end

  describe '#update_condition' do
    it 'updates current_value' do
      cond = engine.register_condition(subsystem: :trust, metric: :score, threshold: 0.6)
      engine.update_condition(cond.condition_id, current_value: 0.9)
      expect(engine.conditions[cond.condition_id].current_value).to eq(0.9)
    end

    it 'returns nil for unknown condition_id' do
      result = engine.update_condition('nonexistent', current_value: 0.5)
      expect(result).to be_nil
    end
  end

  describe '#satisfied_conditions' do
    it 'returns only satisfied conditions' do
      engine.register_condition(subsystem: :a, metric: :x, threshold: 0.8, current_value: 0.3)
      engine.register_condition(subsystem: :b, metric: :y, threshold: 0.5, current_value: 0.9)
      satisfied = engine.satisfied_conditions
      expect(satisfied.size).to eq(1)
      expect(satisfied.first.subsystem).to eq(:b)
    end
  end

  describe '#check_convergence' do
    it 'returns nil when fewer than MIN_CONDITIONS_FOR_AURORA are satisfied' do
      engine.register_condition(subsystem: :a, metric: :x, threshold: 0.5, current_value: 0.9)
      engine.register_condition(subsystem: :b, metric: :y, threshold: 0.5, current_value: 0.9)
      expect(engine.check_convergence).to be_nil
    end

    it 'returns nil when beauty_score < BEAUTY_THRESHOLD' do
      # Conditions that barely satisfy but low current_value means low beauty
      engine.register_condition(subsystem: :a, metric: :x, threshold: 0.0, current_value: 0.0)
      engine.register_condition(subsystem: :b, metric: :y, threshold: 0.0, current_value: 0.0)
      engine.register_condition(subsystem: :c, metric: :z, threshold: 0.0, current_value: 0.0)
      # With all zeros, beauty should be very low
      result = engine.check_convergence
      expect(result).to be_nil
    end

    it 'returns an AuroraEvent when enough conditions are satisfied with high values' do
      add_satisfied_conditions(3, engine)
      result = engine.check_convergence
      expect(result).to be_a(Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent)
    end

    it 'records the event' do
      add_satisfied_conditions(3, engine)
      engine.check_convergence
      expect(engine.events.size).to eq(1)
    end

    it 'event has beauty_score >= BEAUTY_THRESHOLD' do
      add_satisfied_conditions(5, engine)
      event = engine.check_convergence
      expect(event.beauty_score).to be >= Legion::Extensions::CognitiveAurora::Helpers::Constants::BEAUTY_THRESHOLD
    end
  end

  describe '#peak_aurora' do
    it 'returns nil when no events' do
      expect(engine.peak_aurora).to be_nil
    end

    it 'returns the event with highest beauty_score' do
      add_satisfied_conditions(3, engine, base_value: 0.8)
      engine.check_convergence
      add_satisfied_conditions(4, engine, base_value: 0.95)
      engine.check_convergence
      peak = engine.peak_aurora
      expect(peak).to be_a(Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent)
    end
  end

  describe '#aurora_frequency' do
    it 'returns 0.0 when no events' do
      expect(engine.aurora_frequency).to eq(0.0)
    end

    it 'computes frequency as events / window' do
      add_satisfied_conditions(3, engine)
      engine.check_convergence
      freq = engine.aurora_frequency(window: 5)
      expect(freq).to eq(0.2)
    end
  end

  describe '#golden_ratio_alignment' do
    it 'returns 0.0 for single intensity' do
      expect(engine.golden_ratio_alignment([0.8])).to eq(0.0)
    end

    it 'returns a float in [0, 1] for multiple intensities' do
      result = engine.golden_ratio_alignment([0.9, 0.55, 0.34])
      expect(result).to be_between(0.0, 1.0)
    end

    it 'returns 0.0 for empty intensities' do
      expect(engine.golden_ratio_alignment([])).to eq(0.0)
    end

    it 'handles zero second value gracefully' do
      result = engine.golden_ratio_alignment([0.5, 0.0])
      expect(result).to be_between(0.0, 1.0)
    end
  end

  describe '#aurora_report' do
    it 'returns a hash with expected keys' do
      report = engine.aurora_report
      expect(report.keys).to include(:condition_count, :satisfied_count, :event_count,
                                     :peak_beauty, :aurora_frequency, :domains_seen, :most_common_domain)
    end

    it 'reflects zero state initially' do
      expect(engine.aurora_report[:condition_count]).to eq(0)
      expect(engine.aurora_report[:event_count]).to eq(0)
      expect(engine.aurora_report[:peak_beauty]).to eq(0.0)
    end

    it 'reflects conditions and events after activity' do
      add_satisfied_conditions(3, engine)
      engine.check_convergence
      report = engine.aurora_report
      expect(report[:condition_count]).to eq(3)
      expect(report[:event_count]).to eq(1)
    end
  end
end
