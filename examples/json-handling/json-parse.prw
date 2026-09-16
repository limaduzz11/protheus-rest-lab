#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  JsonParse()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplos de parsing de JSON via JsonObject nativo do Protheus
| Obs.:  Exemplo educacional — acesso direto por propriedades e colchetes
*---------------------------------------------------------------------*/

User Function JsonParse()

    ConOut("=== Exemplo 1: JSON simples ===")
    ParseSimpleJson()

    ConOut("=== Exemplo 2: JSON com arrays e objetos aninhados ===")
    ParseComplexJson()

    ConOut("=== Exemplo 3: Tratamento de erros ===")
    ParseWithErrorHandling()

Return

/*--------------------------------------------------------------------*
| ParseSimpleJson — JSON simples com tipos basicos
*---------------------------------------------------------------------*/
Static Function ParseSimpleJson()

    Local cJson := '{"nome":"Eduardo","idade":28,"ativo":true,"saldo":1500.50}'
    Local oJson := JsonObject():New()
    Local cRet  := ""

    cRet := oJson:FromJson(cJson)

    If cRet == Nil
        ConOut("Nome: "  + cValToChar(oJson["nome"]))
        ConOut("Idade: " + cValToChar(oJson["idade"]))
        ConOut("Ativo: " + cValToChar(oJson["ativo"]))
        ConOut("Saldo: " + cValToChar(oJson["saldo"]))
    Else
        ConOut("Erro no parse: " + cValToChar(cRet))
    EndIf

Return

/*--------------------------------------------------------------------*
| ParseComplexJson — JSON com array de objetos aninhados
*---------------------------------------------------------------------*/
Static Function ParseComplexJson()

    Local cJson := '{' + ;
        '"empresa": "ELP Tecnologia",' + ;
        '"endereco": {' + ;
            '"rua": "Av. Exemplo",' + ;
            '"numero": 100,' + ;
            '"cidade": "Rio de Janeiro"' + ;
        '},' + ;
        '"servicos": [' + ;
            '{"nome":"Consultoria Protheus","valor":5000},' + ;
            '{"nome":"Desenvolvimento ADVPL","valor":8000},' + ;
            '{"nome":"Integracao APIs","valor":3500}' + ;
        ']' + ;
    '}'

    Local oJson     := JsonObject():New()
    Local oEndereco
    Local aServicos := {}
    Local nI        := 0
    Local oServico

    If oJson:FromJson(cJson) == Nil
        ConOut("Empresa: " + cValToChar(oJson["empresa"]))

        // Objeto aninhado
        If oJson:HasProperty("endereco")
            oEndereco := oJson["endereco"]
            ConOut("Cidade: " + cValToChar(oEndereco["cidade"]))
        EndIf

        // Array de objetos
        If oJson:HasProperty("servicos") .And. ValType(oJson["servicos"]) == "A"
            aServicos := oJson["servicos"]
            ConOut("Total de servicos: " + cValToChar(Len(aServicos)))

            For nI := 1 To Len(aServicos)
                oServico := aServicos[nI]
                ConOut("  " + cValToChar(oServico["nome"]) + ;
                       " — R$ " + cValToChar(oServico["valor"]))
            Next nI
        EndIf
    EndIf

Return

/*--------------------------------------------------------------------*
| ParseWithErrorHandling — Tratamento de JSON invalido e chaves ausentes
*---------------------------------------------------------------------*/
Static Function ParseWithErrorHandling()

    Local cJsonInvalido := '{nome: sem aspas}'
    Local cJsonValido   := '{"status":"ok"}'
    Local oJson         := JsonObject():New()
    Local cRet          := ""

    // Tentativa de parse com JSON invalido
    cRet := oJson:FromJson(cJsonInvalido)
    If cRet != Nil
        ConOut("[ParseWithErrorHandling] Sucesso na deteccao de erro: " + cValToChar(cRet))
    EndIf

    // Parse valido com checagem de propriedade
    If oJson:FromJson(cJsonValido) == Nil
        If oJson:HasProperty("campo_inexistente")
            ConOut("Campo existe!")
        Else
            ConOut("Campo 'campo_inexistente' ausente — aplicando valor padrao seguro")
        EndIf
    EndIf

Return
