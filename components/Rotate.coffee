noflo = require 'noflo'
Hammer = require 'hammerjs'

class Rotate extends noflo.Component
  description: 'Listen to pinch events on a DOM element'
  constructor: ->
    @inPorts =
      element: new noflo.Port 'object'
      minangle: new noflo.Port 'number'
      preventdefault: new noflo.Port 'boolean'
    @outPorts =
      start: new noflo.Port 'bang'
      angle: new noflo.Port 'number'
      end: new noflo.Port 'bang'

    @options =
      transform_min_scale: 0.01
      prevent_default: true

    @inPorts.element.on 'data', (element) =>
      @updateElement(element)
    @inPorts.minangle.on 'data', (value) =>
      @applyOrCache('transform_min_rotation', value)
    @inPorts.preventdefault.on 'data', (value) =>
      @applyOrCache('prevent_default', value)

  disposeElement: () ->
    @hammer.dispose()
    delete @hammer

  updateElement: (element) ->
    @disposeElement() if @hammer
    return unless element
    @hammer = new Hammer(element, @options)
    @hammer.on('transformstart', () =>
      return unless @outPorts.start.isAttached()
      @outPorts.start.send(true)
      @outPorts.start.disconnect())
    @hammer.on('transformend', () =>
      return unless @outPorts.end.isAttached()
      @outPorts.end.send(true)
      @outPorts.end.disconnect())
    @hammer.on('rotate', (ev) =>
      return unless @outPorts.angle.isAttached()
      @outPorts.angle.send(ev.rotation)
      @outPorts.angle.disconnect())

  applyOrCache: (property, value) =>
    @options[property] = value
    @hammer.options[property] = value if @hammer

exports.getComponent = -> new Rotate
