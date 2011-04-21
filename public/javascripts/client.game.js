(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  typeof Client != "undefined" && Client !== null ? Client : Client = {};
  Client.Game = (function() {
    function Game(container) {
      this.container = container;
      this.container.click(__bind(function(e) {
        var gameId, target;
        target = $(e.target);
        if (!target.is('a')) {
          return;
        }
        gameId = this.container.attr('id');
        target.attr("href", "/g/" + gameId + "/set/" + (target.data('edgeNum')));
        return true;
      }, this));
      console.log("Client game construction detected");
    }
    Game.prototype.render = function() {
      var currentOrientation, edge, edgeNum, link, switching, _len, _ref, _results;
      console.log("render triggered on client game");
      _ref = this.board;
      _results = [];
      for (edgeNum = 0, _len = _ref.length; edgeNum < _len; edgeNum++) {
        edge = _ref[edgeNum];
        link = $("<a></a>").html('&nbsp');
        currentOrientation = this.isVerticalEdge(edgeNum);
        switching = currentOrientation !== this.isVerticalEdge(edgeNum - 1);
        if (currentOrientation) {
          link.addClass('vert');
        } else {
          link.addClass('horiz');
        }
        this.container.append(link);
        if (switching) {
          link.css('clear', 'left');
        }
        if (this.board[edgeNum]) {
          link.addClass('filled');
        }
        _results.push(link.data('edgeNum', edgeNum));
      }
      return _results;
    };
    Game.prototype.isVerticalEdge = function(edgeNum) {
      return (edgeNum % this.alpha) >= Math.floor(this.alpha / 2);
    };
    Game.prototype.isOnPerimeter = function(direction, edgeNum) {
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
    return Game;
  })();
}).call(this);
