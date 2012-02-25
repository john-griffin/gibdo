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

class World
  width: 512
  height: 480
  viewWidth: 100
  viewHeight: 100
  sprites: []

  constructor: ->
    @ctx = @createCanvas()
    @hero = new Hero
    @sprites.push(new Background(@viewWidth, @viewHeight))
    @sprites.push(new Monster)
    @sprites.push(@hero)

  createCanvas: ->
    canvas = document.createElement("canvas")
    canvas.width = @viewWidth
    canvas.height = @viewHeight
    document.body.appendChild(canvas)
    canvas.getContext("2d")

  reset: -> @hero.reset(@width, @height)

  render: -> 
    heroOffsetX = @hero.viewOffsetX(@viewWidth)
    heroOffsetY = @hero.viewOffsetY(@viewHeight)
    sprite.draw(@ctx, heroOffsetX, heroOffsetY, @viewWidth, @viewHeight, @width, @height, @hero.x, @hero.y) for sprite in @sprites

  up:    (mod) -> @hero.up(mod)
  down:  (mod) -> @hero.down(mod, @height)
  left:  (mod) -> @hero.left(mod)
  right: (mod) -> @hero.right(mod, @width)

class Background extends Sprite
  # 512x480
  imageUrl: "images/background.png"

  constructor: (@dw, @dh) ->
    @sw = @dw
    @sh = @dh
    super

  draw: (ctx, heroOffsetX, heroOffsetY, viewWidth, viewHeight, gameWidth, gameHeight, herox, heroy) -> 
    x = herox - heroOffsetX
    y = heroy - heroOffsetY
    x = 0 if herox < heroOffsetX
    y = 0 if heroy < heroOffsetY
    x = gameWidth - viewWidth if herox > gameWidth - viewWidth + heroOffsetX
    y = gameHeight - viewHeight if heroy > gameHeight - viewHeight + heroOffsetY
    ctx.drawImage(@image, x, y, @sw, @sh, @dx, @dy, @dw, @dh) if @ready

class Entity extends Sprite
  drawOffset: (ctx, heroOffsetX, heroOffsetY, viewWidth, viewHeight, gameWidth, gameHeight, x, y, offsetX = @x, offsetY = @y) ->
    x = @x if offsetX < heroOffsetX
    y = @y if offsetY < heroOffsetY
    x = @x - (gameWidth - viewWidth) if offsetX > gameWidth - viewWidth + heroOffsetX
    y = @y - (gameHeight - viewHeight) if offsetY > gameHeight - viewHeight + heroOffsetY

    ctx.drawImage(@image, @sx, @sy, @sw, @sh, x, y, @dw, @dh) if @ready


class Monster extends Entity
  # 30 x 32
  speed: 128
  imageUrl: "images/monster.png"
  x: 400
  y: 400
  sw: 30
  sh: 32
  dw: 30
  dh: 32

  draw: (ctx, heroOffsetX, heroOffsetY, viewWidth, viewHeight, gameWidth, gameHeight, herox, heroy) -> 
    x = @x - herox + heroOffsetX
    y = @y - heroy + heroOffsetY
    @drawOffset(ctx, heroOffsetX, heroOffsetY, viewWidth, viewHeight, gameWidth, gameHeight, x, y, herox, heroy)

class Hero extends Entity
  # 32 x 32
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  speed: 256
  imageUrl: "images/hero.png"

  draw: (ctx, heroOffsetX, heroOffsetY, viewWidth, viewHeight, gameWidth, gameHeight) -> 
    @drawOffset(ctx, heroOffsetX, heroOffsetY, viewWidth, viewHeight, gameWidth, gameHeight, heroOffsetX, heroOffsetY)

  velocity: (mod) -> @speed * mod

  up:    (mod)         -> @y -= @velocity(mod) if @y - @velocity(mod) > 0
  down:  (mod, height) -> @y += @velocity(mod) if @y + @velocity(mod) < height - @dh
  left:  (mod)         -> @x -= @velocity(mod) if @x - @velocity(mod) > 0
  right: (mod, width)  -> @x += @velocity(mod) if @x + @velocity(mod) < width - @dw

  viewOffsetX: (width)  -> (width / 2)   - (@dw / 2)
  viewOffsetY: (height) -> (height / 2)  - (@dh / 2)

  reset: (width, height) ->
    @x = @viewOffsetX(width)
    @y = @viewOffsetY(height)

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