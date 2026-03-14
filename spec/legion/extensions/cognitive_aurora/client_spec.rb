# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Client do
  subject(:client) { described_class.new }

  describe '#detect_aurora' do
    it 'returns a success hash' do
      result = client.detect_aurora(type: :harmonic, domain: :memory,
                                     contributing_subsystems: %i[memory emotion],
                                     luminosity: 0.7, harmony_score: 0.6)
      expect(result[:success]).to be true
    end

    it 'returns an event hash under :event key' do
      result = client.detect_aurora(type: :harmonic, domain: :memory,
                                     contributing_subsystems: %i[memory emotion],
                                     luminosity: 0.7, harmony_score: 0.6)
      expect(result[:event]).to be_a(Hash)
      expect(result[:event]).to include(:id, :aurora_type, :luminosity)
    end

    it 'uses default values when called with no args' do
      result = client.detect_aurora
      expect(result[:success]).to be true
      expect(result[:event][:luminosity]).to be_a(Float)
    end

    it 'accepts an external engine' do
      engine = Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new
      result = client.detect_aurora(type: :resonant, domain: :emotion,
                                     contributing_subsystems: [:emotion],
                                     luminosity: 0.8, harmony_score: 0.7, engine: engine)
      expect(result[:success]).to be true
      expect(engine.aurora_frequency).to eq(1)
    end

    it 'accumulates events across calls' do
      engine = Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new
      3.times do
        client.detect_aurora(type: :harmonic, domain: :memory,
                              contributing_subsystems: [:memory], luminosity: 0.7, harmony_score: 0.6,
                              engine: engine)
      end
      expect(engine.aurora_frequency).to eq(3)
    end
  end

  describe '#fade_all' do
    before do
      client.detect_aurora(type: :harmonic, domain: :memory,
                            contributing_subsystems: %i[memory emotion],
                            luminosity: 0.95, harmony_score: 0.8)
    end

    it 'returns success' do
      result = client.fade_all
      expect(result[:success]).to be true
    end

    it 'includes brilliant_before and brilliant_after' do
      result = client.fade_all
      expect(result).to include(:brilliant_before, :brilliant_after)
    end

    it 'reports the change in brilliant count' do
      result = client.fade_all
      expect(result[:brilliant_before]).to be >= result[:brilliant_after]
    end

    it 'accepts an external engine' do
      engine = Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new
      engine.detect_aurora(type: :harmonic, domain: :memory, contributing_subsystems: [:memory],
                           luminosity: 0.95, harmony_score: 0.8)
      result = client.fade_all(engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#list_brilliant' do
    before do
      client.detect_aurora(type: :harmonic, domain: :memory,
                            contributing_subsystems: [:memory], luminosity: 0.95, harmony_score: 0.8)
      client.detect_aurora(type: :resonant, domain: :emotion,
                            contributing_subsystems: [:emotion], luminosity: 0.4, harmony_score: 0.5)
    end

    it 'returns success' do
      result = client.list_brilliant
      expect(result[:success]).to be true
    end

    it 'returns only brilliant events' do
      result = client.list_brilliant
      expect(result[:count]).to eq(1)
    end

    it 'returns events as hashes' do
      result = client.list_brilliant
      expect(result[:events]).to all(be_a(Hash))
    end

    it 'respects the limit parameter' do
      engine = Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new
      10.times { |i| engine.detect_aurora(type: :harmonic, domain: :memory, contributing_subsystems: [:memory], luminosity: 0.9 - (i * 0.001), harmony_score: 0.8) }
      result = client.list_brilliant(limit: 3, engine: engine)
      expect(result[:events].size).to be <= 3
    end

    it 'includes count matching events array size' do
      result = client.list_brilliant
      expect(result[:count]).to eq(result[:events].size)
    end
  end

  describe '#aurora_status' do
    before do
      client.detect_aurora(type: :harmonic, domain: :memory,
                            contributing_subsystems: %i[memory emotion],
                            luminosity: 0.8, harmony_score: 0.75)
    end

    it 'returns success' do
      result = client.aurora_status
      expect(result[:success]).to be true
    end

    it 'includes a report hash' do
      result = client.aurora_status
      expect(result[:report]).to be_a(Hash)
    end

    it 'report includes total_events' do
      result = client.aurora_status
      expect(result[:report][:total_events]).to be >= 1
    end

    it 'report includes overall_luminosity' do
      result = client.aurora_status
      expect(result[:report][:overall_luminosity]).to be_a(Float)
    end

    it 'accepts an external engine' do
      engine = Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine.new
      result = client.aurora_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report][:total_events]).to eq(0)
    end
  end

  describe 'client isolation' do
    it 'two clients have independent default engines' do
      client1 = described_class.new
      client2 = described_class.new
      client1.detect_aurora(type: :harmonic, domain: :memory,
                             contributing_subsystems: [:memory], luminosity: 0.7, harmony_score: 0.6)
      result1 = client1.aurora_status
      result2 = client2.aurora_status
      expect(result1[:report][:total_events]).to eq(1)
      expect(result2[:report][:total_events]).to eq(0)
    end
  end
end
