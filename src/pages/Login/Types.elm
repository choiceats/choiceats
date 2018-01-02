module Signup.Types exposing (..)

import Http exposing (Error)

type Msg
  = Email String
  | Password String
  | RequestAccount
  | ReceiveResponse (Result Http.Error Session)

type alias Session =
  {
    userId: String,
    email: String,
    name: String,
    token: String
  }

type alias Flags = { token: String }

-- type UserInput = Int | String | Number
-- had problems getting union types to play nicely with things that expected a String. TODO: Make this type work as it generalizes better to different form field types

type alias FormField =
  { userInput: String
  , isValid: Bool
  , message: String
  }

type alias LoginFields =
  { email: FormField
  , firstName: FormField
  , lastName: FormField
  , password: FormField
  , passwordCheck: FormField
  }

type alias Model =
  { emailInput: String
  , passwordInput: String
  , loggedIn: Bool
  , flags: Flags
  , serverFeedback : String
  }


type alias LabelName = String
type alias InputAttr = String

