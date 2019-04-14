import { isValidElement as reactIsValidElement } from 'react'

export isValidElement =
  "
  const hasSymbol = typeof Symbol === 'function' && Symbol.for;
  var REACT_ELEMENT_TYPE = hasSymbol ? Symbol.for('react.element') : 0xeac7;
  #{ reactIsValidElement }
  "