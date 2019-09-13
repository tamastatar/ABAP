CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS:
    handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
                      IMPORTING  e_row_id
                                 e_column_id,
on_f4 FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname
                es_row_no
                er_event_data,
handle_data_changed FOR EVENT data_changed
                                  OF  cl_gui_alv_grid
                                  IMPORTING er_data_changed.
ENDCLASS.                    "lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_hotspot_click .
    DATA: ls_col_id   TYPE lvc_s_col.
    READ TABLE gt_data INTO gs_data
                             INDEX e_row_id-index.
    IF sy-subrc = 0.
      CASE e_column_id-fieldname.
        WHEN 'CHECK'.
          IF gs_data-check IS INITIAL.
            gs_data-check = 'X'.
          ELSE.
            gs_data-check = ''.
          ENDIF.
          TRANSLATE gs_data-new_val TO UPPER CASE.
          if gs_data-new_val EQ 'Y' or gs_data-new_val EQ 'N'.
            else.
            Message text-008 Type 'S' DISPLAY LIKE 'E'.
            gs_data-check = ''.
            ENDIF.
          MODIFY gt_data INDEX e_row_id-index FROM gs_data.
          CALL METHOD g_grid->refresh_table_display.
        WHEN OTHERS.
*       do nothing
      ENDCASE.
      CALL METHOD g_grid->set_current_cell_via_id
        EXPORTING
          is_row_id    = e_row_id
          is_column_id = ls_col_id.
    ENDIF.
  ENDMETHOD.                    "handle_hotspot_click
  METHOD on_f4.
    PERFORM on_f4 USING e_fieldname
                es_row_no-row_id.
    er_event_data->m_event_handled = 'X'.

  ENDMETHOD.                    "on_f4
  METHOD handle_data_changed.

    PERFORM data_changed USING er_data_changed.

  ENDMETHOD.                    "handle_data_changed
ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SAVE'.
      CALL METHOD g_grid->check_changed_data.
      PERFORM update.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&  Include           YSDE200R_AUSP_REPORT_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  data_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  YSDE200R_AUSP_REPORT
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   16.08.2019 14:23:36
* CR/IN: CR8000005024
*----------------------------------------------------------------------*
* Short description:
* F&P role to control AOQ flag on customer
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*
FORM data_selection.

  FIELD-SYMBOLS: <ls_ausp> LIKE LINE OF gt_ausp.
  DATA:
        lrng_objek TYPE RANGE OF objnum,
        lsrng_objek LIKE LINE OF lrng_objek,
        ls_kunnr LIKE LINE OF s_kunnr,
        ls_vkorg LIKE LINE OF s_vkorg,
        ls_vtweg LIKE LINE OF s_vtweg,
        ls_spart LIKE LINE OF s_spart.

  lsrng_objek-sign = 'I'.
  lsrng_objek-option = 'EQ'.

  READ TABLE s_vkorg INTO ls_vkorg INDEX 1.
  READ TABLE s_vtweg INTO ls_vtweg INDEX 1.
  READ TABLE s_spart INTO ls_spart INDEX 1.
  READ TABLE s_kunnr INTO ls_kunnr INDEX 1.

  LOOP AT s_kunnr INTO ls_kunnr.
    READ TABLE s_vkorg INTO ls_vkorg INDEX sy-tabix.
    READ TABLE s_vtweg INTO ls_vtweg INDEX sy-tabix.
    READ TABLE s_spart INTO ls_spart INDEX sy-tabix.
    CONCATENATE ls_kunnr-low ls_vkorg-low ls_vtweg-low ls_spart-low INTO lsrng_objek-low.
    APPEND lsrng_objek TO lrng_objek.
  ENDLOOP.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE  gt_ausp
    FROM ausp
    WHERE objek IN lrng_objek
      AND atinn EQ gv_atinn.

  IF s_kunnr-low IS INITIAL
      AND s_vkorg-low IS INITIAL
      AND s_vtweg-low IS INITIAL
      AND s_spart-low IS INITIAL.
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE  gt_ausp
    FROM ausp
    WHERE  atinn EQ gv_atinn.
  ENDIF.
  IF s_kunnr-low IS INITIAL
      OR s_vkorg-low IS INITIAL
      OR s_vtweg-low IS INITIAL
      OR s_spart-low IS INITIAL.

    lsrng_objek-sign = 'I'.
    lsrng_objek-option = 'CP'.

    IF s_kunnr IS NOT INITIAL.
      LOOP AT s_kunnr INTO ls_kunnr.
        READ TABLE s_vkorg INTO ls_vkorg INDEX sy-tabix.
        IF ls_vkorg IS INITIAL.
          ls_vkorg-low = '*'.
        ENDIF.
        READ TABLE s_vtweg INTO ls_vtweg INDEX sy-tabix.
        IF ls_vtweg IS INITIAL.
          ls_vtweg-low = '*'.
        ENDIF.
        READ TABLE s_spart INTO ls_spart INDEX sy-tabix.
        IF ls_spart IS INITIAL.
          ls_spart-low = '*'.
        ENDIF.
        CONCATENATE ls_kunnr-low ls_vkorg-low ls_vtweg-low ls_spart-low INTO lsrng_objek-low.
        APPEND lsrng_objek TO lrng_objek.
      ENDLOOP.
    ELSEIF s_vkorg IS NOT INITIAL.
      LOOP AT s_vkorg INTO ls_vkorg.
        READ TABLE s_kunnr INTO ls_kunnr INDEX sy-tabix.
        IF ls_kunnr IS INITIAL.
          ls_kunnr-low = '*'.
        ENDIF.
        READ TABLE s_vtweg INTO ls_vtweg INDEX sy-tabix.
        IF ls_vtweg IS INITIAL.
          ls_vtweg-low = '*'.
        ENDIF.
        READ TABLE s_spart INTO ls_spart INDEX sy-tabix.
        IF ls_spart IS INITIAL.
          ls_spart-low = '*'.
        ENDIF.
        CONCATENATE ls_kunnr-low ls_vkorg-low ls_vtweg-low ls_spart-low INTO lsrng_objek-low.
        APPEND lsrng_objek TO lrng_objek.
      ENDLOOP.
    ELSEIF s_vtweg IS NOT INITIAL.
      LOOP AT s_vtweg INTO ls_vtweg.
        READ TABLE s_vkorg INTO ls_vkorg INDEX sy-tabix.
        IF ls_vkorg IS INITIAL.
          ls_vkorg-low = '*'.
        ENDIF.
        READ TABLE s_kunnr INTO ls_kunnr INDEX sy-tabix.
        IF ls_kunnr IS INITIAL.
          ls_kunnr-low = '*'.
        ENDIF.
        READ TABLE s_spart INTO ls_spart INDEX sy-tabix.
        IF ls_spart IS INITIAL.
          ls_spart-low = '*'.
        ENDIF.
        CONCATENATE ls_kunnr-low ls_vkorg-low ls_vtweg-low ls_spart-low INTO lsrng_objek-low.
        APPEND lsrng_objek TO lrng_objek.
      ENDLOOP.
    ELSEIF s_spart IS NOT INITIAL.
      LOOP AT s_spart INTO ls_spart.
        READ TABLE s_vkorg INTO ls_vkorg INDEX sy-tabix.
        IF ls_vkorg IS INITIAL.
          ls_vkorg-low = '*'.
        ENDIF.
        READ TABLE s_vtweg INTO ls_vtweg INDEX sy-tabix.
        IF ls_vtweg IS INITIAL.
          ls_vtweg-low = '*'.
        ENDIF.
        READ TABLE s_kunnr INTO ls_kunnr INDEX sy-tabix.
        IF ls_kunnr IS INITIAL.
          ls_kunnr-low = '*'.
        ENDIF.
        CONCATENATE ls_kunnr-low ls_vkorg-low ls_vtweg-low ls_spart-low INTO lsrng_objek-low.
        APPEND lsrng_objek TO lrng_objek.
      ENDLOOP.
    ENDIF.

    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE  gt_ausp
    FROM ausp
    WHERE objek IN lrng_objek
      AND atinn EQ gv_atinn.

  ENDIF.

  LOOP AT gt_ausp ASSIGNING <ls_ausp>.
    gs_data-objek = <ls_ausp>-objek.
    gs_data-kunnr = <ls_ausp>-objek(10).
    gs_data-vkorg = <ls_ausp>-objek+10(4).
    gs_data-vtweg = <ls_ausp>-objek+14(2).
    gs_data-char = <ls_ausp>-atinn.
    gs_data-curr_val = <ls_ausp>-atwrt.
    APPEND gs_data TO gt_data.
  ENDLOOP.



