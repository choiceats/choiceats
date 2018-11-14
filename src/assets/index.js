"use strict"

var sessionString = localStorage.session
var api_url = window.api_url || window.location.href.indexOf('localhost') > -1 ? "http://localhost:4000" : "http://choiceats.com";
var flags = {
  api_url: api_url,
  session: sessionString ? JSON.parse(localStorage.session) : null
};
var app = Elm.Main.init({
  node: document.getElementById("mount-point"),
  flags: JSON.stringify(flags)
});

app.ports.storeSession.subscribe(function(session) {
  localStorage.session = session
});

app.ports.selectText.subscribe(selector => {
  setTimeout(() => {
    window.selectText(selector);
  }, 50)
});

window.selectText = function(selector) {
  var element = document.querySelector(selector);
  if (element) {
    element.select();
  }
};

window.addEventListener(
  "storage",
  function(event) {
    if (event.storageArea === localStorage && event.key === "session") {
      app.ports.onSessionChange.send(event.newValue)
    }
  },
  false
);
