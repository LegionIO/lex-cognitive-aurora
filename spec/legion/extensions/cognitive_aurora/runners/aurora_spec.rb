# frozen_string_literal: true

require 'legion/extensions/cognitive_aurora/client'

RSpec.describe Legion::Extensions::CognitiveAurora::Runners::Aurora do
  let(:engine) { Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new }
  let(:client) { Legion::Extensions::CognitiveAurora::Client.new }

  def setup_converging_conditions(engine, count: 4, value: 0.9)
    count.times do |i|
      engine.register_condition(
        subsystem:     :"sub_#{i}",
        metric:        :intensity,
        threshold:     0.5,
        current_value: value
      )
    end
  end

  describe '#check_aurora' do
    context 'when conditions do not converge' do
      it 'returns aurora_detected: false' do
        result = client.check_aurora(engine: engine)
        expect(result[:aurora_detected]).to be false
        expect(result[:success]).to be true
      end
    end

    context 'when enough conditions are satisfied' do
      before { setup_converging_conditions(engine) }

      it 'detects an aurora' do
        result = client.check_aurora(engine: engine)
        expect(result[:aurora_detected]).to be true
      end

      it 'returns event_id' do
        result = client.check_aurora(engine: engine)
        expect(result[:event_id]).to match(/\A[0-9a-f-]{36}\z/)
      end

      it 'returns domain' do
        result = client.check_aurora(engine: engine)
        expect(Legion::Extensions::CognitiveAurora::Helpers::Constants::AURORA_DOMAINS).to include(result[:domain])
      end

      it 'returns beauty_label' do
        result = client.check_aurora(engine: engine)
        expect(result[:beauty_label]).to be_a(Symbol)
      end

      it 'returns rarity_label' do
        result = client.check_aurora(engine: engine)
        expect(result[:rarity_label]).to be_a(Symbol)
      end

      it 'returns intensity_label' do
        result = client.check_aurora(engine: engine)
        expect(result[:intensity_label]).to be_a(Symbol)
      end

      it 'returns ephemeral: true' do
        result = client.check_aurora(engine: engine)
        expect(result[:ephemeral]).to be true
      end

      it 'returns conditions_met array' do
        result = client.check_aurora(engine: engine)
        expect(result[:conditions_met]).to be_an(Array)
        expect(result[:conditions_met].size).to be >= 3
      end
    end
  end

  describe '#aurora_report' do
    it 'returns success: true with report keys' do
      result = client.aurora_report(engine: engine)
      expect(result[:success]).to be true
      expect(result.keys).to include(:condition_count, :event_count, :peak_beauty)
    end

    it 'reflects zero state initially' do
      result = client.aurora_report(engine: engine)
      expect(result[:event_count]).to eq(0)
      expect(result[:peak_beauty]).to eq(0.0)
    end

    it 'reflects events after detection' do
      setup_converging_conditions(engine)
      client.check_aurora(engine: engine)
      result = client.aurora_report(engine: engine)
      expect(result[:event_count]).to eq(1)
    end
  end

  describe '#peak_aurora' do
    it 'returns found: false when no events' do
      result = client.peak_aurora(engine: engine)
      expect(result[:found]).to be false
      expect(result[:success]).to be true
    end

    it 'returns the peak event after detections' do
      setup_converging_conditions(engine)
      client.check_aurora(engine: engine)
      result = client.peak_aurora(engine: engine)
      expect(result[:found]).to be true
      expect(result[:event]).to be_a(Hash)
      expect(result[:event][:beauty_score]).to be > 0
    end
  end

  describe '#aurora_frequency' do
    it 'returns 0.0 frequency when no events' do
      result = client.aurora_frequency(engine: engine)
      expect(result[:frequency]).to eq(0.0)
    end

    it 'returns non-zero frequency after detection' do
      setup_converging_conditions(engine)
      client.check_aurora(engine: engine)
      result = client.aurora_frequency(window: 5, engine: engine)
      expect(result[:frequency]).to be > 0.0
      expect(result[:window]).to eq(5)
    end
  end

  describe '#golden_ratio_alignment' do
    it 'returns alignment score for intensities' do
      result = client.golden_ratio_alignment(intensities: [0.9, 0.55, 0.34], engine: engine)
      expect(result[:success]).to be true
      expect(result[:alignment]).to be_between(0.0, 1.0)
    end

    it 'returns 0.0 for single intensity' do
      result = client.golden_ratio_alignment(intensities: [0.8], engine: engine)
      expect(result[:alignment]).to eq(0.0)
    end

    it 'returns 0.0 for empty list' do
      result = client.golden_ratio_alignment(intensities: [], engine: engine)
      expect(result[:alignment]).to eq(0.0)
    end
  end

  describe '#rarity_score' do
    it 'returns 0.0 rarity when no events' do
      result = client.rarity_score(engine: engine)
      expect(result[:rarity_score]).to eq(0.0)
      expect(result[:rarity_label]).to eq(:common)
    end

    it 'returns rarity info after an aurora event' do
      setup_converging_conditions(engine)
      client.check_aurora(engine: engine)
      result = client.rarity_score(engine: engine)
      expect(result[:success]).to be true
      expect(result[:rarity_label]).to be_a(Symbol)
    end
  end
end
