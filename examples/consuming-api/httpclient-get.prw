#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  HttpClientGet()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de consumo de API REST via HTTP GET com parametros
| Obs.:  Exemplo educacional — endpoints e dados ficticios
*---------------------------------------------------------------------*/

User Function HttpClientGet()

    Local oHttp := FWHttpRest():New("https://api.exemplo.com/clientes")
    Local cResponse := ""
    Local oJson
    Local aClientes := {}
    Local nI := 0

    // Configura query parameters
    oHttp:SetQueryParam("status", "ativo")
    oHttp:SetQueryParam("limite", "50")

    // Adiciona headers
    oHttp:SetHeader("Accept", "application/json")
    oHttp:SetHeader("Authorization", "Bearer {seu-token-aqui}")

    // Executa GET
    oHttp:Get()

    // Verifica resposta
    If oHttp:GetStatus() == 200
        cResponse := oHttp:GetResult()
        oJson := JsonObject():New()
        oJson:FromJson(cResponse)

        // Itera sobre array de clientes
        If oJson:GetProperty("data") != Nil
            aClientes := oJson:GetProperty("data"):GetArray()
            For nI := 1 To Len(aClientes)
                ConOut("Cliente: " + aClientes[nI]:GetProperty("nome"):GetString())
            Next nI
        EndIf
    Else
        ConOut("Erro HTTP: " + cValToChar(oHttp:GetStatus()))
        ConOut("Resposta: " + oHttp:GetResult())
    EndIf

Return
