noflo = require 'noflo'
Hammer = require 'hammerjs'

class Tap extends noflo.Component
  description: 'Listen to tap events on a DOM element'
  constructor: ->
    @inPorts =
      element: new noflo.Port 'object'
      maxtouches: new noflo.Port 'number'
      preventdefault: new noflo.Port 'boolean'
    @outPorts =
      tap: new noflo.ArrayPort 'bang'

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
    return unless element
    @hammer = new Hammer(element, @options)
    @hammer.on('tap', () =>
      return unless @outPorts.tap.isAttached()
      @outPorts.tap.send(true)
      @outPorts.tap.disconnect())

  applyOrCache: (property, value) =>
    @options[property] = value
    @hammer.options[property] = value if @hammer

exports.getComponent = -> new Tap
