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

type ToggleState
  = Both
  | Edit
  | View

type alias Model =
  { list : List String
  , selected : String
  , content : String
  , modal : Bool
  , name : String
  , toggle : ToggleState
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  (Model flags.list flags.selected flags.content False "" Both, Cmd.none)


-- UPDATE

type Msg
    = List (List String)
    | Select String
    | Content String
    | Modal Bool
    | Name String
    | Create
    | Delete String
    | Toggle ToggleState

update : Msg -> Model -> (Model, Cmd Msg)
update msg m =
  case msg of
    List list ->
      ({ m | list = list }, Cmd.none)
    Select selected ->
      ({ m | selected = selected }, Cmd.batch [select selected, save [m.selected, m.content]])
    Content content ->
      ({ m | content = content }, autosave [m.selected, content])
    Modal modal ->
      ({ m | modal = modal }, Cmd.none)
    Name name ->
      ({ m | name = name }, Cmd.none)
    Create ->
      ({ m | selected = m.name, modal = False, name = "" }, create m.name)
    Delete name ->
      (m, delete name)
    Toggle state ->
      ({ m | toggle = state}, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ viewHeader model
    , viewMain model
    , viewModal model
    ]

viewHeader : Model -> Html Msg
viewHeader m =
  header [ class "header" ]
    [ p [ class "title" ] [ text "Marker" ]
    , viewControls m
    ]

viewControls : Model -> Html Msg
viewControls m =
  let
    (eb, bb, vb) = case m.toggle of
      Edit ->
        ("button active", "button", "button")
      Both ->
        ("button", "button active", "button")
      View ->
        ("button", "button", "button active")
  in
  div [ class "controls" ]
    [ div [ class eb, onClick (Toggle Edit)] [ text "Edit" ]
    , div [ class bb, onClick (Toggle Both)] [ text "Both" ]
    , div [ class vb, onClick (Toggle View)] [ text "View" ]
    , div [ class "button add", onClick (Modal True) ] [ text "+" ]
    , viewDropdown m.selected m.list
    ]

viewDropdown : String -> List String -> Html Msg
viewDropdown selected list =
  div [class "dropdown" ]
    [ p [ class "active" ] [ text selected ]
    , viewDropdownList selected list
    ]

viewDropdownList : String -> List String -> Html Msg
viewDropdownList selected list =
  list
    |> List.filter (\l -> selected /= l)
    |> List.map (viewDropdownItem)
    |> ul [ class "list" ]

viewDropdownItem : String -> Html Msg
viewDropdownItem item =
  li []
    [ div [ class "item", onClick (Select item) ] [ text item ]
    , div [ class "del", onClick (Delete item) ] [ text "×" ]
    ]

viewMain : Model -> Html Msg
viewMain m =
  let
    (subview, wrapper) = case m.toggle of
      Both ->
        ([(viewEditor m), (viewPreview m "markdown-body overflow")], "wrapper")
      View ->
        ([(viewPreview m "markdown-body")], "wrapper overflow")
      Edit ->
        ([(viewEditor m)], "wrapper")
  in
    div [ class wrapper ] subview

viewEditor : Model -> Html Msg
viewEditor m =
  textarea [ placeholder "Write something...", onInput Content, class "editor", value m.content] []

previewOptions : Markdown.Options
previewOptions =
    { githubFlavored = Just { tables = True, breaks = False }
    , defaultHighlighting = Nothing
    , sanitize = True
    , smartypants = False
    }

viewPreview : Model -> String -> Html Msg
viewPreview m classes =
  Markdown.toHtmlWith previewOptions [ class classes ] m.content

viewModal : Model -> Html Msg
viewModal m =
  let
    modalClass = case m.modal of
        True -> "modal"
        False -> "modal hidden"
    isDisabled = case m.name of
      "" -> True
      _ -> False
  in
    div [ class modalClass ]
      [ div [ class "modal-bg", onClick (Modal False) ] []
      , div [ class "modal-body" ]
        [ h2 [ ] [ text "New Marker" ]
        , input [ value m.name, onInput Name, placeholder "Name" ] []
        , div [ class "controls" ]
          [ button [ class "btn cancel", onClick (Modal False) ] [ text "Cancel" ]
          , button [ class "btn create", onClick Create, disabled isDisabled ] [ text "Create" ]
          ]
        ]
      ]

-- PORTS

port autosave : List String -> Cmd msg

port save : List String -> Cmd msg

port create : String -> Cmd msg

port delete : String -> Cmd msg

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
