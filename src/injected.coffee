export resolveComponent = (child) ->
  convertReactObjectsToChildren = (objectToConvert) ->
    returnObject = {}
    for key in objectToConvert
      value = objectToConvert[key]
      if isValidElement value
        returnObject[key] = getChild value
      returnObject[key] = value
    returnObject

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
      { children: childrenTree, ...getChild child }
    else
      getChild child
  
  recurseOverChildren child

export resolveComponents = (children) ->
  Array.from children
    .map resolveComponent
