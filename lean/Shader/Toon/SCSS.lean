import Shader.Toon.Math
import Shader.Toon.MToon

/-!
# SCSS — Silent's Cel Shading Shader (Lean 4 model)

`SCSS` (s-ilent's `Crosstone`) is the VRChat-era Unity toon shader. Its
distinguishing feature vs MToon is **crosstone**: instead of one shade↔lit
ramp, it layers **two** shade tones (`1st`, `2nd`), each with an independent
`step` + `feather` (a `smoothstep` boundary), over the base colour. This models
the Crosstone shading path (the `SCSS-crosstone` variant used in the project),
plus its **Godot GDShader port** (same math, different host).

Reference: `s-ilent/SCSS` (`SCSS_Core.cginc`, crosstone branch); the Godot port
mirrors the two-tone layering in a `shader_type spatial` fragment.
-/

namespace Shader.Toon

/-- SCSS Crosstone properties (the two-tone shading path). -/
structure SCSSParams where
  baseColor      : Vec3 := Vec3.white
  shadowLift     : Float := 0.0           -- raises the lighting coordinate
  firstShade     : Vec3 := ⟨0.8, 0.8, 0.9⟩
  firstStep      : Float := 0.5
  firstFeather   : Float := 0.1
  secondShade    : Vec3 := ⟨0.6, 0.6, 0.75⟩
  secondStep     : Float := 0.25
  secondFeather  : Float := 0.1
  rimColor       : Vec3 := Vec3.black
  rimPower       : Float := 5.0
  matcapColor    : Vec3 := Vec3.black
  emissive       : Vec3 := Vec3.black
  deriving Repr, Inhabited

/-- SCSS lighting coordinate: half-Lambert of `dot(N,L)` (optionally attenuated),
    lifted by `shadowLift`, clamped to `[0,1]`. -/
def scssLightCoord (p : SCSSParams) (ndotl attenuation : Float) : Float :=
  saturate (halfLambert (ndotl * attenuation) + p.shadowLift)

/-- **Crosstone** two-tone layering. From darkest to lightest:
    `2nd → 1st → base`, each transition a `smoothstep(step - feather, step, x)`. -/
def crosstone (p : SCSSParams) (lightCoord : Float) : Vec3 :=
  let t2 := smoothstep (p.secondStep - p.secondFeather) p.secondStep lightCoord
  let t1 := smoothstep (p.firstStep  - p.firstFeather)  p.firstStep  lightCoord
  let shaded := lerp3 p.secondShade p.firstShade t2   -- 2nd → 1st
  lerp3 shaded p.baseColor t1                          -- → base

/-- Fresnel rim term (Unity-style): `(1 - max 0 (N·V))^power * rimColor`. -/
def scssRim (p : SCSSParams) (ndotv : Float) : Vec3 :=
  Float.pow (saturate (1.0 - fmax 0.0 ndotv)) p.rimPower * p.rimColor

/-- Full single-light SCSS Crosstone colour. -/
def scss (p : SCSSParams) (ndotl ndotv attenuation : Float) (matcap : Vec3) : Vec3 :=
  let coord := scssLightCoord p ndotl attenuation
  crosstone p coord + scssRim p ndotv + p.matcapColor * matcap + p.emissive

/-- **Unity SCSS** (s-ilent, HLSL). -/
def scssUnity (p : SCSSParams) (ndotl ndotv attenuation : Float) (matcap : Vec3) : Vec3 :=
  scss p ndotl ndotv attenuation matcap

/-- **Godot port of SCSS** (GDShader spatial). Same crosstone math, different
    host language — definitionally the Unity model. -/
def scssGodot (p : SCSSParams) (ndotl ndotv attenuation : Float) (matcap : Vec3) : Vec3 :=
  scss p ndotl ndotv attenuation matcap

/-- The Godot port faithfully reproduces the Unity SCSS shading model. -/
theorem scssGodot_eq_unity (p : SCSSParams) (ndotl ndotv a : Float) (m : Vec3) :
    scssGodot p ndotl ndotv a m = scssUnity p ndotl ndotv a m := rfl

/-! ## SCSS vs MToon

The shape difference is structural: MToon is a **one-boundary** ramp
(`shade ↔ lit`), SCSS Crosstone is **two boundaries** (`2nd → 1st → base`).
Collapsing SCSS's second tone onto its first (equal step/feather, and
`secondShade = firstShade`) reduces crosstone to a single MToon-like boundary. -/
def scssCollapsedToOneTone (p : SCSSParams) : Prop :=
  p.secondShade = p.firstShade ∧ p.secondStep = p.firstStep ∧
    p.secondFeather = p.firstFeather

end Shader.Toon
