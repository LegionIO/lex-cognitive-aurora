# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent do
  subject(:event) do
    described_class.new(
      aurora_type:             :harmonic,
      domain:                  :memory,
      contributing_subsystems: %i[memory emotion prediction],
      luminosity:              0.85,
      harmony_score:           0.75
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(event.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets aurora_type' do
      expect(event.aurora_type).to eq(:harmonic)
    end

    it 'sets domain' do
      expect(event.domain).to eq(:memory)
    end

    it 'sets contributing_subsystems as symbols' do
      expect(event.contributing_subsystems).to eq(%i[memory emotion prediction])
    end

    it 'clamps luminosity to 0-1' do
      over = described_class.new(aurora_type: :harmonic, domain: :memory,
                                 contributing_subsystems: [], luminosity: 1.5, harmony_score: 0.5)
      expect(over.luminosity).to eq(1.0)
    end

    it 'clamps luminosity below 0' do
      under = described_class.new(aurora_type: :harmonic, domain: :memory,
                                  contributing_subsystems: [], luminosity: -0.5, harmony_score: 0.5)
      expect(under.luminosity).to eq(0.0)
    end

    it 'clamps harmony_score to 0-1' do
      over = described_class.new(aurora_type: :harmonic, domain: :memory,
                                 contributing_subsystems: [], luminosity: 0.5, harmony_score: 2.0)
      expect(over.harmony_score).to eq(1.0)
    end

    it 'sets created_at to a Time' do
      expect(event.created_at).to be_a(Time)
    end

    it 'converts contributing_subsystems strings to symbols' do
      e = described_class.new(aurora_type: :harmonic, domain: :memory,
                               contributing_subsystems: %w[memory emotion], luminosity: 0.5, harmony_score: 0.5)
      expect(e.contributing_subsystems).to eq(%i[memory emotion])
    end
  end

  describe '#fade!' do
    it 'reduces luminosity by LUMINOSITY_DECAY' do
      original = event.luminosity
      event.fade!
      expect(event.luminosity).to be_within(0.001).of(original - described_class::LUMINOSITY_DECAY)
    end

    it 'does not go below 0' do
      faint = described_class.new(aurora_type: :harmonic, domain: :memory,
                                   contributing_subsystems: [], luminosity: 0.01, harmony_score: 0.5)
      faint.fade!
      expect(faint.luminosity).to be >= 0.0
    end

    it 'can be called multiple times' do
      original = event.luminosity
      5.times { event.fade! }
      expect(event.luminosity).to be < original
    end

    it 'returns a float rounded to 10 decimal places' do
      event.fade!
      decimal_places = event.luminosity.to_s.split('.').last&.length || 0
      expect(decimal_places).to be <= 10
    end
  end

  describe '#brilliant?' do
    it 'returns true when luminosity > BRILLIANCE_THRESHOLD' do
      expect(event.brilliant?).to be true
    end

    it 'returns false when luminosity is below threshold' do
      dim = described_class.new(aurora_type: :harmonic, domain: :memory,
                                 contributing_subsystems: [], luminosity: 0.5, harmony_score: 0.5)
      expect(dim.brilliant?).to be false
    end

    it 'returns false at exactly BRILLIANCE_THRESHOLD' do
      threshold = described_class.new(aurora_type: :harmonic, domain: :memory,
                                       contributing_subsystems: [], luminosity: 0.8, harmony_score: 0.5)
      expect(threshold.brilliant?).to be false
    end
  end

  describe '#faint?' do
    it 'returns false for a bright event' do
      expect(event.faint?).to be false
    end

    it 'returns true when luminosity < FAINT_THRESHOLD' do
      dim = described_class.new(aurora_type: :harmonic, domain: :memory,
                                 contributing_subsystems: [], luminosity: 0.1, harmony_score: 0.5)
      expect(dim.faint?).to be true
    end

    it 'returns false at exactly FAINT_THRESHOLD' do
      threshold = described_class.new(aurora_type: :harmonic, domain: :memory,
                                       contributing_subsystems: [], luminosity: 0.2, harmony_score: 0.5)
      expect(threshold.faint?).to be false
    end
  end

  describe '#harmonious?' do
    it 'returns true when harmony_score > HARMONY_THRESHOLD' do
      expect(event.harmonious?).to be true
    end

    it 'returns false when harmony is low' do
      discordant = described_class.new(aurora_type: :harmonic, domain: :memory,
                                        contributing_subsystems: [], luminosity: 0.5, harmony_score: 0.3)
      expect(discordant.harmonious?).to be false
    end

    it 'returns false at exactly HARMONY_THRESHOLD' do
      threshold = described_class.new(aurora_type: :harmonic, domain: :memory,
                                       contributing_subsystems: [], luminosity: 0.5, harmony_score: 0.7)
      expect(threshold.harmonious?).to be false
    end
  end

  describe '#multi_source?' do
    it 'returns true when more than 2 subsystems' do
      expect(event.multi_source?).to be true
    end

    it 'returns false with exactly 2 subsystems' do
      e = described_class.new(aurora_type: :harmonic, domain: :memory,
                               contributing_subsystems: %i[memory emotion], luminosity: 0.5, harmony_score: 0.5)
      expect(e.multi_source?).to be false
    end

    it 'returns false with 1 subsystem' do
      e = described_class.new(aurora_type: :harmonic, domain: :memory,
                               contributing_subsystems: [:memory], luminosity: 0.5, harmony_score: 0.5)
      expect(e.multi_source?).to be false
    end

    it 'returns false with empty subsystems' do
      e = described_class.new(aurora_type: :harmonic, domain: :memory,
                               contributing_subsystems: [], luminosity: 0.5, harmony_score: 0.5)
      expect(e.multi_source?).to be false
    end
  end

  describe '#spectral_color' do
    it 'returns a symbol' do
      expect(event.spectral_color).to be_a(Symbol)
    end

    it 'returns a color from SPECTRAL_COLORS' do
      expect(described_class::SPECTRAL_COLORS).to include(event.spectral_color)
    end

    it 'returns :violet for zero luminosity' do
      dim = described_class.new(aurora_type: :harmonic, domain: :memory,
                                 contributing_subsystems: [], luminosity: 0.0, harmony_score: 0.5)
      expect(dim.spectral_color).to eq(:violet)
    end

    it 'returns :ultraviolet for full luminosity' do
      bright = described_class.new(aurora_type: :harmonic, domain: :memory,
                                    contributing_subsystems: [], luminosity: 1.0, harmony_score: 0.5)
      expect(bright.spectral_color).to eq(:ultraviolet)
    end
  end

  describe '#to_h' do
    subject(:hash) { event.to_h }

    it 'includes all expected keys' do
      expected_keys = %i[id aurora_type domain contributing_subsystems luminosity harmony_score
                         spectral_color luminosity_label harmony_label brilliant faint harmonious
                         multi_source created_at]
      expect(hash.keys).to match_array(expected_keys)
    end

    it 'serializes created_at as ISO8601 string' do
      expect(hash[:created_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    it 'includes correct brilliant value' do
      expect(hash[:brilliant]).to be true
    end

    it 'includes correct multi_source value' do
      expect(hash[:multi_source]).to be true
    end

    it 'includes luminosity_label' do
      expect(hash[:luminosity_label]).to be_a(Symbol)
    end

    it 'includes harmony_label' do
      expect(hash[:harmony_label]).to be_a(Symbol)
    end
  end
end
