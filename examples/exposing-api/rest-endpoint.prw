#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  RestEndpoint()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de endpoint REST simples usando WSOBJ
|        Configurar no Protheus: WSOBJ com path "/api/exemplo/status"
| Obs.:  Exemplo educacional — dados ficticios
*---------------------------------------------------------------------*/

WSRESTFUL RestEndpoint Description "Endpoint de exemplo — retorna status do sistema"

    WsMethod GET Description "Retorna status e informacoes do servidor"
    WsMethod POST Description "Recebe dados e confirma processamento"

ENDWSRESTFUL

/*--------------------------------------------------------------------*
| GET — Retorna status do servidor Protheus
*---------------------------------------------------------------------*/
WSMETHOD GET WsReceive EMPTY WsService RestEndpoint

    Local oResponse := JsonObject():New()

    // Constroi resposta
    oResponse:SetProperty("status", "online")
    oResponse:SetProperty("servidor", GetServerName())
    oResponse:SetProperty("data_hora", DtoS(Date()) + " " + Time())
    oResponse:SetProperty("versao_protheus", GetBuild())
    oResponse:SetProperty("ambiente", GetEnvServer())

    // Define response
    WsSetResponse(200, "application/json", oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| POST — Recebe dados e confirma
*---------------------------------------------------------------------*/
WSMETHOD POST WsReceive JSON WsService RestEndpoint

    Local oBody := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cMensagem := ""

    // Le corpo da requisicao
    oBody:FromJson(WsGetPostContent())

    // Valida campos obrigatorios
    If oBody:GetProperty("mensagem") != Nil
        cMensagem := oBody:GetProperty("mensagem"):GetString()
    EndIf

    // Monta resposta
    oResponse:SetProperty("recebido", .T.)
    oResponse:SetProperty("mensagem_original", cMensagem)
    oResponse:SetProperty("timestamp", DtoS(Date()) + " " + Time())

    WsSetResponse(200, "application/json", oResponse:ToJson())

Return .T.
