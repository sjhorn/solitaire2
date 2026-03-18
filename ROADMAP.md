# 🃏 Flutter Solitaire — Implementation Roadmap

A phased plan for building a fully-featured Klondike Solitaire game in Flutter with drag-and-drop, rich card visuals, and polished UX.

---

## Phase 1 — Project Scaffold & Architecture

**Goal:** Establish a clean, scalable foundation before writing any game logic.

- [ ] Define the folder structure:
  ```
  lib/
  ├── models/        # Card, Deck, Pile, GameState
  ├── providers/     # State / logic layer
  ├── widgets/       # CardWidget, PileWidget, BoardWidget
  ├── utils/         # Constants, helpers
  └── main.dart
  ```
- [ ] Add dependencies to `pubspec.yaml`:
  - `collection` (for list utilities)
  - `audioplayers` (for sound effects, later)
- [ ] Set up `CardSuit` and `CardRank` enums
- [ ] Create the core `PlayingCard` model (suit, rank, isFaceUp, isSelected)

---

## Phase 2 — Game Logic & Data Models

**Goal:** Implement the complete rules of Klondike Solitaire in pure Dart, fully testable with no UI dependency.

- [ ] **Deck model** — 52-card deck, shuffle logic
- [ ] **Pile types:**
  - `StockPile` — the draw pile (top-left)
  - `WastePile` — drawn cards (next to stock)
  - `FoundationPile` × 4 — Ace → King per suit (top-right)
  - `TableauPile` × 7 — alternating color, descending rank
- [ ] **Deal logic** — distribute cards correctly at game start (1–7 cards per tableau, top card face-up)
- [ ] **Move validation rules:**
  - Tableau: alternating color, rank n–1
  - Foundation: same suit, ascending from Ace
  - Stock → Waste: flip 1 or 3 cards (configurable)
  - Waste → Stock: recycle when stock is empty
- [ ] **Move execution** — immutable state updates (move returns new `GameState`)
- [ ] **Win detection** — all 52 cards on foundations
- [ ] **Undo stack** — save snapshots of `GameState` for undo support
- [ ] **Auto-complete** — detect when all cards are face-up and move to foundations automatically
- [ ] Unit tests for all move rules and edge cases

---

## Phase 3 — Card Visuals

**Goal:** Design beautiful, recognizable playing cards rendered entirely in Flutter (no image assets required).

- [ ] **`CardWidget`** — a `StatelessWidget` accepting a `PlayingCard`
  - Rounded rectangle with white background and subtle shadow
  - Top-left and bottom-right rank + suit labels
  - Large centered suit symbol for face cards or pip layout for number cards
- [ ] **Suit symbols** — render using Unicode characters (♠ ♥ ♦ ♣) with correct colors (red / black)
- [ ] **Pip layout** — accurate pip arrangements for 2–10 (e.g. 3-of-hearts has 3 hearts in the right positions)
- [ ] **Face cards (J, Q, K)** — stylized letter + suit symbol in contrasting color block; or optionally use SVG assets
- [ ] **Card back design** — decorative repeating pattern (e.g. diagonal hatching or club/diamond tile) using `CustomPainter`
- [ ] **Face-down card** — show back design; face-up card shows rank/suit
- [ ] **Empty pile placeholder** — outlined rounded rectangle with faint suit icon
- [ ] **Selected / dragging state** — slight scale-up + elevation shadow to indicate a card is lifted
- [ ] **Responsive card sizing** — cards scale to screen width so the game fits phones and tablets

---

## Phase 4 — Board Layout

**Goal:** Lay out all piles correctly and responsively on screen.

- [ ] **`BoardWidget`** — top-level layout using `Stack` or `Column` + `Row`
- [ ] **Top row:** Stock | Waste | (gap) | Foundation × 4
- [ ] **Tableau row:** 7 overlapping `TableauPileWidget` columns
- [ ] **`TableauPileWidget`** — vertically stacked cards with a fixed overlap offset (e.g. 30 px per card, more if face-up)
- [ ] **`FoundationPileWidget`** — single card shown (or placeholder)
- [ ] **`StockPileWidget`** — tappable stack; fan-offset for 3-card draw mode
- [ ] **`WastePileWidget`** — shows top 1 or 3 cards fanned
- [ ] Ensure layout uses `LayoutBuilder` for different screen sizes
- [ ] Landscape and portrait orientations handled gracefully

