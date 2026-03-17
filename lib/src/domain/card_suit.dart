/// Card suit enumeration for playing cards.
enum CardSuit {
  Spades(symbol: '♠', color: 'black'),
  Hearts(symbol: '♥', color: 'red'),
  Diamonds(symbol: '♦', color: 'red'),
  Clubs(symbol: '♣', color: 'black');

  const CardSuit({required this.symbol, required this.color});

  /// The Unicode symbol representing this suit.
  final String symbol;

  /// The display color for this suit ('red' or 'black').
  final String color;
}
