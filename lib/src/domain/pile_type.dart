/// Types of piles in Klondike Solitaire.
enum PileType {
  /// Foundation piles - where cards are built up by suit (4 piles).
  foundations,

  /// Tableau piles - where cards are built down by rank alternating colors (7 piles).
  tableau,

  /// Waste pile - where drawn cards go.
  waste,

  /// Stock pile - the draw pile.
  stock,
}
