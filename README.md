# entities-godot-toon-shaders

Godot ports of three avatar toon shaders, with editor inspectors and a parameter map that carries material settings between them.

## What it is for

Each shader directory holds the shader and an inspector that groups its parameters; the inspectors share one base in `shared/`. `PARAMETERS.md` gives one row per semantic parameter, such as shade colour, rim or outline, with its name in every shader, so a converter translates a material without a case per shader. The Lean specs under `lean/` are the canonical shader definitions.

## Run

Copy the repository into a Godot project's `addons/` directory and enable the plugin in the project settings.

## Licence

MIT; see `LICENSE`. Each ported shader keeps its upstream licence and attribution, which `LICENSE` and the shader's directory record.
