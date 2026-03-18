import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/pile_type.dart';

void main() {
  group('PileType', () {
    test('has 4 values', () {
      expect(PileType.values, hasLength(4));
    });

    test('has correct value indices', () {
      expect(PileType.values.map((e) => e.index), equals([0, 1, 2, 3]));
    });

    test('foundations is index 0', () {
      expect(PileType.foundations.index, equals(0));
    });

    test('tableau is index 1', () {
      expect(PileType.tableau.index, equals(1));
    });

    test('waste is index 2', () {
      expect(PileType.waste.index, equals(2));
    });

    test('stock is index 3', () {
      expect(PileType.stock.index, equals(3));
    });

    group('fromIndex', () {
      test('returns foundations for index 0', () {
        expect(PileType.values[0], equals(PileType.foundations));
      });

      test('returns tableau for index 1', () {
        expect(PileType.values[1], equals(PileType.tableau));
      });

      test('returns waste for index 2', () {
        expect(PileType.values[2], equals(PileType.waste));
      });

      test('returns stock for index 3', () {
        expect(PileType.values[3], equals(PileType.stock));
      });
    });
  });
}
