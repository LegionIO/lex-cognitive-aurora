# lex-cognitive-aurora

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Emergent beauty and aesthetic pattern detection for the LegionIO cognitive architecture. Detects moments of harmony, elegance, and resonance across cognitive subsystems. Aurora events represent fleeting moments of cognitive coherence — not sustained states but bursts of cross-domain alignment.

## Gem Info

- **Gem name**: `lex-cognitive-aurora`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::CognitiveAurora`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_aurora/
  cognitive_aurora.rb
  version.rb
  client.rb
  helpers/
    constants.rb
    aurora_engine.rb
    aurora_event.rb
    spectral_band.rb
  runners/
    cognitive_aurora.rb
```

## Key Constants

From `helpers/constants.rb`:

- `AURORA_TYPES` — `%i[harmonic resonant cascading convergent emergent serendipitous synchronous prismatic]`
- `SPECTRAL_COLORS` — `%i[violet indigo blue green yellow orange red ultraviolet]`
- `DOMAINS` — `%i[memory emotion prediction identity trust consent governance perception]`
- `MAX_EVENTS` = `300`, `MAX_BANDS` = `50`
- `DEFAULT_LUMINOSITY` = `0.5`, `LUMINOSITY_DECAY` = `0.03`, `LUMINOSITY_BOOST` = `0.1`
- `HARMONY_THRESHOLD` = `0.7`, `BRILLIANCE_THRESHOLD` = `0.8`, `FAINT_THRESHOLD` = `0.2`
- `LUMINOSITY_LABELS` — `0.8+` = `:brilliant`, `0.6` = `:bright`, `0.4` = `:moderate`, `0.2` = `:dim`, below = `:faint`
- `HARMONY_LABELS` — `0.9+` = `:perfect`, `0.7` = `:harmonious`, `0.5` = `:resonating`, `0.3` = `:unsettled`, below = `:discordant`
- `BRILLIANCE_LABELS` — `0.75+` = `:transcendent`, `0.5` = `:radiant`, `0.25` = `:emerging`, below = `:nascent`

## Runners

All methods in `Runners::CognitiveAurora`:

- `detect_aurora(type:, domain:, contributing_subsystems:, luminosity:, harmony_score:, engine: nil)` — records a new aurora event; prunes faint events when `MAX_EVENTS` reached
- `fade_all(engine: nil)` — applies luminosity decay to all events; returns before/after brilliant count
- `list_brilliant(limit: 10, engine: nil)` — returns events sorted by luminosity descending
- `aurora_status(engine: nil)` — returns full aurora report: totals, luminosity, harmony, band distribution

## Helpers

- `AuroraEngine` — stores events in `@events` array and `@spectral_bands` keyed by aurora type. Computes aggregate luminosity and harmony as simple averages. Pruning removes faint events first, then oldest.
- `AuroraEvent` — individual aurora occurrence with `aurora_type`, `domain`, `contributing_subsystems`, `luminosity`, `harmony_score`, `id`. Methods: `fade!`, `brilliant?`, `harmonious?`, `faint?`.
- `SpectralBand` — groups events by aurora type; tracks band-level intensity.

## Integration Points

- Designed to be called from tick phases when cross-domain alignment is detected — e.g., when emotion + memory + prediction all converge on a consistent signal.
- `contributing_subsystems` links aurora events back to named subsystems in `lex-cognitive-architecture`.
- `DOMAINS` list maps to the core agentic LEXs (memory, emotion, prediction, identity, trust, consent, governance, perception).
- No hard dependency on any other LEX; callers pass domain context via arguments.

## Development Notes

- `AuroraEngine` is per-runner-instance in-memory state (no persistence).
- Pruning strategy: removes faint events first; if none are faint, removes the oldest event. This preserves brilliance at the cost of history.
- `overall_luminosity` and `overall_harmony` are simple arithmetic means, not weighted. Large numbers of faint events pull these values down.
- `SpectralBand` intensity tracks the running signal across all events of a given aurora type — useful for detecting which type of cognitive harmony fires most frequently.