ENDFORM.                    "data_selection
*&---------------------------------------------------------------------*
*&      Form  Update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update.
  DATA:
        lt_ausp   TYPE TABLE OF ausp,
        lrng_objek TYPE RANGE OF objnum,
        lsrng_objek LIKE LINE OF lrng_objek.

  FIELD-SYMBOLS: <ls_ausp> TYPE ausp.


  LOOP AT gt_data INTO gs_data WHERE check = 'X'.
    lsrng_objek-sign = 'I'.
    lsrng_objek-option = 'EQ'.
    lsrng_objek-low = gs_data-objek.
    APPEND lsrng_objek TO lrng_objek.
  ENDLOOP.

  IF lrng_objek IS NOT INITIAL.
    SELECT *
      INTO TABLE lt_ausp
      FROM ausp
      WHERE objek IN lrng_objek
        AND atinn EQ gv_atinn.
  ENDIF.

  LOOP AT lt_ausp ASSIGNING <ls_ausp>.
    READ TABLE gt_data INTO gs_data WITH KEY objek = <ls_ausp>-objek.
    IF gs_data-new_val EQ 'N' OR gs_data-new_val EQ 'Y'.
      <ls_ausp>-atwrt = gs_data-new_val.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'CLVF_UPDATE_AUSP'
    TABLES
      upd_ausp = lt_ausp.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  LEAVE TO SCREEN 0.

