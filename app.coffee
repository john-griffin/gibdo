$ = Zepto
$ -> 
  game = new Game
  game.run()

class Sprite
  ready: false
  sx: 0
  sy: 0
  sw: 0
  sh: 0
  dx: 0
  dy: 0
  dw: 0
  dh: 0
  x: 0
  y: 0

  constructor: ->
    image = new Image
    image.src = @imageUrl
    image.onload = => @ready = true
    @image = image

  draw: (ctx) -> ctx.drawImage(@image, @sx, @sy, @sw, @sh, @dx, @dy, @dw, @dh) if @ready

class World
  width: 512
  height: 480

class Background extends Sprite
  # 512x480
  sw: 100
  sh: 100
  dw: 100
  dh: 100
  imageUrl: "images/background.png"

  draw: (ctx, herox, heroy) -> 
    x = herox - 34
    y = heroy - 34
    x = 0 if x <= 0
    y = 0 if y <= 0
    x = 512 - 100 if x >= 512 - 100
    y = 480 - 100 if y >= 480 - 100
    ctx.drawImage(@image, x, y, @sw, @sh, @dx, @dy, @dw, @dh) if @ready

class Monster extends Sprite
  # 30 x 32
  speed: 128
  imageUrl: "images/monster.png"
  x: 400
  y: 400
  sw: 30
  sh: 32
  dw: 30
  dh: 32

  draw: (ctx, herox, heroy) -> 
    x = @x - herox + 34
    y = @y - heroy + 34

    x = @x if herox - 34 <= 0
    y = @y if heroy - 34 <= 0

    x = @x - 412 if herox >= 444
    y = @y - 380 if heroy >= 412

    # console.log herox - 34, heroy - 34
    ctx.drawImage(@image, @sx, @sy, @sw, @sh, x, y, @dw, @dh) if @ready

class Hero extends Sprite
  # 32 x 32
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  speed: 256
  imageUrl: "images/hero.png"

  draw: (ctx) -> 
    x = 32
    y = 32
    x = @x if @x < 32
    y = @y if @y < 32

    x = @x - 412 if @x > 444
    y = @y - 380 if @y > 412

    # console.log @x, @y 
    ctx.drawImage(@image, @sx, @sy, @sw, @sh, x, y, @dw, @dh) if @ready

class Game
  keysDown: {}
  offsetX: 0
  offsetY: 0

  setup: ->
    @world = new World
    @canvas = document.createElement("canvas")
    @ctx = @canvas.getContext("2d")
    @canvas.width = 100
    @canvas.height = 100
    document.body.appendChild(@canvas)
    @hero = new Hero
    @background = new Background
    @monster = new Monster
    $("body").keydown (e) => @keysDown[e.keyCode] = true
    $("body").keyup (e) => delete @keysDown[e.keyCode]

  reset: ->
    @hero.x = (@world.width / 2) - 16
    @hero.y = (@world.height / 2) - 16

  update: (modifier) ->
    # console.log modifier
    # Player holding up
    velocity = @hero.speed * modifier
    @hero.y -= velocity if 38 of @keysDown and @hero.y - velocity > 0
    # Player holding down
    @hero.y += velocity if 40 of @keysDown and @hero.y + velocity < @world.height - 32
    # Player holding left
    @hero.x -= velocity if 37 of @keysDown and @hero.x - velocity > 0
    # Player holding right
    @hero.x += velocity if 39 of @keysDown and @hero.x + velocity < @world.width - 32

    @ctx.clearRect(0,0,100,100)

  render: ->
    @background.draw(@ctx, @hero.x, @hero.y)
    @hero.draw(@ctx)
    @monster.draw(@ctx, @hero.x, @hero.y)

  main: =>
    now = Date.now()
    delta = now - @then
    @update(delta / 1000)
    @render()
    @then = now

  run: ->
    @setup()
    @reset()
    @then = Date.now()
    setInterval(@main, 1)