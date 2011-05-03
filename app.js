(function() {
  var DEFAULT_BOARD_SIZE, DEFAULT_PORT, ServerGame, all_games, app, createNewGame, everyone, express, fs, nowjs, onClientDisconnected, uid2Client;
  var __slice = Array.prototype.slice;
  express = require('express');
  nowjs = require('now');
  fs = require('fs');
  ServerGame = require('./models/server_game');
  app = module.exports = express.createServer();
  DEFAULT_BOARD_SIZE = 6;
  DEFAULT_PORT = 3000;
  all_games = {};
  uid2Client = {};
  createNewGame = function(gameId) {
    var room;
    room = nowjs.getGroup(gameId);
    return new ServerGame({
      id: gameId,
      size: DEFAULT_BOARD_SIZE,
      clients: room
    });
  };
  app.configure(function() {
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(express.static(__dirname + '/public'));
    return app.use(require('browserify')({
      base: __dirname + '/models',
      mount: '/browserify.js'
    }));
  });
  app.get('/games', function(req, res) {
    res.local('all_games', all_games);
    return res.render('games/index');
  });
  app.get('/g/:game_id', function(req, res) {
    var gid;
    gid = req.params.game_id;
    all_games[gid] || (all_games[gid] = createNewGame(gid));
    res.local('game_id', gid);
    res.local('game', all_games[gid]);
    return res.render('games/show');
  });
  if (!module.parent) {
    app.listen(DEFAULT_PORT);
    console.log("Express server listening on port %d", app.address().port);
    onClientDisconnected = function() {
      var gameId, room;
      gameId = this.now.gameId;
      room = nowjs.getGroup(gameId);
      room.removeUser(this.user.clientId);
      if (this.now.uid != null) {
        return delete uid2Client[this.now.uid];
      }
    };
    everyone = nowjs.initialize(app);
    everyone.now.startGame = function(gameId, uid) {
      var oldClient, room, serialized;
      if (oldClient = uid2Client[uid]) {
        onClientDisconnected.call(oldClient);
        oldClient.now.handleServerEvent('gtfo', ['Duplicate Connection']);
      }
      uid2Client[uid] = this;
      room = nowjs.getGroup(gameId);
      room.addUser(this.user.clientId);
      serialized = all_games[gameId].forClient();
      serialized['clientId'] = this.user.clientId;
      return this.now.initializeClientGame(serialized);
    };
    everyone.disconnected(onClientDisconnected);
    everyone.now.handleClientEvent = function() {
      var game, gameId, _ref;
      gameId = this.now.gameId;
      game = all_games[gameId];
      return (_ref = ServerGame.prototype.handleClientEvent).call.apply(_ref, [game, this].concat(__slice.call(arguments)));
    };
  }
}).call(this);
