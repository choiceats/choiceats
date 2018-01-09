port module RecipeEditor exposing (main)

import Html exposing (Html, h1, label, button, textarea, form, div, input, text, a, img, i, option, select)
import Html.Attributes exposing (type_, class, style, href, src, placeholder, value)
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
    div [ class "editor" ]
        [ form [ class "recipe-form" ]
            [ h1 [] [ text "Recipe Editor" ] ]
        , div [ class "form-field" ]
            [ label [] [ text "Recipe Name" ]
            , input [ placeholder "Recipe Name" ] []
            ]
        , div [ class "form-field" ]
            [ label [] [ text "Description" ]
            , input [ placeholder "description" ] []
            ]
        , div [ class "form-field" ]
            [ label [] [ text "Instructions" ]
            , textarea [] []
            ]
        , div [ class "form-field" ]
            [ label [] [ text "Ingredients" ]
            , div [ class "recipe-field-group" ]
                [ div [ class "recipe-field" ]
                    [ input [ type_ "number" ] [] ]
                , div [ class "recipe-field" ]
                    [ select [] [ option [ value "cups" ] [ text "Cups" ] ] ]
                , div [ class "recipe-field" ]
                    [ input [] [] ]
                , div [ class " recipe-field" ]
                    [ button [] [ text "X" ] ]
                ]
            ]
        ]
