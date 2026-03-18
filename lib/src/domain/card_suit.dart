/// Card suit enumeration for playing cards.
enum CardSuit {
  spades(symbol: '♠', color: 'black'),
  hearts(symbol: '♥', color: 'red'),
  diamonds(symbol: '♦', color: 'red'),
  clubs(symbol: '♣', color: 'black');

  const CardSuit({required this.symbol, required this.color});

  /// The Unicode symbol representing this suit.
  final String symbol;

  /// The display color for this suit ('red' or 'black').
  final String color;
}
