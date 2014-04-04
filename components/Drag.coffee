noflo = require 'noflo'
Hammer = require 'hammer'

class Drag extends noflo.Component
  description: 'Listen to drag events on a DOM element'
  constructor: ->
    @inPorts =
      element: new noflo.Port 'object'
      maxtouches: new noflo.Port 'number'
      preventdefault: new noflo.Port 'boolean'
    @outPorts =
      start: new noflo.ArrayPort 'object'
      movex: new noflo.ArrayPort 'number'
      movey: new noflo.ArrayPort 'number'
      end: new noflo.ArrayPort 'object'

    @options =
      drag_max_touches: 0
      prevent_default: true

    @inPorts.element.on 'data', (element) =>
      @updateElement(element)
    @inPorts.maxtouches.on 'data', (value) =>
      @applyOrCache('drag_max_touches', value)
    @inPorts.preventdefault.on 'data', (value) =>
      @applyOrCache('prevent_default', value)

  disposeElement: () ->
    @hammer.dispose()
    delete @hammer

  updateElement: (element) ->
    @disposeElement() if @hammer
    @hammer = new Hammer(element, @options)
    @hammer.on('dragstart', () =>
      return unless @outPorts.start.isAttached()
      @outPorts.start.send(true)
      @outPorts.start.disconnect())
    @hammer.on('dragend', () =>
      return unless @outPorts.end.isAttached()
      @outPorts.end.send(true)
      @outPorts.end.disconnect())
    @hammer.on('drag', (ev) =>
      if @outPorts.movex.isAttached()
        @outPorts.movex.send(ev.deltaX)
        @outPorts.movex.disconnect()
      if @outPorts.movey.isAttached()
        @outPorts.movey.send(ev.deltaY)
        @outPorts.movey.disconnect())

  applyOrCache: (property, value) =>
    @options[property] = value
    @hammer.options[property] = value if @hammer

exports.getComponent = -> new Drag
