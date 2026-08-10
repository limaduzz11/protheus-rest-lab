#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  HttpClientPost()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de envio de dados via HTTP POST com corpo JSON
| Obs.:  Exemplo educacional — endpoints e dados ficticios
*---------------------------------------------------------------------*/

User Function HttpClientPost()

    Local oHttp := FWHttpRest():New("https://api.exemplo.com/pedidos")
    Local oJsonBody := JsonObject():New()
    Local cResponse := ""
    Local oJsonResp
    Local nPedido := 0

    // Constroi corpo JSON
    oJsonBody:SetProperty("cliente_id", "CLI-12345")
    oJsonBody:SetProperty("data", DtoS(Date()))
    oJsonBody:SetProperty("valor_total", 1500.00)
    oJsonBody:SetProperty("observacao", "Pedido de exemplo via ADVPL")

    // Adiciona itens (array)
    oJsonBody:SetProperty("itens", JsonArray():New())

    // Configura headers
    oHttp:SetHeader("Content-Type", "application/json")
    oHttp:SetHeader("Accept", "application/json")
    oHttp:SetHeader("Authorization", "Bearer {seu-token-aqui}")

    // Define body como JSON string
    oHttp:SetPostParams(oJsonBody:ToJson())

    // Executa POST
    oHttp:Post()

    // Trata resposta
    If oHttp:GetStatus() == 201
        cResponse := oHttp:GetResult()
        oJsonResp := JsonObject():New()
        oJsonResp:FromJson(cResponse)

        nPedido := oJsonResp:GetProperty("pedido_id"):GetNumber()
        ConOut("Pedido criado com sucesso! ID: " + cValToChar(nPedido))
    ElseIf oHttp:GetStatus() == 422
        ConOut("Erro de validacao: " + oHttp:GetResult())
    Else
        ConOut("Erro HTTP: " + cValToChar(oHttp:GetStatus()))
    EndIf

Return
