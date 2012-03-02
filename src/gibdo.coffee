# ![Screenshot](game.png)

# Gibdo is a starting point for creating HTML5 Canvas games in a 
# top-down 2D style. It is written in [CoffeeScript](http://coffeescript.org/) 
# and provides the following features,
# 
# * A scrolling view window that tracks the player across the game world.
# * View edge detection to allow the player to move off the centre
# of the screen as edges are reached.
# * Collision detection.
# * Keyboard input.
# * Sprite animation.

# [Zepto.js](http://zeptojs.com/) is used for event handling

$ = Zepto

# Create a new instance of the game and get it running.

$ -> 
  game = new Game
  game.run()

# The game class handles top level game loop and initialisation.

class Game
  # Start the game in a default state and initiate the game loop. 
  # It attempts to run the loop every 1 millisecond but in reality 
  # the loop is just running as fast as it can.  
  run: ->
    @setup()
    @reset()
    @then = Date.now()
    setInterval(@main, 1)

  # Create a new game world and keyboard input handler
  setup: ->
    @world = new World
    @inputHandler = new InputHandler(@world)

  # Nothing is reset at this level so just ask the world to reset itself.
  reset: -> @world.reset()

  # The main game loop. Establish the time since the loop last ran
  # in seconds and pass that through to the update method for recalculating
  # sprite positions. After recalulation positions, render the sprites.
  main: =>
    now = Date.now()
    delta = now - @lastUpdate
    @lastUpdate = now
    @lastElapsed = delta
    @update(delta / 1000)
    @render()

  # Updates are handled by the input handler.
  update: (modifier) -> @inputHandler.update(modifier)

  # Tell the world to rerender itself.
  render: -> @world.render(@lastUpdate, @lastElapsed)

# The World class manages the game world and what can be seen
# by the player.
class World
  width: 512
  height: 480
  viewWidth: 400
  viewHeight: 300
  sprites: []

  # When the world is created it adds a canvas to the page and
  # inserts all the sprites that are needed into the sprite array.
  constructor: ->
    @ctx = @createCanvas()
    @hero = new Hero(this)
    @collumn = new Collumn(this)
    @sprites.push(new Background(this))
    @sprites.push(new Monster(this))
    @sprites.push(@collumn)
    @sprites.push(@hero)

  # Create an HTML5 canvas element and append it to the document
  createCanvas: ->
    canvas = document.createElement("canvas")
    canvas.width = @viewWidth
    canvas.height = @viewHeight
    $("body").append(canvas)
    canvas.getContext("2d")

  # Only the hero (player character) needs to be reset.
  reset: -> @hero.reset(@width, @height)

  # The co-ordinates the hero occupies in the centre of the view.
  heroViewOffsetX: -> @hero.viewOffsetX(@viewWidth)
  heroViewOffsetY: -> @hero.viewOffsetY(@viewHeight)

  # The maximum co-ordinates the view can scroll to.
  viewWidthLimit:  -> @width  - @viewWidth
  viewHeightLimit: -> @height - @viewHeight

  # Check to see if the hero is at the limits of the world.
  atViewLimitLeft:   -> @hero.x < @heroViewOffsetX()
  atViewLimitTop:    -> @hero.y < @heroViewOffsetY()
  atViewLimitRight:  -> @hero.x > @viewWidthLimit() + @heroViewOffsetX()
  atViewLimitBottom: -> @hero.y > @viewHeightLimit() + @heroViewOffsetY()

  render: (lastUpdate, lastElapsed) -> 
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

  collidableSprites: -> sprite for sprite in @sprites when sprite.collidable

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
  collidable: false

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
  collidable: true

  draw: -> 
    @dx = @x - @world.hero.x + @world.heroViewOffsetX()
    @dy = @y - @world.hero.y + @world.heroViewOffsetY()
    super

class Collumn extends Entity
  x: 300
  y: 300
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  sy: 544
  collidable: true

  draw: -> 
    @dx = @x - @world.hero.x + @world.heroViewOffsetX()
    @dy = @y - @world.hero.y + @world.heroViewOffsetY()
    super

class Hero extends Entity
  # 32 x 32
  sw: 32
  sh: 30
  dw: 32
  dh: 30
  speed: 256
  sy: 513
  direction: 0

  draw: -> 
    @dx = @world.heroViewOffsetX()
    @dy = @world.heroViewOffsetY()
    @sx = if Math.round(@x+@y)%64 < 32 then @direction else @direction + 32
    super

  velocity: (mod) -> @speed * mod

  collision: (x, y) ->
    for o in @world.collidableSprites()
      return true if y > o.y - @dh and y < o.y + o.dh and x > o.x - @dw and x < o.x + o.dw
    false

  up: (mod) -> 
    @direction = 64
    y = @y - @velocity(mod)
    @y -= @velocity(mod) if y > 0 and !@collision(@x, y)
  down: (mod, height) -> 
    @direction = 0
    y = @y + @velocity(mod)
    @y += @velocity(mod) if y < height - @dh and !@collision(@x, y)
  left: (mod) -> 
    @direction = 128
    x = @x - @velocity(mod)
    @x -= @velocity(mod) if x > 0 and !@collision(x, @y)
  right: (mod, width) -> 
    @direction = 192
    x = @x + @velocity(mod)
    @x += @velocity(mod) if x < width - @dw and !@collision(x, @y)

  viewOffsetX: (width)  -> (width / 2)   - (@dw / 2)
  viewOffsetY: (height) -> (height / 2)  - (@dh / 2)

  reset: (width, height) ->
    @x = @viewOffsetX(width)
    @y = @viewOffsetY(height)