# Loading
# )cs •Ex "../bqn-ws/src/math.bqn"

keyb ← "
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬─────────┐
│~ ¬ │! ⎉ │@ ⚇ │# ⍟ │$ ◶ │% ⊘ │^ ⎊ │& ⍎ │* ⍕ │( ⟨ │) ⟩ │_ √ │+ ⋆ │Backspace│
│` ˜ │1 ˘ │2 ¨ │3 ⁼ │4 ⌜ │5 ´ │6 ˝ │7   │8 ∞ │9 ¯ │0 • │- ÷ │= × │         │
├────┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬──────┤
│Tab    │Q ↙ │W 𝕎 │E ⍷ │R 𝕣 │T ⍋ │Y   │U   │I ⊑ │O ⊒ │P ⍳ │{ ⊣ │} ⊢ │|     │
│       │q ⌽ │w 𝕨 │e ∊ │r ↑ │t ∧ │y   │u ⊔ │i ⊏ │o ⊐ │p π │[ ← │] → │\     │
├───────┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴┬───┴──────┤
│Caps    │A ↖ │S 𝕊 │D   │F 𝔽 │G 𝔾 │H   │J   │K ⌾ │L   │: · │"" ˙ │Enter     │
│Lock    │a ⍉ │s 𝕤 │d ↕ │f 𝕗 │g 𝕘 │h ⊸ │j ∘ │k ○ │l ⟜ │; ⋄ │' ↩ │          │
├────────┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──────────┤
│Shift      │Z   │X 𝕏 │C   │V ⍒ │B ⌈ │N   │M ≢ │< ≤ │> ≥ │?   │Shift       │
│           │z ⥊ │x 𝕩 │c ↓ │v ∨ │b ⌊ │n   │m ≡ │, ∾ │. ≍ │/ ≠ │            │
└───────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────────────┘
                             Space: ‿
"
# Univariate Sample Statistics

⟨Mean,Stdev,Skew,Kurt⟩ ← {
    Mean  ← { (+´÷≠) 𝕩}
    _asop ← { (𝕗 +≠ 𝕩) ÷˜ +´(𝕩 - Mean 𝕩) ⋆ 𝕨    } # adjusted sum of powers
    _bar  ← { (𝕨 𝔽  𝕩) ÷    (2   𝔽    𝕩) ⋆ 𝕨 ÷ 2} #TODO rewrite using tacit fns
    Stdev ← { √ 2(¯1 _asop)      𝕩}
    Skew  ← {   3( 0 _asop) _bar 𝕩}
    Kurt  ← {   4( 0 _asop) _bar 𝕩}
    ⟨Mean,Stdev,Skew,Kurt⟩
}

# tests
#    Stdev ⟨2,3,4,6,13,2⟩
# 4.19523539268061
#    Skew ⟨2,3,4,6,13,2⟩
# 1.33525474738746
#    Kurt ⟨2,3,4,6,13,2⟩
# 3.31301652892562

# Univariate Population Statistics #TODO

# circle functions
⟨Cos,Sin⟩ ← {
    Factorial ← {×´1+↕𝕩}
    _taylor ← {+´(Factorial¨𝕗+2×𝕨)÷˜(¯1⋆𝕨)×𝕩⋆𝕗+2×𝕨}
    Cos ← { (↕𝕨) (0 _taylor) 𝕩 }
    Sin ← { (↕𝕨) (1 _taylor) 𝕩 }
    ⟨Cos,Sin⟩
}

# PRNG
# xoshiro256ss
⟨Enc,Dec,Ladd,Badd,Bmult,Prng⟩ ← {
    Enc   ← { (64⥊2) {𝕨|1↓⌊∘÷`⌾⌽𝕨∾<𝕩} 𝕩 }   # Base64 Encode
    Dec   ← { 2 {+⟜(𝕨⊸×)´⌽𝕩} 𝕩 }            # Base64 Decode
    _add  ← {𝔽(𝔽𝕨) (2|⌊∘÷⟜2⊸+`∘+) 𝔽 𝕩}      # binary adder
    Ladd  ← { 𝕨 ⊢ _add 𝕩}                   # little endian adder
    Badd  ← { 𝕨 ⌽ _add 𝕩}                   # big endian adder
    Shl   ← { (𝕨⥊0)∾˜(𝕨-≠𝕩)↑ 𝕩}             # shift left
    Bmult ← {Badd´(↕≠𝕨)Shl¨⌽(<⎉1) 𝕨×⌜𝕩}     # big endian multiply

    # usage
    # rng ← Prng Enc¨60‿120‿240‿480
    # >rng ¨↕4
    Prng ← {
        s0‿s1‿s2‿s3 ← 𝕩
        {
            result ← 3⊸Shl⊸Badd 7 ⌽ 2⊸Shl⊸Badd s1
            t ← 17 Shl s1
            s2 ≠↩ s0
            s3 ≠↩ s1
            s1 ≠↩ s2
            s0 ≠↩ s3
            s2 ≠↩ t
            s3 ↩ 45 ⌽ s3
            result⊣𝕩
        }
    }

    ⟨Enc,Dec,Ladd,Badd,Bmult,Prng⟩
}

⍎
