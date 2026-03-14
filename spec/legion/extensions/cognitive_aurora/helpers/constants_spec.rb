# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::Constants do
  describe 'constants' do
    it 'defines MAX_CONDITIONS' do
      expect(described_class::MAX_CONDITIONS).to eq(50)
    end

    it 'defines MAX_EVENTS' do
      expect(described_class::MAX_EVENTS).to eq(200)
    end

    it 'defines MIN_CONDITIONS_FOR_AURORA' do
      expect(described_class::MIN_CONDITIONS_FOR_AURORA).to eq(3)
    end

    it 'defines BEAUTY_THRESHOLD' do
      expect(described_class::BEAUTY_THRESHOLD).to eq(0.6)
    end

    it 'defines CONVERGENCE_WINDOW' do
      expect(described_class::CONVERGENCE_WINDOW).to eq(5)
    end

    it 'defines RARITY_BASELINE' do
      expect(described_class::RARITY_BASELINE).to eq(0.1)
    end

    it 'defines BEAUTY_DECAY' do
      expect(described_class::BEAUTY_DECAY).to eq(0.08)
    end

    it 'defines 8 AURORA_DOMAINS' do
      expect(described_class::AURORA_DOMAINS.size).to eq(8)
      expect(described_class::AURORA_DOMAINS).to include(:insight, :creativity, :harmony, :transcendence)
      expect(described_class::AURORA_DOMAINS).to include(:flow, :resonance, :synthesis, :wonder)
    end

    it 'defines BEAUTY_LABELS with 5 ranges' do
      expect(described_class::BEAUTY_LABELS.size).to eq(5)
    end

    it 'defines RARITY_LABELS with 5 ranges' do
      expect(described_class::RARITY_LABELS.size).to eq(5)
    end

    it 'defines INTENSITY_LABELS with 5 ranges' do
      expect(described_class::INTENSITY_LABELS.size).to eq(5)
    end
  end

  describe '.label_for' do
    it 'returns :nascent for beauty score 0.1' do
      expect(described_class.label_for(described_class::BEAUTY_LABELS, 0.1)).to eq(:nascent)
    end

    it 'returns :transcendent for beauty score 0.9' do
      expect(described_class.label_for(described_class::BEAUTY_LABELS, 0.9)).to eq(:transcendent)
    end

    it 'returns :radiant for beauty score 0.7' do
      expect(described_class.label_for(described_class::BEAUTY_LABELS, 0.7)).to eq(:radiant)
    end

    it 'clamps values below 0.0' do
      result = described_class.label_for(described_class::BEAUTY_LABELS, -0.5)
      expect(result).to eq(:nascent)
    end

    it 'clamps values above 1.0' do
      result = described_class.label_for(described_class::BEAUTY_LABELS, 1.5)
      expect(result).to be_a(Symbol)
    end

    it 'returns :common for rarity score 0.1' do
      expect(described_class.label_for(described_class::RARITY_LABELS, 0.1)).to eq(:common)
    end

    it 'returns :singular for rarity score 0.9' do
      expect(described_class.label_for(described_class::RARITY_LABELS, 0.9)).to eq(:singular)
    end

    it 'returns correct intensity labels' do
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.1)).to eq(:faint)
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.7)).to eq(:strong)
      expect(described_class.label_for(described_class::INTENSITY_LABELS, 0.9)).to eq(:blazing)
    end
  end
end
