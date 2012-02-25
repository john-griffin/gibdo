$ = Zepto
$ -> 
  game = new Game
  game.run()

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
    document.body.appendChild(canvas)
    canvas.getContext("2d")

  reset: -> @hero.reset(@width, @height)

  heroViewOffsetX: -> @hero.viewOffsetX(@viewWidth)
  heroViewOffsetY: -> @hero.viewOffsetY(@viewHeight)

  viewWidthLimit:  -> @width  - @viewWidth
  viewHeightLimit: -> @height - @viewHeight

  render: -> 
    heroOffsetX = @hero.viewOffsetX(@viewWidth)
    heroOffsetY = @hero.viewOffsetY(@viewHeight)
    sprite.draw(@ctx, heroOffsetX, heroOffsetY, @viewWidth, @viewHeight, @width, @height, @hero.x, @hero.y) for sprite in @sprites

  up:    (mod) -> @hero.up(mod)
  down:  (mod) -> @hero.down(mod, @height)
  left:  (mod) -> @hero.left(mod)
  right: (mod) -> @hero.right(mod, @width)

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

  constructor: (@world) ->
    image = new Image
    image.src = @imageUrl
    image.onload = => @ready = true
    @image = image

class Background extends Sprite
  # 512x480
  imageUrl: "images/background.png"

  constructor: (world) ->
    @dw = world.viewWidth
    @dh = world.viewHeight
    @sw = world.viewWidth
    @sh = world.viewHeight
    super(world)

  draw: -> 
    x = @world.hero.x - @world.heroViewOffsetX()
    y = @world.hero.y - @world.heroViewOffsetY()
    x = 0 if @world.hero.x < @world.heroViewOffsetX()
    y = 0 if @world.hero.y < @world.heroViewOffsetY()
    x = @world.viewWidthLimit() if @world.hero.x > @world.viewWidthLimit() + @world.heroViewOffsetX()
    y = @world.viewHeightLimit() if @world.hero.y > @world.viewHeightLimit() + @world.heroViewOffsetY()
    @world.ctx.drawImage(@image, x, y, @sw, @sh, @dx, @dy, @dw, @dh) if @ready

class Entity extends Sprite
  drawOffset: (x, y, offsetX = @x, offsetY = @y) ->
    x = @x if offsetX < @world.heroViewOffsetX()
    y = @y if offsetY < @world.heroViewOffsetY()
    x = @x - @world.viewWidthLimit() if offsetX > @world.viewWidthLimit() + @world.heroViewOffsetX()
    y = @y - @world.viewHeightLimit() if offsetY > @world.viewHeightLimit() + @world.heroViewOffsetY()

    @world.ctx.drawImage(@image, @sx, @sy, @sw, @sh, x, y, @dw, @dh) if @ready


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

  draw: -> 
    x = @x - @world.hero.x + @world.heroViewOffsetX()
    y = @y - @world.hero.y + @world.heroViewOffsetY()
    @drawOffset(x, y, @world.hero.x, @world.hero.y)

class Hero extends Entity
  # 32 x 32
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  speed: 256
  imageUrl: "images/hero.png"

  draw: -> @drawOffset(@world.heroViewOffsetX(), @world.heroViewOffsetY())

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