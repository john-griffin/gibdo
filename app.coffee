$ -> new Game

class Hero
  image: null
  ready: false
  speed: null
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

  setup: ->
    @canvas = document.createElement("canvas")
    @ctx = @canvas.getContext("2d")
    @canvas.width = 512
    @canvas.height = 480
    document.body.appendChild(@canvas)
    @hero = new Hero

  reset: ->
    @hero.x = @canvas.width / 2
    @hero.y = @canvas.height / 2

  update: (modifier) ->
    # do something

  render: ->
    @hero.draw(@ctx)

  main: =>
    now = Date.now()
    delta = now - @then
    @update(delta / 1000)
    @render()
    @then = now

  constructor: ->
    @setup()
    @reset()
    @then = Date.now()
    setInterval(@main, 1)