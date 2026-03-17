import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_suit.dart';

void main() {
  group('CardSuit', () {
    test('has correct suits with values', () {
      expect(CardSuit.values, hasLength(4));
      expect(CardSuit.values.map((e) => e.index), equals([0, 1, 2, 3]));
    });

    test('Spades returns correct symbol and color', () {
      expect(CardSuit.Spades.symbol, '♠');
      expect(CardSuit.Spades.color, 'black');
    });

    test('Hearts returns correct symbol and color', () {
      expect(CardSuit.Hearts.symbol, '♥');
      expect(CardSuit.Hearts.color, 'red');
    });

    test('Diamonds returns correct symbol and color', () {
      expect(CardSuit.Diamonds.symbol, '♦');
      expect(CardSuit.Diamonds.color, 'red');
    });

    test('Clubs returns correct symbol and color', () {
      expect(CardSuit.Clubs.symbol, '♣');
      expect(CardSuit.Clubs.color, 'black');
    });
  });
}
