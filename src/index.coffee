import fs from 'fs'
import { resolveComponent, resolveComponents } from './injected'
import { maxDepth } from './constants'
import { isValidElement } from './helpers'

export ID = 'react'

taiko = undefined
resq = undefined

export clientHandler = (taikoInstance) ->
  taiko = taikoInstance
  resqLocation = require.resolve 'resq'
  resq = fs.readFileSync resqLocation

defaultOptions = {
  multiple: false
  depth: maxDepth
}

export react = (selector, options = defaultOptions) ->
  options = { ...defaultOptions, ...options }

  unless selector?
    throw new Error 'Selector needs to be either a string or an object'
  
  if typeof selector is 'string'
    selectorString = selector
  else if isValidElement selector
    selectorString = selector.type
  else
    throw new Error 'Could not ascertain the type of this React component'
  
  if 'depth' of options and typeof options.depth is 'number'
    depth = options.depth
  else
    throw new Error 'Depth needs to be a number'
  
  { selectorToUse, componentResolver } =
  if options?.multiple then {
    selectorToUse: 'resq$$'
    componentResolver: 'resolveComponents'
  }
  else {
    selectorToUse: 'resq$'
    componentResolver: 'resolveComponent'
  }

  expression = "
  (async function() {
    #{ resq }
    const isValidElement = #{ isValidElement };
    const maxDepth = #{ depth };
    const resolveComponent = #{ resolveComponent() };
    const resolveComponents = #{ resolveComponents() };
    await window.resq.waitToLoadReact();
    result = window.resq.#{ selectorToUse }('#{ selectorString }');
    return #{ componentResolver }(result);
  })()
  "

  client = await taiko.client()

  result = await client.Runtime.evaluate({
    expression: expression,
    returnByValue: true,
    awaitPromise: true
  })

  {
    result: {
      value = (if options?multiple then [] else {}),
      type
    }
  } = result

  return {
    exists: () ->
      if options?.multiple
      then Boolean value.length
      else Boolean (Object.keys value).length
  }
