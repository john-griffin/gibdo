(function() {
  var $, Background, Entity, Game, Hero, InputHandler, Monster, Sprite, World,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  $ = Zepto;

  $(function() {
    var game;
    game = new Game;
    return game.run();
  });

  Game = (function() {

    function Game() {
      this.main = __bind(this.main, this);
    }

    Game.prototype.setup = function() {
      this.world = new World;
      return this.inputHandler = new InputHandler(this.world);
    };

    Game.prototype.reset = function() {
      return this.world.reset();
    };

    Game.prototype.update = function(modifier) {
      return this.inputHandler.update(modifier);
    };

    Game.prototype.render = function() {
      return this.world.render();
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

  World = (function() {

    World.prototype.width = 512;

    World.prototype.height = 480;

    World.prototype.viewWidth = 400;

    World.prototype.viewHeight = 300;

    World.prototype.sprites = [];

    function World() {
      this.ctx = this.createCanvas();
      this.hero = new Hero(this);
      this.sprites.push(new Background(this));
      this.sprites.push(new Monster(this));
      this.sprites.push(this.hero);
    }

    World.prototype.createCanvas = function() {
      var canvas;
      canvas = document.createElement("canvas");
      canvas.width = this.viewWidth;
      canvas.height = this.viewHeight;
      $("body").append(canvas);
      return canvas.getContext("2d");
    };

    World.prototype.reset = function() {
      return this.hero.reset(this.width, this.height);
    };

    World.prototype.heroViewOffsetX = function() {
      return this.hero.viewOffsetX(this.viewWidth);
    };

    World.prototype.heroViewOffsetY = function() {
      return this.hero.viewOffsetY(this.viewHeight);
    };

    World.prototype.viewWidthLimit = function() {
      return this.width - this.viewWidth;
    };

    World.prototype.viewHeightLimit = function() {
      return this.height - this.viewHeight;
    };

    World.prototype.atViewLimitLeft = function() {
      return this.hero.x < this.heroViewOffsetX();
    };

    World.prototype.atViewLimitTop = function() {
      return this.hero.y < this.heroViewOffsetY();
    };

    World.prototype.atViewLimitRight = function() {
      return this.hero.x > this.viewWidthLimit() + this.heroViewOffsetX();
    };

    World.prototype.atViewLimitBottom = function() {
      return this.hero.y > this.viewHeightLimit() + this.heroViewOffsetY();
    };

    World.prototype.render = function() {
      var heroOffsetX, heroOffsetY, sprite, _i, _len, _ref, _results;
      heroOffsetX = this.hero.viewOffsetX(this.viewWidth);
      heroOffsetY = this.hero.viewOffsetY(this.viewHeight);
      _ref = this.sprites;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sprite = _ref[_i];
        _results.push(sprite.draw());
      }
      return _results;
    };

    World.prototype.up = function(mod) {
      return this.hero.up(mod);
    };

    World.prototype.down = function(mod) {
      return this.hero.down(mod, this.height);
    };

    World.prototype.left = function(mod) {
      return this.hero.left(mod);
    };

    World.prototype.right = function(mod) {
      return this.hero.right(mod, this.width);
    };

    return World;

  })();

  InputHandler = (function() {

    InputHandler.prototype.keysDown = {};

    function InputHandler(world) {
      var _this = this;
      this.world = world;
      $("body").keydown(function(e) {
        return _this.keysDown[e.keyCode] = true;
      });
      $("body").keyup(function(e) {
        return delete _this.keysDown[e.keyCode];
      });
    }

    InputHandler.prototype.update = function(modifier) {
      if (38 in this.keysDown) this.world.up(modifier);
      if (40 in this.keysDown) this.world.down(modifier);
      if (37 in this.keysDown) this.world.left(modifier);
      if (39 in this.keysDown) return this.world.right(modifier);
    };

    return InputHandler;

  })();

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

    function Sprite(world) {
      var image,
        _this = this;
      this.world = world;
      image = new Image;
      image.src = this.imageUrl;
      image.onload = function() {
        return _this.ready = true;
      };
      this.image = image;
    }

    Sprite.prototype.drawImage = function(sx, sy, dx, dy) {
      if (this.ready) {
        return this.world.ctx.drawImage(this.image, sx, sy, this.sw, this.sh, dx, dy, this.dw, this.dh);
      }
    };

    return Sprite;

  })();

  Background = (function(_super) {

    __extends(Background, _super);

    Background.prototype.imageUrl = "images/background.png";

    function Background(world) {
      this.dw = world.viewWidth;
      this.dh = world.viewHeight;
      this.sw = world.viewWidth;
      this.sh = world.viewHeight;
      Background.__super__.constructor.call(this, world);
    }

    Background.prototype.draw = function() {
      var x, y;
      x = this.world.hero.x - this.world.heroViewOffsetX();
      y = this.world.hero.y - this.world.heroViewOffsetY();
      if (this.world.atViewLimitLeft()) x = 0;
      if (this.world.atViewLimitTop()) y = 0;
      if (this.world.atViewLimitRight()) x = this.world.viewWidthLimit();
      if (this.world.atViewLimitBottom()) y = this.world.viewHeightLimit();
      return this.drawImage(x, y, this.dx, this.dy);
    };

    return Background;

  })(Sprite);

  Entity = (function(_super) {

    __extends(Entity, _super);

    function Entity() {
      Entity.__super__.constructor.apply(this, arguments);
    }

    Entity.prototype.draw = function() {
      if (this.world.atViewLimitLeft()) this.dx = this.x;
      if (this.world.atViewLimitTop()) this.dy = this.y;
      if (this.world.atViewLimitRight()) {
        this.dx = this.x - this.world.viewWidthLimit();
      }
      if (this.world.atViewLimitBottom()) {
        this.dy = this.y - this.world.viewHeightLimit();
      }
      return this.drawImage(this.sx, this.sy, this.dx, this.dy);
    };

    return Entity;

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

    Monster.prototype.draw = function() {
      this.dx = this.x - this.world.hero.x + this.world.heroViewOffsetX();
      this.dy = this.y - this.world.hero.y + this.world.heroViewOffsetY();
      return Monster.__super__.draw.apply(this, arguments);
    };

    return Monster;

  })(Entity);

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

    Hero.prototype.draw = function() {
      this.dx = this.world.heroViewOffsetX();
      this.dy = this.world.heroViewOffsetY();
      return Hero.__super__.draw.apply(this, arguments);
    };

    Hero.prototype.velocity = function(mod) {
      return this.speed * mod;
    };

    Hero.prototype.up = function(mod) {
      if (this.y - this.velocity(mod) > 0) return this.y -= this.velocity(mod);
    };

    Hero.prototype.down = function(mod, height) {
      if (this.y + this.velocity(mod) < height - this.dh) {
        return this.y += this.velocity(mod);
      }
    };

    Hero.prototype.left = function(mod) {
      if (this.x - this.velocity(mod) > 0) return this.x -= this.velocity(mod);
    };

    Hero.prototype.right = function(mod, width) {
      if (this.x + this.velocity(mod) < width - this.dw) {
        return this.x += this.velocity(mod);
      }
    };

    Hero.prototype.viewOffsetX = function(width) {
      return (width / 2) - (this.dw / 2);
    };

    Hero.prototype.viewOffsetY = function(height) {
      return (height / 2) - (this.dh / 2);
    };

    Hero.prototype.reset = function(width, height) {
      this.x = this.viewOffsetX(width);
      return this.y = this.viewOffsetY(height);
    };

    return Hero;

  })(Entity);

}).call(this);
