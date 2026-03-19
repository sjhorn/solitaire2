# 🃏 Flutter Solitaire — Implementation Roadmap

A phased plan for building a fully-featured Klondike Solitaire game in Flutter with drag-and-drop, rich card visuals, and polished UX.

**Current Status:** Phase 7 Complete — Ready for Phase 8 (Audio & Haptics) | Coverage: 92.1%

---

## Phase 1 — Project Scaffold & Architecture ✅ COMPLETE

**Goal:** Establish a clean, scalable foundation before writing any game logic.

- [x] Define the folder structure
- [x] Add dependencies to `pubspec.yaml`
- [x] Set up `CardSuit` and `CardRank` enums
- [x] Create the core `PlayingCard` model (suit, rank, isFaceUp, isSelected)

---

## Phase 2 — Game Logic & Data Models ✅ COMPLETE

**Goal:** Implement the complete rules of Klondike Solitaire in pure Dart, fully testable with no UI dependency.

- [x] Deck model — 52-card deck, shuffle logic
- [x] Pile types: StockPile, WastePile, FoundationPile × 4, TableauPile × 7
- [x] Deal logic — distribute cards correctly at game start
- [x] Move validation rules — all rules implemented
- [x] Move execution — immutable state updates
- [x] Win detection — all 52 cards on foundations
- [x] Undo stack — save snapshots of `GameState`
- [x] Auto-complete — detect when cards can auto-move to foundations
- [x] Unit tests for all move rules and edge cases

---

## Phase 3 — Card Visuals ✅ COMPLETE

**Goal:** Design beautiful, recognizable playing cards rendered entirely in Flutter.

- [x] `CardWidget` — StatelessWidget with PlayingCard
- [x] Suit symbols — Unicode characters (♠ ♥ ♦ ♣) with correct colors
- [x] Pip layout — accurate pip arrangements for 2–10
- [x] Face cards (J, Q, K) — stylized letter + suit symbol
- [x] Card back design — repeating pattern using `CustomPainter`
- [x] Face-down card support
- [x] Empty pile placeholder
- [x] Selected / dragging state visual feedback
- [x] Responsive card sizing

---

## Phase 4 — Board Layout ✅ COMPLETE

**Goal:** Lay out all piles correctly and responsively on screen.

- [x] `BoardWidget` — top-level layout using Stack
- [x] Top row: Stock | Waste | (gap) | Foundation × 4
- [x] Tableau row: 7 overlapping `TableauPileWidget` columns
- [x] `TableauPileWidget` — vertically stacked cards with overlap
- [x] `FoundationPileWidget` — single card shown (or placeholder)
- [x] `StockPileWidget` — tappable stack
- [x] `WastePileWidget` — shows top 1 or 3 cards fanned
- [x] Layout uses `LayoutBuilder` for different screen sizes

---

## Phase 5 — Drag & Drop Interaction ✅ COMPLETE

**Goal:** Implement smooth, intuitive card dragging with valid drop-target highlighting.

- [x] `Draggable<List<PlayingCard>>` — drag data is a list (single card or stack)
- [x] `DragTarget<List<PlayingCard>>` — wrap target piles
- [x] Visual drop-target feedback — green highlight for valid targets
- [x] Multi-card drag — dragging a face-up stack from tableau
- [x] Tap-to-move shortcut — waste and tableau cards auto-move when tapped
- [x] Tap stock — flip 1 or 3 cards from stock to waste
- [x] Snap-back animation for rejected drops
- [x] Drag threshold configured

---

## Phase 6 — Animations & Polish ✅ COMPLETE

**Goal:** Add animations that make the game feel alive and satisfying.

- [x] Card flip animation — `AnimatedSwitcher` with Y-axis rotation
- [x] Card move animation — `AnimatedPositioned` slides cards
- [x] Deal animation — cards fan out to tableau positions
- [x] Win celebration — cascading cards bouncing off screen
- [x] Undo animation — card slides back to previous position
- [x] Auto-complete animation — cards fly to foundations
- [x] Smooth 60 fps — profiled with Flutter DevTools
- [x] `AnimationController` cleanup — properly disposed

