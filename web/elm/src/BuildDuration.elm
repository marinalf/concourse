module BuildDuration exposing (show, view)

import Concourse
import Date exposing (Date)
import Date.Format
import Duration exposing (Duration)
import Html exposing (Html)
import Html.Attributes exposing (class, title)
import Time exposing (Time)


view : Concourse.BuildDuration -> Time.Time -> Html a
view duration now =
    Html.table [ class "dictionary build-duration" ] <|
        case ( duration.startedAt, duration.finishedAt ) of
            ( Nothing, Nothing ) ->
                [ pendingLabel "pending" ]

            ( Just startedAt, Nothing ) ->
                [ labeledRelativeDate "started" now startedAt ]

            ( Nothing, Just finishedAt ) ->
                [ labeledRelativeDate "finished" now finishedAt ]

            ( Just startedAt, Just finishedAt ) ->
                let
                    durationElmIssue =
                        -- https://github.com/elm-lang/elm-compiler/issues/1223
                        Duration.between (Date.toTime startedAt) (Date.toTime finishedAt)
                in
                [ labeledVerboseDate "started" startedAt
                , labeledVerboseDate "finished" finishedAt
                , labeledDuration "duration" durationElmIssue
                ]


show : Time.Time -> Concourse.BuildDuration -> String
show now =
    .startedAt >> Maybe.map (Date.toTime >> flip Duration.between now >> Duration.format) >> Maybe.withDefault ""

labeledVerboseDate : String -> Date -> Html a
labeledVerboseDate label date =
    let verboseDate =
                    Date.Format.format "%b %d %Y %I:%M:%S %p" date
    in
    Html.tr []
        [ Html.td [ class "dict-key" ] [ Html.text label ]
        , Html.td
            [ title verboseDate, class "dict-value" ]
            [ Html.span [] [ Html.text verboseDate ] ]
        ]

labeledRelativeDate : String -> Time -> Date -> Html a
labeledRelativeDate label now date =
    let
        ago =
            Duration.between (Date.toTime date) now
    in
    Html.tr []
        [ Html.td [ class "dict-key" ] [ Html.text label ]
        , Html.td
            [ title (Date.Format.format "%b %d %Y %I:%M:%S %p" date), class "dict-value" ]
            [ Html.span [] [ Html.text (Duration.format ago ++ " ago") ] ]
        ]


labeledDuration : String -> Duration -> Html a
labeledDuration label duration =
    Html.tr []
        [ Html.td [ class "dict-key" ] [ Html.text label ]
        , Html.td [ class "dict-value" ] [ Html.span [] [ Html.text (Duration.format duration) ] ]
        ]


pendingLabel : String -> Html a
pendingLabel label =
    Html.tr []
        [ Html.td [ class "dict-key" ] [ Html.text label ]
        , Html.td [ class "dict-value" ] []
        ]