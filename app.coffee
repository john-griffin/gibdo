$ = jQuery
$ -> 
  game = new Game
  game.run()

class Hero
  image: null
  ready: false
  speed: 256
  x: null
  y: null

  constructor: ->
    image = new Image
    image.src = "images/hero.png"
    image.onload = => @ready = true
    @image = image

  draw: (ctx) ->
    ctx.drawImage(@image, @x, @y) if @ready

class Game
  then: null
  hero: null
  canvas: null
  ctx: null
  keysDown: null

  setup: ->
    @canvas = document.createElement("canvas")
    @ctx = @canvas.getContext("2d")
    @canvas.width = 512
    @canvas.height = 480
    document.body.appendChild(@canvas)
    @hero = new Hero

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
    @hero.draw(@ctx)

  main: =>
    now = Date.now()
    delta = now - @then
    @update(delta / 1000)
    @render()
    @then = now

  constructor: ->
    @keysDown = {}

  run: ->
    @setup()
    @reset()
    @then = Date.now()
    setInterval(@main, 1)