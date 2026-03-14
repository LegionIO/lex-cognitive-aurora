# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAurora::Helpers::SpectralBand do
  subject(:band) { described_class.new(aurora_type: :harmonic) }

  let(:bright_event) do
    Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent.new(
      aurora_type:             :harmonic,
      domain:                  :memory,
      contributing_subsystems: %i[memory emotion],
      luminosity:              0.9,
      harmony_score:           0.8
    )
  end

  let(:dim_event) do
    Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent.new(
      aurora_type:             :harmonic,
      domain:                  :emotion,
      contributing_subsystems: %i[emotion],
      luminosity:              0.15,
      harmony_score:           0.3
    )
  end

  let(:moderate_event) do
    Legion::Extensions::CognitiveAurora::Helpers::AuroraEvent.new(
      aurora_type:             :harmonic,
      domain:                  :prediction,
      contributing_subsystems: %i[prediction trust],
      luminosity:              0.5,
      harmony_score:           0.6
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(band.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets aurora_type' do
      expect(band.aurora_type).to eq(:harmonic)
    end

    it 'starts with empty events' do
      expect(band.events).to be_empty
    end
  end

  describe '#add_event' do
    it 'adds an event to the band' do
      band.add_event(bright_event)
      expect(band.events.size).to eq(1)
    end

    it 'can hold multiple events' do
      band.add_event(bright_event)
      band.add_event(dim_event)
      expect(band.events.size).to eq(2)
    end
  end

  describe '#intensity' do
    it 'returns 0.0 for empty band' do
      expect(band.intensity).to eq(0.0)
    end

    it 'returns average luminosity of events' do
      band.add_event(bright_event)
      band.add_event(dim_event)
      expected = ((bright_event.luminosity + dim_event.luminosity) / 2).round(10)
      expect(band.intensity).to be_within(0.001).of(expected)
    end

    it 'returns single event luminosity when only one event' do
      band.add_event(bright_event)
      expect(band.intensity).to be_within(0.001).of(bright_event.luminosity)
    end
  end

  describe '#average_harmony' do
    it 'returns 0.0 for empty band' do
      expect(band.average_harmony).to eq(0.0)
    end

    it 'returns average harmony_score of events' do
      band.add_event(bright_event)
      band.add_event(dim_event)
      expected = ((bright_event.harmony_score + dim_event.harmony_score) / 2).round(10)
      expect(band.average_harmony).to be_within(0.001).of(expected)
    end
  end

  describe '#dominant_color' do
    it 'returns first spectral color for empty band' do
      expect(band.dominant_color).to eq(Legion::Extensions::CognitiveAurora::Helpers::Constants::SPECTRAL_COLORS.first)
    end

    it 'returns the most common spectral color' do
      band.add_event(bright_event)
      band.add_event(bright_event)
      band.add_event(dim_event)
      expect(band.dominant_color).to eq(bright_event.spectral_color)
    end

    it 'returns a valid spectral color' do
      band.add_event(moderate_event)
      expect(Legion::Extensions::CognitiveAurora::Helpers::Constants::SPECTRAL_COLORS).to include(band.dominant_color)
    end
  end

  describe '#active?' do
    it 'returns false for empty band' do
      expect(band.active?).to be false
    end

    it 'returns true when at least one non-faint event exists' do
      band.add_event(bright_event)
      expect(band.active?).to be true
    end

    it 'returns false when all events are faint' do
      band.add_event(dim_event)
      expect(band.active?).to be false
    end

    it 'returns true when mix of faint and non-faint' do
      band.add_event(bright_event)
      band.add_event(dim_event)
      expect(band.active?).to be true
    end
  end

  describe '#bandwidth' do
    it 'returns 0..0 range for empty band' do
      expect(band.bandwidth).to eq(0.0..0.0)
    end

    it 'returns min..max range of luminosities' do
      band.add_event(bright_event)
      band.add_event(dim_event)
      expect(band.bandwidth.min).to be_within(0.001).of(dim_event.luminosity)
      expect(band.bandwidth.max).to be_within(0.001).of(bright_event.luminosity)
    end

    it 'returns equal min and max for single event' do
      band.add_event(moderate_event)
      expect(band.bandwidth.min).to eq(band.bandwidth.max)
    end
  end

  describe '#event_count' do
    it 'returns 0 for empty band' do
      expect(band.event_count).to eq(0)
    end

    it 'counts all events' do
      band.add_event(bright_event)
      band.add_event(dim_event)
      expect(band.event_count).to eq(2)
    end
  end

  describe '#to_h' do
    before { band.add_event(bright_event) }

    subject(:hash) { band.to_h }

    it 'includes all expected keys' do
      expected = %i[id aurora_type event_count intensity average_harmony dominant_color active bandwidth]
      expect(hash.keys).to match_array(expected)
    end

    it 'includes bandwidth as hash with min and max' do
      expect(hash[:bandwidth]).to include(:min, :max)
    end

    it 'includes correct event_count' do
      expect(hash[:event_count]).to eq(1)
    end

    it 'includes active status' do
      expect(hash[:active]).to be true
    end
  end
end
