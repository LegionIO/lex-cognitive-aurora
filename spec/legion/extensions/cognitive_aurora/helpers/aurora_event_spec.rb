# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent do
  subject(:event) do
    described_class.new(
      conditions_met: %w[id1 id2 id3],
      intensity:      0.8,
      beauty_score:   0.75,
      domain:         :insight,
      duration_ticks: 5,
      rarity_score:   0.6
    )
  end

  describe '#initialize' do
    it 'assigns a uuid event_id' do
      expect(event.event_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores conditions_met' do
      expect(event.conditions_met).to eq(%w[id1 id2 id3])
    end

    it 'clamps intensity to [0, 1]' do
      e = described_class.new(conditions_met: [], intensity: 2.0, beauty_score: 0.5,
                              domain: :flow, duration_ticks: 1)
      expect(e.intensity).to eq(1.0)
    end

    it 'clamps beauty_score to [0, 1]' do
      e = described_class.new(conditions_met: [], intensity: 0.5, beauty_score: -1.0,
                              domain: :flow, duration_ticks: 1)
      expect(e.beauty_score).to eq(0.0)
    end

    it 'defaults rarity_score to 0.0' do
      e = described_class.new(conditions_met: [], intensity: 0.5, beauty_score: 0.5,
                              domain: :flow, duration_ticks: 1)
      expect(e.rarity_score).to eq(0.0)
    end
  end

  describe '#ephemeral?' do
    it 'returns true' do
      expect(event.ephemeral?).to be true
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = event.to_h
      expect(h.keys).to include(:event_id, :conditions_met, :intensity, :beauty_score,
                                :domain, :duration_ticks, :rarity_score, :ephemeral, :created_at)
    end

    it 'includes ephemeral: true' do
      expect(event.to_h[:ephemeral]).to be true
    end
  end
end
