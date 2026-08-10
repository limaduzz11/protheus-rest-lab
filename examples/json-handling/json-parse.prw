#include "protheus.ch"

/*--------------------------------------------------------------------*
| Func:  JsonParse()
| Autor: Eduardo Paranhos
| Data:  10/08/2026
| Desc:  Exemplos de parsing de JSON — string, arquivo e resposta HTTP
| Obs.:  Exemplo educacional — dados ficticios
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

    If oJson:FromJson(cJson)
        ConOut("Nome: " + oJson:GetProperty("nome"):GetString())
        ConOut("Idade: " + cValToChar(oJson:GetProperty("idade"):GetNumber()))
        ConOut("Ativo: " + cValToChar(oJson:GetProperty("ativo"):GetLogic()))
        ConOut("Saldo: " + cValToChar(oJson:GetProperty("saldo"):GetNumber()))
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

    Local oJson := JsonObject():New()
    Local oEndereco
    Local aServicos := {}
    Local nI := 0
    Local oServico

    If oJson:FromJson(cJson)
        ConOut("Empresa: " + oJson:GetProperty("empresa"):GetString())

        // Objeto aninhado
        oEndereco := oJson:GetProperty("endereco")
        ConOut("Cidade: " + oEndereco:GetProperty("cidade"):GetString())

        // Array de objetos
        aServicos := oJson:GetProperty("servicos"):GetArray()
        ConOut("Total de servicos: " + cValToChar(Len(aServicos)))

        For nI := 1 To Len(aServicos)
            oServico := aServicos[nI]
            ConOut("  " + oServico:GetProperty("nome"):GetString() + ;
                   " — R$ " + cValToChar(oServico:GetProperty("valor"):GetNumber()))
        Next nI
    EndIf

Return

/*--------------------------------------------------------------------*
| ParseWithErrorHandling — Tratamento de JSON invalido e campos ausentes
*---------------------------------------------------------------------*/
Static Function ParseWithErrorHandling()

    Local cJsonInvalido := '{nome: sem aspas}' // JSON propositalmente invalido
    Local cJsonValido := '{"status":"ok"}'
    Local oJson := JsonObject():New()

    // Tentativa de parse com JSON invalido
    If !oJson:FromJson(cJsonInvalido)
        ConOut("Erro ao parse JSON: formato invalido")
    EndIf

    // Parse valido — verificacao de propriedade ausente
    oJson:FromJson(cJsonValido)

    If oJson:GetProperty("campo_inexistente") != Nil
        ConOut("Campo existe!")
    Else
        ConOut("Campo 'campo_inexistente' nao encontrado — usando valor padrao")
    EndIf

Return
