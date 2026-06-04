# Toon-shader parameter map

One row per *semantic* parameter, with the name each shader uses. A converter
(e.g. Unity material → OpenUSD → Godot) reads this to translate parameters
without hard-coding every shader pair.

Columns:
- **MToon 0.x** — Unity shader `VRM/MToon` (UniVRM 0.x) uniform.
- **MToon10** — Unity shader `VRM10/MToon10` / glTF `VRMC_materials_mtoon` property.
- **SCSS** — Silent's Cel Shading Shader (Unity) property.
- **lilToon** — lilToon (Unity) property.
- **Godot** — uniform in this repo's Godot shader (`mtoon/` mirrors MToon 0.x names).

> SCSS and lilToon expose *hundreds* of properties and their names vary across
> versions; the names below are the closest core-parameter equivalents, not an
> exhaustive or version-pinned mapping. Treat them as the starting point the
> `liltoon/` and `scss/` ports refine. Blank = no direct equivalent.

## Base / lit

| Semantic            | MToon 0.x      | MToon10              | SCSS            | lilToon          | Godot          |
|---------------------|----------------|----------------------|-----------------|------------------|----------------|
| Lit color (RGBA)    | `_Color`       | `baseColorFactor`    | `_Color`        | `_Color`         | `_Color`       |
| Lit texture         | `_MainTex`     | `baseColorTexture`   | `_MainTex`      | `_MainTex`       | `_MainTex`     |
| Alpha cutoff        | `_Cutoff`      | `alphaCutoff`        | `_Cutoff`       | `_Cutoff`        | `_Cutoff`      |
| Normal map          | `_BumpMap`     | `normalTexture`      | `_BumpMap`      | `_BumpMap`       | `_BumpMap`     |
| Normal scale        | `_BumpScale`   | `normalTextureScale` | `_BumpScale`    | `_BumpScale`     | `_BumpScale`   |

## Shading (toon ramp)

| Semantic            | MToon 0.x        | MToon10               | SCSS                | lilToon            | Godot            |
|---------------------|------------------|-----------------------|---------------------|--------------------|------------------|
| Shade color         | `_ShadeColor`    | `shadeColorFactor`    | `_1st_ShadeColor`   | `_ShadowColor`     | `_ShadeColor`    |
| Shade texture       | `_ShadeTexture`  | `shadeMultiplyTexture`| `_1st_ShadeMap`     | `_ShadowColorTex`  | `_ShadeTexture`  |
| Shade shift         | `_ShadeShift`    | `shadingShiftFactor`  | `_BaseColor_Step`   | `_ShadowBorder`    | `_ShadeShift`    |
| Shade toony / blur  | `_ShadeToony`    | `shadingToonyFactor`  | `_1st_ShadeColor_Step` | `_ShadowBlur`   | `_ShadeToony`    |
| GI / indirect       | `_IndirectLightIntensity` | `giEqualizationFactor` | | `_LightMinLimit` | `_IndirectLightIntensity` |

## Rim light

| Semantic            | MToon 0.x          | MToon10                          | SCSS               | lilToon              | Godot              |
|---------------------|--------------------|----------------------------------|--------------------|----------------------|--------------------|
| Rim color           | `_RimColor`        | `parametricRimColorFactor`       | `_RimColor`        | `_RimColor`          | `_RimColor`        |
| Rim fresnel power   | `_RimFresnelPower` | `parametricRimFresnelPowerFactor`| `_RimFresnelPower` | `_RimFresnelPower`   | `_RimFresnelPower` |
| Rim lift            | `_RimLift`         | `parametricRimLiftFactor`        |                    | `_RimShadowMask`     | `_RimLift`         |
| Rim lighting mix    | `_RimLightingMix`  | `rimLightingMixFactor`           |                    | `_RimEnableLighting` | `_RimLightingMix`  |
| Matcap / sphere add | `_SphereAdd`       | `matcapTexture`                  | `_MatCap`          | `_MatCapTex`         | `_SphereAdd`       |

## Outline

| Semantic            | MToon 0.x           | MToon10                       | SCSS             | lilToon              | Godot               |
|---------------------|---------------------|-------------------------------|------------------|----------------------|---------------------|
| Outline width mode  | `_OutlineWidthMode` | `outlineWidthMode`            | `_OutlineMode`   | `_OutlineWidthMode`  | `_OutlineWidthMode` |
| Outline width       | `_OutlineWidth`     | `outlineWidthFactor`          | `_Outline_Width` | `_OutlineWidth`      | `_OutlineWidth`     |
| Outline width tex   | `_OutlineWidthTexture` | `outlineWidthMultiplyTexture` | | `_OutlineWidthMask` | `_OutlineWidthTexture` |
| Outline color       | `_OutlineColor`     | `outlineColorFactor`          | `_Outline_Color` | `_OutlineColor`      | `_OutlineColor`     |
| Outline lighting mix| `_OutlineLightingMix` | `outlineLightingMixFactor`  |                  | `_OutlineLitShadowReceive` | `_OutlineLightingMix` |

## Emission

| Semantic            | MToon 0.x        | MToon10            | SCSS             | lilToon          | Godot            |
|---------------------|------------------|--------------------|------------------|------------------|------------------|
| Emission color      | `_EmissionColor` | `emissiveFactor`   | `_EmissionColor` | `_EmissionColor` | `_EmissionColor` |
| Emission texture    | `_EmissionMap`   | `emissiveTexture`  | `_EmissionMap`   | `_EmissionMap`   | `_EmissionMap`   |
