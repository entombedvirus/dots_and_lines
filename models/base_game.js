(function() {
  var BaseGame, StateMachine;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  StateMachine = require('./state_machine');
  module.exports = BaseGame = (function() {
    function BaseGame() {}
    BaseGame.prototype.resetBoard = function() {
      this.totalMoves = 0;
      this.alpha = 2 * this.size - 1;
      this.num_edges = 2 * this.size * (this.size - 1);
      this.board = new Array(this.num_edges);
      this.completedSquares = {};
      this.players = new StateMachine;
      return this.scoreCard = {};
    };
    BaseGame.prototype.addPlayer = function(clientId, uid) {
      var _base, _ref;
      (_ref = (_base = this.scoreCard)[uid]) != null ? _ref : _base[uid] = 0;
      return this.players.addState(uid);
    };
    BaseGame.prototype.removePlayer = function(uid) {
      return this.players.removeState(uid);
    };
    BaseGame.prototype.isVerticalEdge = function(edgeNum) {
      return (edgeNum % this.alpha) >= Math.floor(this.alpha / 2);
    };
    BaseGame.prototype.isOnPerimeter = function(direction, edgeNum) {
      var _i, _j, _ref, _ref2, _ref3, _results, _results2;
      switch (direction) {
        case 'left':
          return edgeNum % this.alpha === this.size - 1;
        case 'right':
          return edgeNum % this.alpha === this.alpha - 1;
        case 'top':
          return __indexOf.call((function() {
            _results = [];
            for (var _i = 0, _ref = this.size; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i += 1 : _i -= 1){ _results.push(_i); }
            return _results;
          }).apply(this, arguments), edgeNum) >= 0;
        case 'bottom':
          return __indexOf.call((function() {
            _results2 = [];
            for (var _j = _ref2 = this.num_edges - this.size + 1, _ref3 = this.num_edges; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; _ref2 <= _ref3 ? _j += 1 : _j -= 1){ _results2.push(_j); }
            return _results2;
          }).apply(this, arguments), edgeNum) >= 0;
      }
    };
    BaseGame.prototype.fillEdge = function(edgeNum) {
      var bottom, left, pointScored, right, top;
      if (!((0 <= edgeNum && edgeNum < this.num_edges))) {
        throw "Edge " + edgeNum + " is out of bounds. total: " + this.num_edges;
      }
      left = right = top = bottom = false;
      this.totalMoves++;
      this.board[edgeNum] = true;
      if (this.isVerticalEdge(edgeNum)) {
        if (!this.isOnPerimeter('left', edgeNum)) {
          left = this.checkSquare('left', edgeNum);
        }
        if (!this.isOnPerimeter('right', edgeNum)) {
          right = this.checkSquare('right', edgeNum);
        }
      } else {
        if (!this.isOnPerimeter('top', edgeNum)) {
          top = this.checkSquare('top', edgeNum);
        }
        if (!this.isOnPerimeter('bottom', edgeNum)) {
          bottom = this.checkSquare('bottom', edgeNum);
        }
      }
      pointScored = left || right || top || bottom;
      if (!pointScored) {
        this.players.nextState();
      }
      return pointScored;
    };
    BaseGame.prototype.checkSquare = function(direction, edgeNum) {
      var coordinates, edge, _i, _len;
      coordinates = (function() {
        switch (direction) {
          case 'left':
            return [edgeNum - 1, edgeNum - this.size, edgeNum + (this.size - 1)];
          case 'right':
            return [edgeNum + 1, edgeNum + this.size, edgeNum - (this.size - 1)];
          case 'top':
            return [edgeNum - this.alpha, edgeNum - this.size, edgeNum - (this.size - 1)];
          case 'bottom':
            return [edgeNum + this.alpha, edgeNum + this.size, edgeNum + (this.size - 1)];
        }
      }).call(this);
      for (_i = 0, _len = coordinates.length; _i < _len; _i++) {
        edge = coordinates[_i];
        if (!((0 <= edge && edge < this.num_edges))) {
          continue;
        }
        if (this.board[edge] == null) {
          return false;
        }
      }
      this.addCompletedSquare(direction, edgeNum);
      return true;
    };
    BaseGame.prototype.addCompletedSquare = function(direction, edgeNum) {
      var topEdge, uid, _base, _ref;
      topEdge = (function() {
        switch (direction) {
          case 'left':
            return edgeNum - this.size;
          case 'right':
            return edgeNum - this.size + 1;
          case 'top':
            return edgeNum - this.alpha;
          case 'bottom':
            return edgeNum;
        }
      }).call(this);
      uid = this.players.getCurrentState();
      this.scoreCard[uid] += 1;
      ((_ref = (_base = this.completedSquares)[uid]) != null ? _ref : _base[uid] = []).push(topEdge);
      return topEdge;
    };
    return BaseGame;
  })();
}).call(this);
