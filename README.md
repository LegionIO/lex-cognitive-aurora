# lex-cognitive-aurora

Emergent beauty and aesthetic pattern detection for the LegionIO cognitive architecture. Detects moments of harmony, elegance, and resonance across cognitive subsystems.

## What It Does

Aurora events model fleeting moments when cognitive subsystems align — bursts of harmony that feel like insight, elegance, or unexpected coherence. The extension tracks these events with luminosity (brightness/intensity) and harmony scores, groups them into spectral bands by type, and provides reports on when and how often cognitive brilliance emerges.

Aurora types include harmonic, resonant, cascading, convergent, emergent, serendipitous, synchronous, and prismatic. Luminosity decays over time; brilliant events (luminosity > 0.8) are preserved as long as possible during pruning.

## Usage

```ruby
client = Legion::Extensions::CognitiveAurora::Client.new

result = client.detect_aurora(
  type: :emergent,
  domain: :memory,
  contributing_subsystems: [:memory, :emotion],
  luminosity: 0.85,
  harmony_score: 0.78
)

client.list_brilliant(limit: 5)
client.fade_all
client.aurora_status
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
