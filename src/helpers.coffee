export isValidElement = (objectToCheck) ->
  hasSymbol = typeof Symbol == 'function' and Symbol.for
  REACT_ELEMENT_TYPE = if hasSymbol then Symbol.for('react.element') else 0xeac7
  objectToCheck? and
  typeof objectToCheck == 'object' and
  objectToCheck.$$typeof == REACT_ELEMENT_TYPE
