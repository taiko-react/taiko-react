import fs from 'fs'

export ID = 'react'

taiko = undefined
resq = undefined
maxDepth = 1

export clientHandler = (taikoInstance) ->
  taiko = taikoInstance
  resqLocation = require.resolve 'resq'
  resq = fs.readFileSync resqLocation

resolveComponent = (child) ->
  getChild = (child) -> {
      name: child.name
      isFragment: child.isFragment
      state: child.state
      props: child.props
    }

  recurseOverChildren = (child, depth) ->
    if depth < maxDepth
      { children } = child
      childrenTree = Array.from children
        .map (innerChild) ->
          recurseOverChildren innerChild, depth + 1
      return { children: childrenTree, ...getChild child }
    else
      return getChild child
  
  recurseOverChildren child, 0
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

  if not selector?
    throw new Error 'Selector needs to be either a string or an object'
  
  if typeof selector is 'string'
    selectorString = selector
  else if typeof selector is 'object' and 'name' of selector
    selectorString = selector.name
  else
    throw new Error 'Could not ascertain the name of this React component'
  
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

  result = await client.Runtime.evaluate({
    expression: expression,
    returnByValue: true,
    awaitPromise: true
  })
  
  console.log JSON.stringify result
