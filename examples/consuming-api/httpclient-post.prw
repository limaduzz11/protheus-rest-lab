#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  HttpClientPost()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de envio de dados via HTTP POST com FWRest e JSON
| Obs.:  Exemplo educacional — endpoints e dados ficticios
*---------------------------------------------------------------------*/

User Function HttpClientPost()

    Local oRest     := FWRest():New("https://api.exemplo.com")
    Local aHeader   := {}
    Local oJsonBody := JsonObject():New()
    Local cResponse := ""
    Local oJsonResp := JsonObject():New()
    Local cPedidoId := ""

    // Define recurso
    oRest:SetPath("/pedidos")

    // Monta cabecalhos
    AAdd(aHeader, "Content-Type: application/json; charset=utf-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "Authorization: Bearer {seu-token-aqui}")

    // Constroi corpo JSON nativo
    oJsonBody["cliente_id"]  := "CLI-12345"
    oJsonBody["data"]        := DtoS(Date())
    oJsonBody["valor_total"] := 1500.00
    oJsonBody["observacao"]  := "Pedido de exemplo via ADVPL FWRest"
    oJsonBody["itens"]       := {}

    // Configura payload no FWRest
    oRest:SetPostParams(oJsonBody:ToJson())

    // Executa POST
    If oRest:Post(aHeader)
        cResponse := oRest:GetResult()

        If oJsonResp:FromJson(cResponse) == Nil .And. oJsonResp:HasProperty("pedido_id")
            cPedidoId := cValToChar(oJsonResp["pedido_id"])
            ConOut("[HttpClientPost] Pedido criado com sucesso! ID: " + cPedidoId)
        Else
            ConOut("[HttpClientPost] Resposta recebida: " + cResponse)
        EndIf
    Else
        ConOut("[HttpClientPost] Falha HTTP: " + cValToChar(oRest:GetHTTPCode()))
        ConOut("[HttpClientPost] Erro: " + oRest:GetLastError())
    EndIf

Return
