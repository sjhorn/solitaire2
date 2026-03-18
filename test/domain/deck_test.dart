import 'package:flutter_test/flutter_test.dart';
import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/deck.dart';
import 'package:solitaire/src/domain/playing_card.dart';

void main() {
  group('Deck', () {
    group('constructor', () {
      test('creates a deck with 52 cards', () {
        final deck = Deck();

        expect(deck.cards, hasLength(52));
      });

      test('creates all combinations of suits and ranks', () {
        final deck = Deck();

        final suitCount = <CardSuit, int>{};
        final rankCount = <CardRank, int>{};

        for (final card in deck.cards) {
          suitCount[card.suit] = (suitCount[card.suit] ?? 0) + 1;
          rankCount[card.rank] = (rankCount[card.rank] ?? 0) + 1;
        }

        // Each suit should have 13 cards (one of each rank)
        for (final suit in CardSuit.values) {
          expect(suitCount[suit], equals(13));
        }

        // Each rank should appear 4 times (once per suit)
        for (final rank in CardRank.values) {
          expect(rankCount[rank], equals(4));
        }
      });

      test('all cards are face-up by default', () {
        final deck = Deck();

        for (final card in deck.cards) {
          expect(card.faceUp, isTrue);
        }
      });
    });

    group('shuffle', () {
      test('shuffled deck has same cards as original', () {
        final deck = Deck();
        final originalCards = List<PlayingCard>.from(deck.cards);
        deck.shuffle();

        final shuffledCards = deck.cards;

        expect(shuffledCards.length, equals(originalCards.length));
        for (final card in originalCards) {
          expect(shuffledCards, contains(card));
        }
      });

      test('shuffled deck is different from original order', () {
        final deck = Deck();
        final originalCards = List<PlayingCard>.from(deck.cards);
        deck.shuffle();

        final shuffledCards = deck.cards;

        expect(shuffledCards, isNot(equals(originalCards)));
      });

      test('shuffled deck is properly randomized', () {
        final deck = Deck();
        deck.shuffle();
        deck.shuffle();
        deck.shuffle();

        final firstTen = deck.cards.take(10).toList();
        // Check that not all first cards are the same suit
        final firstCardSuits = firstTen.map((c) => c.suit).toSet();
        expect(firstCardSuits.length, greaterThan(1));
      });
    });

    group('isEmpty', () {
      test('deck is not empty after creation', () {
        final deck = Deck();

        expect(deck.isEmpty, isFalse);
      });

      test('deck is empty after drawing all cards', () {
        final deck = Deck();

        while (deck.cards.isNotEmpty) {
          deck.draw();
        }

        expect(deck.isEmpty, isTrue);
      });
    });

    group('draw', () {
      test('returns top card and removes it from deck', () {
        final deck = Deck();
        final topCard = deck.cards.last;
        final drawnCard = deck.draw();

        expect(drawnCard, equals(topCard));
        expect(deck.cards, hasLength(51));
        expect(deck.cards, isNot(contains(topCard)));
      });

      test('throws exception when drawing from empty deck', () {
        final deck = Deck();
        while (deck.cards.isNotEmpty) {
          deck.draw();
        }

        expect(() => deck.draw(), throwsStateError);
      });

      test('draws cards in LIFO order', () {
        final deck = Deck();
        final originalCards = List<PlayingCard>.from(deck.cards);
        final drawnCards = <PlayingCard>[];

        while (deck.cards.isNotEmpty) {
          drawnCards.add(deck.draw());
        }

        // Cards should be drawn in reverse order (last added is first drawn)
        expect(drawnCards, orderedEquals(originalCards.reversed));
      });
    });

    group('reset', () {
      test('restores deck to 52 cards after shuffling and drawing', () {
        final deck = Deck();
        deck.shuffle();
        while (deck.cards.isNotEmpty) {
          deck.draw();
        }

        deck.reset();

        expect(deck.cards, hasLength(52));
        for (final suit in CardSuit.values) {
          for (final rank in CardRank.values) {
            expect(deck.cards, contains(PlayingCard(suit: suit, rank: rank)));
          }
        }
      });

      test('resets cards to face-up state', () {
        final deck = Deck();
        deck.shuffle();
        // Draw some cards (they become face-up after draw, but let's simulate face-down)
        for (var i = 0; i < 10; i++) {
          deck.draw();
        }
        deck.reset();

        for (final card in deck.cards) {
          expect(card.faceUp, isTrue);
        }
      });
    });
  });
}
