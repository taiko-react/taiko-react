{ spawn, spawnSync } = require 'child_process'
{ openBrowser, goto, closeBrowser, loadPlugin } = require 'taiko'
{ assert } = require 'chai'
{ createElement } = require 'react'
{ ID, clientHandler, react } = require '../../lib'

killServer = () ->
  spawnSync 'sh', ["#{ __dirname }/../stop_server.sh"]

beforeHook = () ->
  this.timeout(30 * 1000)
  spawn 'sh', ["#{ __dirname }/../start_server.sh"]
  try
    await loadPlugin ID, clientHandler
    await openBrowser()
    await new Promise((resolve) -> setTimeout resolve, 10000)
    await goto "http://localhost:3000"
  catch error
    console.error error
    killServer()

before beforeHook

describe 'Functional tests', () ->
  it 'successfully finds the App', () ->
    app = await react 'App'
    assert.isTrue app.exists()
  
  it 'successfully finds the <App />', () ->
    app = await react createElement 'App'
    assert.isTrue app.exists()

afterHook = () ->
  await closeBrowser()
  killServer()

after afterHook
