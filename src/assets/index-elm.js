// This js file is intended to be used in Elm dev mode only.
'use strict';

require('./favicon.ico');
require('./keyframes.css');
require('./manifest.json');
require('./reset.css');
require('./style.scss');

const sessionString = localStorage.session
const flags = {
    api_url: api_url, // defined by webpack
    session: sessionString ? JSON.parse(sessionString) : null
}

// Elm provided by elm-dev-bundle via dev-server.sh
const {
    storeSession,
    setDocumentTitle,
    selectText,
    onSessionChange
} = Elm.Main.fullscreen(JSON.stringify(flags)).ports

storeSession.subscribe(function(session) {
    localStorage.session = session
});

setDocumentTitle.subscribe(function(title) {
    const appName = "ChoicEats"
    console.log('title', title)

    if (title.length > 0) {
        document.title = appName + ' - ' + title
    } else {

        document.title = appName
    }
})

window.highlightText = function (selector) {
    const element = document.querySelector(selector)
    if (element) {
        element.select()
    }
}

selectText.subscribe(selector => {
    setTimeout(() => {
        window.highlightText(selector)
    }, 50)
})

window.addEventListener("storage", function(event) {
    if (event.storageArea === localStorage && event.key === "session") {
        onSessionChange.send(event.newValue)
    }
}, false)
