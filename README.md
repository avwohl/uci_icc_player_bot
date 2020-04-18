# uci_icc_player_bot - play chess on to Internet Chess Club written in xojo

### Author Aaron Wohl https://github.com/avwohl

### Where to find the latest stable version of this file:
[https://github.com/avwohl/uci_icc_player_bot/blob/master/README.md](https://github.com/avwohl/uci_icc_player_bot/blob/master/README.md)

### Documentation using git and submodules and these libs in xojo:
[https://github.com/avwohl/xojo_documentation](https://github.com/avwohl/xojo_documentation)

### Download the stable version of this git project for xojo:
[https://github.com/avwohl/uci_icc_player_bot/tree/stable](https://github.com/avwohl/uci_icc_player_bot)

## UCI to ICC chess player
### ICC Internet Chess Club
Internet Chess Club (chessclub.com) is online game playing server.  This program connects to ICC. It can play multiple chess games at once.  Playing multiple games at once is called a Simul.  We do not figure out the moves to make ourselves, that is done by asking a chess playing engine via a protocol called UCI, see below.

### UCI - Universal Chess Engine protocol
UCI is a standard used to talk to chess computation engines.  We use it to ask a selected engine to compute a move for us.

## Configuration
uci_icc_chessbot takes a command line argument which is the name of a config file.  That config file can include other configs.  It is used to tell us where to connect to, hostname and port, what chess engine to run and how to configure it.