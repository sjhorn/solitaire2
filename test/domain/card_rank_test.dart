import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';

void main() {
  group('CardRank', () {
    test('has correct number of ranks', () {
      expect(CardRank.values, hasLength(13));
    });

    test('Ace has value 1 and string "A"', () {
      expect(CardRank.ace.value, 1);
      expect(CardRank.ace.toStringValue, 'A');
    });

    test('2-9 have correct values and string representations', () {
      expect(CardRank.two.value, 2);
      expect(CardRank.two.toStringValue, '2');
      expect(CardRank.nine.value, 9);
      expect(CardRank.nine.toStringValue, '9');
    });

    test('10 has value 10 and string "10"', () {
      expect(CardRank.ten.value, 10);
      expect(CardRank.ten.toStringValue, '10');
    });

    test('Jack has value 11 and string "J"', () {
      expect(CardRank.jack.value, 11);
      expect(CardRank.jack.toStringValue, 'J');
    });

    test('Queen has value 12 and string "Q"', () {
      expect(CardRank.queen.value, 12);
      expect(CardRank.queen.toStringValue, 'Q');
    });

    test('King has value 13 and string "K"', () {
      expect(CardRank.king.value, 13);
      expect(CardRank.king.toStringValue, 'K');
    });

    test('values are in ascending order', () {
      final values = CardRank.values.map((r) => r.value).toList();
      expect(values, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]));
    });
  });
}
