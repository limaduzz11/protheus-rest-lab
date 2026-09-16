#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  HttpClientAuth()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de autenticacao via FWRest — Basic Auth e OAuth2 Client Credentials
| Obs.:  Exemplo educacional — endpoints e dados ficticios
*---------------------------------------------------------------------*/

User Function HttpClientAuth()

    // ---------- Exemplo 1: Basic Auth ----------
    ConOut("=== Basic Auth ===")
    BasicAuthExample()

    // ---------- Exemplo 2: Token OAuth2 ----------
    ConOut("=== OAuth2 Client Credentials ===")
    OAuth2Example()

Return

/*--------------------------------------------------------------------*
| BasicAuthExample — Autenticacao via usuario/senha codificados Base64
*---------------------------------------------------------------------*/
Static Function BasicAuthExample()

    Local oRest   := FWRest():New("https://api.exemplo.com")
    Local aHeader := {}
    Local cUser   := "usuario_api"
    Local cPass   := "senha_api"
    Local cAuth   := Encode64(cUser + ":" + cPass)

    oRest:SetPath("/status")

    AAdd(aHeader, "Authorization: Basic " + cAuth)
    AAdd(aHeader, "Accept: application/json")

    If oRest:Get(aHeader)
        ConOut("[BasicAuthExample] Autenticado com sucesso via Basic Auth")
    Else
        ConOut("[BasicAuthExample] Falha HTTP: " + cValToChar(oRest:GetHTTPCode()))
    EndIf

Return

/*--------------------------------------------------------------------*
| OAuth2Example — Fluxo Client Credentials para obter Bearer Token
*---------------------------------------------------------------------*/
Static Function OAuth2Example()

    Local oRestAuth := FWRest():New("https://auth.exemplo.com")
    Local aHeader   := {}
    Local cBody     := ""
    Local cResponse := ""
    Local oJson     := JsonObject():New()
    Local cToken    := ""
    Local oRestApi
    Local aApiHead  := {}

    oRestAuth:SetPath("/oauth/token")

    AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
    AAdd(aHeader, "Accept: application/json")

    cBody := "grant_type=client_credentials" + ;
             "&client_id=seu_client_id" + ;
             "&client_secret=seu_client_secret" + ;
             "&scope=read write"

    oRestAuth:SetPostParams(cBody)

    If oRestAuth:Post(aHeader)
        cResponse := oRestAuth:GetResult()

        If oJson:FromJson(cResponse) == Nil .And. oJson:HasProperty("access_token")
            cToken := oJson["access_token"]
            ConOut("[OAuth2Example] Token obtido: " + SubStr(cToken, 1, 15) + "...")

            // Chamada subsequente autenticada com Bearer token
            oRestApi := FWRest():New("https://api.exemplo.com")
            oRestApi:SetPath("/dados")

            AAdd(aApiHead, "Authorization: Bearer " + cToken)
            AAdd(aApiHead, "Accept: application/json")

            If oRestApi:Get(aApiHead)
                ConOut("[OAuth2Example] Chamada autenticada com sucesso! Resposta: " + SubStr(oRestApi:GetResult(), 1, 80))
            Else
                ConOut("[OAuth2Example] Falha na API: " + cValToChar(oRestApi:GetHTTPCode()))
            EndIf
        EndIf
    Else
        ConOut("[OAuth2Example] Erro ao obter token: " + cValToChar(oRestAuth:GetHTTPCode()))
        ConOut("[OAuth2Example] Detalhe: " + oRestAuth:GetLastError())
    EndIf

Return
