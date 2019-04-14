{ createElement } = require 'react'
{ assert } = require 'chai'
{ fake } = require 'sinon'
{ clientHandler, react } = require '../lib'

createTaikoInstance = (fakeFunction = fake()) ->
  return {
    client: () -> await {
      Runtime: {
        evaluate: fakeFunction
      }
    }
  }

describe 'Validation', () ->
  beforeHook = () ->
    fakeFn = fake.returns { type: 'object', result: {} }
    clientHandler createTaikoInstance fakeFn
  before beforeHook

  it 'rejects a selector that does not exist', () ->
    try
      await react()
    catch error
      assert.equal error.message, 'Selector needs to be either a string or an object'
  
  it 'accepts a selector that exists', () ->
    assert.doesNotThrow (() -> await react 'Header'),
    'Selector needs to be either a string or an object'
  
  it 'rejects a selector that is an object but not a React element', () ->
    try
      await react {
        meow: 'Cat'
      }
      assert.fail()
    catch error
      assert.equal error.message,
      'Could not ascertain the type of this React component'

  it 'accepts a selector that is a React element', () ->
    assert.doesNotThrow (() -> await react createElement 'Something'),
    'Could not ascertain the name of this React component'
  
  it 'rejects a selector that is neither an object nor a string', () ->
    try
      await react 1
      assert.fail()
    catch error
      assert.equal error.message,
      'Could not ascertain the type of this React component'

describe '#exists', () ->
  it 'checks whether single component exists', () ->
    clientHandler createTaikoInstance fake.returns {
      result: {
        value: {
          node: {},
          isFragment: false,
          state: {},
          props: {}
        },
        type: 'object'
      }
    }
    assert.isTrue (await react 'Meow').exists()
  
  it 'checks that a single component does not exist', () ->
    clientHandler createTaikoInstance fake.returns {
      result: {
        value: {},
        type: 'object'
      }
    }
    assert.isFalse (await react 'NoMeow').exists()

  it 'checks whether multiple components exist', () ->
    clientHandler createTaikoInstance fake.returns {
      result: {
        value: [{
          node: {},
          isFragment: false,
          state: {},
          props: {}
        }],
        type: 'array'
      }
    }
    assert.isTrue (await react 'Meow', { multiple: true }).exists()
  
  it 'checks that multiple components do not exist', () ->
    clientHandler createTaikoInstance fake.returns {
      result: {
        value: [],
        type: 'array'
      }
    }
    assert.isFalse (await react 'NoMeow', { multiple: true }).exists()
