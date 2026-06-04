import Shader.Toon.Math

/-!
# MToon — Lean 4 model

`MToon` is VRM's toon material. This formalises its **shading ramp** and the
core shade↔lit mix, then instantiates the three implementations the V-Sekai
pipeline cares about:

* **UniVRM**   — the reference VRM 1.0 implementation (`VRMC_materials_mtoon`).
* **three-vrm** — pixiv's three.js port; tracks the VRM 1.0 spec.
* **godot-vrm** — the Godot addon's GDShader; ported from the **legacy MToon
  0.x** math (half-Lambert + `smoothstep`) which predates the 1.0 `linearstep`
  reformulation — a genuine, observable difference (`rampV0` vs `rampV1`).

The ramp is the heart of MToon; everything else (rim, matcap, emission,
outline) is additive/compositing and modelled as records + functions.
References: `VRMC_materials_mtoon` glTF extension; UniVRM `MToon`; three-vrm
`mtoon.frag`; godot's `vrm/shaders/MToon.gdshader`.
-/

namespace Shader.Toon

/-- Outline width is computed in one of three spaces (VRM 1.0). -/
inductive OutlineWidthMode
  | none
  | worldCoordinates
  | screenCoordinates
  deriving Repr, DecidableEq, Inhabited

/-- The VRM 1.0 MToon property set (`VRMC_materials_mtoon`). Factors only —
    textures are modelled as their sampled scalar/colour contribution where a
    ramp needs them. -/
structure MToonParams where
  litColorFactor            : Vec3 := Vec3.white
  shadeColorFactor          : Vec3 := ⟨0.97, 0.81, 0.86⟩
  shadingShiftFactor        : Float := 0.0       -- ∈ [-1, 1]
  shadingToonyFactor        : Float := 0.9        -- ∈ [0, 1]
  giEqualizationFactor      : Float := 0.9
  rimColorFactor            : Vec3 := Vec3.black
  rimLightingMixFactor      : Float := 1.0
  parametricRimColorFactor  : Vec3 := Vec3.black
  parametricRimFresnelPower : Float := 5.0
  parametricRimLiftFactor   : Float := 0.0
  matcapFactor              : Vec3 := Vec3.black
  emissiveFactor            : Vec3 := Vec3.black
  outlineWidthMode          : OutlineWidthMode := .none
  outlineWidthFactor        : Float := 0.0
  outlineColorFactor        : Vec3 := Vec3.black
  outlineLightingMixFactor  : Float := 1.0
  deriving Repr, Inhabited

/-! ## The shading ramp -/

/-- **MToon 1.0 ramp** (UniVRM 1.x, three-vrm). Raw `dot(N,L)` plus the shading
    shift, mapped through a `linearstep` whose edges are pulled in by the toony
    factor: `toony = 1` ⇒ hard step at 0, `toony = 0` ⇒ fully smooth ramp.

    `getShading(dotNL) = linearstep(-1 + toony, 1 - toony, dotNL + shift)`. -/
def rampV1 (shadingShift shadingToony dotNL : Float) : Float :=
  linearstep (-1.0 + shadingToony) (1.0 - shadingToony) (dotNL + shadingShift)

/-- **Legacy MToon 0.x ramp** (godot-vrm's port). Half-Lambert remap of `dot(N,L)`
    into `[0,1]`, then a `smoothstep` toon boundary centred on the shift with a
    width set by toony. This is the pre-1.0 formulation. -/
def rampV0 (shadeShift shadeToony dotNL : Float) : Float :=
  let li := halfLambert dotNL
  -- boundary at (0.5 + shadeShift), softened by (1 - shadeToony)
  let e0 := saturate (0.5 + shadeShift - (1.0 - shadeToony) * 0.5)
  let e1 := saturate (0.5 + shadeShift + (1.0 - shadeToony) * 0.5)
  smoothstep e0 e1 li

/-! ## Core shading -/

/-- Base colour after the toon ramp: `lerp(shade, lit, toon)`. -/
def toonBase (p : MToonParams) (toon : Float) : Vec3 :=
  lerp3 p.shadeColorFactor p.litColorFactor toon

/-- Parametric rim term: `(saturate(lift + 1 - max(0, N·V)))^power * rimColor`. -/
def parametricRim (p : MToonParams) (ndotv : Float) : Vec3 :=
  let f := saturate (p.parametricRimLiftFactor + 1.0 - fmax 0.0 ndotv)
  let fp := Float.pow f p.parametricRimFresnelPower
  fp * p.parametricRimColorFactor

/-- Full single-light MToon colour for a chosen ramp. `ndotl`/`ndotv` are the
    light/view cosines; `matcapSample` is the matcap texel. -/
def shade (ramp : Float → Float → Float → Float)
    (p : MToonParams) (ndotl ndotv : Float) (matcapSample : Vec3) : Vec3 :=
  let toon := ramp p.shadingShiftFactor p.shadingToonyFactor ndotl
  let base := toonBase p toon
  let rim  := parametricRim p ndotv
  let mat  := p.matcapFactor * matcapSample
  base + rim + mat + p.emissiveFactor

/-! ## The three implementations -/

/-- UniVRM (reference VRM 1.0): the spec ramp. -/
def uniVRM (p : MToonParams) (ndotl ndotv : Float) (matcap : Vec3) : Vec3 :=
  shade rampV1 p ndotl ndotv matcap

/-- three-vrm (pixiv, three.js): tracks the VRM 1.0 spec — same ramp as UniVRM. -/
def threeVRM (p : MToonParams) (ndotl ndotv : Float) (matcap : Vec3) : Vec3 :=
  shade rampV1 p ndotl ndotv matcap

/-- godot-vrm (Godot GDShader): legacy 0.x ramp (half-Lambert + smoothstep). -/
def godotVRM (p : MToonParams) (ndotl ndotv : Float) (matcap : Vec3) : Vec3 :=
  shade rampV0 p ndotl ndotv matcap

/-- UniVRM and three-vrm are definitionally the same material model: both are
    the VRM 1.0 spec ramp. (The remaining differences are colour-space and GI
    integration, outside the per-fragment ramp modelled here.) -/
theorem uniVRM_eq_threeVRM (p : MToonParams) (ndotl ndotv : Float) (m : Vec3) :
    uniVRM p ndotl ndotv m = threeVRM p ndotl ndotv m := rfl

end Shader.Toon
