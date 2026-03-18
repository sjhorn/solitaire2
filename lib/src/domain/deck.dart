import 'dart:math';

import 'package:solitaire/src/domain/card_rank.dart';
import 'package:solitaire/src/domain/card_suit.dart';
import 'package:solitaire/src/domain/playing_card.dart';

/// A standard 52-card deck for Klondike Solitaire.
class Deck {
  final List<PlayingCard> _cards = [];
  final Random _random = Random();

  /// Creates a new deck with all 52 cards.
  Deck() {
    _initializeCards();
  }

  /// The cards in the deck.
  List<PlayingCard> get cards => List.unmodifiable(_cards);

  /// Whether the deck is empty.
  bool get isEmpty => _cards.isEmpty;

  void _initializeCards() {
    _cards.clear();
    for (final suit in CardSuit.values) {
      for (final rank in CardRank.values) {
        _cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  /// Shuffles the deck randomly.
  void shuffle() {
    for (var i = _cards.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }
  }

  /// Draws the top card from the deck.
  PlayingCard draw() {
    if (_cards.isEmpty) {
      throw StateError('Cannot draw from an empty deck');
    }
    return _cards.removeLast();
  }

  /// Resets the deck to a fresh 52-card state.
  void reset() {
    _initializeCards();
  }
}