---

## Phase 5 — Drag & Drop Interaction

**Goal:** Implement smooth, intuitive card dragging with valid drop-target highlighting.

- [ ] Wrap draggable cards with Flutter's `Draggable<List<PlayingCard>>`
  - Drag data is a list (single card or a stack of cards)
  - `feedback` widget: lifted card(s) with shadow, slightly larger than normal
  - `childWhenDragging`: faded/ghost placeholder in original position
- [ ] Wrap target piles with `DragTarget<List<PlayingCard>>`
  - `onWillAccept`: call move validator — returns `true`/`false`
  - `onAccept`: dispatch move to game state provider
- [ ] **Visual drop-target feedback:**
  - Valid target: green highlight border on pile
  - Invalid target: red tint or no highlight (reject silently)
- [ ] **Multi-card drag** — dragging a face-up stack from a tableau pile drags all cards below it together; render as a fanned vertical stack in the feedback widget
- [ ] **Tap-to-move shortcut:**
  - Tap a waste card → auto-move to valid tableau or foundation if possible
  - Tap a tableau card → auto-move to foundation if valid
  - Tap stock → draw card(s)
- [ ] **Tap stock** — flip 1 or 3 cards from stock to waste
- [ ] Snap-back animation when a drop is rejected (card flies back to origin)
- [ ] Drag threshold (minimum drag distance before drag starts, to prevent accidental drags)

---

## Phase 6 — Animations & Polish

**Goal:** Add animations that make the game feel alive and satisfying.

- [ ] **Card flip animation** — `AnimatedSwitcher` or `TweenAnimationBuilder` rotating on Y-axis (3D perspective flip) when a card is revealed
- [ ] **Card move animation** — `AnimatedPositioned` / `Hero` widget slides a card from source pile to destination
- [ ] **Deal animation** — cards fan out to tableau positions one by one on game start
- [ ] **Win celebration** — classic cascading cards bouncing off the screen (custom `CustomPainter` + `AnimationController`)
- [ ] **Undo animation** — card slides back to its previous position
- [ ] **Auto-complete animation** — cards fly to foundations one by one in sequence
- [ ] Smooth 60 fps — profile with Flutter DevTools; avoid `setState` in hot paths
- [ ] `AnimationController` cleanup — dispose all controllers properly

---

## Phase 7 — Scoring & Game Options

**Goal:** Add replayability and customisation.

- [ ] **Scoring system** (Standard Vegas or classic Windows rules):
  - +10 pts: waste → tableau
  - +10 pts: tableau → foundation
  - +5 pts: turning over a tableau card
  - –2 pts/10s: time penalty (timed mode)
- [ ] **Timer** — optional countdown or elapsed-time display
- [ ] **Move counter** — show number of moves taken
- [ ] **Settings screen:**
  - Draw 1 vs Draw 3
  - Timed mode on/off
  - Scoring mode
  - Card back design selector
  - Sound on/off
- [ ] **New game / restart** button
- [ ] **Undo button** (with move counter penalty in Vegas mode)
- [ ] **Hint system** — highlight a valid move if the player is stuck (tap 💡)
- [ ] Persist high scores and best times with `shared_preferences`

---

## Phase 8 — Audio & Haptics

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

## Phase 9 — Accessibility & QA

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

## Phase 10 — Release Preparation

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

| Milestone | Phases | Deliverable |
|---|---|---|
| **M1 — Playable prototype** | 1–4 | Tappable game with no drag, correct rules |
| **M2 — Interactive MVP** | 5 | Full drag & drop, playable end-to-end |
| **M3 — Polished beta** | 6–8 | Animations, audio, scoring, settings |
| **M4 — Release candidate** | 9–10 | Tested, accessible, store-ready |

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