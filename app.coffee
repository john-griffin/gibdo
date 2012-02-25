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
  sprites: []

  constructor: ->
    @ctx = @createCanvas()
    @hero = new Hero
    @sprites.push(new Background)
    @sprites.push(new Monster)
    @sprites.push(@hero)

  createCanvas: ->
    canvas = document.createElement("canvas")
    canvas.width = 100
    canvas.height = 100
    document.body.appendChild(canvas)
    canvas.getContext("2d")

  reset: ->
    @hero.x = (@width / 2) - 16
    @hero.y = (@height / 2) - 16

  render: -> sprite.draw(@ctx, @hero.x, @hero.y) for sprite in @sprites

  up:    (mod) -> @hero.up(mod)
  down:  (mod) -> @hero.down(mod, @height)
  left:  (mod) -> @hero.left(mod)
  right: (mod) -> @hero.right(mod, @width)

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
    x = 0 if herox < 34
    y = 0 if heroy < 34
    x = 512 - 100 if herox > 446
    y = 480 - 100 if heroy > 414
    ctx.drawImage(@image, x, y, @sw, @sh, @dx, @dy, @dw, @dh) if @ready

class Entitiy extends Sprite
  drawOffset: (ctx, x, y, offsetX = @x, offsetY = @y) ->
    x = @x if offsetX < 34
    y = @y if offsetY < 34

    x = @x - 412 if offsetX > 446
    y = @y - 380 if offsetY > 414

    ctx.drawImage(@image, @sx, @sy, @sw, @sh, x, y, @dw, @dh) if @ready


class Monster extends Entitiy
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
    @drawOffset(ctx, x, y, herox, heroy)

class Hero extends Entitiy
  # 32 x 32
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  speed: 256
  imageUrl: "images/hero.png"

  draw: (ctx) -> @drawOffset(ctx, 34, 34)

  velocity: (mod) -> @speed * mod

  up:    (mod)         -> @y -= @velocity(mod) if @y - @velocity(mod) > 0
  down:  (mod, height) -> @y += @velocity(mod) if @y + @velocity(mod) < height - 32
  left:  (mod)         -> @x -= @velocity(mod) if @x - @velocity(mod) > 0
  right: (mod, width)  -> @x += @velocity(mod) if @x + @velocity(mod) < width - 32

class InputHandler
  keysDown: {}

  constructor: (@world) ->
    $("body").keydown (e) => @keysDown[e.keyCode] = true
    $("body").keyup (e)   => delete @keysDown[e.keyCode]

  update: (modifier) ->
    @world.up(modifier)    if 38 of @keysDown
    @world.down(modifier)  if 40 of @keysDown
    @world.left(modifier)  if 37 of @keysDown
    @world.right(modifier) if 39 of @keysDown

class Game
  setup: ->
    @world = new World
    @inputHandler = new InputHandler(@world)

  reset: -> @world.reset()

  update: (modifier) -> @inputHandler.update(modifier)

  render: -> @world.render()

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