import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';

void main() {
  group('CardRank', () {
    test('has correct number of ranks', () {
      expect(CardRank.values, hasLength(13));
    });

    test('Ace has value 1 and string "A"', () {
      expect(CardRank.Ace.value, 1);
      expect(CardRank.Ace.toStringValue, 'A');
    });

    test('2-9 have correct values and string representations', () {
      expect(CardRank.Two.value, 2);
      expect(CardRank.Two.toStringValue, '2');
      expect(CardRank.Nine.value, 9);
      expect(CardRank.Nine.toStringValue, '9');
    });

    test('10 has value 10 and string "10"', () {
      expect(CardRank.Ten.value, 10);
      expect(CardRank.Ten.toStringValue, '10');
    });

    test('Jack has value 11 and string "J"', () {
      expect(CardRank.Jack.value, 11);
      expect(CardRank.Jack.toStringValue, 'J');
    });

    test('Queen has value 12 and string "Q"', () {
      expect(CardRank.Queen.value, 12);
      expect(CardRank.Queen.toStringValue, 'Q');
    });

    test('King has value 13 and string "K"', () {
      expect(CardRank.King.value, 13);
      expect(CardRank.King.toStringValue, 'K');
    });

    test('values are in ascending order', () {
      final values = CardRank.values.map((r) => r.value).toList();
      expect(values, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]));
    });
  });
}
