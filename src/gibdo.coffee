# ![Screenshot](resources/game.png)

# [Gibdo](https://github.com/john-griffin/gibdo) is a starting point for creating HTML5 Canvas games in a 
# top-down 2D style. It is written in [CoffeeScript](http://coffeescript.org/) 
# and provides the following features,
# 
# * A scrolling view window that tracks the player across the game world.
# * View limit detection to allow the player to move off the centre
# of the screen as edges are reached.
# * Collision detection.
# * Keyboard input.
# * Sprite animation.
# 
# Try it out [here](http://john-griffin.github.com/gibdo/public/index.html).

# [Zepto.js](http://zeptojs.com/) is used for event handling

$ = Zepto

# Helper for animating efficiently using request animation frame when available

window.requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
    window.setTimeout callback, 1000 / 60
)()

# Create a new instance of the game and get it running.

$ -> 
  game = new Game
  game.run()

# ## Game
# The game class handles top level game loop and initialisation.
class Game
  # Start the game in a default state and initiate the game loop. 
  # It attempts to run the loop every 1 millisecond but in reality 
  # the loop is just running as fast as it can.  
  run: ->
    @setup()
    @reset()
    @then = Date.now()
    @animate()

  # Animate the game
  animate: =>
    requestAnimFrame(@animate)
    @main()

  # Create a new game world and keyboard input handler
  setup: ->
    @world = new World
    @inputHandler = new InputHandler(@world)

  # Nothing is reset at this level so just ask the world to reset itself.
  reset: -> @world.reset()

  # The main game loop. Establish the time since the loop last ran
  # in seconds and pass that through to the update method for recalculating
  # sprite positions. After recalculation positions, render the sprites.
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

# ## World
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
    @column = new Column(this)
    @sprites.push(new Background(this))
    @sprites.push(new Monster(this))
    @sprites.push(@column)
    @sprites.push(@hero)

  # Create an HTML5 canvas element and append it to the document
  createCanvas: ->
    canvas = document.createElement("canvas")
    canvas.width = @viewWidth
    canvas.height = @viewHeight
    $(".container .game").append(canvas)
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

  # Tell all the sprites to render.
  render: (lastUpdate, lastElapsed) -> 
    sprite.draw() for sprite in @sprites
    @renderDebugOverlay(lastElapsed)

  # Show the frames per second at the top of the view.
  renderDebugOverlay: (lastElapsed) ->
    @ctx.save()
    @ctx.fillStyle = "rgb(241, 241, 242)"
    @ctx.font = "Bold 20px Monospace"
    @ctx.fillText("#{Math.round(1e3 / lastElapsed)} FPS", 10, 20)
    @ctx.restore()

  # Pass any keyboard events that come in from the input
  # handler off to the hero.
  up:    (mod) -> @hero.up(mod)
  down:  (mod) -> @hero.down(mod, @height)
  left:  (mod) -> @hero.left(mod)
  right: (mod) -> @hero.right(mod, @width)

  # Find the sprites that have collision detection enabled.
  collidableSprites: -> sprite for sprite in @sprites when sprite.collidable

# ## InputHandler
# Responsible for dealing with keyboard input.
class InputHandler
  keysDown: {}

  # Listen for keys being presses and being released. As this happens
  # add and remove them from the key store.
  constructor: (@world) ->
    $("body").keydown (e) => @keysDown[e.keyCode] = true
    $("body").keyup (e)   => delete @keysDown[e.keyCode]

  # Every time update is called from the game loop act on the currently
  # pressed keys by passing the events on to the world.
  update: (modifier) ->
    @world.up(modifier)    if 38 of @keysDown
    @world.down(modifier)  if 40 of @keysDown
    @world.left(modifier)  if 37 of @keysDown
    @world.right(modifier) if 39 of @keysDown

# ## SpriteImage
# Wraps sprite loading.
class SpriteImage
  ready: false
  url: "images/sheet.png"

  # Create a new image based on the sprite file and set
  # ready to true when loaded.
  constructor: ->
    image = new Image
    image.src = @url
    image.onload = => @ready = true
    @image = image

# ## Sprite
class Sprite
  # The base class from which all sprites get their draw function
  # and default values from.
  # 
  # Configure sane defaults for sprite positions and dimensions.
  sx: 0 # Source x position
  sy: 0 # Source y position
  sw: 0 # Source width
  sh: 0 # Source height
  dx: 0 # Destination x position
  dy: 0 # Destination y position
  dw: 0 # Destination width
  dh: 0 # Destination height
  x:  0 # Position x in the world
  y:  0 # Position y in the world
  image: new SpriteImage
  collidable: false

  constructor: (@world) ->

  # If the image is loaded then draw the sprite on to the canvas.
  drawImage: (sx, sy, dx, dy) ->
    if @image.ready
      @world.ctx.drawImage(@image.image, sx, sy, @sw, @sh, dx, dy, @dw, @dh)

