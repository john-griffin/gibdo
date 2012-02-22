(function() {
  var Game, Hero,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $(function() {
    return new Game;
  });

  Hero = (function() {

    Hero.prototype.image = null;

    Hero.prototype.ready = false;

    Hero.prototype.speed = null;

    Hero.prototype.x = null;

    Hero.prototype.y = null;

    function Hero() {
      var image,
        _this = this;
      image = new Image;
      image.src = "images/hero.png";
      image.onload = function() {
        return _this.ready = true;
      };
      this.image = image;
    }

    Hero.prototype.draw = function(ctx) {
      if (this.ready) return ctx.drawImage(this.image, this.x, this.y);
    };

    return Hero;

  })();

  Game = (function() {

    Game.prototype.then = null;

    Game.prototype.hero = null;

    Game.prototype.canvas = null;

    Game.prototype.ctx = null;

    Game.prototype.setup = function() {
      this.canvas = document.createElement("canvas");
      this.ctx = this.canvas.getContext("2d");
      this.canvas.width = 512;
      this.canvas.height = 480;
      document.body.appendChild(this.canvas);
      return this.hero = new Hero;
    };

    Game.prototype.reset = function() {
      this.hero.x = this.canvas.width / 2;
      return this.hero.y = this.canvas.height / 2;
    };

    Game.prototype.update = function(modifier) {};

    Game.prototype.render = function() {
      return this.hero.draw(this.ctx);
    };

    Game.prototype.main = function() {
      var delta, now;
      now = Date.now();
      delta = now - this.then;
      this.update(delta / 1000);
      this.render();
      return this.then = now;
    };

    function Game() {
      this.main = __bind(this.main, this);      this.setup();
      this.reset();
      this.then = Date.now();
      setInterval(this.main, 1);
    }

    return Game;

  })();

}).call(this);
