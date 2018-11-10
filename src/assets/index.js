"use strict"

// require('./index.html');
// require('./favicon.ico');
// require('./keyframes.css');
// require('./manifest.json');
// require('./reset.css');
// require('./style.scss');
// require('./semantic.min.css');

// const Elm = require('../Main.elm');

const sessionString = localStorage.session
const flags = {
  api_url: window.api_url || "http://localhost:4000", // set by webpack // http://choiceats.com
  session: sessionString ? JSON.parse(localStorage.session) : null
}
const app = Elm.Main.init({
  node: document.getElementById("mount-point"),
  flags: JSON.stringify(flags)
})

app.ports.storeSession.subscribe(function(session) {
  localStorage.session = session
})

app.ports.setDocumentTitle.subscribe(function(title) {
  const appName = "ChoicEats"

  if (title.length > 0) {
    document.title = appName + " - " + title
  } else {
    document.title = appName
  }
})

app.ports.selectText.subscribe(selector => {
  setTimeout(() => {
    window.selectText(selector)
  }, 50)
})

window.selectText = function(selector) {
  const element = document.querySelector(selector)
  if (element) {
    element.select()
  }
}

window.addEventListener(
  "storage",
  function(event) {
    if (event.storageArea === localStorage && event.key === "session") {
      app.ports.onSessionChange.send(event.newValue)
    }
  },
  false
)