ENDFORM.                    "Update
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_fieldcatalog.
  gs_fieldcat-fieldname = 'CHECK'.
  gs_fieldcat-scrtext_s   = text-001.
  gs_fieldcat-scrtext_m   = text-001.
  gs_fieldcat-scrtext_l   = text-001.
  gs_fieldcat-hotspot = 'X'.
  gs_fieldcat-checkbox = 'X'.
  gs_fieldcat-edit = 'X'.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'KUNNR'.
  gs_fieldcat-scrtext_s    = text-002.
  gs_fieldcat-scrtext_l    = text-002.
  gs_fieldcat-scrtext_m    = text-002.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VKORG'.
  gs_fieldcat-scrtext_s    = text-003.
  gs_fieldcat-scrtext_l    = text-003.
  gs_fieldcat-scrtext_m    = text-003.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VTWEG'.
  gs_fieldcat-scrtext_s    = text-004.
  gs_fieldcat-scrtext_l    = text-004.
  gs_fieldcat-scrtext_m    = text-004.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'CHAR'.
  gs_fieldcat-scrtext_s    = text-005.
  gs_fieldcat-scrtext_l    = text-005.
  gs_fieldcat-scrtext_m    = text-005.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'CURR_VAL'.
  gs_fieldcat-scrtext_s    = text-006.
  gs_fieldcat-scrtext_l    = text-006.
  gs_fieldcat-scrtext_m    = text-006.
  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'NEW_VAL'.
  gs_fieldcat-scrtext_s    = text-007.
  gs_fieldcat-scrtext_l    = text-007.
  gs_fieldcat-scrtext_m    = text-007.
  gs_fieldcat-edit = 'X'.
  gs_fieldcat-f4availabl = 'X'.
  APPEND gs_fieldcat TO gt_fieldcat.
