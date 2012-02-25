(function() {
  var $, Background, Entitiy, Game, Hero, InputHandler, Monster, Sprite, World,
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

    World.prototype.width = 512;

    World.prototype.height = 480;

    function World() {
      this.ctx = this.createCanvas();
      this.hero = new Hero;
      this.background = new Background;
      this.monster = new Monster;
    }

    World.prototype.createCanvas = function() {
      var canvas;
      canvas = document.createElement("canvas");
      canvas.width = 100;
      canvas.height = 100;
      document.body.appendChild(canvas);
      return canvas.getContext("2d");
    };

    World.prototype.reset = function() {
      this.hero.x = (this.width / 2) - 16;
      return this.hero.y = (this.height / 2) - 16;
    };

    World.prototype.render = function() {
      this.background.draw(this.ctx, this.hero.x, this.hero.y);
      this.hero.draw(this.ctx);
      return this.monster.draw(this.ctx, this.hero.x, this.hero.y);
    };

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
      if (herox < 34) x = 0;
      if (heroy < 34) y = 0;
      if (herox > 446) x = 512 - 100;
      if (heroy > 414) y = 480 - 100;
      if (this.ready) {
        return ctx.drawImage(this.image, x, y, this.sw, this.sh, this.dx, this.dy, this.dw, this.dh);
      }
    };

    return Background;

  })(Sprite);

  Entitiy = (function(_super) {

    __extends(Entitiy, _super);

    function Entitiy() {
      Entitiy.__super__.constructor.apply(this, arguments);
    }

    Entitiy.prototype.drawOffset = function(ctx, x, y, offsetX, offsetY) {
      if (offsetX == null) offsetX = this.x;
      if (offsetY == null) offsetY = this.y;
      if (offsetX < 34) x = this.x;
      if (offsetY < 34) y = this.y;
      if (offsetX > 446) x = this.x - 412;
      if (offsetY > 414) y = this.y - 380;
      if (this.ready) {
        return ctx.drawImage(this.image, this.sx, this.sy, this.sw, this.sh, x, y, this.dw, this.dh);
      }
    };

    return Entitiy;

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
      return this.drawOffset(ctx, x, y, herox, heroy);
    };

    return Monster;

  })(Entitiy);

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
      return this.drawOffset(ctx, 34, 34);
    };

    return Hero;

  })(Entitiy);

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
      var hero, velocity;
      hero = this.world.hero;
      velocity = hero.speed * modifier;
      if (38 in this.keysDown && hero.y - velocity > 0) hero.y -= velocity;
      if (40 in this.keysDown && hero.y + velocity < this.world.height - 32) {
        hero.y += velocity;
      }
      if (37 in this.keysDown && hero.x - velocity > 0) hero.x -= velocity;
      if (39 in this.keysDown && hero.x + velocity < this.world.width - 32) {
        return hero.x += velocity;
      }
    };

    return InputHandler;

  })();

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

}).call(this);
