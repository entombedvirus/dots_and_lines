(function() {
  var EventEmitter, StateMachine;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  EventEmitter = require('events').EventEmitter;
  module.exports = StateMachine = (function() {
    __extends(StateMachine, EventEmitter);
    function StateMachine() {
      this.states = new Array;
      this.counter = 0;
    }
    StateMachine.prototype.addState = function(newState) {
      this.states.push(newState);
      this.emit('stateAdded', newState);
      return this;
    };
    StateMachine.prototype.removeState = function(aState) {
      this.states = this.states.filter(function(currentState) {
        return currentState !== aState;
      });
      this.emit('stateRemoved', aState);
      return this;
    };
    StateMachine.prototype.nextState = function() {
      this.counter++;
      this.emit('stateChanged');
      return this;
    };
    StateMachine.prototype.getCurrentState = function() {
      var idx;
      idx = this.counter % this.states.length;
      return this.states[idx];
    };
    return StateMachine;
  })();
}).call(this);
