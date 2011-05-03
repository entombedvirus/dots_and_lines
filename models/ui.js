(function() {
  var UI, instance;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  UI = (function() {
    function UI() {
      this.hideMessage = __bind(this.hideMessage, this);;      $(document).ready(__bind(function() {
        this.container = $("<div id='notifications'><p></p></div>");
        this.container.prependTo($('body'));
        return this.container.click(this.hideMessage);
      }, this));
    }
    UI.prototype.showMessage = function(msg, sticky) {
      if (sticky == null) {
        sticky = false;
      }
      this.container.find('p:first').text(msg);
      this.container.fadeIn('fast');
      if (!sticky) {
        return this.restartHideTimer();
      }
    };
    UI.prototype.hideMessage = function() {
      return this.container.fadeOut('slow');
    };
    UI.prototype.restartHideTimer = function() {
      if (this.timer != null) {
        clearTimeout(this.timer);
      }
      return this.timer = setTimeout(this.hideMessage, 3000);
    };
    return UI;
  })();
  instance = null;
  module.exports = {
    getInstance: function() {
      return instance || (instance = new UI);
    }
  };
}).call(this);
