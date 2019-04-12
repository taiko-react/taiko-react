# taiko-react [![Build Status](https://travis-ci.org/tkshnwesper/taiko-react.svg?branch=master)](https://travis-ci.org/tkshnwesper/taiko-react)

`taiko-react` allows you to select React components on the site you want to perform tests on.

It uses [resq](https://github.com/baruchvlz/resq) to find the React components.

## Pre-requisites

1. The webpage that is being tested needs to be using React.
2. React needs to be running in development mode (not production).

## Install

```Shell
npm i taiko-react
```

## Usage

### Selecting using a **string** selector

```js
const { ID, clientHandler, react } = require('taiko-react');

await loadPlugin(ID, clientHandler)
await openBrowser();
await goto("http://localhost:8080");
const selection = await react('App')
```

### Selecting using a **React component**

```jsx
const selection = await react(<App />)
```

## API

### `.exists` _-> `Boolean`_

```jsx
const selection = await react(<App />)

assert(selection.exists)
```

Made with 💟 + ☕️ from 🇮🇳