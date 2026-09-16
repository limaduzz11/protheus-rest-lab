#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  JsonBuild()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplos de construcao de JSON nativo via JsonObject (TDN Protheus)
| Obs.:  Exemplo educacional — sintaxe nativa com colchetes
*---------------------------------------------------------------------*/

User Function JsonBuild()

    ConOut("=== Exemplo 1: JSON simples ===")
    BuildSimpleJson()

    ConOut("=== Exemplo 2: JSON com array ===")
    BuildArrayJson()

    ConOut("=== Exemplo 3: JSON de resposta de API ===")
    BuildApiResponseJson()

Return

/*--------------------------------------------------------------------*
| BuildSimpleJson — Objeto JSON basico
*---------------------------------------------------------------------*/
Static Function BuildSimpleJson()

    Local oJson   := JsonObject():New()
    Local cResult := ""

    oJson["status"]    := "success"
    oJson["codigo"]    := 200
    oJson["mensagem"]  := "Operacao concluida com sucesso"
    oJson["timestamp"] := DtoS(Date()) + " " + Time()

    cResult := oJson:ToJson()
    ConOut(cResult)

Return

/*--------------------------------------------------------------------*
| BuildArrayJson — JSON com array de objetos
*---------------------------------------------------------------------*/
Static Function BuildArrayJson()

    Local oRoot  := JsonObject():New()
    Local aItens := {}
    Local oItem

    // Item 1
    oItem := JsonObject():New()
    oItem["id"]             := "001"
    oItem["descricao"]      := "Servico A"
    oItem["quantidade"]     := 2
    oItem["valor_unitario"] := 150.00
    AAdd(aItens, oItem)

    // Item 2
    oItem := JsonObject():New()
    oItem["id"]             := "002"
    oItem["descricao"]      := "Servico B"
    oItem["quantidade"]     := 1
    oItem["valor_unitario"] := 450.00
    AAdd(aItens, oItem)

    oRoot["itens"]       := aItens
    oRoot["total_itens"] := Len(aItens)
    oRoot["valor_total"] := 750.00

    ConOut(oRoot:ToJson())

Return

/*--------------------------------------------------------------------*
| BuildApiResponseJson — Padrao comum de envelope de API REST
*---------------------------------------------------------------------*/
Static Function BuildApiResponseJson()

    Local oResponse := JsonObject():New()
    Local oData     := JsonObject():New()
    Local oMeta     := JsonObject():New()

    // Metadados de paginacao
    oMeta["pagina"]          := 1
    oMeta["total_paginas"]   := 5
    oMeta["total_registros"] := 47

    // Payload de dados
    oData["cliente"] := "Empresa Exemplo LTDA"
    oData["cnpj"]    := "00.000.000/0001-00"
    oData["status"]  := "ativo"

    // Envelope final
    oResponse["success"] := .T.
    oResponse["data"]    := oData
    oResponse["meta"]    := oMeta

    ConOut(oResponse:ToJson())

Return
