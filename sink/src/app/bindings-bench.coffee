app = require './index.coffee'

# Change N to change the number of drawn circles.
N = 100

app.get app.pages.bindingsBench.href, (page, model) ->
  boxes = []
  for i in [0...N]
    boxes.push
      count: 0
      top: 0
      left: 0
      color: 0
      content: 0
      i: i
  model.set '_page.boxes', boxes

  page.render 'bindingsBench',
    modes: ['setProperty', 'setBox', 'setAll']


app.enter app.pages.bindingsBench.href, (model) ->
  boxes = model.at '_page.boxes'

  tickProperty = (box) ->
    count = box.increment 'count'
    box.set 'top', Math.sin(count / 10) * 10
    box.set 'left', Math.cos(count / 10) * 10
    box.set 'color', count % 255
    box.set 'content', count % 100
  setProperty = ->
    for i in [0...N]
      tickProperty boxes.at(i)
    return

  tickBox = (box, i) ->
    count = box.get('count') + 1
    box.set
      count: count
      top: Math.sin(count / 10) * 10
      left: Math.cos(count / 10) * 10
      color: count % 255
      content: count % 100
      i: i
  setBox = ->
    for i in [0...N]
      tickBox boxes.at(i), i
    return

  boxValue = (box, i) ->
    count = box.count + 1
    return {
      count: count
      top: Math.sin(count / 10) * 10
      left: Math.cos(count / 10) * 10
      color: count % 255
      content: count % 100
      i: i
    }
  setAll = ->
    previous = boxes.get()
    value = []
    for box, i in previous
      value.push boxValue(box, i)
    boxes.set value


  frames = 0
  start = fn = timeout = null
  run = ->
    fn()
    if frames++ == 20
      fps = frames * 1000 / (new Date - start)
      model.set '_page.fps', fps.toFixed(1)
      frames = 0
      start = +new Date
    timeout = setTimeout run, 0

  modes =
    setProperty: setProperty
    setBox: setBox
    setAll: setAll
  app.start = (e, el) ->
    clearTimeout timeout
    mode = el.innerHTML
    model.set '_page.bindProperties', mode is 'setProperty'
    model.set '_page.mode', mode
    fn = modes[mode]
    frames = 0
    start = +new Date
    run()
  app.stop = ->
    clearTimeout timeout
