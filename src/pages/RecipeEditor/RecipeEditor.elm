port module RecipeEditor exposing (main)

import Html exposing (Html, div, input, text, a, img, i, option, select)
import Html.Attributes exposing (class, style, href, src, placeholder, value)
import Recipes.Types exposing (..)
import Recipes.Types exposing (..)


type alias Model =
    { recipe : String
    }


type Msg
    = None


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { recipe = "nope" }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div [ class "search" ]
        [ text "TODO.  Sorry." ]
