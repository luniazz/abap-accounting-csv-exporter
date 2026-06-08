# Accounting Documents CSV Exporter

Projeto ABAP para exportação de documentos contábeis do SAP para arquivo CSV, com foco em integração com sistemas legados.

## Objetivo

Selecionar documentos contábeis nas tabelas standard `BKPF` e `BSEG`, preparar os dados em um layout funcional e gerar um arquivo `.csv` separado por ponto e vírgula.

O programa permite filtrar os documentos por:

- Empresa (`BKPF-BUKRS`)
- Ano fiscal (`BKPF-GJAHR`)
- Número do documento (`BKPF-BELNR`)

A seleção considera apenas documentos contábeis do tipo `SA`, utilizando o campo `BKPF-BLART`.

## Objetos ABAP

| Objeto | Tipo | Descrição |
|---|---|---|
| `ZFII001_15E` | Report executável | Programa principal |
| `ZFII001_15E_TOP` | Include | Declarações globais, tipos, constantes e tabelas internas |
| `ZFII001_15E_SEL` | Include | Tela de seleção |
| `ZFII001_15E_F01` | Include | Rotinas de busca, tratamento, conversão e download |
| `ZFITI001_15E` | Transação | Transação para execução do report |

## Layout do arquivo CSV

```text
Empresa;Ano;NrDocumento;DataLançamento;Moeda;Nr.Item;ContaContábil;Chave Lançamento;Débito/Crédito;Valor
```

Campos SAP utilizados:

| Campo CSV | Origem SAP |
|---|---|
| Empresa | `BKPF-BUKRS` |
| Ano | `BKPF-GJAHR` |
| NrDocumento | `BKPF-BELNR` |
| DataLançamento | `BKPF-BUDAT` |
| Moeda | `BKPF-WAERS` |
| Nr.Item | `BSEG-BUZEI` |
| ContaContábil | `BSEG-HKONT` |
| Chave Lançamento | `BSEG-BSCHL` |
| Débito/Crédito | Conversão de `BSEG-SHKZG`: `S -> D`, `H -> C` |
| Valor | `BSEG-DMBTR` |

## Fluxo de processamento

1. O usuário informa os filtros na tela de seleção.
2. O programa seleciona documentos nas tabelas `BKPF` e `BSEG`.
3. O indicador de débito/crédito é convertido para o layout esperado.
4. Os dados são preparados no layout final.
5. A tabela interna é convertida para CSV usando `SAP_CONVERT_TO_CSV_FORMAT`.
6. O usuário escolhe o caminho de download usando `CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG`.
7. O arquivo é salvo localmente usando `CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD`.

## Observações técnicas

- O programa foi desenvolvido para execução online, pois utiliza serviços de frontend para seleção de caminho e download do arquivo.
- A geração do arquivo depende do SAP GUI ou de ambiente compatível com `CL_GUI_FRONTEND_SERVICES`.
- O separador utilizado no CSV é ponto e vírgula (`;`).
- O filtro por tipo de documento está fixo para `SA` através da constante `c_blart_sa`.

## Estrutura do repositório

```text
.
├── README.md
├── src
│   ├── ZFII001_15E.abap
│   ├── ZFII001_15E_TOP.abap
│   ├── ZFII001_15E_SEL.abap
│   └── ZFII001_15E_F01.abap
├── docs
│   ├── TEXT_SYMBOLS.md
│   └── SETUP.md
└── examples
    └── sample_output.csv
```
