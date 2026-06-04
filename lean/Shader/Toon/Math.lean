/-!
# Toon shading math primitives

Small `Float`-valued vector/scalar helpers shared by the MToon and SCSS
models in `Shader.Toon`. Unlike `Shader.Float4` (raw IEEE bits, for the
bit-exact bytecode VM), these model the *numeric semantics* of the shading
equations, so they use Lean's `Float` directly.

No Mathlib dependency — `Float` has no decidable equality or order lemmas, so
the toon models below are **definitional** (faithful transcriptions of each
shader's math); numeric proofs would need a real-field abstraction.
-/

namespace Shader.Toon

/-- RGB (or any 3-vector). -/
structure Vec3 where
  x : Float
  y : Float
  z : Float
  deriving Repr, Inhabited

namespace Vec3

@[inline] def add (a b : Vec3) : Vec3 := ⟨a.x + b.x, a.y + b.y, a.z + b.z⟩
@[inline] def sub (a b : Vec3) : Vec3 := ⟨a.x - b.x, a.y - b.y, a.z - b.z⟩
@[inline] def mul (a b : Vec3) : Vec3 := ⟨a.x * b.x, a.y * b.y, a.z * b.z⟩
@[inline] def scale (s : Float) (a : Vec3) : Vec3 := ⟨s * a.x, s * a.y, s * a.z⟩
@[inline] def dot (a b : Vec3) : Float := a.x * b.x + a.y * b.y + a.z * b.z

instance : Add Vec3 := ⟨add⟩
instance : Sub Vec3 := ⟨sub⟩
instance : Mul Vec3 := ⟨mul⟩
instance : HMul Float Vec3 Vec3 := ⟨scale⟩

def black : Vec3 := ⟨0, 0, 0⟩
def white : Vec3 := ⟨1, 1, 1⟩

end Vec3

/-! ## Scalar helpers (the GPU intrinsics the shaders call) -/

/-- Lean's `Float` exposes no `Float.min`/`Float.max`; define them by comparison. -/
@[inline] def fmin (a b : Float) : Float := if a ≤ b then a else b
@[inline] def fmax (a b : Float) : Float := if a ≤ b then b else a

/-- `clamp x lo hi`. -/
def clampf (x lo hi : Float) : Float :=
  if x < lo then lo else if x > hi then hi else x

/-- `saturate` = `clamp _ 0 1`. -/
def saturate (x : Float) : Float := clampf x 0.0 1.0

/-- Linear interpolation. -/
def lerp (a b t : Float) : Float := a + (b - a) * t

/-- Component-wise vector lerp. -/
def lerp3 (a b : Vec3) (t : Float) : Vec3 :=
  ⟨lerp a.x b.x t, lerp a.y b.y t, lerp a.z b.z t⟩

/-- `linearstep e0 e1 x` = saturate((x - e0) / (e1 - e0)). The clamped linear
    ramp; MToon's toon factor is a `linearstep` (no Hermite smoothing). -/
def linearstep (e0 e1 x : Float) : Float :=
  saturate ((x - e0) / (e1 - e0))

/-- `smoothstep e0 e1 x` — Hermite-smoothed ramp (HLSL/GLSL `smoothstep`). -/
def smoothstep (e0 e1 x : Float) : Float :=
  let t := saturate ((x - e0) / (e1 - e0))
  t * t * (3.0 - 2.0 * t)

/-- Half-Lambert remap of n·l from [-1,1] to [0,1] (`*0.5 + 0.5`). -/
def halfLambert (ndotl : Float) : Float := ndotl * 0.5 + 0.5

end Shader.Toon
