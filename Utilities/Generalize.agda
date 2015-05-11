module HMTS.Utilities.Generalize where

open import Level
open import Function
open import Relation.Nullary.Decidable
open import Data.Bool
open import Data.Nat  as Nat
open import Data.Maybe
open import Data.Product
open import Data.List as List

open import HMTS.Utilities.Prelude
open import HMTS.Data.Type
open import HMTS.Data.Term

Subst : Set
Subst = List (ℕ × Type)

apply : Subst -> Type -> Type
apply Ψ (Var i) = maybe′ id (Var i) (lookup-for i Ψ)
apply Ψ (σ ⇒ τ) = apply Ψ σ ⇒ apply Ψ τ

specialize-var : ∀ {Γ σ Ψ} -> σ ∈ Γ -> apply Ψ σ ∈ List.map (apply Ψ) Γ
specialize-var  vz    = vz
specialize-var (vs v) = vs (specialize-var v)

specialize : ∀ {Γ σ Ψ} -> Γ ⊢ σ -> List.map (apply Ψ) Γ ⊢ apply Ψ σ
specialize (var v) = var (specialize-var v)
specialize (ƛ b)   = ƛ (specialize b)
specialize (f ∙ x) = specialize f ∙ specialize x

Generalizeᶜ : ∀ {γ α β} {A : Set α} {B : Set β}
            -> List A -> (List (A × B) -> Set (β Level.⊔ γ)) -> Set (β Level.⊔ γ)
Generalizeᶜ      []      C = C []
Generalizeᶜ {γ} (x ∷ xs) C = ∀ {y} -> Generalizeᶜ {γ} xs (C ∘ _∷_ (x , y))

generalizeᶜ : ∀ {Γ σ} {c : Subst -> Subst} is
            -> Γ ⊢ σ -> Generalizeᶜ is λ Ψ ->
                 let Φ = c Ψ in List.map (apply Φ) Γ ⊢ apply Φ σ
generalizeᶜ  []      e = specialize e
generalizeᶜ (i ∷ is) e = generalizeᶜ is e

generalize : ∀ {Γ σ}
           -> Γ ⊢ σ -> Generalizeᶜ (ftv σ) λ Ψ -> List.map (apply Ψ) Γ ⊢ apply Ψ σ
generalize {σ = σ} = generalizeᶜ (ftv σ)
