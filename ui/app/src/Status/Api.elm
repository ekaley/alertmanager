module Status.Api exposing (getStatus)

import Utils.Api exposing (send, get)
import Utils.Types exposing (ApiData)
import Status.Types exposing (StatusResponse, VersionInfo, MeshStatus, MeshPeer, MeshConnection)
import Json.Decode exposing (Decoder, map2, string, field, at, list, int, maybe, bool)


getStatus : String -> (ApiData StatusResponse -> msg) -> Cmd msg
getStatus apiUrl msg =
    let
        url =
            String.join "/" [ apiUrl, "status" ]

        request =
            get url decodeStatusResponse
    in
        Cmd.map msg <| send request


decodeStatusResponse : Decoder StatusResponse
decodeStatusResponse =
    field "data" decodeData


decodeData : Decoder StatusResponse
decodeData =
    Json.Decode.map4 StatusResponse
        (field "configYAML" string)
        (field "uptime" string)
        (field "versionInfo" decodeVersionInfo)
        (field "meshStatus" (maybe decodeMeshStatus))


decodeVersionInfo : Decoder VersionInfo
decodeVersionInfo =
    Json.Decode.map6 VersionInfo
        (field "branch" string)
        (field "buildDate" string)
        (field "buildUser" string)
        (field "goVersion" string)
        (field "revision" string)
        (field "version" string)


decodeMeshStatus : Decoder MeshStatus
decodeMeshStatus =
    Json.Decode.map4 MeshStatus
        (field "name" string)
        (field "nickName" string)
        (field "peers" (list decodeMeshPeer))
        (field "connections" (list decodeMeshConnection))


decodeMeshPeer : Decoder MeshPeer
decodeMeshPeer =
    Json.Decode.map3 MeshPeer
        (field "name" string)
        (field "nickName" string)
        (field "uid" int)


decodeMeshConnection : Decoder MeshConnection
decodeMeshConnection =
    Json.Decode.map4 MeshConnection
        (field "address" string)
        (field "outbound" bool)
        (field "state" string)
        (field "info" string)
