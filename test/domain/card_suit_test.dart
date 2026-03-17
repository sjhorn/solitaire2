import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_suit.dart';

void main() {
  group('CardSuit', () {
    test('has correct suits with values', () {
      expect(CardSuit.values, hasLength(4));
      expect(CardSuit.values.map((e) => e.index), equals([0, 1, 2, 3]));
    });

    test('spades returns correct symbol and color', () {
      expect(CardSuit.spades.symbol, '♠');
      expect(CardSuit.spades.color, 'black');
    });

    test('hearts returns correct symbol and color', () {
      expect(CardSuit.hearts.symbol, '♥');
      expect(CardSuit.hearts.color, 'red');
    });

    test('diamonds returns correct symbol and color', () {
      expect(CardSuit.diamonds.symbol, '♦');
      expect(CardSuit.diamonds.color, 'red');
    });

    test('clubs returns correct symbol and color', () {
      expect(CardSuit.clubs.symbol, '♣');
      expect(CardSuit.clubs.color, 'black');
    });
  });
}
