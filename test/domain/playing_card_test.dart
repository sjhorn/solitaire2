import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/playing_card.dart';

void main() {
  group('PlayingCard', () {
    group('factory constructor', () {
      test('creates face-up card with suit and rank', () {
        final card = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.Ace);

        expect(card.suit, CardSuit.Hearts);
        expect(card.rank, CardRank.Ace);
        expect(card.faceUp, isTrue);
        expect(card.isSelected, isFalse);
      });

      test('creates face-down card when faceUp is false', () {
        final card = PlayingCard(
          suit: CardSuit.Spades,
          rank: CardRank.King,
          faceUp: false,
        );

        expect(card.suit, CardSuit.Spades);
        expect(card.rank, CardRank.King);
        expect(card.faceUp, isFalse);
        expect(card.isSelected, isFalse);
      });

      test('creates selected card when isSelected is true', () {
        final card = PlayingCard(
          suit: CardSuit.Diamonds,
          rank: CardRank.Queen,
          isSelected: true,
        );

        expect(card.suit, CardSuit.Diamonds);
        expect(card.rank, CardRank.Queen);
        expect(card.faceUp, isTrue);
        expect(card.isSelected, isTrue);
      });
    });

    group('properties', () {
      test('suit and rank are accessible', () {
        final card = PlayingCard(suit: CardSuit.Clubs, rank: CardRank.Jack);

        expect(card.suit, equals(CardSuit.Clubs));
        expect(card.rank, equals(CardRank.Jack));
      });

      test('isFaceUp defaults to true', () {
        final card = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.Ten);
        expect(card.faceUp, isTrue);
      });

      test('isSelected defaults to false', () {
        final card = PlayingCard(suit: CardSuit.Spades, rank: CardRank.Seven);
        expect(card.isSelected, isFalse);
      });

      test('isFaceUp can be set to false', () {
        final card = PlayingCard(
          suit: CardSuit.Diamonds,
          rank: CardRank.Five,
          faceUp: false,
        );
        expect(card.faceUp, isFalse);
      });
    });

    group('equality', () {
      test('two cards with same suit and rank are equal', () {
        final card1 = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.King);
        final card2 = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.King);

        expect(card1, equals(card2));
      });

      test('two cards with different suits are not equal', () {
        final card1 = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.King);
        final card2 = PlayingCard(suit: CardSuit.Spades, rank: CardRank.King);

        expect(card1, isNot(equals(card2)));
      });

      test('two cards with different ranks are not equal', () {
        final card1 = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.King);
        final card2 = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.Queen);

        expect(card1, isNot(equals(card2)));
      });
    });

    group('hashCode', () {
      test('cards with same suit and rank have same hashCode', () {
        final card1 = PlayingCard(suit: CardSuit.Clubs, rank: CardRank.Ace);
        final card2 = PlayingCard(suit: CardSuit.Clubs, rank: CardRank.Ace);

        expect(card1.hashCode, equals(card2.hashCode));
      });
    });

    group('toString', () {
      test('returns string with rank and suit symbol', () {
        final card = PlayingCard(suit: CardSuit.Hearts, rank: CardRank.Ace);

        expect(card.toString(), equals('A of ♥'));
      });

      test('returns string with rank and suit symbol for other cards', () {
        final card = PlayingCard(suit: CardSuit.Spades, rank: CardRank.King);

        expect(card.toString(), equals('K of ♠'));
      });
    });

    group('face-down cards', () {
      test('face-down cards are equal regardless of suit and rank', () {
        final card1 = PlayingCard(
          suit: CardSuit.Hearts,
          rank: CardRank.Ace,
          faceUp: false,
        );
        final card2 = PlayingCard(
          suit: CardSuit.Spades,
          rank: CardRank.King,
          faceUp: false,
        );

        expect(card1, equals(card2));
      });

      test('two face-down cards with same properties are equal', () {
        final card1 = PlayingCard(
          suit: CardSuit.Diamonds,
          rank: CardRank.Queen,
          faceUp: false,
        );
        final card2 = PlayingCard(
          suit: CardSuit.Diamonds,
          rank: CardRank.Queen,
          faceUp: false,
        );

        expect(card1, equals(card2));
      });
    });
  });
}
