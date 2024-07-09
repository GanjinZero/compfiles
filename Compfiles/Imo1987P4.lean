/-
Copyright (c) 2023 The Compfiles Contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Renshaw
-/

import Aesop
import Mathlib.Data.Set.Basic
import Mathlib.Data.Fintype.Card
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Tactic.Ring

import ProblemExtraction

problem_file { tags := [.Algebra] }

/-!
# International Mathematical Olympiad 1987, Problem 4

Prove that there is no function f : ℕ → ℕ such that f(f(n)) = n + 1987
for every n.
-/

namespace Imo1987P4

snip begin

noncomputable def subset_fintype {A B : Set ℕ} (h : A ⊆ B) (_hab : Fintype ↑B)
    : Fintype ↑A :=
  @Fintype.ofFinite A (Finite.Set.subset B h)

snip end

problem imo1987_p4 : ¬∃ f : ℕ → ℕ, ∀ n, f (f n) = n + 1987 := by
  -- Informal solution by Sawa Pavlov, listed at
  -- https://artofproblemsolving.com/wiki/index.php/1987_IMO_Problems/Problem_4

  -- We will prove a more general statement.
  suffices generalized : ∀ m : ℕ, ¬∃ f : ℕ → ℕ, ∀ n, f (f n) = n + (2 * m + 1) from
    generalized 993

  rintro m ⟨f, hf⟩

  -- Note that f is injective, because if f(x) = f(y),
  -- then f(f(x)) = f(f(y)), so x = y.
  have f_injective : f.Injective := by
    intro x y hxy;
    have hfx := hf x;
    rw [hxy, hf y] at hfx
    exact Nat.add_right_cancel hfx.symm

  -- Let A := ℕ - f(ℕ) and B := f(A).
  let A : Set ℕ := Set.univ \ (f '' Set.univ)
  let B : Set ℕ := f '' A

  -- A and B have union ℕ - f(f(ℕ)).
  have ab_union : A ∪ B = Set.univ \ (f '' (f '' Set.univ)) := by
    -- Note that B = f(ℕ) - f(f(ℕ)).
    have hB : B = f '' Set.univ \ f '' (f '' Set.univ) := by
      exact Set.image_diff f_injective Set.univ (f '' Set.univ)
    rw [hB]
    apply Set.eq_of_subset_of_subset
    · rintro x (hx1 | hx2) <;> aesop
    · rintro x ⟨_hx, hx'⟩
      by_cases (x ∈ A) <;> aesop

  -- ... which is {0, 1, ... , 2 * m}.
  have ab_range : A ∪ B = {n | n < 2*m + 1} := by
    apply Set.eq_of_subset_of_subset
    · rw [ab_union]
      rintro x hx
      replace hx : ∀ (y : ℕ), ¬f (f y) = x := by aesop
      rw [Set.mem_setOf_eq]
      by_contra! H
      obtain ⟨z, hz⟩ : ∃ z, x = (2 * m + 1) + z := exists_add_of_le H
      have hzz := hx z
      rw [hz, hf z, add_comm] at hzz
      exact (hzz rfl).elim
    · rw [ab_union]
      intro x hx
      aesop

  -- A and B are disjoint.
  have ab_disjoint : Disjoint A B := by
    intro _C hca hcb c hc
    exact Set.not_mem_of_mem_diff (hca hc) (Set.image_subset f sdiff_le (hcb hc))

  -- But since f is injective they have the
  -- same number of elements, which is impossible since {0, 1, ... , 2 * m}
  -- has an odd number of elements.

  have ab_fintype : Fintype ↑(A ∪ B) := by rw [ab_range]; exact inferInstance

  have h2 : Fintype.card ↑(A ∪ B) = 2 * m + 1 := by
    simp_rw [ab_range]
    rw [Fintype.card_ofFinset, Finset.card_range]

  have a_fintype := subset_fintype Set.subset_union_left ab_fintype
  rw [← @Set.toFinset_card _ (A ∪ B) ab_fintype] at h2
  rw [Set.toFinset_union] at h2

  rw [←Set.disjoint_toFinset] at ab_disjoint
  rw [Finset.card_union_of_disjoint ab_disjoint] at h2
  rw [Set.toFinset_card, Set.toFinset_card] at h2
  rw [Set.card_image_of_injective A f_injective] at h2
  omega
