(function() {
  var $, Background, Game, Hero, Monster, Sprite, World,
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

    Sprite.prototype.sx = 0;

    Sprite.prototype.sy = 0;

    Sprite.prototype.sw = 0;

    Sprite.prototype.sh = 0;

    Sprite.prototype.dx = 0;

    Sprite.prototype.dy = 0;

    Sprite.prototype.dw = 0;

    Sprite.prototype.dh = 0;

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
      if (this.ready) {
        return ctx.drawImage(this.image, this.sx, this.sy, this.sw, this.sh, this.dx, this.dy, this.dw, this.dh);
      }
    };

    return Sprite;

  })();

  World = (function() {

    function World() {}

    World.prototype.width = 512;

    World.prototype.height = 480;

    return World;

  })();

  Background = (function(_super) {

    __extends(Background, _super);

    function Background() {
      Background.__super__.constructor.apply(this, arguments);
    }

    Background.prototype.sw = 100;

    Background.prototype.sh = 100;

    Background.prototype.dw = 100;

    Background.prototype.dh = 100;

    Background.prototype.imageUrl = "images/background.png";

    Background.prototype.draw = function(ctx, herox, heroy) {
      var x, y;
      x = herox - 34;
      y = heroy - 34;
      if (x <= 0) x = 0;
      if (y <= 0) y = 0;
      if (x >= 512 - 100) x = 512 - 100;
      if (y >= 480 - 100) y = 480 - 100;
      if (this.ready) {
        return ctx.drawImage(this.image, x, y, this.sw, this.sh, this.dx, this.dy, this.dw, this.dh);
      }
    };

    return Background;

  })(Sprite);

  Monster = (function(_super) {

    __extends(Monster, _super);

    function Monster() {
      Monster.__super__.constructor.apply(this, arguments);
    }

    Monster.prototype.speed = 128;

    Monster.prototype.imageUrl = "images/monster.png";

    Monster.prototype.x = 400;

    Monster.prototype.y = 400;

    Monster.prototype.sw = 30;

    Monster.prototype.sh = 32;

    Monster.prototype.dw = 30;

    Monster.prototype.dh = 32;

    Monster.prototype.draw = function(ctx, herox, heroy) {
      var x, y;
      x = this.x - herox + 34;
      y = this.y - heroy + 34;
      if (herox < 34) x = this.x;
      if (heroy < 34) y = this.y;
      if (herox >= 446) x = this.x - 412;
      if (heroy >= 414) y = this.y - 380;
      if (this.ready) {
        return ctx.drawImage(this.image, this.sx, this.sy, this.sw, this.sh, x, y, this.dw, this.dh);
      }
    };

    return Monster;

  })(Sprite);

  Hero = (function(_super) {

    __extends(Hero, _super);

    function Hero() {
      Hero.__super__.constructor.apply(this, arguments);
    }

    Hero.prototype.sw = 32;

    Hero.prototype.sh = 32;

    Hero.prototype.dw = 32;

    Hero.prototype.dh = 32;

    Hero.prototype.speed = 256;

    Hero.prototype.imageUrl = "images/hero.png";

    Hero.prototype.draw = function(ctx) {
      var x, y;
      x = 34;
      y = 34;
      if (this.x < 34) x = this.x;
      if (this.y < 34) y = this.y;
      if (this.x > 446) x = this.x - 412;
      if (this.y > 414) y = this.y - 380;
      if (this.ready) {
        return ctx.drawImage(this.image, this.sx, this.sy, this.sw, this.sh, x, y, this.dw, this.dh);
      }
    };

    return Hero;

  })(Sprite);

  Game = (function() {

    function Game() {
      this.main = __bind(this.main, this);
    }

    Game.prototype.keysDown = {};

    Game.prototype.offsetX = 0;

    Game.prototype.offsetY = 0;

    Game.prototype.setup = function() {
      var _this = this;
      this.world = new World;
      this.canvas = document.createElement("canvas");
      this.ctx = this.canvas.getContext("2d");
      this.canvas.width = 100;
      this.canvas.height = 100;
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
      this.hero.x = (this.world.width / 2) - 16;
      return this.hero.y = (this.world.height / 2) - 16;
    };

    Game.prototype.update = function(modifier) {
      var velocity;
      velocity = this.hero.speed * modifier;
      if (38 in this.keysDown && this.hero.y - velocity > 0) {
        this.hero.y -= velocity;
      }
      if (40 in this.keysDown && this.hero.y + velocity < this.world.height - 32) {
        this.hero.y += velocity;
      }
      if (37 in this.keysDown && this.hero.x - velocity > 0) {
        this.hero.x -= velocity;
      }
      if (39 in this.keysDown && this.hero.x + velocity < this.world.width - 32) {
        this.hero.x += velocity;
      }
      return this.ctx.clearRect(0, 0, 100, 100);
    };

    Game.prototype.render = function() {
      this.background.draw(this.ctx, this.hero.x, this.hero.y);
      this.hero.draw(this.ctx);
      return this.monster.draw(this.ctx, this.hero.x, this.hero.y);
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
