# frozen_string_literal: true

require 'legion/extensions/cognitive_aurora/client'

RSpec.describe Legion::Extensions::CognitiveAurora::Client do
  it 'responds to condition runner methods' do
    client = described_class.new
    expect(client).to respond_to(:register_condition)
    expect(client).to respond_to(:update_condition)
    expect(client).to respond_to(:list_conditions)
    expect(client).to respond_to(:satisfied_conditions)
  end

  it 'responds to aurora runner methods' do
    client = described_class.new
    expect(client).to respond_to(:check_aurora)
    expect(client).to respond_to(:aurora_report)
    expect(client).to respond_to(:peak_aurora)
    expect(client).to respond_to(:aurora_frequency)
    expect(client).to respond_to(:golden_ratio_alignment)
    expect(client).to respond_to(:rarity_score)
  end

  it 'uses the same engine instance across calls' do
    client = described_class.new
    client.register_condition(subsystem: :a, metric: :x, threshold: 0.5)
    result = client.list_conditions
    expect(result[:count]).to eq(1)
  end
end
