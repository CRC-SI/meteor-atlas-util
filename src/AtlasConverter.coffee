# AMD modules.
WKT = Style = Color = null

class AtlasConverter

  toGeoEntityArgs: (args) ->
    geoEntity = _.extend({
      show: true
    }, args)
    vertices = args.vertices
    elevation = args.elevation ? 0
    zIndex = args.zIndex
    geometry =
      vertices: vertices
      elevation: elevation
      zIndex: zIndex

    # Vertices
    wkt = WKT.getInstance()
    if wkt.isPolygon(vertices)
      height = args.height ? 10
      geoEntity.polygon = geometry
      geoEntity.displayMode ?= if height > 0 || elevation > 0 then 'extrusion' else 'footprint'
      geometry.height = height
    else if wkt.isLineString vertices
      geoEntity.line = geometry
      geometry.width = args.width ? 10
      # Height can be set on features only if the form is a polygon.
      delete geoEntity.height
    else if vertices != null
      console.warn('Unknown type of vertices', args)
    
    # Style
    style = args.style
    if style
      geometry.style = args.style
    
    geoEntity

  toAtlasStyleArgs: (color, opacity, prefix) ->
    styleArgs = {}
    styleArgs[prefix + 'Color'] = new Color(color)
    if opacity != undefined
      styleArgs[prefix + 'Color'].alpha = opacity
    styleArgs

  toColor: (color) -> new Color(color)

  # TODO(aramk) Remove once c3ml color is refactored.
  colorFromC3mlColor: (color) ->
    if Types.isArray(color)
      new Color(color[0] / 255, color[1] / 255, color[2] / 255, color[3] / 255)
    else
      new Color(color)

_.extend(AtlasConverter, {

  _instance: null

  ready: ->
    df = Q.defer()
    # Load requirements when requesting instance.
    requirejs [
      'atlas/util/WKT'
      'atlas/material/Style'
      'atlas/material/Color'
    ], (_WKT, _Style, _Color) ->
      WKT = _WKT
      Style = _Style
      Color = _Color
      df.resolve()
    df.promise

  newInstance: -> @ready().then -> new AtlasConverter()

  getInstance: ->
    @ready().then =>
      unless @_instance
        @_instance = new AtlasConverter()
      @_instance

})
