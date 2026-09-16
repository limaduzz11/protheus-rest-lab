#include "protheus.ch"
#include "restful.ch"

/*--------------------------------------------------------------------*
| Func:  RestEndpoint()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de endpoint REST de status usando WSRESTFUL nativo
|        Path configurado: "/api/exemplo/status"
| Obs.:  Exemplo educacional
*---------------------------------------------------------------------*/

WSRESTFUL RestEndpoint DESCRIPTION "Endpoint de exemplo — status e eco" FORMAT APPLICATION_JSON

    WSMETHOD GET DESCRIPTION "Retorna status e informacoes do servidor" WSSYNTAX "/api/exemplo/status"
    WSMETHOD POST DESCRIPTION "Recebe dados e confirma processamento" WSSYNTAX "/api/exemplo/status"

END WSRESTFUL

/*--------------------------------------------------------------------*
| GET — Retorna status do servidor Protheus
*---------------------------------------------------------------------*/
WSMETHOD GET WSSERVICE RestEndpoint

    Local oResponse := JsonObject():New()

    ::SetContentType("application/json")

    oResponse["status"]          := "online"
    oResponse["servidor"]        := GetServerName()
    oResponse["data_hora"]       := DtoS(Date()) + " " + Time()
    oResponse["versao_protheus"] := GetBuild()
    oResponse["ambiente"]        := GetEnvServer()

    ::SetResponse(oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| POST — Recebe dados e confirma
*---------------------------------------------------------------------*/
WSMETHOD POST WSSERVICE RestEndpoint

    Local oBody     := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cMensagem := ""
    Local cContent  := ::GetContent()

    ::SetContentType("application/json")

    If !Empty(cContent) .And. oBody:FromJson(cContent) == Nil
        If oBody:HasProperty("mensagem")
            cMensagem := cValToChar(oBody["mensagem"])
        EndIf
    EndIf

    oResponse["recebido"]          := .T.
    oResponse["mensagem_original"] := cMensagem
    oResponse["timestamp"]         := DtoS(Date()) + " " + Time()

    ::SetResponse(oResponse:ToJson())

Return .T.
