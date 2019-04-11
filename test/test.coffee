{ assert } = require 'chai'
{ clientHandler, react } = require '../lib'

describe 'Test', () ->
  it 'adds correctly', () ->
    assert 1 + 2, 3