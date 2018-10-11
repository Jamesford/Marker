port module Marker exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Markdown
import Browser

type alias Flags =
  { list : List String
  , selected : String
  , content : String
  }

main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { list : List String
  , selected : String
  , content : String
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  (Model flags.list flags.selected flags.content, Cmd.none)


-- UPDATE

type Msg
    = List (List String)
    | Select String
    | Content String

update : Msg -> Model -> (Model, Cmd Msg)
update msg m =
  case msg of
    List list ->
      ({ m | list = list }, Cmd.none)
    Select selected ->
      ({ m | selected = selected }, Cmd.batch [select selected, save [m.selected, m.content]])
    Content content ->
      ({ m | content = content }, autosave [m.selected, content])


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ viewHeader model
    , div [ class "wrapper" ]
      [ viewEditor model
      , viewPreview model
      ]
    ]

viewHeader : Model -> Html Msg
viewHeader m =
  header [ class "header" ]
    [ p [ class "title" ] [ text "Marker" ]
    , viewDropdown m.selected m.list
    ]

viewDropdown : String -> List String -> Html Msg
viewDropdown selected list =
  div [class "dropdown" ]
    [ p [ class "active" ] [ text selected ]
    , viewDropdownList selected list
    ]

viewDropdownList selected list =
  list
    -- |> List.filter (\l -> selected /= l)
    |> List.map (\l -> li [ onClick (Select l)] [ text l ])
    |> ul [ class "list" ]

viewEditor : Model -> Html Msg
viewEditor m =
  textarea [ placeholder "Write something...", onInput Content, class "editor", value m.content] []

viewPreview : Model -> Html Msg
viewPreview m =
  Markdown.toHtml [ class "markdown-body" ] m.content


-- PORTS

port autosave : List String -> Cmd msg

port save : List String -> Cmd msg

port select : String -> Cmd msg

port loadList : (List String -> msg) -> Sub msg

port loadContent : (String -> msg) -> Sub msg


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ loadList List
    , loadContent Content
    ]
