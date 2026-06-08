# Setup no SAP

## 1. Criar os objetos ABAP

Criar os objetos abaixo no pacote desejado do sistema SAP:

- Report executável: `ZFII001_15E`
- Include: `ZFII001_15E_TOP`
- Include: `ZFII001_15E_SEL`
- Include: `ZFII001_15E_F01`

Copiar o conteúdo dos arquivos da pasta `src` para os respectivos objetos ABAP.

## 2. Cadastrar os Text Symbols

Cadastrar os símbolos de texto listados em `docs/TEXT_SYMBOLS.md`.

## 3. Criar a transação

Criar uma transação do tipo report apontando para o programa principal:

- Transação: `ZFITI001_15E`
- Programa: `ZFII001_15E`

## 4. Executar

Executar o programa pela transação ou diretamente pelo report.

Informar:

- Empresa
- Número do documento, opcional
- Ano fiscal, obrigatório

Ao final, selecionar o caminho local para salvar o arquivo CSV.
