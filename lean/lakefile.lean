import Lake
open Lake DSL

-- Toon-shader source for godot-toon-shaders. The Lean specs in Shader/Toon are
-- the canonical shader definitions; the Lean -> Slang -> GLSL pipeline (slangc)
-- emits the Godot .gdshader. Copied from V-Sekai/materialx-shaders-lean
-- (Shader/Toon/{Math,MToon,SCSS}.lean) — still placeholder specs to complete.

package «godot-toon-shaders» where
  leanOptions := #[⟨`autoImplicit, false⟩]

@[default_target]
lean_lib «ToonShader» where
  srcDir := "."
  globs  := #[.andSubmodules `Shader]
