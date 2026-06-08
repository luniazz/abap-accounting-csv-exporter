*&---------------------------------------------------------------------*
*& Include          ZFII001_15E_TOP
*&---------------------------------------------------------------------*
*& Declarações globais do programa:
*& - Estrutura técnica com dados lidos das tabelas BKPF/BSEG
*& - Estrutura final no layout do arquivo CSV
*& - Tabelas internas utilizadas no processamento
*& - Variáveis auxiliares para seleção do caminho de download
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
* Estrutura técnica com os dados selecionados nas tabelas BKPF/BSEG
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_data,
         bukrs TYPE bkpf-bukrs,
         gjahr TYPE bkpf-gjahr,
         belnr TYPE bkpf-belnr,
         budat TYPE bkpf-budat,
         waers TYPE bkpf-waers,
         buzei TYPE bseg-buzei,
         hkont TYPE bseg-hkont,
         bschl TYPE bseg-bschl,
         shkzg TYPE bseg-shkzg,
         dc    TYPE c LENGTH 1,
         dmbtr TYPE bseg-dmbtr,
       END OF ty_data.

*---------------------------------------------------------------------*
* Estrutura final utilizada para montar o layout do arquivo CSV
* Os campos são definidos como CHAR para controlar o formato de saída
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_csv_data,
         empresa          TYPE char4,
         ano              TYPE char4,
         nr_documento     TYPE char10,
         data_lancamento  TYPE char8,
         moeda            TYPE char5,
         nr_item          TYPE char3,
         conta_contabil   TYPE char10,
         chave_lancamento TYPE char2,
         debito_credito   TYPE char1,
         valor            TYPE char20,
       END OF ty_csv_data.

*---------------------------------------------------------------------*
* Constantes utilizadas nas regras de negócio
*---------------------------------------------------------------------*
CONSTANTS: c_blart_sa TYPE bkpf-blart VALUE 'SA'.

*---------------------------------------------------------------------*
* Tabelas internas do processamento
*---------------------------------------------------------------------*
DATA: gt_data     TYPE TABLE OF ty_data,      " Dados técnicos BKPF/BSEG
      gt_csv_data TYPE TABLE OF ty_csv_data,  " Dados preparados para CSV
      gt_csv      TYPE truxs_t_text_data.     " Linhas finais do arquivo CSV

*---------------------------------------------------------------------*
* Variáveis auxiliares para escolha do caminho e nome do arquivo
*---------------------------------------------------------------------*
DATA: lv_filename TYPE string,
      lv_path     TYPE string,
      lv_fullpath TYPE string,
      lv_action   TYPE i.