ENDFORM. " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  register_f4_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM register_f4_fields.    "which fields will have F4 search help
  DATA: lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.
  DATA: lt_f4_data TYPE lvc_s_f4.

  lt_f4_data-fieldname = 'NEW_VAL'.
  lt_f4_data-register = 'X' .
  lt_f4_data-chngeafter  ='X'.
  INSERT lt_f4_data INTO TABLE lt_f4.
  CALL METHOD g_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].
ENDFORM.                    "register_f4_fields
*&---------------------------------------------------------------------*
*&      Form  on_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME    text
*      -->ROW_ID           text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS   text
*      -->P_E_DISPLAY      text
*      -->IR_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM on_f4  USING   p_e_fieldname
                    row_id.
  TYPES: BEGIN OF ty_f4table , "the value table that is passed to F4 fm
           field  TYPE char10,
           field2 TYPE char40,
    END OF ty_f4table,
    tty_f4table TYPE STANDARD TABLE OF ty_f4table.
  DATA:
     lt_data               TYPE tty_f4table,
     ls_data               TYPE ty_f4table,
     lt_return             TYPE TABLE OF ddshretval WITH HEADER LINE.

  ls_data-field = 'Y'.
  ls_data-field2 = 'Yes'.
  APPEND ls_data TO lt_data.
  ls_data-field = 'N'.
  ls_data-field2 = 'No'.
  APPEND ls_data TO lt_data.

  CASE p_e_fieldname.   "read changed cell
    WHEN 'NEW_VAL'.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'NEW_VAL'
          value_org       = 'S'
          dynpprog        = sy-repid
          dynpnr          = sy-dynnr
          dynprofield     = 'GT_DATA-NEW_VAL'
        TABLES
          value_tab       = lt_data
          return_tab      = lt_return
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
      IF sy-subrc = 0 .
        READ TABLE gt_data INTO gs_data INDEX row_id.
        IF lt_return-fieldval EQ 'Yes'.
          gs_data-new_val = 'Y'.
          MODIFY gt_data INDEX row_id FROM gs_data.
        ELSE.
          gs_data-new_val = 'N'.
          MODIFY gt_data INDEX row_id FROM gs_data.
        ENDIF.
        CALL METHOD g_grid->refresh_table_display.
      ENDIF.
  ENDCASE.
ENDFORM.                    "on_f4
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM data_changed  USING p_er_data_changed
                         TYPE REF TO cl_alv_changed_data_protocol.
  DATA : ls_mod_cells TYPE lvc_s_modi,
         lv_new_value TYPE atwrt.

  LOOP AT p_er_data_changed->mt_good_cells INTO ls_mod_cells .
    CASE ls_mod_cells-fieldname.
      WHEN 'NEW_VAL'.
        CALL METHOD p_er_data_changed->get_cell_value
          EXPORTING
            i_row_id    = ls_mod_cells-row_id
            i_fieldname = 'NEW_VAL'
          IMPORTING
            e_value     = lv_new_value.

        TRANSLATE lv_new_value TO UPPER CASE.

        IF lv_new_value EQ 'Y' OR  lv_new_value EQ 'N'.
        ELSE.
          Message text-008 Type 'S' DISPLAY LIKE 'E'.
*          CALL METHOD p_er_data_changed->add_protocol_entry
*            EXPORTING
*              i_msgid     = '00'
*              i_msgno     = '001'
*              i_msgty     = 'E'
*              i_msgv1     = text-008
*              i_fieldname = ls_mod_cells-fieldname
*              i_row_id    = ls_mod_cells-row_id.
*          EXIT.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    "DATA_CHANGED

