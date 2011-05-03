(function() {
  var BaseGame, ServerGame;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  BaseGame = require('./base_game');
  module.exports = ServerGame = (function() {
    __extends(ServerGame, BaseGame);
    function ServerGame(options) {
      this.id = options.id;
      this.size = options.size;
      this.clients = options.clients;
      this.attachListeners();
      this.resetBoard();
    }
    ServerGame.prototype.attachListeners = function() {
      var game;
      game = this;
      this.clients.on('connect', function() {
        var client, clientId;
        client = this;
        clientId = client.user.clientId;
        return client.now.getSession(function(session) {
          if (session == null) {
            return;
          }
          game.addPlayer(clientId, session.uid);
          return game.emit('playerJoined', clientId, session.uid);
        });
      });
      return this.clients.on('disconnect', function() {
        game.removePlayer(this.now.uid);
        return game.emit('playerLeft', this.now.uid);
      });
    };
    ServerGame.prototype.emit = function() {
      var data, eventName;
      eventName = arguments[0], data = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.clients.now.handleServerEvent(eventName, data);
    };
    ServerGame.prototype.handleClientEvent = function(client, eventName, data) {
      var edgeNum;
      switch (eventName) {
        case 'fillEdge':
          if (this.players.states.length < 2) {
            client.now.handleServerEvent('needMorePlayers');
            return false;
          }
          if (this.players.getCurrentState() === client.now.uid) {
            edgeNum = data[0];
            return this.fillEdge(edgeNum);
          } else {
            return client.now.handleServerEvent('notYourTurn');
          }
      }
    };
    ServerGame.prototype.fillEdge = function(edgeNum) {
      this.emit('fillEdge', edgeNum);
      return ServerGame.__super__.fillEdge.apply(this, arguments);
    };
    ServerGame.prototype.checkSquare = function(direction, edgeNum) {
      var squareCompleted;
      squareCompleted = ServerGame.__super__.checkSquare.apply(this, arguments);
      if (squareCompleted === false) {
        return false;
      }
      this.emit('completeSquare');
      return true;
    };
    ServerGame.prototype.forClient = function() {
      return {
        size: this.size,
        alpha: this.alpha,
        num_edges: this.num_edges,
        board: this.board,
        completedSquares: this.completedSquares,
        players: this.players,
        scoreCard: this.scoreCard,
        totalMoves: this.totalMoves
      };
    };
    return ServerGame;
  })();
}).call(this);
