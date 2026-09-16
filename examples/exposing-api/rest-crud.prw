#include "protheus.ch"
#include "restful.ch"
#include "topconn.ch"

/*--------------------------------------------------------------------*
| Func:  RestCrud()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplo de CRUD REST completo com WSRESTFUL e JsonObject nativo
|        Path configurado: "/api/exemplo/produtos"
| Obs.:  Exemplo educacional para tabela generica ZZ1
*---------------------------------------------------------------------*/

WSRESTFUL RestCrud DESCRIPTION "CRUD de produtos — exemplo educacional" FORMAT APPLICATION_JSON

    WSDATA id AS CHARACTER OPTIONAL

    WSMETHOD GET DESCRIPTION "Lista todos os produtos ou busca por ID" WSSYNTAX "/api/exemplo/produtos || /api/exemplo/produtos/{id}"
    WSMETHOD POST DESCRIPTION "Cria novo produto" WSSYNTAX "/api/exemplo/produtos"
    WSMETHOD PUT DESCRIPTION "Atualiza produto existente" WSSYNTAX "/api/exemplo/produtos/{id}"
    WSMETHOD DELETE DESCRIPTION "Remove produto" WSSYNTAX "/api/exemplo/produtos/{id}"

END WSRESTFUL

/*--------------------------------------------------------------------*
| GET — Lista produtos ou busca por ID
*---------------------------------------------------------------------*/
WSMETHOD GET WSRECEIVE id WSSERVICE RestCrud

    Local cAlias    := GetNextAlias()
    Local cQuery    := ""
    Local oResponse := JsonObject():New()
    Local aProdutos := {}
    Local oProduto
    Local cId       := ""

    ::SetContentType("application/json")

    If ValType(::id) == "C"
        cId := AllTrim(::id)
    ElseIf Len(::aURLParms) >= 1
        cId := AllTrim(::aURLParms[1])
    EndIf

    cQuery := "SELECT ZZ1_CODIGO, ZZ1_DESC, ZZ1_PRECO "
    cQuery += "  FROM " + RetSqlName("ZZ1") + " ZZ1 "
    cQuery += " WHERE ZZ1.ZZ1_FILIAL = '" + xFilial("ZZ1") + "' "
    cQuery += "   AND ZZ1.D_E_L_E_T_ = ' ' "
    If !Empty(cId)
        cQuery += "   AND ZZ1.ZZ1_CODIGO = '" + cId + "' "
    EndIf
    cQuery += " ORDER BY ZZ1.ZZ1_CODIGO "
    cQuery := ChangeQuery(cQuery)

    TCQuery cQuery New Alias (cAlias)

    While !(cAlias)->(Eof())
        oProduto := JsonObject():New()
        oProduto["id"]    := AllTrim((cAlias)->ZZ1_CODIGO)
        oProduto["nome"]  := AllTrim((cAlias)->ZZ1_DESC)
        oProduto["preco"] := (cAlias)->ZZ1_PRECO
        AAdd(aProdutos, oProduto)
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

    If !Empty(cId) .And. Len(aProdutos) == 0
        SetRestFault(404, "Produto nao encontrado")
        Return .F.
    EndIf

    If !Empty(cId)
        oResponse["produto"] := aProdutos[1]
    Else
        oResponse["total"]    := Len(aProdutos)
        oResponse["produtos"] := aProdutos
    EndIf

    ::SetResponse(oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| POST — Cria novo produto
*---------------------------------------------------------------------*/
WSMETHOD POST WSSERVICE RestCrud

    Local oBody     := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cCodigo   := ""
    Local cNome     := ""
    Local nPreco    := 0
    Local cContent  := ::GetContent()

    ::SetContentType("application/json")

    If Empty(cContent) .Or. oBody:FromJson(cContent) != Nil
        SetRestFault(400, "Payload JSON invalido")
        Return .F.
    EndIf

    If !oBody:HasProperty("nome") .Or. Empty(oBody["nome"])
        SetRestFault(422, "Campo 'nome' e obrigatorio")
        Return .F.
    EndIf

    cNome := oBody["nome"]
    If oBody:HasProperty("preco")
        nPreco := oBody["preco"]
    EndIf

    Begin Transaction
        cCodigo := GetSxeNum("ZZ1", "ZZ1_CODIGO")

        DbSelectArea("ZZ1")
        DbSetOrder(1) // ZZ1_FILIAL + ZZ1_CODIGO

        RecLock("ZZ1", .T.)
        ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
        ZZ1->ZZ1_CODIGO := cCodigo
        ZZ1->ZZ1_DESC   := cNome
        ZZ1->ZZ1_PRECO  := nPreco
        MsUnlock()

        ConfirmSX8()
    End Transaction

    oResponse["id"]       := cCodigo
    oResponse["mensagem"] := "Produto criado com sucesso"

    ::SetResponse(oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| PUT — Atualiza produto existente
*---------------------------------------------------------------------*/
WSMETHOD PUT WSRECEIVE id WSSERVICE RestCrud

    Local oBody     := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cId       := ""
    Local cContent  := ::GetContent()

    ::SetContentType("application/json")

    If ValType(::id) == "C"
        cId := AllTrim(::id)
    ElseIf Len(::aURLParms) >= 1
        cId := AllTrim(::aURLParms[1])
    EndIf

    If Empty(cId)
        SetRestFault(400, "ID do produto nao informado na URL")
        Return .F.
    EndIf

    If Empty(cContent) .Or. oBody:FromJson(cContent) != Nil
        SetRestFault(400, "Payload JSON invalido")
        Return .F.
    EndIf

    DbSelectArea("ZZ1")
    DbSetOrder(1)

    If !DbSeek(xFilial("ZZ1") + cId)
        SetRestFault(404, "Produto nao encontrado")
        Return .F.
    EndIf

    Begin Transaction
        RecLock("ZZ1", .F.)
        If oBody:HasProperty("nome")
            ZZ1->ZZ1_DESC := oBody["nome"]
        EndIf
        If oBody:HasProperty("preco")
            ZZ1->ZZ1_PRECO := oBody["preco"]
        EndIf
        MsUnlock()
    End Transaction

    oResponse["id"]       := cId
    oResponse["mensagem"] := "Produto atualizado com sucesso"

    ::SetResponse(oResponse:ToJson())

Return .T.

/*--------------------------------------------------------------------*
| DELETE — Remove produto
*---------------------------------------------------------------------*/
WSMETHOD DELETE WSRECEIVE id WSSERVICE RestCrud

    Local oResponse := JsonObject():New()
    Local cId       := ""

    ::SetContentType("application/json")

    If ValType(::id) == "C"
        cId := AllTrim(::id)
    ElseIf Len(::aURLParms) >= 1
        cId := AllTrim(::aURLParms[1])
    EndIf

    If Empty(cId)
        SetRestFault(400, "ID do produto nao informado na URL")
        Return .F.
    EndIf

    DbSelectArea("ZZ1")
    DbSetOrder(1)

    If !DbSeek(xFilial("ZZ1") + cId)
        SetRestFault(404, "Produto nao encontrado")
        Return .F.
    EndIf

    Begin Transaction
        RecLock("ZZ1", .F.)
        DbDelete()
        MsUnlock()
    End Transaction

    oResponse["mensagem"] := "Produto removido com sucesso"
    ::SetResponse(oResponse:ToJson())

Return .T.