*----------------------------------------------------------------------*
***INCLUDE YSDE200R_AUSP_REPORT_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  YSDE200R_AUSP_REPORT
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   16.08.2019 14:23:36
* CR/IN: CR8000005024
*----------------------------------------------------------------------*
* Short description:
* F&P role to control AOQ flag on customer
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'PF_STATUS'.
  SET TITLEBAR 'TITLE'.

  IF g_custom_container IS INITIAL.

    DATA: l_handler TYPE REF TO lcl_event_handler.
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_custom_container.

    PERFORM build_fieldcatalog.

    " SET_TABLE_FOR_FIRST_DISPLAY
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_fieldcatalog = gt_fieldcat
        it_outtab       = gt_data. " Data

  ELSE.
    CALL METHOD g_grid->refresh_table_display.
  ENDIF.

  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.


  CREATE OBJECT l_handler.
  SET HANDLER l_handler->handle_hotspot_click FOR g_grid.
  SET HANDLER l_handler->on_f4 FOR g_grid.
  SET HANDLER l_handler->handle_data_changed FOR g_grid.
  PERFORM register_f4_fields.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&  Include           YSDE200R_AUSP_REPORT_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  YSDE200R_AUSP_REPORT
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   16.08.2019 14:23:36
* CR/IN: CR8000005024
*----------------------------------------------------------------------*
* Short description:
* F&P role to control AOQ flag on customer
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*

SELECT-OPTIONS: s_kunnr FOR gs_knvv-kunnr,
                s_vkorg FOR gs_knvv-vkorg OBLIGATORY,
                s_vtweg FOR gs_knvv-vtweg OBLIGATORY,
                s_spart FOR gs_knvv-spart OBLIGATORY.

PARAMETERS: p_char(50) TYPE c AS LISTBOX VISIBLE LENGTH 20  OBLIGATORY.

DATA: lv_name  TYPE vrm_id,
      lt_list  TYPE vrm_values,
      ls_list LIKE LINE OF lt_list,
      lv_atinn(50) TYPE c,
      lv_text(50) TYPE c.

AT SELECTION-SCREEN OUTPUT.

  SELECT SINGLE parval
     INTO lv_atinn
     FROM
    yxpw_globe_par
    WHERE yprogram EQ gc_par_program .

  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      input  = lv_atinn
    IMPORTING
      output = gv_atinn.

  SELECT SINGLE atbez
  INTO lv_text
  FROM cabnt
  WHERE atinn EQ gv_atinn.

  lv_name = 'P_CHAR'.
  ls_list-text = lv_text.
  ls_list-key = lv_text.
  APPEND ls_list TO lt_list.
  DELETE ADJACENT DUPLICATES FROM lt_list.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = lv_name
      values = lt_list.

  p_char = lv_text.

START-OF-SELECTION.
  PERFORM data_selection.

  CALL SCREEN 100.
  
  *&---------------------------------------------------------------------*
*&  Include           YSDE200R_AUSP_REPORT_TOP
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   06.09.2019 15:29:09
* CR/IN: 01
*----------------------------------------------------------------------*
* Short description:
*
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*
TYPE-POOLS: vrm , slis.

CONSTANTS:
gc_par_program(40) type c VALUE 'YSDE200R_AUSP_REPORT'.

TYPES:
 BEGIN OF ty_data,
  objek             TYPE objnum,
  check(1),
  kunnr             TYPE kunnr,
  vkorg             TYPE vkorg,
  vtweg             TYPE vtweg,
  char              TYPE atinn,
  curr_val          TYPE atwrt,
  new_val           TYPE atwrt,
  END OF ty_data,
  tty_data TYPE STANDARD TABLE OF ty_data.

DATA: gv_atinn(50)          TYPE c,
      gt_ausp               TYPE TABLE OF ausp,
      gs_knvv               TYPE knvv,
      gt_data               TYPE tty_data,
      gs_data               TYPE ty_data,
      gs_layout             TYPE lvc_s_layo,
      g_container           TYPE scrfname VALUE 'CUSTOM_CONTROL',
      g_custom_container    TYPE REF TO cl_gui_custom_container,
      g_grid                TYPE REF TO cl_gui_alv_grid,
      gt_fieldcat           TYPE lvc_s_fcat OCCURS 0,
      gs_fieldcat           LIKE LINE OF gt_fieldcat.
