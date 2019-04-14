import fs from 'fs'
import { isValidElement } from 'react'

export ID = 'react'

taiko = undefined
resq = undefined
maxDepth = 1

export clientHandler = (taikoInstance) ->
  taiko = taikoInstance
  resqLocation = require.resolve 'resq'
  resq = fs.readFileSync resqLocation

resolveComponent = (child) ->
  convertReactObjectsToChildren = (objectToConvert) ->
    returnObject = {}
    for key in objectToConvert
      value = objectToConvert[key]
      if isValidElement value
        returnObject[key] = getChild value
      returnObject[key] = value
    return returnObject

  getChild = (child) -> {
      name: child.name
      isFragment: child.isFragment
      state: convertReactObjectsToChildren child.props
      props: convertReactObjectsToChildren child.props
    }

  recurseOverChildren = (child, depth = 0) ->
    if depth < maxDepth
      { children } = child
      childrenTree = Array.from children
        .map (innerChild) ->
          recurseOverChildren innerChild, depth + 1
      return { children: childrenTree, ...getChild child }
    else
      return getChild child
  
  recurseOverChildren child
.toString()

resolveComponents = (children) ->
  Array.from children
    .map resolveComponent
.toString()

defaultOptions = {
  multiple: false
  depth: maxDepth
}

export react = (selector, options = defaultOptions) ->
  options = { ...defaultOptions, ...options }

  unless selector? and selector isnt undefined
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
    const maxDepth = #{ depth };
    const resolveComponent = #{ resolveComponent };
    const resolveComponents = #{ resolveComponents };
    await window.resq.waitToLoadReact();
    result = window.resq.#{ selectorToUse }('#{ selectorString }');
    return #{ componentResolver }(result);
  })()
  "

  client = await taiko.client()

  {
    result: {
      value = (if options?multiple then [] else {}),
      type
    }
  } = await client.Runtime.evaluate({
    expression: expression,
    returnByValue: true,
    awaitPromise: true
  })

  return {
    exists:
      if options?.multiple
      then Boolean value.length
      else Boolean (Object.keys value).length
  }
