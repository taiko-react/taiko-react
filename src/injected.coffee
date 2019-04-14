import { isValidElement as reactIsValidElement } from 'react'
import { maxDepth as maxDepthConstant } from './constants'

export resolveComponent = (
  maxDepth = maxDepthConstant,
  isValidElement = reactIsValidElement
) ->
  (child) ->
    convertReactObjectsToChildren = (objectToConvert) ->
      returnObject = {}
      for key, value of objectToConvert
        returnObject[key] = if isValidElement value then getChild value else value
      returnObject

    getChild = (child) -> {
        name: child.name
        isFragment: child.isFragment
        state: convertReactObjectsToChildren child.state
        props: convertReactObjectsToChildren child.props
      }

    recurseOverChildren = (child, depth = 0) ->
      if depth < maxDepth
        { children } = child
        childrenTree =
          if children?
          then (
            Array.from children
              .map (innerChild) ->
                recurseOverChildren innerChild, depth + 1
          )
          else []
        { children: childrenTree, ...getChild child }
      else
        getChild child
    
    recurseOverChildren child

proxyResolveComponent = resolveComponent

export resolveComponents = (resolveComponent = proxyResolveComponent) ->
  (children) ->
    Array.from children
      .map resolveComponent
