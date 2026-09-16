#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  HttpClientGet()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de consumo de API REST externa via FWRest (GET)
| Obs.:  Exemplo educacional — endpoints e dados ficticios
*---------------------------------------------------------------------*/

User Function HttpClientGet()

    Local oRest     := FWRest():New("https://api.exemplo.com")
    Local aHeader   := {}
    Local cResponse := ""
    Local oJson     := JsonObject():New()
    Local aClientes := {}
    Local nI        := 0

    // Configura caminho e query parameters
    oRest:SetPath("/clientes?status=ativo&limite=50")

    // Monta cabeçalhos HTTP
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Mozilla/4.0 (compatible; Protheus " + GetBuild() + ")")
    AAdd(aHeader, "Authorization: Bearer {seu-token-aqui}")

    // Executa GET
    If oRest:Get(aHeader)
        cResponse := oRest:GetResult()

        If oJson:FromJson(cResponse) == Nil
            // Itera sobre array de clientes retornado
            If oJson:HasProperty("data") .And. ValType(oJson["data"]) == "A"
                aClientes := oJson["data"]
                For nI := 1 To Len(aClientes)
                    If ValType(aClientes[nI]) == "J" .And. aClientes[nI]:HasProperty("nome")
                        ConOut("[HttpClientGet] Cliente: " + cValToChar(aClientes[nI]["nome"]))
                    EndIf
                Next nI
            EndIf
        Else
            ConOut("[HttpClientGet] Erro ao deserializar JSON de resposta")
        EndIf
    Else
        ConOut("[HttpClientGet] Erro HTTP: " + cValToChar(oRest:GetHTTPCode()))
        ConOut("[HttpClientGet] Detalhe: " + oRest:GetLastError())
    EndIf

Return