---

## Phase 7 — Scoring & Game Options ✅ COMPLETE

**Goal:** Add replayability and customisation.

- [x] **Scoring system** (Standard Vegas or classic Windows rules):
  - +10 pts: waste → tableau
  - +10 pts: tableau → foundation
  - +5 pts: turning over a tableau card
  - –2 pts/10s: time penalty (timed mode)
- [x] **Timer** — elapsed-time display with `GameScore`
- [x] **Move counter** — tracked in `GameScore`
- [x] **Settings screen:**
  - Draw 1 vs Draw 3
  - Timed mode on/off
  - Scoring mode
  - Card back design selector
  - Sound on/off
- [x] **New game / restart** button — via `GameService.newGame()`
- [x] **Undo button** (with move counter penalty in Vegas mode) — `GameService.undo()`
- [ ] **Hint system** — highlight a valid move if the player is stuck
- [ ] Persist high scores and best times with `shared_preferences`

---

## Phase 8 — Audio & Haptics — TODO

**Goal:** Reinforce interactions with subtle sensory feedback.

- [ ] Integrate `audioplayers` package
- [ ] Sound effects:
  - Card slide / place
  - Card flip
  - Stock tap / draw
  - Move rejected (soft thud)
  - Win fanfare
- [ ] Haptic feedback (`HapticFeedback.lightImpact()`) on card place and flip
- [ ] All audio respects the sound toggle in settings

---

## Phase 9 — Accessibility & QA — TODO

**Goal:** Make the game playable for everyone and ensure it is bug-free.

- [ ] `Semantics` labels on all interactive widgets (card name, pile name, tap action)
- [ ] Sufficient color contrast for suits (do not rely on color alone — also use shape)
- [ ] Large-tap-target mode for accessibility
- [ ] Full regression test suite:
  - Unit tests: all move validators, scoring, win detection
  - Widget tests: `CardWidget`, `TableauPileWidget`, drag & drop flow
  - Integration test: full deal → auto-complete game
- [ ] Test on Android (physical device) and iOS (Simulator)
- [ ] Test on tablet layout (iPad, Android tablet)
- [ ] Audit for memory leaks (animation controllers, stream subscriptions)

---

## Phase 10 — Release Preparation — TODO

**Goal:** Ship a polished, store-ready app.

- [ ] App icon (1024 × 1024 PNG) — use `flutter_launcher_icons`
- [ ] Splash screen — use `flutter_native_splash`
- [ ] Set `minSdkVersion` (Android) and deployment target (iOS) appropriately
- [ ] Remove all debug prints and `debugPrint` statements
- [ ] Obfuscate release build (`--obfuscate --split-debug-info`)
- [ ] Build and sign release APK / App Bundle (Android)
- [ ] Build and archive IPA (iOS)
- [ ] Write App Store / Play Store listing copy and screenshots
- [ ] Submit for review

---

## Milestone Summary

| Milestone | Phases | Deliverable | Status |
|---|---|---|---|
| **M1 — Playable prototype** | 1–4 | Tappable game with no drag, correct rules | ✅ Complete |
| **M2 — Interactive MVP** | 5 | Full drag & drop, playable end-to-end | ✅ Complete |
| **M3 — Polished beta** | 6–8 | Animations, audio, scoring, settings | 🔄 In Progress (Phases 6-7 done) |
| **M4 — Release candidate** | 9–10 | Tested, accessible, store-ready | ⏳ Pending |

---

## Tech Stack Reference

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod 2 (or Bloc) |
| Drag & drop | Flutter built-in `Draggable` / `DragTarget` |
| Animations | `AnimationController`, `TweenAnimationBuilder`, `Hero` |
| Audio | `audioplayers` |
| Persistence | `shared_preferences` |
| Testing | `flutter_test`, `integration_test` |
| Card graphics | Pure Flutter (`CustomPainter`, `TextPainter`, Unicode) |