# ## Background
# The sprite that represents the floor or level on which the other sprites
# walk around on.
class Background extends Sprite
  # As the background represents the entire world it's source image
  # has the same dimensions.
  constructor: (world) ->
    @dw = world.viewWidth
    @dh = world.viewHeight
    @sw = world.viewWidth
    @sh = world.viewHeight
    super(world)

  draw: ->
    # The background moves as the hero does.
    x = @world.hero.x - @world.heroViewOffsetX()
    y = @world.hero.y - @world.heroViewOffsetY()
    # Prevent the background from scrolling at the start of the world.
    x = 0 if @world.atViewLimitLeft()
    y = 0 if @world.atViewLimitTop()
    # Prevent the background from scrolling at the end of the world.
    x = @world.viewWidthLimit() if @world.atViewLimitRight()
    y = @world.viewHeightLimit() if @world.atViewLimitBottom()
    @drawImage(x, y, @dx, @dy)

# ## Entity
# Entities are non-background sprites that share a common draw
# function as they need to be offset from the player differently.
class Entity extends Sprite
  draw: ->
    # When the view is at the start of the world the sprites can be
    # drawn at their full world co-ordinates.
    @dx = @x if @world.atViewLimitLeft()
    @dy = @y if @world.atViewLimitTop()
    # When the view is at the end of the world the sprites are drawn
    # as an offset from the edge of the world.
    @dx = @x - @world.viewWidthLimit() if @world.atViewLimitRight()
    @dy = @y - @world.viewHeightLimit() if @world.atViewLimitBottom()
    @drawImage(@sx, @sy, @dx, @dy)

# ## Monster
# An example collidable stationary sprite.
class Monster extends Entity
  x:  400
  y:  400
  sw: 30
  sh: 32
  dw: 30
  dh: 32
  sy: 480
  collidable: true

  # Offset the view co-ordinates from the player.
  draw: -> 
    @dx = @x - @world.hero.x + @world.heroViewOffsetX()
    @dy = @y - @world.hero.y + @world.heroViewOffsetY()
    super

# ## Column
# Another example of a collidable stationary sprite.
class Column extends Entity
  x:  300
  y:  300
  sw: 32
  sh: 32
  dw: 32
  dh: 32
  sy: 544
  collidable: true

  # Offset the view co-ordinates from the player.
  draw: -> 
    @dx = @x - @world.hero.x + @world.heroViewOffsetX()
    @dy = @y - @world.hero.y + @world.heroViewOffsetY()
    super

# ## Hero
class Hero extends Entity
  # The sprite that represents the player and can be controlled and
  # moved through the world.
  sw:    32
  sh:    30
  dw:    32
  dh:    30
  speed: 256
  sy:    513
  direction: 0

  draw: -> 
    # By default the hero is drawn to the centre of the view.
    @dx = @world.heroViewOffsetX()
    @dy = @world.heroViewOffsetY()
    # Alternate sprite frames as the player's position changes to
    # create an animation effect.
    @sx = if Math.round(@x+@y)%64 < 32 then @direction else @direction + 32
    super

  # The player's velocity is the default speed multiplied by the 
  # current time difference.
  velocity: (mod) -> @speed * mod

  # Detect a collision between the proposed new player co-ordinates
  # and the collidable objects in the world. If the player's co-ordinates
  # fall within their bounds then it has collided.
  collision: (x, y) ->
    for o in @world.collidableSprites()
      return true if y > o.y - @dh and y < o.y + o.dh and x > o.x - @dw and x < o.x + o.dw
    false

  # Handle keyboard input. By changing the `@direction` value in each
  # function the player's sprite changes and produces the effect that 
  # makes the hero look in the direction he is travelling.
  # 
  # The player's position is modified in the direction of the key
  # press if still inside the world and no collisions are detected.
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

  # Helpers that the world uses to calculate the centre position of the
  # hero.
  viewOffsetX: (width)  -> (width / 2)   - (@dw / 2)
  viewOffsetY: (height) -> (height / 2)  - (@dh / 2)

  # The hero starts the game in the centre of the world.
  reset: (width, height) ->
    @x = @viewOffsetX(width)
    @y = @viewOffsetY(height)