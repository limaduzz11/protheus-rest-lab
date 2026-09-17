# Laboratório REST Protheus

[![ADVPL](https://img.shields.io/badge/Linguagem-ADVPL%2FTL%2B%2B-005696?style=flat)](https://tdn.totvs.com/)
[![ERP](https://img.shields.io/badge/Plataforma-TOTVS%20Protheus%2012-ED1C24?style=flat)](https://www.totvs.com/protheus/)
[![API](https://img.shields.io/badge/Protocolo-REST%20%2F%20JSON-blue?style=flat)](https://www.json.org/)
[![Banco de Dados](https://img.shields.io/badge/Banco-SQL%20Server-CC292B?style=flat&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![Licença: MIT](https://img.shields.io/badge/Licen%C3%A7a-MIT-yellow.svg)](LICENSE)

<br />

[English](README.md) &nbsp;|&nbsp; **Português (Brasil)**

<br />

Laboratório e referência arquitetural para desenvolvimento, consumo e testes de **Web Services RESTful** no ecossistema **TOTVS Protheus ERP** utilizando **ADVPL** e **TL++**.

Aborda publicação nativa de rotas (`WSRESTFUL` / `restful.ch`), consumo HTTP outbound (`FWRest`), serialização JSON de alto desempenho (`JsonObject`), códigos de status HTTP padronizados e persistência segura em banco de dados.

---

> [!NOTE]
> **Aviso Educacional & de Segurança**:  
> Todas as rotinas, esquemas, endpoints, tabelas customizadas (`ZZ1`) e cargas de dados de exemplo neste repositório são estritamente educacionais e genéricas. Não há nomes de clientes reais, regras de negócio confidenciais, IPs de produção ou credenciais corporativas.

---

## Ciclo de Vida Arquitetural de Requisição e Resposta

O diagrama abaixo ilustra como uma requisição HTTP percorre a arquitetura do TOTVS Protheus, executa a lógica de negócios em ADVPL, interage com o banco de dados relacional e retorna uma resposta JSON padronizada ao cliente consumidor.

```mermaid
sequenceDiagram
    autonumber
    actor Client as Cliente Externo (cURL / Postman / Barramento)
    participant AppServer as Protheus AppServer (REST Worker / Porta 8084)
    participant WS as Servico WSRESTFUL (rest-crud.prw)
    participant Model as Logica ADVPL / RecLock / ExecAuto
    participant DBAccess as TOTVS DBAccess / TopConnect
    participant DB as Banco Relacional (SQL Server / Oracle / PostgreSQL)

    Client->>AppServer: HTTP POST /api/exemplo/produtos (Payload JSON)
    Note over AppServer: Leitura de appserver.ini [HTTPREST]<br/>Alocacao de thread worker
    AppServer->>WS: Direciona para WSMETHOD POST
    WS->>WS: Faz parse do payload via JsonObject:FromJson(::GetContent())
    
    alt Campo obrigatorio ausente ("nome")
        WS-->>Client: SetRestFault(422, "Campo nome e obrigatorio")
    else Payload Valido
        WS->>Model: Prepara insercao de registro (ZZ1_CODIGO, ZZ1_DESC, ZZ1_PRECO)
        Model->>DBAccess: Begin Transaction + RecLock("ZZ1", .T.) + MsUnlock()
        DBAccess->>DB: INSERT INTO ZZ1010 (ZZ1_FILIAL, ZZ1_CODIGO, ...)
        DB-->>DBAccess: Commit com sucesso (201 Created)
        DBAccess-->>Model: Confirmacao da operacao
        Model-->>WS: Confirma transacao (ConfirmSX8)
        WS->>WS: Monta objeto JSON {"id": "000001", "mensagem": "..."}
        WS->>AppServer: ::SetResponse(oResponse:ToJson())
        AppServer-->>Client: HTTP/1.1 201 Created (Resposta JSON)
    end
```

---

## Padrões Arquiteturais

### 1. Serviços REST Inbound (Exposição de APIs)
- Hospedados nativamente pelo Protheus AppServer através da seção `[HTTPREST]` utilizando `#include "restful.ch"`.
- Métodos suportados: `GET`, `POST`, `PUT`, `DELETE` via diretiva `WSMETHOD`.
- Respostas padronizadas com tratamento defensivo de erros via `SetRestFault()`.

### 2. Consumo de APIs Outbound (Cliente REST)
- Implementado através da classe `FWRest`, gerenciando cabeçalhos HTTP, codificação de payloads, autenticação Bearer/Basic e controle de timeouts.

### 3. Manipulação e Serialização JSON
- Estruturação de dados com `JsonObject`, garantindo serialização fluida e segura para estruturas aninhadas e coleções dinâmicas.

---

## Licença

Distribuído sob a licença [MIT](LICENSE).
