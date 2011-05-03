(function() {
  var BaseGame, ClientGame, StateMachine, UI;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __slice = Array.prototype.slice;
  BaseGame = require('./base_game');
  StateMachine = require('./state_machine');
  UI = require('./ui').getInstance();
  module.exports = ClientGame = (function() {
    __extends(ClientGame, BaseGame);
    function ClientGame(options) {
      this.refreshPlayerUI = __bind(this.refreshPlayerUI, this);;      var attr, _i, _len, _ref;
      this.container = options.container;
      this.gameUrl = window.location.href;
      _ref = ['size', 'alpha', 'num_edges', 'board', 'totalMoves', 'scoreCard', 'clientId', 'completedSquares'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        this[attr] = options[attr];
      }
      this.setupPlayerStateMachine(options.players);
    }
    ClientGame.prototype.setupPlayerStateMachine = function(serverStateMachine) {
      this.players = $.extend(new StateMachine, serverStateMachine);
      this.players.on('stateAdded', this.refreshPlayerUI);
      this.players.on('stateRemoved', this.refreshPlayerUI);
      return this.players.on('stateChanged', this.refreshPlayerUI);
    };
    ClientGame.prototype.refreshPlayerUI = function() {
      return $(document).ready(__bind(function() {
        var li, players, score, txt, uid, _ref;
        players = this.container.find('.players').empty();
        _ref = this.scoreCard;
        for (uid in _ref) {
          score = _ref[uid];
          txt = "<fb:profile-pic uid='" + uid + "'></fb:profile-pic>";
          txt += "<span>" + score + "</span>";
          li = $("<li/>").html(txt);
          if (__indexOf.call(this.players.states, uid) < 0) {
            li.addClass('offline').attr('title', 'offline');
          }
          if (this.players.getCurrentState() === uid) {
            li.addClass('currentTurn').attr('title', 'Current Turn');
          }
          players.append(li);
        }
        return FB.XFBML.parse(this.container.get(0));
      }, this));
    };
    ClientGame.prototype.emit = function() {
      var data, eventName;
      eventName = arguments[0], data = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return window.now.handleClientEvent(eventName, data);
    };
    ClientGame.prototype.handleServerEvent = function(eventName, data) {
      var clientId, edgeNum, msg, uid, _ref;
      console.log("server said", eventName, data);
      switch (eventName) {
        case 'needMorePlayers':
          return UI.showMessage('You\'re the only one connected\nto this game right now. Invite someone to play\nwith you by sending them a link to this page.');
        case 'notYourTurn':
          return UI.showMessage('It\'s not your turn...');
        case 'playerJoined':
          clientId = data[0];
          uid = data[1];
          return this.addPlayer(clientId, uid);
        case 'playerLeft':
          uid = data[0];
          return this.removePlayer(uid);
        case 'fillEdge':
          edgeNum = data[0];
          return this.fillEdge(edgeNum);
        case 'completeSquare':
          return this.refreshPlayerUI();
        case 'gtfo':
          msg = data[0];
          UI.showMessage("Server kicked you. Reason: " + msg, true);
          return (_ref = window.socket) != null ? _ref.disconnect() : void 0;
      }
    };
    ClientGame.prototype.render = function() {
      $.get("/game.pde", __bind(function(res) {
        var jsCode;
        jsCode = Processing.compile(res);
        return new Processing(this.container.find("canvas").get(0), jsCode);
      }, this));
      return this.renderPlayerUI();
    };
    ClientGame.prototype.renderPlayerUI = function() {
      var list;
      list = $("<ul class='players'></ul>");
      return list.appendTo(this.container);
    };
    return ClientGame;
  })();
}).call(this);
