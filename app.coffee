$ = jQuery
$ -> 
  game = new Game
  game.run()

class Sprite
  ready: false
  x: 0
  y: 0

  constructor: ->
    image = new Image
    image.src = @imageUrl
    image.onload = => @ready = true
    @image = image

  draw: (ctx) -> ctx.drawImage(@image, @x, @y) if @ready

class Background extends Sprite
  imageUrl: "images/background.png"

class Hero extends Sprite
  speed: 256
  imageUrl: "images/hero.png"

class Game
  keysDown: {}

  setup: ->
    @canvas = document.createElement("canvas")
    @ctx = @canvas.getContext("2d")
    @canvas.width = 512
    @canvas.height = 480
    document.body.appendChild(@canvas)
    @hero = new Hero
    @background = new Background

    $("body").keydown (e) =>
      @keysDown[e.keyCode] = true
    $("body").keyup (e) =>
      delete @keysDown[e.keyCode]

  reset: ->
    @hero.x = @canvas.width / 2
    @hero.y = @canvas.height / 2

  update: (modifier) ->
    # Player holding up
    @hero.y -= @hero.speed * modifier if 38 of @keysDown
    # Player holding down
    @hero.y += @hero.speed * modifier if 40 of @keysDown
    # Player holding left
    @hero.x -= @hero.speed * modifier if 37 of @keysDown
    # Player holding right
    @hero.x += @hero.speed * modifier if 39 of @keysDown

  render: ->
    @background.draw(@ctx)
    @hero.draw(@ctx)

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