port module Navbar exposing (main)

-- BUILTIN CODE
import Html exposing (Html, div, button, text, a)
import Html.Attributes exposing (class, style, href, type_)
import Html.Events exposing (onClick)

main =
  Html.programWithFlags
  { update        = update
  , view          = viewNavbar
  , init          = init
  , subscriptions = subscriptions
  }

type alias FlagsHeader = { headerHeight : String }

type alias ModelHeader =
  { loggedIn : Bool
  , flags    : FlagsHeader
  }

type MsgHeader
  = NoOp
  | RequestLogout
  | ReceiveExternalState String


init : FlagsHeader -> (ModelHeader, Cmd MsgHeader)
init initFlags = 
  ({ loggedIn = False
  ,  flags    = initFlags
  }, Cmd.none)

update : MsgHeader -> ModelHeader -> (ModelHeader, Cmd MsgHeader)
update msg model = 
  case msg of

    NoOp ->
      (model, Cmd.none)

    RequestLogout ->
      (model, requestLogout "")

    ReceiveExternalState sessionStatus ->
      ({model | loggedIn = 
        case sessionStatus of
      
          "true" -> True

          "false" -> False

          _ -> False
      
      }, Cmd.none)

subscriptions : ModelHeader -> Sub MsgHeader
subscriptions model =
  readReactState ReceiveExternalState 

port readReactState : (String -> msg) -> Sub msg
port requestLogout  : String          -> Cmd msg

viewNavbar : ModelHeader -> Html MsgHeader
viewNavbar model = 
  div [style [("height", model.flags.headerHeight ++ "px" )]]
  [
     div [class "ui secondary menu"]
     [ div [class "header item"][text "ChoicEats"]
     , div [class "item"][a [href "/"][text "Recipes"]]
     , div [class "item"][a [href "/random"][text "Ideas"]]
     , div [class "right menu"]
       [
         div [class "item"] [ manageSessionButton model.loggedIn ]
       ]
     ]
  ]

manageSessionButton : Bool -> Html MsgHeader
manageSessionButton loggedIn = 
  case loggedIn of

    True ->
      button [ class "ui button"
             , type_ "button"
             , onClick RequestLogout
             ]
      [text "Logout"]

    False ->
      a [href "/login"]
        [ button [class "ui button", type_ "button"] [text "Login"] ]
