import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/playing_card.dart';

void main() {
  group('PlayingCard', () {
    group('factory constructor', () {
      test('creates face-up card with suit and rank', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);

        expect(card.suit, CardSuit.hearts);
        expect(card.rank, CardRank.ace);
        expect(card.faceUp, isTrue);
        expect(card.isSelected, isFalse);
      });

      test('creates face-down card when faceUp is false', () {
        final card = PlayingCard(
          suit: CardSuit.spades,
          rank: CardRank.king,
          faceUp: false,
        );

        expect(card.suit, CardSuit.spades);
        expect(card.rank, CardRank.king);
        expect(card.faceUp, isFalse);
        expect(card.isSelected, isFalse);
      });

      test('creates selected card when isSelected is true', () {
        final card = PlayingCard(
          suit: CardSuit.diamonds,
          rank: CardRank.queen,
          isSelected: true,
        );

        expect(card.suit, CardSuit.diamonds);
        expect(card.rank, CardRank.queen);
        expect(card.faceUp, isTrue);
        expect(card.isSelected, isTrue);
      });
    });

    group('properties', () {
      test('suit and rank are accessible', () {
        final card = PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack);

        expect(card.suit, equals(CardSuit.clubs));
        expect(card.rank, equals(CardRank.jack));
      });

      test('isFaceUp defaults to true', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ten);
        expect(card.faceUp, isTrue);
      });

      test('isSelected defaults to false', () {
        final card = PlayingCard(suit: CardSuit.spades, rank: CardRank.seven);
        expect(card.isSelected, isFalse);
      });

      test('isFaceUp can be set to false', () {
        final card = PlayingCard(
          suit: CardSuit.diamonds,
          rank: CardRank.five,
          faceUp: false,
        );
        expect(card.faceUp, isFalse);
      });
    });

    group('equality', () {
      test('two cards with same suit and rank are equal', () {
        final card1 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);
        final card2 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);

        expect(card1, equals(card2));
      });

      test('two cards with different suits are not equal', () {
        final card1 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);
        final card2 = PlayingCard(suit: CardSuit.spades, rank: CardRank.king);

        expect(card1, isNot(equals(card2)));
      });

      test('two cards with different ranks are not equal', () {
        final card1 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);
        final card2 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.queen);

        expect(card1, isNot(equals(card2)));
      });
    });

    group('hashCode', () {
      test('cards with same suit and rank have same hashCode', () {
        final card1 = PlayingCard(suit: CardSuit.clubs, rank: CardRank.ace);
        final card2 = PlayingCard(suit: CardSuit.clubs, rank: CardRank.ace);

        expect(card1.hashCode, equals(card2.hashCode));
      });
    });

    group('toString', () {
      test('returns string with rank and suit symbol', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);

        expect(card.toString(), equals('A of ♥'));
      });

      test('returns string with rank and suit symbol for other cards', () {
        final card = PlayingCard(suit: CardSuit.spades, rank: CardRank.king);

        expect(card.toString(), equals('K of ♠'));
      });
    });

    group('face-down cards', () {
      test('face-down cards are equal regardless of suit and rank', () {
        final card1 = PlayingCard(
          suit: CardSuit.hearts,
          rank: CardRank.ace,
          faceUp: false,
        );
        final card2 = PlayingCard(
          suit: CardSuit.spades,
          rank: CardRank.king,
          faceUp: false,
        );

        expect(card1, equals(card2));
      });

      test('two face-down cards with same properties are equal', () {
        final card1 = PlayingCard(
          suit: CardSuit.diamonds,
          rank: CardRank.queen,
          faceUp: false,
        );
        final card2 = PlayingCard(
          suit: CardSuit.diamonds,
          rank: CardRank.queen,
          faceUp: false,
        );

        expect(card1, equals(card2));
      });
    });
  });
}
