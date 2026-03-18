import 'package:solitaire/src/domain/pile_type.dart';
import 'package:solitaire/src/domain/playing_card.dart';

/// A pile of cards in the game.
class GamePile {
  final List<PlayingCard> _cards = [];
  final PileType type;

  GamePile({required this.type});

  List<PlayingCard> get cards => List.unmodifiable(_cards);

  List<PlayingCard> get topCards => List.unmodifiable(_cards);

  bool get isEmpty => _cards.isEmpty;

  bool get isNotEmpty => _cards.isNotEmpty;

  PlayingCard? get topCard => _cards.isNotEmpty ? _cards.last : null;

  PlayingCard get topCardThrow {
    if (_cards.isEmpty) {
      throw StateError('Cannot get top card from empty pile');
    }
    return _cards.last;
  }

  void addCard(PlayingCard card) {
    _cards.add(card);
  }

  void addCards(List<PlayingCard> cards) {
    _cards.addAll(cards);
  }

  PlayingCard removeTopCard() {
    if (_cards.isEmpty) {
      throw StateError('Cannot remove card from empty pile');
    }
    return _cards.removeLast();
  }

  List<PlayingCard> removeCards(int count) {
    if (count > _cards.length) {
      throw StateError('Cannot remove more cards than available');
    }
    final cardsToRemove = _cards.sublist(_cards.length - count);
    _cards.removeRange(_cards.length - count, _cards.length);
    return cardsToRemove;
  }

  void removeTopCardIf(FunMatchCard predicate) {
    if (_cards.isEmpty) {
      throw StateError('Cannot remove card from empty pile');
    }
    if (!predicate(_cards.last)) {
      throw StateError('Card does not match predicate');
    }
    _cards.removeLast();
  }

  void flipTopCard() {
    if (_cards.isNotEmpty) {
      _cards[_cards.length - 1] = PlayingCard(
        suit: _cards.last.suit,
        rank: _cards.last.rank,
        faceUp: !_cards.last.faceUp,
        isSelected: _cards.last.isSelected,
      );
    }
  }
}

typedef FunMatchCard = bool Function(PlayingCard);
