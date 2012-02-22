(function() {
  var $, Game, Hero,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $ = jQuery;

  $(function() {
    var game;
    game = new Game;
    return game.run();
  });

  Hero = (function() {

    Hero.prototype.ready = false;

    Hero.prototype.speed = 256;

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

    Game.prototype.setup = function() {
      var _this = this;
      this.canvas = document.createElement("canvas");
      this.ctx = this.canvas.getContext("2d");
      this.canvas.width = 512;
      this.canvas.height = 480;
      document.body.appendChild(this.canvas);
      this.hero = new Hero;
      $("body").keydown(function(e) {
        return _this.keysDown[e.keyCode] = true;
      });
      return $("body").keyup(function(e) {
        return delete _this.keysDown[e.keyCode];
      });
    };

    Game.prototype.reset = function() {
      this.hero.x = this.canvas.width / 2;
      return this.hero.y = this.canvas.height / 2;
    };

    Game.prototype.update = function(modifier) {
      if (38 in this.keysDown) this.hero.y -= this.hero.speed * modifier;
      if (40 in this.keysDown) this.hero.y += this.hero.speed * modifier;
      if (37 in this.keysDown) this.hero.x -= this.hero.speed * modifier;
      if (39 in this.keysDown) return this.hero.x += this.hero.speed * modifier;
    };

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
      this.main = __bind(this.main, this);      this.keysDown = {};
    }

    Game.prototype.run = function() {
      this.setup();
      this.reset();
      this.then = Date.now();
      return setInterval(this.main, 1);
    };

    return Game;

  })();

}).call(this);
