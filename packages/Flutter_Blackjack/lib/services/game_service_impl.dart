//game_service_impl.dart
import 'package:flutter_blackjack_pkg/models/player_model.dart';
import 'package:flutter_blackjack_pkg/services/card_service_impl.dart';
import 'package:flutter_blackjack_pkg/services/game_service.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart'
    show BlackjackGameManager, blackjackManager;

import 'card_service.dart';

const HIGHES_SCORE_VALUE = 21;
const int DEALER_MIN_SCORE = 17;

class GameServiceImpl extends GameService {
  late Player player;
  late Player dealer;
  GameState gameState = GameState.equal;

  final CardServiceImpl _cardService = CardServiceImpl();

  GameServiceImpl() {
    dealer = Player([]);
    player = Player([]);
    _restoreGameState();
  }

  void _saveGameState() {
    blackjackManager.saveGameState(
        player: player, dealer: dealer, gameState: gameState);
  }

  void _restoreGameState() {
    final savedState = blackjackManager.getSavedState();
    if (savedState != null) {
      player = savedState['player'] as Player;
      dealer = savedState['dealer'] as Player;
      gameState = savedState['gameState'] as GameState;
    }
  }

  @override
  void startNewGame() {
    _saveGameState();

    _cardService.new52Deck();
    player.hand = _cardService.drawCards(2);
    dealer.hand = _cardService.drawCards(2);

    if (player.bet < 500) {
      player.bet = 500;
    }

    gameState = GameState.playerActive;
  }

  @override
  PlayingCard drawCard() {
    final drawnCard = _cardService.drawCard();
    player.hand.add(drawnCard);
    if (getScore(player) >= HIGHES_SCORE_VALUE) {
      endTurn();
    }
    _saveGameState();
    return drawnCard;
  }

  @override
  void endTurn() {
    int dealerScore = getScore(dealer);
    while (dealerScore < DEALER_MIN_SCORE) {
      dealer.hand.add(_cardService.drawCard());
      dealerScore = getScore(dealer);
    }

    final playerScore = getScore(player);
    final bool burntDealer = (dealerScore > HIGHES_SCORE_VALUE);
    final bool burntPlayer = (playerScore > HIGHES_SCORE_VALUE);

    if (burntDealer && burntPlayer) {
      gameState = GameState.equal;
    } else if (dealerScore == playerScore) {
      gameState = GameState.equal;
    } else if (burntDealer && playerScore <= HIGHES_SCORE_VALUE) {
      playerWon();
    } else if (burntPlayer && dealerScore <= HIGHES_SCORE_VALUE) {
      dealerWon();
    } else if (dealerScore < playerScore) {
      playerWon();
    } else if (dealerScore > playerScore) {
      dealerWon();
    }

    _saveGameState();
  }

  void playerWon() {
    gameState = GameState.playerWon;
    player.won += 1;
    dealer.lose += 1;
    player.wonBet();
    _saveGameState();
  }

  void dealerWon() {
    gameState = GameState.dealerWon;
    dealer.won += 1;
    player.lose += 1;
    player.lostBet();
    _saveGameState();
  }

  void resetGameState() {
    player.hand = [];
    dealer.hand = [];
    gameState = GameState.equal;
    _saveGameState();
  }

  @override
  Player getPlayer() {
    return player;
  }

  @override
  Player getDealer() {
    return dealer;
  }

  @override
  int getScore(Player player) {
    return mapCardValueRules(player.hand);
  }

  @override
  GameState getGameState() {
    return gameState;
  }

  @override
  String getWinner() {
    if (GameState.dealerWon == gameState) {
      return "딜러";
    }
    if (GameState.playerWon == gameState) {
      return "You";
    }
    return "Nobody";
  }

  int mapCardValueRules(List<PlayingCard> cards) {
    List<PlayingCard> standardCards = cards
        .where((card) => (0 <= card.value.index && card.value.index <= 11))
        .toList();

    final sumStandardCards = _getSumOfStandardCards(standardCards);

    int acesAmount = cards.length - standardCards.length;
    if (acesAmount == 0) {
      return sumStandardCards;
    }

    final pointsLeft = HIGHES_SCORE_VALUE - sumStandardCards;
    final oneAceIsEleven = 11 + (acesAmount - 1);

    if (pointsLeft >= oneAceIsEleven) {
      return sumStandardCards + oneAceIsEleven;
    }

    return sumStandardCards + acesAmount;
  }

  int _getSumOfStandardCards(List<PlayingCard> standardCards) {
    return standardCards.fold<int>(
        0, (sum, card) => sum + _mapStandardCardValue(card.value.index));
  }

  int _mapStandardCardValue(int cardEnumIdex) {
    const GAP_BETWEEN_INDEX_AND_VALUE = 2;

    if (0 <= cardEnumIdex && cardEnumIdex <= 8) {
      return cardEnumIdex + GAP_BETWEEN_INDEX_AND_VALUE;
    }

    if (9 <= cardEnumIdex && cardEnumIdex <= 11) {
      return 10;
    }

    return 0;
  }
}
