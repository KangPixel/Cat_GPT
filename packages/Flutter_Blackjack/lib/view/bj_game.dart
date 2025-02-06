// bj_game.dart
import 'package:flutter/material.dart';
import 'package:flutter_blackjack_pkg/services/game_service.dart';
import 'package:flutter_blackjack_pkg/services/game_service_impl.dart';
import 'package:flutter_blackjack_pkg/widgets/card.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart';
import 'package:flame_audio/flame_audio.dart';

class BlackJackGame extends StatefulWidget {
  final GameService gameService;
  const BlackJackGame({Key? key, required this.gameService}) : super(key: key);
  @override
  State<BlackJackGame> createState() => _BlackJackGameState();
}

class _BlackJackGameState extends State<BlackJackGame> {
  final List<int> betOptions = [500, 1000, 2000, 5000, 10000];
  bool _isSettling = false;
  bool _hasGameStarted = false;

  @override
  void initState() {
    super.initState();
    _loadAudio();
    if (blackjackManager.getSavedState() == null) {
      widget.gameService.getPlayer().wallet = blackjackManager.initialWallet;
      widget.gameService.getPlayer().bet = betOptions[0];
    }
    final savedState = blackjackManager.getSavedState();
    if (savedState != null &&
        savedState['gameState'] == GameState.playerActive) {
      _hasGameStarted = true;
    }
  }

  Future<void> _loadAudio() async {
    await FlameAudio.audioCache.load('card.wav');
  }

  void _playCardSound() {
    FlameAudio.play('card.wav', volume: 2.0);
  }

  void _checkForAutoSettlement() {
    final currentWallet = widget.gameService.getPlayer().wallet;
    if (currentWallet <= 0 || currentWallet >= 150000) {
      if (!_isSettling && _hasGameStarted) {
        _onPressSettlement(isAuto: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameService.getGameState();
    final bool isPlayerActive = (gameState == GameState.playerActive);
    final int wallet = widget.gameService.getPlayer().wallet;
    final bool hasPlayedAtLeastOneRound =
        widget.gameService.getPlayer().won > 0 ||
            widget.gameService.getPlayer().lose > 0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.green[800],
        appBar: AppBar(
          title: const Text('Blackjack'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Dealer cards
            SizedBox(
              height: 150,
              width: widget.gameService.getDealer().hand.length * 90,
              child: FlatCardFan(
                children: [
                  for (var card in widget.gameService.getDealer().hand)
                    CardAnimatedWidget(card, isPlayerActive, 3.0),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Center controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Hit
                GestureDetector(
                  onTap: () {
                    if (isPlayerActive) {
                      _playCardSound();
                      widget.gameService.drawCard();
                      setState(() {});
                      _checkForAutoSettlement();
                    }
                  },
                  child: SizedBox(
                    width: 120,
                    child: FlatCardFan(
                      children: [
                        cardWidget(
                            PlayingCard(Suit.joker, CardValue.joker_1), true),
                        cardWidget(
                            PlayingCard(Suit.joker, CardValue.joker_2), true),
                        cardWidget(
                            PlayingCard(Suit.joker, CardValue.joker_2), true),
                      ],
                    ),
                  ),
                ),

                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (isPlayerActive) {
                          _playCardSound();
                          _onGameEnd();
                        } else {
                          _playCardSound();
                          setState(() {
                            _startNewGame();
                          });
                        }
                      },
                      child: Text(isPlayerActive ? "Finish" : "New Game"),
                    ),
                    const SizedBox(height: 10),
                    if (!isPlayerActive && _hasGameStarted) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "승자: ${widget.gameService.getWinner()}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dealer: ${widget.gameService.getScore(widget.gameService.getDealer())}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "You: ${widget.gameService.getScore(widget.gameService.getPlayer())}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),

                // Settlement button
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: (isPlayerActive ||
                          _isSettling ||
                          !hasPlayedAtLeastOneRound)
                      ? null
                      : () => _onPressSettlement(),
                  child: const Text("정산"),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Stats and betting
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("Won: ${widget.gameService.getPlayer().won}"),
                    Text("Lost: ${widget.gameService.getPlayer().lose}"),
                  ],
                ),
                const SizedBox(width: 30),

                // Bet buttons
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Bet Options",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: betOptions.map((option) {
                          final bool isSelected =
                              (option == widget.gameService.getPlayer().bet);
                          final bool canAfford = wallet >= option;
                          final bool isPlayingCurrentRound = isPlayerActive;

                          return SizedBox(
                            width: 80,
                            height: 35,
                            child: Tooltip(
                              message: !canAfford
                                  ? '잔액 부족'
                                  : isPlayingCurrentRound
                                      ? '게임 진행 중에는 베팅을 변경할 수 없습니다'
                                      : '베팅 가능',
                              child: ElevatedButton(
                                onPressed: (!canAfford || isPlayingCurrentRound)
                                    ? null
                                    : () {
                                        setState(() {
                                          widget.gameService.getPlayer().bet =
                                              option;
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  backgroundColor: isSelected
                                      ? Colors.orange
                                      : canAfford
                                          ? Colors.blueGrey
                                          : Colors.red.shade200,
                                  disabledBackgroundColor: isSelected
                                      ? Colors.orange.shade200
                                      : canAfford
                                          ? Colors.grey.shade400
                                          : Colors.red.shade100,
                                ),
                                child: Text(
                                  '$option',
                                  style: TextStyle(
                                    color: canAfford
                                        ? Colors.white
                                        : Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Player cards
            SizedBox(
              height: 200,
              width: widget.gameService.getPlayer().hand.length * 90,
              child: FlatCardFan(
                children: [
                  for (var card in widget.gameService.getPlayer().hand)
                    CardAnimatedWidget(card, false, 3.0),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Wallet
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wallet),
                const SizedBox(width: 7.5),
                Text(
                  "$wallet",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _startNewGame() {
    _playCardSound();
    widget.gameService.startNewGame();
    _hasGameStarted = true;
    blackjackManager.saveGameState(
        player: widget.gameService.getPlayer(),
        dealer: widget.gameService.getDealer(),
        gameState: widget.gameService.getGameState());
  }

  void _onGameEnd() {
    _playCardSound();
    widget.gameService.endTurn();
    setState(() {});
    _checkForAutoSettlement();
  }

  void _onPressSettlement({bool isAuto = false}) {
    if (_isSettling || !_hasGameStarted) return;
    setState(() {
      _isSettling = true;
    });

    final currentWallet = widget.gameService.getPlayer().wallet;
    final pointsMultiplier = currentWallet >= 150000 ? 1.5 : 1.0;
    final bonusMessage = currentWallet >= 150000
        ? {'main': "돈을 많이 벌었어요!", 'sub': "축하보너스로 포인트가 1.5배 적용됩니다!"}
        : null;

    widget.gameService.resetGameState();
    blackjackManager.clearSavedState();

    if (mounted) {
      Navigator.pop(context, {
        'wallet': currentWallet,
        'pointsMultiplier': pointsMultiplier,
        'bonusMessage': bonusMessage,
      });
    }
  }
}
