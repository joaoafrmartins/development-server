{ Model } = require 'theorist'

module.exports = class Notify extends Model

  @eventHandler: (v, m) ->

    m.uuid = v.uuid

    { keys, defineProperty } = Object

    defineProperty m, "$el", value: v

    keys(m.declaredPropertyValues or {}).map (key) =>

      capitalized = key.charAt(0).toUpperCase() +

        key.slice(1, key.length)

      if "on#{capitalized}Value" of v

        m["$#{key}"].onValue v["on#{capitalized}Value"].bind v

  @type: (obj) ->

    if obj == undefined or obj == null
      return String obj
    classToType = {
      '[object Boolean]': 'boolean',
      '[object Number]': 'number',
      '[object String]': 'string',
      '[object Function]': 'function',
      '[object Array]': 'array',
      '[object Date]': 'date',
      '[object RegExp]': 'regexp',
      '[object Object]': 'object'
    }

    return classToType[Object.prototype.toString.call(obj)]

  @properties

    uuid: undefined

    global: undefined

    alias: undefined

    vertical: undefined

    animation: undefined

    timeout: undefined

    timelapse: undefined

    horizontal: undefined

    levels: undefined
