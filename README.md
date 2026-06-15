# Accounting Documents CSV Exporter

ABAP project for exporting SAP accounting documents to a CSV file, designed for integration with legacy systems.

## Objective

Select accounting documents from the standard SAP tables `BKPF` and `BSEG`, transform the data into a functional layout, and generate a semicolon-separated `.csv` file.

The program allows users to filter accounting documents by:

* Company Code (`BKPF-BUKRS`)
* Fiscal Year (`BKPF-GJAHR`)
* Document Number (`BKPF-BELNR`)

The selection is restricted to accounting documents of type `SA`, using the field `BKPF-BLART`.

## ABAP Objects

| Object            | Type              | Description                                                  |
| ----------------- | ----------------- | ------------------------------------------------------------ |
| `ZFII001_15E`     | Executable Report | Main program                                                 |
| `ZFII001_15E_TOP` | Include           | Global declarations, types, constants and internal tables    |
| `ZFII001_15E_SEL` | Include           | Selection screen                                             |
| `ZFII001_15E_F01` | Include           | Data selection, processing, conversion and download routines |
| `ZFITI001_15E`    | Transaction       | Transaction used to execute the report                       |

## CSV File Layout

```text
Empresa;Ano;NrDocumento;DataLançamento;Moeda;Nr.Item;ContaContábil;Chave Lançamento;Débito/Crédito;Valor
```

SAP fields used in the output:

| CSV Field        | SAP Source                                       |
| ---------------- | ------------------------------------------------ |
| Empresa          | `BKPF-BUKRS`                                     |
| Ano              | `BKPF-GJAHR`                                     |
| NrDocumento      | `BKPF-BELNR`                                     |
| DataLançamento   | `BKPF-BUDAT`                                     |
| Moeda            | `BKPF-WAERS`                                     |
| Nr.Item          | `BSEG-BUZEI`                                     |
| ContaContábil    | `BSEG-HKONT`                                     |
| Chave Lançamento | `BSEG-BSCHL`                                     |
| Débito/Crédito   | Conversion from `BSEG-SHKZG`: `S -> D`, `H -> C` |
| Valor            | `BSEG-DMBTR`                                     |

## Processing Flow

1. The user enters the filters on the selection screen.
2. The program selects accounting documents from `BKPF` and `BSEG`.
3. The debit/credit indicator is converted to the expected output format.
4. The selected data is transformed into the final CSV layout.
5. The internal table is converted to CSV format using `SAP_CONVERT_TO_CSV_FORMAT`.
6. The user selects the download path using `CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG`.
7. The file is saved locally using `CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD`.

## Technical Notes

* The program is designed for online execution, as it uses frontend services for file path selection and download.
* File generation depends on SAP GUI or an environment compatible with `CL_GUI_FRONTEND_SERVICES`.
* The CSV separator used is a semicolon (`;`).
* The accounting document type filter is fixed to `SA` through the constant `c_blart_sa`.

## Repository Structure

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
