#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  JsonBuild()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplos de construcao de JSON — objeto, array, aninhado e via TJsonStruct
| Obs.:  Exemplo educacional — dados ficticios
*---------------------------------------------------------------------*/

User Function JsonBuild()

    ConOut("=== Exemplo 1: JSON simples ===")
    BuildSimpleJson()

    ConOut("=== Exemplo 2: JSON com array ===")
    BuildArrayJson()

    ConOut("=== Exemplo 3: JSON de resposta de API ===")
    BuildApiResponseJson()

    ConOut("=== Exemplo 4: Via TJsonStruct (estruturado) ===")
    BuildWithStruct()

Return

/*--------------------------------------------------------------------*
| BuildSimpleJson — Objeto JSON basico
*---------------------------------------------------------------------*/
Static Function BuildSimpleJson()

    Local oJson := JsonObject():New()
    Local cResult := ""

    oJson:SetProperty("status", "success")
    oJson:SetProperty("codigo", 200)
    oJson:SetProperty("mensagem", "Operacao concluida")
    oJson:SetProperty("timestamp", DtoS(Date()) + " " + Time())

    cResult := oJson:ToJson()
    ConOut(cResult)

Return

/*--------------------------------------------------------------------*
| BuildArrayJson — JSON com array de objetos
*---------------------------------------------------------------------*/
Static Function BuildArrayJson()

    Local oRoot := JsonObject():New()
    Local aItens := {}
    Local oItem

    // Item 1
    oItem := JsonObject():New()
    oItem:SetProperty("id", "001")
    oItem:SetProperty("descricao", "Servico A")
    oItem:SetProperty("quantidade", 2)
    oItem:SetProperty("valor_unitario", 150.00)
    AAdd(aItens, oItem)

    // Item 2
    oItem := JsonObject():New()
    oItem:SetProperty("id", "002")
    oItem:SetProperty("descricao", "Servico B")
    oItem:SetProperty("quantidade", 1)
    oItem:SetProperty("valor_unitario", 450.00)
    AAdd(aItens, oItem)

    oRoot:SetProperty("itens", aItens)
    oRoot:SetProperty("total_itens", Len(aItens))
    oRoot:SetProperty("valor_total", 750.00)

    ConOut(oRoot:ToJson())

Return

/*--------------------------------------------------------------------*
| BuildApiResponseJson — Padrao comum de resposta de API
*---------------------------------------------------------------------*/
Static Function BuildApiResponseJson()

    Local oResponse := JsonObject():New()
    Local oData := JsonObject():New()
    Local oMeta := JsonObject():New()

    // Meta dados da resposta
    oMeta:SetProperty("pagina", 1)
    oMeta:SetProperty("total_paginas", 5)
    oMeta:SetProperty("total_registros", 47)

    // Dados (objeto aninhado com array)
    oData:SetProperty("cliente", "Empresa Exemplo LTDA")
    oData:SetProperty("cnpj", "00.000.000/0001-00")
    oData:SetProperty("status", "ativo")

    // Monta resposta completa
    oResponse:SetProperty("success", .T.)
    oResponse:SetProperty("data", oData)
    oResponse:SetProperty("meta", oMeta)

    ConOut(oResponse:ToJson())

Return

/*--------------------------------------------------------------------*
| BuildWithStruct — Construcao via TJsonStruct para dados tabulares
*---------------------------------------------------------------------*/
Static Function BuildWithStruct()

    Local oStruct := TJsonStruct():New()
    Local cJson := ""

    // Define campos
    oStruct:Add("codigo", "001")
    oStruct:Add("nome", "Produto Exemplo")
    oStruct:Add("preco", 99.90)
    oStruct:Add("estoque", 150)

    // Gera JSON
    cJson := oStruct:ToJson()
    ConOut(cJson)

Return
