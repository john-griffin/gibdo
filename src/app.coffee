# [Zepto.js](http://zeptojs.com/) is used for event handling

$ = Zepto

# Start the game loop

$ -> 
  game = new Game
  game.run()

class Game
  run: ->
    @setup()
    @reset()
    @then = Date.now()
    setInterval(@main, 1)

  setup: ->
    @world = new World
    @inputHandler = new InputHandler(@world)

  reset: -> @world.reset()

  main: =>
    now = Date.now()
    delta = now - @lastUpdate
    @lastUpdate = now
    @lastElapsed = delta
    @update(delta / 1000)
    @render()

  update: (modifier) -> @inputHandler.update(modifier)

  render: -> @world.render(@lastUpdate, @lastElapsed)

class World
  width: 512
  height: 480
  viewWidth: 400
  viewHeight: 300
  sprites: []

  constructor: ->
    @ctx = @createCanvas()
    @hero = new Hero(this)
    @sprites.push(new Background(this))
    @sprites.push(new Monster(this))
    @sprites.push(@hero)

  createCanvas: ->
    canvas = document.createElement("canvas")
    canvas.width = @viewWidth
    canvas.height = @viewHeight
    $("body").append(canvas)
    canvas.getContext("2d")

  reset: -> @hero.reset(@width, @height)

  heroViewOffsetX: -> @hero.viewOffsetX(@viewWidth)
  heroViewOffsetY: -> @hero.viewOffsetY(@viewHeight)

  viewWidthLimit:  -> @width  - @viewWidth
  viewHeightLimit: -> @height - @viewHeight

  atViewLimitLeft:   -> @hero.x < @heroViewOffsetX()
  atViewLimitTop:    -> @hero.y < @heroViewOffsetY()
  atViewLimitRight:  -> @hero.x > @viewWidthLimit() + @heroViewOffsetX()
  atViewLimitBottom: -> @hero.y > @viewHeightLimit() + @heroViewOffsetY()

  render: (lastUpdate, lastElapsed) -> 
    heroOffsetX = @hero.viewOffsetX(@viewWidth)
    heroOffsetY = @hero.viewOffsetY(@viewHeight)
    sprite.draw() for sprite in @sprites
    @ctx.save()
    @ctx.fillStyle = "rgb(241, 241, 242)"
    @ctx.font = "Bold 20px Monospace"
    @ctx.fillText("#{Math.round(1e3 / lastElapsed)} FPS", 10, 20)
    @ctx.restore()

  up:    (mod) -> @hero.up(mod)
  down:  (mod) -> @hero.down(mod, @height)
  left:  (mod) -> @hero.left(mod)
  right: (mod) -> @hero.right(mod, @width)

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

class SpriteImage
  ready: false
  url: "images/sheet.png"

  constructor: ->
    image = new Image
    image.src = @url
    image.onload = => @ready = true
    @image = image

class Sprite
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
  image: new SpriteImage

  constructor: (@world) ->

  drawImage: (sx, sy, dx, dy) ->
    if @image.ready
      @world.ctx.drawImage(@image.image, sx, sy, @sw, @sh, dx, dy, @dw, @dh)

class Background extends Sprite
  # 512x480

  constructor: (world) ->
    @dw = world.viewWidth
    @dh = world.viewHeight
    @sw = world.viewWidth
    @sh = world.viewHeight
    super(world)

  draw: -> 
    x = @world.hero.x - @world.heroViewOffsetX()
    y = @world.hero.y - @world.heroViewOffsetY()
    x = 0 if @world.atViewLimitLeft()
    y = 0 if @world.atViewLimitTop()
    x = @world.viewWidthLimit() if @world.atViewLimitRight()
    y = @world.viewHeightLimit() if @world.atViewLimitBottom()
    @drawImage(x, y, @dx, @dy)

class Entity extends Sprite
  draw: ->
    @dx = @x if @world.atViewLimitLeft()
    @dy = @y if @world.atViewLimitTop()
    @dx = @x - @world.viewWidthLimit() if @world.atViewLimitRight()
    @dy = @y - @world.viewHeightLimit() if @world.atViewLimitBottom()
    @drawImage(@sx, @sy, @dx, @dy)

class Monster extends Entity
  # 30 x 32
  speed: 128
  x: 400
  y: 400
  sw: 30
  sh: 32
  dw: 30
  dh: 32
  sy: 480

  draw: -> 
    @dx = @x - @world.hero.x + @world.heroViewOffsetX()
    @dy = @y - @world.hero.y + @world.heroViewOffsetY()
    super

class Hero extends Entity
  # 32 x 32
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  speed: 256
  sy: 512
  direction: 0

  draw: -> 
    @dx = @world.heroViewOffsetX()
    @dy = @world.heroViewOffsetY()
    @sx = if Math.round(@x+@y)%64 < 32 then @direction else @direction + 32
    super

  velocity: (mod) -> @speed * mod

  up: (mod) -> 
    @direction = 64
    @y -= @velocity(mod) if @y - @velocity(mod) > 0
  down: (mod, height) -> 
    @direction = 0
    @y += @velocity(mod) if @y + @velocity(mod) < height - @dh
  left: (mod) -> 
    @direction = 128
    @x -= @velocity(mod) if @x - @velocity(mod) > 0
  right: (mod, width) -> 
    @direction = 192
    @x += @velocity(mod) if @x + @velocity(mod) < width - @dw

  viewOffsetX: (width)  -> (width / 2)   - (@dw / 2)
  viewOffsetY: (height) -> (height / 2)  - (@dh / 2)

  reset: (width, height) ->
    @x = @viewOffsetX(width)
    @y = @viewOffsetY(height)