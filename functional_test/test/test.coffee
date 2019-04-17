{ spawn, spawnSync } = require 'child_process'
{ get } = require 'http'
{ openBrowser, goto, closeBrowser, loadPlugin } = require 'taiko'
{ assert } = require 'chai'
{ createElement } = require 'react'
{ ID, clientHandler, react } = require '../../lib'

URL = "http://localhost:3000"

killServer = () ->
  spawnSync 'sh', ["#{ __dirname }/../stop_server.sh"]

waitForServer = () ->
  await new Promise((resolve) -> setTimeout resolve, 1000)
  try
    await new Promise((resolve, reject) ->
      get(URL, resolve).on('error', reject))
  catch
    await waitForServer()

beforeHook = () ->
  this.timeout(100 * 1000)
  spawn 'sh', ["#{ __dirname }/../start_server.sh"]
  try
    await loadPlugin ID, clientHandler
    await openBrowser()
    await waitForServer()
    await goto URL
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
