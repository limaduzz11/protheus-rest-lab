#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  HttpClientAuth()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de autenticacao — Basic Auth e OAuth2 Client Credentials
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

    Local oHttp := FWHttpRest():New("https://api.exemplo.com/status")
    Local cUser := "usuario_api"
    Local cPass := "senha_api"
    Local cAuth := Encode64(cUser + ":" + cPass)

    oHttp:SetHeader("Authorization", "Basic " + cAuth)
    oHttp:SetHeader("Accept", "application/json")
    oHttp:Get()

    If oHttp:GetStatus() == 200
        ConOut("Autenticado com sucesso via Basic Auth")
    ElseIf oHttp:GetStatus() == 401
        ConOut("Falha na autenticacao — credenciais invalidas")
    EndIf

Return

/*--------------------------------------------------------------------*
| OAuth2Example — Fluxo Client Credentials para obter Bearer Token
*---------------------------------------------------------------------*/
Static Function OAuth2Example()

    Local oHttp := FWHttpRest():New("https://auth.exemplo.com/oauth/token")
    Local cResponse := ""
    Local oJson
    Local cToken := ""
    Local oHttpApi

    // Prepara corpo da requisicao de token
    oHttp:SetHeader("Content-Type", "application/x-www-form-urlencoded")

    // Monta parametros no formato form-urlencoded
    oHttp:SetPostParams("grant_type=client_credentials" + ;
                        "&client_id=seu_client_id" + ;
                        "&client_secret=seu_client_secret" + ;
                        "&scope=read write")

    oHttp:Post()

    If oHttp:GetStatus() == 200
        cResponse := oHttp:GetResult()
        oJson := JsonObject():New()
        oJson:FromJson(cResponse)

        cToken := oJson:GetProperty("access_token"):GetString()
        ConOut("Token obtido: " + SubStr(cToken, 1, 20) + "...")

        // Usa o token em chamada subsequente
        oHttpApi := FWHttpRest():New("https://api.exemplo.com/dados")
        oHttpApi:SetHeader("Authorization", "Bearer " + cToken)
        oHttpApi:Get()

        If oHttpApi:GetStatus() == 200
            ConOut("Chamada autenticada com sucesso!")
        EndIf
    Else
        ConOut("Erro ao obter token: " + cValToChar(oHttp:GetStatus()))
    EndIf

Return
