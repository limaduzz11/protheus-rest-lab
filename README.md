# Protheus REST Lab

Practical examples of REST API consumption and exposure within the TOTVS Protheus ecosystem using ADVPL. Covers HTTP requests, JSON handling, authentication, and REST endpoint creation.

> **Disclaimer**: All examples are educational. They use fictional endpoints, mock data, and generic table names. Not production code from any specific client or company.

## Contents

### Consuming APIs
- `httpclient-get.prw` — GET request with query parameters
- `httpclient-post.prw` — POST request with JSON body
- `httpclient-auth.prw` — Authentication (Basic Auth + Token)

### Exposing APIs
- `rest-endpoint.prw` — Simple REST endpoint via WSOBJ
- `rest-crud.prw` — Full CRUD REST service

### JSON Handling
- `json-parse.prw` — Parsing JSON responses
- `json-build.prw` — Building JSON objects

## Tech Stack

`ADVPL` `TOTVS Protheus` `REST APIs` `JSON` `HTTPClient` `WSOBJ`

## Quick Start

1. Copy the `.prw` files to your Protheus environment
2. Compile and run via SmartClient or AppServer
3. For REST endpoints, configure WSOBJ in the Protheus REST configuration

## License

MIT
