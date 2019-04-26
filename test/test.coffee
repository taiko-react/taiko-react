{ createElement } = require 'react'
{ assert } = require 'chai'
{ fake } = require 'sinon'
{ clientHandler, react } = require '../lib'
{ resolveComponent, resolveComponents } = require '../lib/injected'
{ isValidElement } = require '../lib/helpers'
{
  singleInstanceNotFound,
  multipleInstancesNotFound,
  singleInstance,
  multipleInstances
} = require './data'

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

describe 'API', () ->
  describe '#exists', () ->
    it 'checks whether single component exists', () ->
      clientHandler createTaikoInstance fake.returns singleInstance
      assert.isTrue (await react 'Meow').exists()
    
    it 'checks that a single component does not exist', () ->
      clientHandler createTaikoInstance fake.returns singleInstanceNotFound
      assert.isFalse (await react 'NoMeow').exists()

    it 'checks whether multiple components exist', () ->
      clientHandler createTaikoInstance fake.returns multipleInstances
      assert.isTrue (await react 'Meow', { multiple: true }).exists()
    
    it 'checks that multiple components do not exist', () ->
      clientHandler createTaikoInstance fake.returns multipleInstancesNotFound
      assert.isFalse (await react 'NoMeow', { multiple: true }).exists()
  
  describe '#length', ->
    it 'reports 0 length when single element does not exist', ->
      clientHandler createTaikoInstance fake.returns singleInstanceNotFound
      assert.equal (await react 'Nothing').length(), 0
    
    it 'reports length of 1 when single element is found', ->
      clientHandler createTaikoInstance fake.returns singleInstance
      assert.equal (await react 'Something').length(), 1
    
    it 'reports 0 length when multiple elements do not exist', ->
      clientHandler createTaikoInstance fake.returns multipleInstancesNotFound
      assert.equal (await react 'Nothing', { multiple: true }).length(), 0
    
    it 'reports the respective length when multiple elements are found', ->
      clientHandler createTaikoInstance fake.returns multipleInstances
      assert.equal (await react 'Something', { multiple: true }).length(), 2

describe 'Injected code', () ->
  describe '#resolveComponent', () ->
    child = {
      name: 'name',
      isFragment: false,
      state: { stateProperty: 'state' },
      props: { propProperty: 'prop' }
    }
    it 'gets the required details for a child', () ->
      assert.deepEqual (resolveComponent(0) child), child
    
    it 'ignores extraneous properties', () ->
      newChild = { child..., something: 'else' }
      assert.deepEqual (resolveComponent(0) newChild), child
    
    it 'gets children', () ->
      newChild = { children: [child], child... }
      assert.deepEqual (resolveComponent() newChild), newChild
    
    it 'converts react element in prop to child', () ->
      reactChild = {
        child...,
        props: {
          propProperty: {
            child...,
            node: Object()
            $$typeof: Symbol.for('react.element')
          }
        }
      }
      expectedChild = {
        child...,
        props: {
          propProperty: child
        }
      }
      assert.deepEqual (resolveComponent(0) reactChild), expectedChild
    
    it 'converts react element in state to child', () ->
      reactChild = {
        child...,
        state: {
          stateProperty: {
            child...,
            node: Object()
            $$typeof: Symbol.for('react.element')
          }
        }
      }
      expectedChild = {
        child...,
        state: {
          stateProperty: child
        }
      }
      assert.deepEqual (resolveComponent(0) reactChild), expectedChild
  
  describe '#resolveComponents', () ->
    it 'resolves every child', () ->
      resolveComponent = fake()
      (resolveComponents resolveComponent) [1, 2, 3]
      assert.equal resolveComponent.callCount, 3
    
describe 'Helpers', () ->
  describe '#isValidElement', () ->
    it 'confirms a valid react element', () ->
      assert.isTrue isValidElement createElement 'Wow'
    
    it 'busts an invalid react element', () ->
      assert.isFalse isValidElement { type: 'Wow' }
