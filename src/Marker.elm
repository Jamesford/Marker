module Marker exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Markdown
import Browser


main : Program () Model Msg
main =
  Browser.sandbox
    { init = model
    , view = view
    , update = update
    }


-- MODEL

type alias Model =
  { content : String
  }

model : Model
model =
  Model starter


-- UPDATE

type Msg
    = Name String

update : Msg -> Model -> Model
update msg m =
  case msg of
    Name content ->
      { m | content = content }


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
