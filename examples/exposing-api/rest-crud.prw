#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  RestCrud()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de CRUD REST completo para tabela generica (ZZ1)
|        Configurar WSOBJ com path "/api/exemplo/produtos"
| Obs.:  Exemplo educacional — tabela e dados ficticios
*---------------------------------------------------------------------*/

WSRESTFUL RestCrud Description "CRUD de produtos — exemplo educacional"

    WsMethod GET Description "Lista todos ou busca por ID"
    WsMethod POST Description "Cria novo produto"
    WsMethod PUT Description "Atualiza produto existente"
    WsMethod DELETE Description "Remove produto"

ENDWSRESTFUL

/*--------------------------------------------------------------------*
| GET — Lista produtos ou busca por ID no path
*---------------------------------------------------------------------*/
WSMETHOD GET WsReceive QUERY WsService RestCrud

    Local cId := WsGetUrlParam("id")
    Local oResponse := JsonObject():New()
    Local aProdutos := {}
    Local oProduto

    If !Empty(cId)
        // Busca produto especifico
        DbSelectArea("ZZ1")
        DbSetOrder(1) // ZZ1_FILIAL + ZZ1_CODIGO
        If DbSeek(xFilial("ZZ1") + cId)
            oProduto := JsonObject():New()
            oProduto:SetProperty("id", AllTrim(ZZ1->ZZ1_CODIGO))
            oProduto:SetProperty("nome", AllTrim(ZZ1->ZZ1_DESC))
            oProduto:SetProperty("preco", ZZ1->ZZ1_PRECO)
            oResponse:SetProperty("produto", oProduto)
        Else
            WsSetResponse(404, "application/json", '{ "erro": "Produto nao encontrado" }')
            Return .T.
        EndIf
    Else
        // Lista produtos (limitado a 100 para performance)
        DbSelectArea("ZZ1")
        DbSetOrder(1)
        DbGoTop()
        While !Eof() .And. Len(aProdutos) < 100
            oProduto := JsonObject():New()
            oProduto:SetProperty("id", AllTrim(ZZ1->ZZ1_CODIGO))
            oProduto:SetProperty("nome", AllTrim(ZZ1->ZZ1_DESC))
            oProduto:SetProperty("preco", ZZ1->ZZ1_PRECO)
            AAdd(aProdutos, oProduto)
            DbSkip()
        EndDo
        oResponse:SetProperty("total", Len(aProdutos))
        oResponse:SetProperty("produtos", aProdutos)
    EndIf

    WsSetResponse(200, "application/json", oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| POST — Cria novo produto
*---------------------------------------------------------------------*/
WSMETHOD POST WsReceive JSON WsService RestCrud

    Local oBody := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cCodigo := ""

    oBody:FromJson(WsGetPostContent())

    // Valida campos obrigatorios
    If oBody:GetProperty("nome") == Nil
        WsSetResponse(422, "application/json", '{ "erro": "Campo nome obrigatorio" }')
        Return .T.
    EndIf

    // Gera codigo automatico (exemplo simples)
    cCodigo := "PROD" + StrZero(Val(DtoS(Date())), 6)

    // Insere na tabela
    DbSelectArea("ZZ1")
    RecLock("ZZ1", .T.)
    ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
    ZZ1->ZZ1_CODIGO := cCodigo
    ZZ1->ZZ1_DESC   := oBody:GetProperty("nome"):GetString()

    If oBody:GetProperty("preco") != Nil
        ZZ1->ZZ1_PRECO := oBody:GetProperty("preco"):GetNumber()
    EndIf

    MsUnLock()

    oResponse:SetProperty("id", cCodigo)
    oResponse:SetProperty("mensagem", "Produto criado com sucesso")
    WsSetResponse(201, "application/json", oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| PUT — Atualiza produto existente
*---------------------------------------------------------------------*/
WSMETHOD PUT WsReceive JSON WsService RestCrud

    Local cId := WsGetUrlParam("id")
    Local oBody := JsonObject():New()
    Local oResponse := JsonObject():New()

    If Empty(cId)
        WsSetResponse(400, "application/json", '{ "erro": "ID do produto nao informado" }')
        Return .T.
    EndIf

    oBody:FromJson(WsGetPostContent())

    DbSelectArea("ZZ1")
    DbSetOrder(1)

    If DbSeek(xFilial("ZZ1") + cId)
        RecLock("ZZ1", .F.)

        If oBody:GetProperty("nome") != Nil
            ZZ1->ZZ1_DESC := oBody:GetProperty("nome"):GetString()
        EndIf
        If oBody:GetProperty("preco") != Nil
            ZZ1->ZZ1_PRECO := oBody:GetProperty("preco"):GetNumber()
        EndIf

        MsUnLock()

        oResponse:SetProperty("id", cId)
        oResponse:SetProperty("mensagem", "Produto atualizado com sucesso")
        WsSetResponse(200, "application/json", oResponse:ToJson())
    Else
        WsSetResponse(404, "application/json", '{ "erro": "Produto nao encontrado" }')
    EndIf

Return .T.

/*--------------------------------------------------------------------*
| DELETE — Remove produto
*---------------------------------------------------------------------*/
WSMETHOD DELETE WsReceive EMPTY WsService RestCrud

    Local cId := WsGetUrlParam("id")

    If Empty(cId)
        WsSetResponse(400, "application/json", '{ "erro": "ID do produto nao informado" }')
        Return .T.
    EndIf

    DbSelectArea("ZZ1")
    DbSetOrder(1)

    If DbSeek(xFilial("ZZ1") + cId)
        RecLock("ZZ1", .F.)
        DbDelete()
        MsUnLock()

        WsSetResponse(200, "application/json", '{ "mensagem": "Produto removido com sucesso" }')
    Else
        WsSetResponse(404, "application/json", '{ "erro": "Produto nao encontrado" }')
    EndIf

Return .T.
