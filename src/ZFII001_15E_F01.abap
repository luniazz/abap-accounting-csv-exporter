*&---------------------------------------------------------------------*
*& Include          ZFII001_15E_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& FORM buscar_dados
*& Seleciona os documentos contábeis e seus itens nas tabelas BKPF/BSEG
*& conforme os filtros informados na tela de seleção.
*&---------------------------------------------------------------------*
FORM buscar_dados.
  CLEAR gt_data.

  SELECT bk~bukrs,
         bk~gjahr,
         bk~belnr,
         bk~budat,
         bk~waers,
         bs~buzei,
         bs~hkont,
         bs~bschl,
         bs~shkzg,
         bs~dmbtr
    FROM bkpf AS bk
    INNER JOIN bseg AS bs
      ON bk~bukrs = bs~bukrs
     AND bk~belnr = bs~belnr
     AND bk~gjahr = bs~gjahr
   WHERE bk~bukrs IN @s_bukrs
     AND bk~belnr IN @s_belnr
     AND bk~gjahr = @p_gjahr
     AND bk~blart = @c_blart_sa " Apenas documentos contábeis do tipo SA
    INTO CORRESPONDING FIELDS OF TABLE @gt_data.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM tratar_debito_credito
*& Converte o indicador SAP SHKZG:
*& S = Débito  -> D
*& H = Crédito -> C
*&---------------------------------------------------------------------*
FORM tratar_debito_credito.
  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    CASE <fs_data>-shkzg.
      WHEN 'S'.
        <fs_data>-dc = 'D'.
      WHEN 'H'.
        <fs_data>-dc = 'C'.
      WHEN OTHERS.
        CLEAR <fs_data>-dc.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM preparar_dados_csv
*& Move os dados técnicos da GT_DATA para a estrutura final GT_CSV_DATA,
*& mantendo apenas os campos necessários e no layout esperado do CSV.
*&---------------------------------------------------------------------*
FORM preparar_dados_csv.
  CLEAR gt_csv_data.

  LOOP AT gt_data INTO DATA(gs_data).
    DATA(gs_csv_data) = VALUE ty_csv_data(
      empresa          = gs_data-bukrs
      ano              = gs_data-gjahr
      nr_documento     = gs_data-belnr
      data_lancamento  = gs_data-budat
      moeda            = gs_data-waers
      nr_item          = gs_data-buzei
      conta_contabil   = gs_data-hkont
      chave_lancamento = gs_data-bschl
      debito_credito   = gs_data-dc
      valor            = gs_data-dmbtr ).

    APPEND gs_csv_data TO gt_csv_data.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM converter_para_csv
*& Converte a tabela final GT_CSV_DATA em linhas CSV separadas por ';'
*& utilizando a função standard SAP_CONVERT_TO_CSV_FORMAT.
*&---------------------------------------------------------------------*
FORM converter_para_csv.
  CLEAR gt_csv.

  CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
    TABLES
      i_tab_sap_data       = gt_csv_data
    CHANGING
      i_tab_converted_data = gt_csv
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    MESSAGE text-e02 TYPE 'E'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM adicionar_cabecalho
*& Insere manualmente o cabeçalho funcional do arquivo CSV.
*&---------------------------------------------------------------------*
FORM adicionar_cabecalho.
  DATA: lv_header LIKE LINE OF gt_csv.

  lv_header = 'Empresa;Ano;NrDocumento;DataLançamento;Moeda;Nr.Item;ContaContábil;Chave Lançamento;Débito/Crédito;Valor'.
  INSERT lv_header INTO gt_csv INDEX 1.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM caminho_download
*& Abre a janela para o usuário escolher o local e nome do arquivo CSV.
*&---------------------------------------------------------------------*
FORM caminho_download.
  CLEAR: lv_filename,
         lv_path,
         lv_fullpath,
         lv_action.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title              = 'Salvar arquivo CSV'
      default_extension         = 'csv'
      default_file_name         = 'dados_contabeis.csv'
      file_filter               = 'Arquivo CSV (*.csv)|*.csv|'
    CHANGING
      filename                  = lv_filename
      path                      = lv_path
      fullpath                  = lv_fullpath
      user_action               = lv_action
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.

  CASE sy-subrc.
    WHEN 0.
      " Método executou com sucesso
    WHEN 1.
      MESSAGE text-e03 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    WHEN 2.
      MESSAGE text-e04 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    WHEN 3.
      MESSAGE text-e05 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    WHEN 4.
      MESSAGE text-e06 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    WHEN OTHERS.
      MESSAGE text-e07 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDCASE.

  IF lv_action = cl_gui_frontend_services=>action_cancel.
    MESSAGE text-e08 TYPE 'S'.
    CLEAR lv_fullpath.
    RETURN.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM baixar_arquivo
*& Realiza o download do conteúdo da GT_CSV para o caminho selecionado.
*&---------------------------------------------------------------------*
FORM baixar_arquivo.
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename = lv_fullpath
      filetype = 'ASC'
    CHANGING
      data_tab = gt_csv
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      no_authority            = 5
      access_denied           = 15
      disk_full               = 17
      file_not_found          = 19
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 99.

  CASE sy-subrc.
    WHEN 0.
      MESSAGE text-s01 TYPE 'S'.
    WHEN 2 OR 22 OR 23.
      MESSAGE text-e09 TYPE 'S' DISPLAY LIKE 'E'.
    WHEN 5 OR 15.
      MESSAGE text-e10 TYPE 'S' DISPLAY LIKE 'E'.
    WHEN 1 OR 17 OR 19.
      MESSAGE text-e11 TYPE 'S' DISPLAY LIKE 'E'.
    WHEN OTHERS.
      MESSAGE text-e12 TYPE 'S' DISPLAY LIKE 'E'.
  ENDCASE.
ENDFORM.
