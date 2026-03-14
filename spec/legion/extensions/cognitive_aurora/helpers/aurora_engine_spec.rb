# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::AuroraEngine do
  subject(:engine) { described_class.new }

  def detect(overrides = {})
    defaults = {
      type:                    :harmonic,
      domain:                  :memory,
      contributing_subsystems: %i[memory emotion],
      luminosity:              0.7,
      harmony_score:           0.6
    }
    engine.detect_aurora(**defaults.merge(overrides))
  end

  describe '#detect_aurora' do
    it 'returns an AuroraEvent' do
      event = detect
      expect(event).to be_a(Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent)
    end

    it 'increments event count' do
      detect
      expect(engine.aurora_frequency).to eq(1)
    end

    it 'stores events with correct attributes' do
      event = detect(aurora_type: :resonant, domain: :emotion, luminosity: 0.9)
      expect(event.aurora_type).to eq(:resonant)
      expect(event.domain).to eq(:emotion)
      expect(event.luminosity).to be_within(0.001).of(0.9)
    end

    it 'registers event in the spectral band for its type' do
      detect(type: :cascading)
      bands = engine.active_bands
      expect(bands.any? { |b| b.aurora_type == :cascading }).to be true
    end

    it 'stores multiple events' do
      3.times { detect }
      expect(engine.aurora_frequency).to eq(3)
    end

    it 'creates separate bands per aurora type' do
      detect(type: :harmonic)
      detect(type: :resonant)
      active = engine.active_bands
      types = active.map(&:aurora_type)
      expect(types).to include(:harmonic, :resonant)
    end
  end

  describe '#fade_all!' do
    before { detect(luminosity: 0.9) }

    it 'reduces luminosity of all events' do
      event = engine.brilliant_events.first
      original = event.luminosity
      engine.fade_all!
      expect(event.luminosity).to be < original
    end

    it 'affects all events' do
      3.times { detect(luminosity: 0.9) }
      engine.fade_all!
      engine.events.each do |e|
        expect(e.luminosity).to be < 0.9
      end
    end
  end

  describe '#brilliant_events' do
    it 'returns events with luminosity above brilliance threshold' do
      detect(luminosity: 0.9)
      detect(luminosity: 0.5)
      expect(engine.brilliant_events.size).to eq(1)
    end

    it 'returns empty array when no brilliant events' do
      detect(luminosity: 0.4)
      expect(engine.brilliant_events).to be_empty
    end

    it 'returns all brilliant events' do
      detect(luminosity: 0.85)
      detect(luminosity: 0.95)
      detect(luminosity: 0.3)
      expect(engine.brilliant_events.size).to eq(2)
    end
  end

  describe '#harmonious_events' do
    it 'returns events with harmony above threshold' do
      detect(harmony_score: 0.8)
      detect(harmony_score: 0.3)
      expect(engine.harmonious_events.size).to eq(1)
    end

    it 'returns empty array when no harmonious events' do
      detect(harmony_score: 0.4)
      expect(engine.harmonious_events).to be_empty
    end
  end

  describe '#events_by_domain' do
    it 'returns only events matching the domain' do
      detect(domain: :memory)
      detect(domain: :emotion)
      detect(domain: :memory)
      result = engine.events_by_domain(:memory)
      expect(result.size).to eq(2)
      expect(result.all? { |e| e.domain == :memory }).to be true
    end

    it 'returns empty array when no events for domain' do
      detect(domain: :memory)
      expect(engine.events_by_domain(:trust)).to be_empty
    end

    it 'accepts string domain and converts' do
      detect(domain: :memory)
      result = engine.events_by_domain('memory')
      expect(result.size).to eq(1)
    end
  end

  describe '#events_by_type' do
    it 'returns only events matching the type' do
      detect(type: :harmonic)
      detect(type: :resonant)
      detect(type: :harmonic)
      result = engine.events_by_type(:harmonic)
      expect(result.size).to eq(2)
    end

    it 'returns empty when no events of that type' do
      detect(type: :harmonic)
      expect(engine.events_by_type(:prismatic)).to be_empty
    end
  end

  describe '#spectral_distribution' do
    it 'returns a hash with all aurora types as keys' do
      dist = engine.spectral_distribution
      expect(dist.keys).to match_array(Legion::Extensions::CognitiveAurora::Helpers::Constants::AURORA_TYPES)
    end

    it 'returns 0.0 for types with no events' do
      dist = engine.spectral_distribution
      expect(dist[:harmonic]).to eq(0.0)
    end

    it 'returns non-zero for types with events' do
      detect(type: :harmonic, luminosity: 0.7)
      dist = engine.spectral_distribution
      expect(dist[:harmonic]).to be > 0.0
    end
  end

  describe '#overall_luminosity' do
    it 'returns 0.0 when no events' do
      expect(engine.overall_luminosity).to eq(0.0)
    end

    it 'returns average luminosity' do
      detect(luminosity: 0.6)
      detect(luminosity: 0.8)
      expect(engine.overall_luminosity).to be_within(0.001).of(0.7)
    end
  end

  describe '#overall_harmony' do
    it 'returns 0.0 when no events' do
      expect(engine.overall_harmony).to eq(0.0)
    end

    it 'returns average harmony score' do
      detect(harmony_score: 0.4)
      detect(harmony_score: 0.6)
      expect(engine.overall_harmony).to be_within(0.001).of(0.5)
    end
  end

  describe '#aurora_frequency' do
    it 'returns 0 initially' do
      expect(engine.aurora_frequency).to eq(0)
    end

    it 'counts all detected events' do
      5.times { detect }
      expect(engine.aurora_frequency).to eq(5)
    end
  end

  describe '#most_brilliant' do
    before do
      detect(luminosity: 0.9)
      detect(luminosity: 0.5)
      detect(luminosity: 0.85)
      detect(luminosity: 0.3)
    end

    it 'returns events sorted by luminosity descending' do
      top = engine.most_brilliant(limit: 2)
      expect(top.first.luminosity).to be >= top.last.luminosity
    end

    it 'respects the limit parameter' do
      expect(engine.most_brilliant(limit: 2).size).to eq(2)
    end

    it 'defaults to 5' do
      expect(engine.most_brilliant.size).to be <= 5
    end
  end

  describe '#active_bands' do
    it 'returns empty array when no events' do
      expect(engine.active_bands).to be_empty
    end

    it 'returns bands with non-faint events' do
      detect(luminosity: 0.7)
      expect(engine.active_bands.size).to eq(1)
    end

    it 'does not include bands with only faint events' do
      detect(luminosity: 0.1)
      expect(engine.active_bands).to be_empty
    end
  end

  describe '#aurora_report' do
    before do
      detect(luminosity: 0.9, harmony_score: 0.8)
      detect(luminosity: 0.5, harmony_score: 0.5)
    end

    subject(:report) { engine.aurora_report }

    it 'includes all expected keys' do
      expected = %i[total_events overall_luminosity overall_harmony brilliant_count
                    harmonious_count active_band_count spectral_distribution
                    luminosity_label harmony_label]
      expect(report.keys).to match_array(expected)
    end

    it 'reports correct total_events' do
      expect(report[:total_events]).to eq(2)
    end

    it 'reports correct brilliant_count' do
      expect(report[:brilliant_count]).to eq(1)
    end

    it 'includes luminosity_label as symbol' do
      expect(report[:luminosity_label]).to be_a(Symbol)
    end

    it 'includes harmony_label as symbol' do
      expect(report[:harmony_label]).to be_a(Symbol)
    end

    it 'includes spectral_distribution with all types' do
      expect(report[:spectral_distribution].keys).to match_array(
        Legion::Extensions::CognitiveAurora::Helpers::Constants::AURORA_TYPES
      )
    end
  end

  describe 'MAX_EVENTS pruning' do
    it 'prunes when event count reaches MAX_EVENTS' do
      max = Legion::Extensions::CognitiveAurora::Helpers::Constants::MAX_EVENTS
      max.times { detect(luminosity: 0.5) }
      expect(engine.aurora_frequency).to eq(max)
      detect(luminosity: 0.5)
      expect(engine.aurora_frequency).to be <= max
    end
  end

  describe '#events' do
    it 'returns a copy of the events array' do
      detect
      events_copy = engine.events
      events_copy.clear
      expect(engine.aurora_frequency).to eq(1)
    end
  end
end
