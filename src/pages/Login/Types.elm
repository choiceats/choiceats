module Login.Types exposing (..)

import Http exposing (Error)

type Msg
  = Email String
  | Password String
  | AttemptLogin
  | ReceiveResponse (Result Http.Error Session)

type alias Session =
  {
    userId: String,
    email: String,
    name: String,
    token: String
  }

type alias Flags = { token: String }

type alias Model =
  { emailInput: String
  , passwordInput: String
  , loggedIn: Bool
  , flags: Flags
  , serverFeedback : String
  }

type alias LabelName = String
type alias InputAttr = String
