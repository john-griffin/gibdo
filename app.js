(function() {
  var $, Background, Game, Hero, Monster, Sprite,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $ = Zepto;

  $(function() {
    var game;
    game = new Game;
    return game.run();
  });

  Sprite = (function() {

    Sprite.prototype.ready = false;

    Sprite.prototype.x = 0;

    Sprite.prototype.y = 0;

    function Sprite() {
      var image,
        _this = this;
      image = new Image;
      image.src = this.imageUrl;
      image.onload = function() {
        return _this.ready = true;
      };
      this.image = image;
    }

    Sprite.prototype.draw = function(ctx) {
      if (this.ready) return ctx.drawImage(this.image, this.x, this.y);
    };

    return Sprite;

  })();

  Background = (function(_super) {

    __extends(Background, _super);

    function Background() {
      Background.__super__.constructor.apply(this, arguments);
    }

    Background.prototype.imageUrl = "images/background.png";

    return Background;

  })(Sprite);

  Monster = (function(_super) {

    __extends(Monster, _super);

    function Monster() {
      Monster.__super__.constructor.apply(this, arguments);
    }

    Monster.prototype.speed = 128;

    Monster.prototype.imageUrl = "images/monster.png";

    Monster.prototype.x = 30;

    Monster.prototype.y = 30;

    return Monster;

  })(Sprite);

  Hero = (function(_super) {

    __extends(Hero, _super);

    function Hero() {
      Hero.__super__.constructor.apply(this, arguments);
    }

    Hero.prototype.speed = 256;

    Hero.prototype.imageUrl = "images/hero.png";

    return Hero;

  })(Sprite);

  Game = (function() {

    function Game() {
      this.main = __bind(this.main, this);
    }

    Game.prototype.keysDown = {};

    Game.prototype.setup = function() {
      var _this = this;
      this.canvas = document.createElement("canvas");
      this.ctx = this.canvas.getContext("2d");
      this.canvas.width = 512;
      this.canvas.height = 480;
      document.body.appendChild(this.canvas);
      this.hero = new Hero;
      this.background = new Background;
      this.monster = new Monster;
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
      if (39 in this.keysDown) this.hero.x += this.hero.speed * modifier;
      if (this.monster.x < this.hero.x) {
        this.monster.x += this.monster.speed * modifier;
      }
      if (this.monster.x > this.hero.x) {
        this.monster.x -= this.monster.speed * modifier;
      }
      if (this.monster.y < this.hero.y) {
        this.monster.y += this.monster.speed * modifier;
      }
      if (this.monster.y > this.hero.y) {
        return this.monster.y -= this.monster.speed * modifier;
      }
    };

    Game.prototype.render = function() {
      this.background.draw(this.ctx);
      this.hero.draw(this.ctx);
      return this.monster.draw(this.ctx);
    };

    Game.prototype.main = function() {
      var delta, now;
      now = Date.now();
      delta = now - this.then;
      this.update(delta / 1000);
      this.render();
      return this.then = now;
    };

    Game.prototype.run = function() {
      this.setup();
      this.reset();
      this.then = Date.now();
      return setInterval(this.main, 1);
    };

    return Game;

  })();

}).call(this);
