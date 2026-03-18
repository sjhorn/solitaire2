import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/game_pile.dart';
import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';

void main() {
  group('GamePile', () {
    late GamePile pile;

    setUp(() {
      pile = GamePile(type: PileType.tableau);
    });

    group('constructor', () {
      test('creates empty pile', () {
        expect(pile.cards, isEmpty);
        expect(pile.topCards, isEmpty);
        expect(pile.isEmpty, isTrue);
        expect(pile.isNotEmpty, isFalse);
      });

      test('has correct pile type', () {
        expect(pile.type, equals(PileType.tableau));
      });
    });

    group('topCard getter', () {
      test('returns null when pile is empty', () {
        expect(pile.topCard, isNull);
      });

      test('returns top card when pile has cards', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
        pile.addCard(card);

        expect(pile.topCard, equals(card));
      });
    });

    group('topCardThrow getter', () {
      test('throws StateError when pile is empty', () {
        expect(() => pile.topCardThrow, throwsStateError);
      });

      test('returns top card when pile has cards', () {
        final card = PlayingCard(suit: CardSuit.spades, rank: CardRank.king);
        pile.addCard(card);

        expect(pile.topCardThrow, equals(card));
      });
    });

    group('addCard', () {
      test('adds single card to pile', () {
        final card = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.two);
        pile.addCard(card);

        expect(pile.cards, hasLength(1));
        expect(pile.topCardThrow, equals(card));
      });
    });

    group('addCards', () {
      test('adds multiple cards to pile', () {
        final cards = [
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.two),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.three),
        ];
        pile.addCards(cards);

        expect(pile.cards, hasLength(3));
        expect(pile.topCardThrow, equals(cards.last));
      });
    });

    group('removeTopCard', () {
      test('throws StateError when pile is empty', () {
        expect(() => pile.removeTopCard(), throwsStateError);
      });

      test('removes and returns top card', () {
        final card1 = PlayingCard(suit: CardSuit.clubs, rank: CardRank.ace);
        final card2 = PlayingCard(suit: CardSuit.clubs, rank: CardRank.two);
        pile.addCard(card1);
        pile.addCard(card2);

        final removed = pile.removeTopCard();

        expect(removed, equals(card2));
        expect(pile.cards, hasLength(1));
        expect(pile.topCardThrow, equals(card1));
      });
    });

    group('removeCards', () {
      test('throws StateError when count exceeds available', () {
        pile.addCard(PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace));

        expect(() => pile.removeCards(5), throwsStateError);
      });

      test('removes specified number of cards', () {
        final cards = [
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.two),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.three),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.four),
        ];
        pile.addCards(cards);

        final removed = pile.removeCards(2);

        expect(removed, hasLength(2));
        expect(removed, equals([cards[2], cards[3]]));
        expect(pile.cards, hasLength(2));
        expect(pile.topCardThrow, equals(cards[1]));
      });
    });

    group('removeTopCardIf', () {
      test('removes card when predicate matches', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
        pile.addCard(card);

        pile.removeTopCardIf((c) => c.suit == CardSuit.hearts);

        expect(pile.cards, isEmpty);
      });

      test('throws StateError when predicate does not match', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
        pile.addCard(card);

        expect(() => pile.removeTopCardIf((c) => c.suit == CardSuit.spades),
            throwsStateError);
      });

      test('throws StateError when pile is empty', () {
        expect(() => pile.removeTopCardIf((c) => true), throwsStateError);
      });
    });

    group('flipTopCard', () {
      test('flips face-up card to face-down', () {
        final card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
        pile.addCard(card);

        pile.flipTopCard();

        expect(pile.topCardThrow.faceUp, isFalse);
        expect(pile.topCardThrow.suit, equals(CardSuit.hearts));
        expect(pile.topCardThrow.rank, equals(CardRank.ace));
      });

      test('flips face-down card to face-up', () {
        final card = PlayingCard(
            suit: CardSuit.spades, rank: CardRank.king, faceUp: false);
        pile.addCard(card);

        pile.flipTopCard();

        expect(pile.topCardThrow.faceUp, isTrue);
        expect(pile.topCardThrow.suit, equals(CardSuit.spades));
        expect(pile.topCardThrow.rank, equals(CardRank.king));
      });

      test('does nothing when pile is empty', () {
        expect(() => pile.flipTopCard(), returnsNormally);
        expect(pile.cards, isEmpty);
      });
    });

    group('cards getter', () {
      test('returns unmodifiable list', () {
        final card = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.two);
        pile.addCard(card);

        expect(() => pile.cards.add(PlayingCard(suit: CardSuit.clubs, rank: CardRank.three)),
            throwsA(isA<UnsupportedError>()));
      });
    });

    group('topCards getter', () {
      test('returns all cards', () {
        final cards = [
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
          PlayingCard(suit: CardSuit.hearts, rank: CardRank.two),
        ];
        pile.addCards(cards);

        expect(pile.topCards, equals(cards));
      });

      test('returns unmodifiable list', () {
        final card = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.two);
        pile.addCard(card);

        expect(() => pile.topCards.add(PlayingCard(suit: CardSuit.clubs, rank: CardRank.three)),
            throwsA(isA<UnsupportedError>()));
      });
    });
  });
}
