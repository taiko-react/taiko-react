{ assert } = require 'chai'
{ fake } = require 'sinon'
{ clientHandler, react } = require '../lib'

before () ->
  taiko = {
    client: () -> await {
      Runtime: {
        evaluate: fake()
      }
    }
  }
  clientHandler taiko

describe 'Validation', () ->
  it 'throws when selector does not exist', () ->
    try
      await react()
    catch error
      assert.equal error.message, 'Selector needs to be either a string or an object'
  
  it 'does not throw when selector exists', () ->
    assert.doesNotThrow (() -> react 'Header'),
    'Selector needs to be either a string or an object'