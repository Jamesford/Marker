port module Marker exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Markdown
import Browser

type alias Flags =
  { content : String
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
  { content : String
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  (Model flags.content, Cmd.none)


-- UPDATE

type Msg
    = Name String

update : Msg -> Model -> (Model, Cmd Msg)
update msg m =
  case msg of
    Name content ->
      ({ m | content = content }, save content)


-- VIEW

view : Model -> Html Msg
view m =
  div [ class "wrapper" ]
    [ textarea [ placeholder "Write something...", onInput Name, class "editor" ] [ text m.content ]
    , Markdown.toHtml [ class "markdown-body" ] m.content
    ]


-- UTIL

starter : String
starter = """# This is Markdown

[Markdown](http://daringfireball.net/projects/markdown/) lets you write content in a really natural way.

  * You can have lists, like this one
  * Make things **bold** or *italic*
  * Embed snippets of `code`
  * Create [links](/)
  * ...

The [elm-markdown][] package parses all this content, allowing you
to easily generate blocks of `Element` or `Html`.

[elm-markdown]: http://package.elm-lang.org/packages/evancz/elm-markdown/latest
"""


-- PORTS

port save : String -> Cmd msg


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
