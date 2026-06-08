*&---------------------------------------------------------------------*
*& Report ZFII001_15E
*&---------------------------------------------------------------------*
*& Objetivo:
*& Selecionar documentos contábeis nas tabelas BKPF/BSEG,
*& preparar os dados no layout definido e gerar um arquivo CSV
*& para integração com sistema legado.
*&---------------------------------------------------------------------*
REPORT zfii001_15e.

INCLUDE zfii001_15e_top. " Variáveis, tipos e tabelas internas
INCLUDE zfii001_15e_sel. " Tela de seleção: filtros de empresa, ano e documento
INCLUDE zfii001_15e_f01. " Rotinas de processamento: busca, tratamento, conversão e download

START-OF-SELECTION.

  PERFORM buscar_dados.

  " Interrompe o processamento caso nenhum documento seja encontrado
  IF gt_data IS INITIAL.
    MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM tratar_debito_credito.
  PERFORM preparar_dados_csv.
  PERFORM converter_para_csv.
  PERFORM adicionar_cabecalho.
  PERFORM caminho_download.

  IF lv_fullpath IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM baixar_arquivo.
