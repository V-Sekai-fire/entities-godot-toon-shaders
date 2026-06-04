# godot-toon-shaders

Godot ports of the avatar toon shaders used across the VRChat / VRM ecosystem,
plus a **shared parameter map** so material parameters port cleanly between them.

The three shaders cover the overwhelming majority of avatars in the wild:

| Folder      | Shader            | Origin                         | Status |
|-------------|-------------------|--------------------------------|--------|
| `mtoon/`    | **MToon**         | V-Sekai/Godot-MToon-Shader     | Working Godot port (vendored) |
| `liltoon/`  | **lilToon**       | lilxyzw/lilToon (Unity)        | Inspector + core-parameter shader scaffold; port in progress |
| `scss/`     | **SCSS**          | Silent's Cel Shading (Unity)   | Inspector + core-parameter shader scaffold; port in progress |

> **Honest status:** only `mtoon/` is a complete, shipping Godot shader today (it
> is V-Sekai's existing port). `liltoon/` and `scss/` ship an editor **inspector**
> modeled on MToon's and an **initial shader exposing the core avatar-toon
> parameters** — they are a foundation to iterate on, not full feature-parity
> ports of lilToon's / SCSS's very large parameter sets.

## The two MToon variants

"MToon" is not one shader. UniVRM ships two, named differently in Unity:

- **MToon 0.x** — UniVRM 0.x. Unity shader `VRM/MToon`. Uniforms like `_Color`,
  `_ShadeColor`, `_ShadeShift`, `_ShadeToony`. This is what `mtoon/` mirrors.
- **MToon 1.0 / MToon10** — VRM 1.0. Unity shader `VRM10/MToon10`; the glTF
  material extension is `VRMC_materials_mtoon`. Factor-named properties like
  `shadeColorFactor`, `shadingShiftFactor`, `shadingToonyFactor`.

`PARAMETERS.md` maps both, alongside lilToon and SCSS, to one semantic set.

## Parameter porting

`PARAMETERS.md` is the point of this repo: one row per *semantic* parameter
(lit color, shade color, shade shift, rim, outline, emission, matcap, normal…),
with the corresponding name in MToon 0.x, MToon10, SCSS, lilToon, and the Godot
shader uniform. Converters (e.g. Unity → OpenUSD → Godot) read this to translate
material parameters without per-shader special cases.

## Inspectors

Each shader folder has an `EditorInspectorPlugin` (`inspector_<name>.gd`) that
gives its `ShaderMaterial` a grouped, labelled inspector with sliders, color
pickers, and mode dropdowns — modeled on `mtoon/inspector_mtoon.gd`. The reusable
machinery lives in `shared/toon_shader_inspector.gd`; a concrete inspector is
mostly metadata (sections, labels, ranges, enums).

## License

MIT (`LICENSE`). Per-shader upstream components keep their own licenses and
attribution — see `LICENSE` and each folder.
