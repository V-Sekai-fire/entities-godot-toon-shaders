# entities-godot-toon-shaders

Godot toon shaders for avatars, with editor inspectors and a parameter map that carries material settings between them.

## What it is for

Each shader directory holds the shader and an inspector that groups its parameters; the inspectors share one base in `shared/`. `PARAMETERS.md` gives one row per semantic parameter, such as shade colour, rim or outline, with its name in every shader, so a converter translates a material without a case per shader. `mtoon/` is a full port; `liltoon/` and `scss/` expose core parameters only. The Lean specs under `lean/` are placeholders.

## Run

Copy the repository into a Godot project's `addons/` directory and enable the plugin in the project settings. It registers the `liltoon/` and `scss/` inspectors; the `mtoon/` inspector is a separate plugin under `mtoon/`.

## Licence

MIT; see `LICENSE`. Each ported shader keeps its upstream licence: `LICENSE` records the attribution for all three, and `mtoon/` also carries its own.
