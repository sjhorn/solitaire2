/// Card rank enumeration for playing cards.
enum CardRank {
  ace(value: 1, toStringValue: 'A'),
  two(value: 2, toStringValue: '2'),
  three(value: 3, toStringValue: '3'),
  four(value: 4, toStringValue: '4'),
  five(value: 5, toStringValue: '5'),
  six(value: 6, toStringValue: '6'),
  seven(value: 7, toStringValue: '7'),
  eight(value: 8, toStringValue: '8'),
  nine(value: 9, toStringValue: '9'),
  ten(value: 10, toStringValue: '10'),
  jack(value: 11, toStringValue: 'J'),
  queen(value: 12, toStringValue: 'Q'),
  king(value: 13, toStringValue: 'K');

  const CardRank({required this.value, required this.toStringValue});

  /// The numeric value of this rank.
  final int value;

  /// The string representation for display.
  final String toStringValue;
}
