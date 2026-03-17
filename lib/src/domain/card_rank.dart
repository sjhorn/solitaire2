/// Card rank enumeration for playing cards.
enum CardRank {
  Ace(value: 1, toStringValue: 'A'),
  Two(value: 2, toStringValue: '2'),
  Three(value: 3, toStringValue: '3'),
  Four(value: 4, toStringValue: '4'),
  Five(value: 5, toStringValue: '5'),
  Six(value: 6, toStringValue: '6'),
  Seven(value: 7, toStringValue: '7'),
  Eight(value: 8, toStringValue: '8'),
  Nine(value: 9, toStringValue: '9'),
  Ten(value: 10, toStringValue: '10'),
  Jack(value: 11, toStringValue: 'J'),
  Queen(value: 12, toStringValue: 'Q'),
  King(value: 13, toStringValue: 'K');

  const CardRank({required this.value, required this.toStringValue});

  /// The numeric value of this rank.
  final int value;

  /// The string representation for display.
  final String toStringValue;
}
