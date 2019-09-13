*&---------------------------------------------------------------------*
*& Report  YBCR0042R_CHARMUPDATE
*&
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   03.06.2019 13:11:39
* CR/IN: 8000005813
*----------------------------------------------------------------------*
* Short description:
* ChaRM Mass update
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*
INCLUDE YBCR0042R_CHARMUPDATE_TOP               .    " global Data
INCLUDE crm_object_kinds_con                    .    " CRM update
INCLUDE crm_object_names_con                    .    " CRM update
INCLUDE crm_mode_con                            .    " CRM update
INCLUDE YBCR0042R_CHARMUPDATE_C01               .    " Local Classes
INCLUDE YBCR0042R_CHARMUPDATE_SEL               .    " Selection Screen
INCLUDE YBCR0042R_CHARMUPDATE_F01               .    " FORM-Routines


*&---------------------------------------------------------------------*
*& Include YBCR0042R_CHARMUPDATE_TOP                         Report YBCR0042R_CHARMUPDATE
*&
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   03.06.2019 13:11:39
* CR/IN: 8000005813
*----------------------------------------------------------------------*
* Short description:
* ChaRM Mass update
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*

REPORT   ybcr0042r_charmupdate.
TYPE-POOLS: slis,icon.
TYPES:
 BEGIN OF ty_header,
  guid        TYPE crmt_object_guid,
  partner_fct TYPE crmt_partner_fct,
  END OF ty_header,
 tty_header TYPE STANDARD TABLE OF ty_header,

 BEGIN OF ty_data,
  check             TYPE flag,
  icon              TYPE icon-id,
  object_id         LIKE crmd_orderadm_h-object_id,
  program           TYPE ybcr0042s_program-program,
  stream            TYPE ybce0012s_charm_rep-stream,
  module            TYPE ybce0012s_charm_rep-module,
  description       LIKE crmd_orderadm_h-description,
  status(30)        TYPE c,
  name_lan(100)     TYPE c,
  role(40)          TYPE c,
  partner           LIKE but000-partner,
  guid              TYPE crmt_object_guid,
  partner_fct       TYPE crmt_partner_fct,
  END OF ty_data,
  tty_data TYPE STANDARD TABLE OF ty_data,

  BEGIN OF ty_category,
  cat_id            TYPE crm_erms_cat_ca_id,
  cat_descr         TYPE crm_erms_cat_ca_desc,
  cat_guid          TYPE crm_erms_cat_guid,
  END OF ty_category,
  tty_category TYPE STANDARD TABLE OF ty_category,

 BEGIN OF ty_selscreen,
status             TYPE ybce0012s_charm_rep-status,
release            TYPE ybce0012s_charm_rep-release,
program            TYPE ybcr0042s_program-program,
stream             TYPE ybce0012s_charm_rep-stream,
module             TYPE ybce0012s_charm_rep-module,
END OF ty_selscreen.

FIELD-SYMBOLS: <gs_but000> TYPE  but000,
               <gs_output> TYPE ty_data.
DATA:
        alv_table             TYPE REF TO cl_salv_table,
        gt_header             TYPE tty_header,
        gs_header             TYPE ty_header,
        gt_req_obj            TYPE crmt_object_name_tab,
        gs_req_obj            TYPE crmt_object_name,
        gt_guid               TYPE TABLE OF crmt_object_guid,
        gv_guid               TYPE crmt_object_guid,
        gv_log_handle         TYPE balloghndl,
        gt_orderadm_h         TYPE crmt_orderadm_h_wrkt,
        gt_partner            TYPE crmt_partner_external_wrkt,
        gs_partner            TYPE crmt_partner_external_wrk,
        gt_subject            TYPE crmt_subject_wrkt,
        gt_status             TYPE crmt_status_wrkt,
        gs_status             LIKE LINE OF gt_status,
        gt_doc_flow           TYPE crmt_doc_flow_wrkt,
        gs_doc_flow           TYPE crmt_doc_flow_wrk,
        gt_approval           TYPE crmt_approval_wrkt,
        gv_index              TYPE sy-tabix,
        gt_text               TYPE crmt_text_wrkt,
        gs_output             TYPE ty_data,
        gt_category           TYPE tty_category,
        gs_category           TYPE ty_category,
        gs_orderham           LIKE LINE OF gt_orderadm_h,
        gv_partner            TYPE but000-partner,
        gt_data               TYPE TABLE OF ty_data,
        gt_but000             TYPE TABLE OF but000,
        gs_but000             TYPE but000,
        gs_selscreen          TYPE ty_selscreen,
        gv_name_lan(30)       TYPE c,
        gv_name_lan_2(30)     TYPE c,
        grng_partner          TYPE RANGE OF comt_partner_fct,
        gsrng_partner         LIKE LINE OF grng_partner,
        gt_log                TYPE TABLE OF ybcr0042t_log,
        gs_log                TYPE ybcr0042t_log,
        gv_seq_log            TYPE /bcv/fnd_sequence_no,
        gv_complete(1)        TYPE c.



CONSTANTS:
           gc_process_type TYPE process_type VALUE 'ZMCR',
           gc_status_profil TYPE  crm_j_stsma VALUE 'ZMCRHEAD'.
           *----------------------------------------------------------------------*
*   INCLUDE CRM_OBJECT_KINDS_CON                                       *
*----------------------------------------------------------------------*


* object kinds
CONSTANTS: BEGIN OF gc_object_kind,
             orderadm_h     TYPE  crmt_object_kind  VALUE 'A',
             orderadm_i     TYPE  crmt_object_kind  VALUE 'B',
             extension_h    TYPE  crmt_object_kind  VALUE 'C',
             extension_i    TYPE  crmt_object_kind  VALUE 'D',
             set            TYPE  crmt_object_kind  VALUE 'E',
         END OF gc_object_kind.

* ref kinds
CONSTANTS: BEGIN OF gc_object_ref_kind,
             orderadm_h     TYPE  crmt_object_kind
                                      VALUE gc_object_kind-orderadm_h,
             orderadm_i     TYPE  crmt_object_kind
                                      VALUE gc_object_kind-orderadm_i,
             extension_i    TYPE  crmt_object_kind
                                      VALUE gc_object_kind-extension_i,
             any            TYPE  crmt_object_kind
                                      VALUE space,
           END OF gc_object_ref_kind.
*----------------------------------------------------------------------*
*   INCLUDE CRM_OBJECT_NAMES_CON                                       *
*----------------------------------------------------------------------*

* object names
CONSTANTS:

BEGIN OF gc_object_name,
  ac_assign     TYPE  crmt_object_name  VALUE 'AC_ASSIGN',
  accounting    TYPE  crmt_object_name  VALUE 'ACCOUNTING',
  action        TYPE  crmt_object_name  VALUE 'ACTION',
  activity_addr TYPE  crmt_object_name  VALUE 'ACTIVITY_ADDR',
  activity_h    TYPE  crmt_object_name  VALUE 'ACTIVITY_H',
  activity_i    TYPE  crmt_object_name  VALUE 'ACTIVITY_I',
  apo_i         TYPE  crmt_object_name  VALUE 'APO_I',
  appointment   TYPE  crmt_object_name  VALUE 'APPOINTMENT',
  approval      TYPE  crmt_object_name  VALUE 'APPROVAL',
  approval_s    TYPE  crmt_object_name  VALUE 'APPROVAL_S',
  attachments   TYPE  crmt_object_name  VALUE 'ATTACHMENTS',
  batch         TYPE  crmt_object_name  VALUE 'BATCH',
  billing       TYPE  crmt_object_name  VALUE 'BILLING',
  billplan      TYPE  crmt_object_name  VALUE 'BILLPLAN',
  billreq_i     TYPE  crmt_object_name  VALUE 'BILLREQ_I',
  brf           TYPE  crmt_object_name  VALUE 'BRF',
  bpo_fund_extn TYPE  crmt_object_name  VALUE 'FM_BPO_FUND_EXTN',
  fmbpo_fnd_fnp_extn TYPE  crmt_object_name  VALUE 'FMBPO_FND_FNP_EXTN',
  cancel        TYPE  crmt_object_name  VALUE 'CANCEL',
  chklst_ext    TYPE  crmt_object_name  VALUE 'CHKLST',
  chngproc_h    TYPE  crmt_object_name  VALUE 'CHNGPROC_H',
  chngproc_i    TYPE  crmt_object_name  VALUE 'CHNGPROC_I',
  cla_h         TYPE  crmt_object_name  VALUE 'CLA_H',
  cla_i         TYPE  crmt_object_name  VALUE 'CLA_I',
  cnd_fld_cat   TYPE  crmt_object_name  VALUE 'CND_FLD_CAT',
  condition_com TYPE  crmt_object_name  VALUE 'CONDITION_COM',
  config        TYPE  crmt_object_name  VALUE 'CONFIG',
  config_filter TYPE  crmt_object_name  VALUE 'CONFIG_FILTER',
  confirm       TYPE  crmt_object_name  VALUE 'CONFIRM',
  copy          TYPE  crmt_object_name  VALUE 'COPY',
  creditvalues  TYPE  crmt_object_name  VALUE 'CREDITVALUES',
  cumulat_h     TYPE  crmt_object_name  VALUE 'CUMULAT_H',
  cumulated_i   TYPE  crmt_object_name  VALUE 'CUMULATED_I',
  customer_h    TYPE  crmt_object_name  VALUE 'CUSTOMER_H',
  customer_i    TYPE  crmt_object_name  VALUE 'CUSTOMER_I',
  custtab_h     TYPE  crmt_object_name  VALUE 'CUSTTAB_H',
  custtab_i     TYPE  crmt_object_name  VALUE 'CUSTTAB_I',
  dates         TYPE  crmt_object_name  VALUE 'DATES',
  doc_flow      TYPE  crmt_object_name  VALUE 'DOC_FLOW',
  dyn_attr      TYPE  crmt_object_name  VALUE 'DYN_ATTR',
  entitlement   TYPE  crmt_object_name  VALUE 'ENTITLEMENT',
  ext_ref       TYPE  crmt_object_name  VALUE 'EXT_REF',
  finprod_i     TYPE  crmt_object_name  VALUE 'FINPROD_I',
  freightcost   TYPE  crmt_object_name  VALUE 'FREIGHTCOST',
  fs_ca_type    TYPE  crmt_object_name  VALUE 'FSCA01_10_EXT_CA_TYPE',
  fs_ca_det     TYPE  crmt_object_name  VALUE 'FSCA02_10_EXT_CA_DET',
  fs_age        TYPE  crmt_object_name  VALUE 'FS_001_10_EXT_AGE',
  fs_int        TYPE  crmt_object_name  VALUE 'FS_003_10_EXT_INT',
  fs_usage      TYPE  crmt_object_name  VALUE 'FS_004_10_EXT_USAGE',
  fs_disagio    TYPE  crmt_object_name  VALUE 'FS_005_10_EXT_DISAGIO',
  fs_loancond   TYPE  crmt_object_name  VALUE 'FS_007_10_EXT_LOAN_COND',
  fs_sa         TYPE  crmt_object_name  VALUE 'FS_010_10_EXT_SA',
  fs_loanpaym   TYPE  crmt_object_name VALUE 'FS_017_10_EXT_LOANPAYMENTS',
  fs_bankid     TYPE  crmt_object_name  VALUE 'FS_018_10_EXT_BANKID',
  fs_loanres    TYPE  crmt_object_name VALUE 'FS_019_10_EXT_LOAN_RESULT',
  fs_re_type    TYPE  crmt_object_name  VALUE 'FS_C01_10_EXT_RE_TYPE',
  fs_re_det     TYPE  crmt_object_name  VALUE 'FS_C02_10_EXT_RE_DET',
  fs_re_site    TYPE  crmt_object_name  VALUE 'FS_C03_10_EXT_RE_SITE',
  fs_finview    TYPE  crmt_object_name  VALUE 'FS_FINVIEW_10_EXT',
  fs_variant    TYPE  crmt_object_name  VALUE 'FS_VARIANT_10_EXT',
  fs_calcpro    TYPE  crmt_object_name  VALUE 'FS_CALCPRO_10_EXT',
  fs_tax        TYPE  crmt_object_name  VALUE 'FS_TAX_10_EXT',
  fs_classif    TYPE  crmt_object_name  VALUE 'FS_CLASSIF_10_EXT',
  fs_option     TYPE  crmt_object_name  VALUE 'FS_OPTION_10_EXT',
  fs_workcal    TYPE  crmt_object_name  VALUE 'FS_WORKCAL_10_EXT',
  fs_deint      TYPE  crmt_object_name  VALUE 'FS_DEINT_10_EXT',
  fs_deamo      TYPE  crmt_object_name  VALUE 'FS_DEAMO_10_EXT',
  fs_cashflo    TYPE  crmt_object_name  VALUE 'FS_CASHFLO_10_EXT',
  fs_drm        TYPE  crmt_object_name  VALUE 'FS_DRM_1O_EXT',
  fs_bri_group  TYPE  crmt_object_name  VALUE 'BRI_GROUP',
  fuelcard      TYPE  crmt_object_name  VALUE 'FUELCARD',
  fund_h        TYPE  crmt_object_name  VALUE 'FUND_H',
  grid          TYPE  crmt_object_name  VALUE 'GRID',
  gift_cert     TYPE  crmt_object_name  VALUE 'GIFT_CERT',
  grm_com       TYPE  crmt_object_name  VALUE 'GRM_COM',
  ipr_prod_i    TYPE  crmt_object_name  VALUE 'IPR_PROD_I',
  ipm_rctrl_i   TYPE  crmt_object_name  VALUE 'IPM_RCTRL_I',
  ipm_rchar     TYPE  crmt_object_name  VALUE 'IPM_RCHAR',
  ipm_revdist   TYPE  crmt_object_name  VALUE 'IPM_REVDIST',
  ist_item_ext  TYPE  crmt_object_name  VALUE 'IST_ITEM_EXTENSION',
  isuext        TYPE  crmt_object_name  VALUE 'ISUEXT',
  isu_rel       TYPE  crmt_object_name  VALUE 'ISU_REL',
  isu_item_ext  TYPE  crmt_object_name  VALUE 'ISU_ITEM_EXT',
  isu_sec_dep   TYPE  crmt_object_name  VALUE 'ISU_SEC_DEP',
  lawref_h      TYPE  crmt_object_name  VALUE 'LAWREF_H',
  lead_h        TYPE  crmt_object_name  VALUE 'LEAD_H',
  limit         TYPE  crmt_object_name  VALUE 'LIMIT',
  link          TYPE  crmt_object_name  VALUE 'LINK',
  listing       TYPE  crmt_object_name  VALUE 'LISTING',
  mkttopnp_i    TYPE  crmt_object_name  VALUE 'MKTTOPNP_i',
  messages      TYPE  crmt_object_name  VALUE 'MESSAGES',
  opport_h      TYPE  crmt_object_name  VALUE 'OPPORT_H',
  opport_i      TYPE  crmt_object_name  VALUE 'OPPORT_I',
  opp_sem       TYPE  crmt_object_name  VALUE 'OPP_SEM',
  order         TYPE  crmt_object_name  VALUE 'ORDER',
  orderadm_h    TYPE  crmt_object_name  VALUE 'ORDERADM_H',
  orderadm_i    TYPE  crmt_object_name  VALUE 'ORDERADM_I',
  ordprp_i      TYPE  crmt_object_name  VALUE 'ORDPRP_I',
  orgman        TYPE  crmt_object_name  VALUE 'ORGMAN',
  partner       TYPE  crmt_object_name  VALUE 'PARTNER',
  payplan       TYPE  crmt_object_name  VALUE 'PAYPLAN',
  payplan_d     TYPE  crmt_object_name  VALUE 'PAYPLAN_D',
  pricing       TYPE  crmt_object_name  VALUE 'PRICING',
  pridoc_com    TYPE  crmt_object_name  VALUE 'PRIDOC_COM',
  pricing_i     TYPE  crmt_object_name  VALUE 'PRICING_I',
  pridoc        TYPE  crmt_object_name  VALUE 'PRIDOC',
  product_i     TYPE  crmt_object_name  VALUE 'PRODUCT_I',
  qualif        TYPE  crmt_object_name  VALUE 'QUALIF',
  refobj        TYPE  crmt_object_name  VALUE 'REFOBJ',
  sales         TYPE  crmt_object_name  VALUE 'SALES',
  schedlin      TYPE  crmt_object_name  VALUE 'SCHEDLIN',
  schedlin_i    TYPE  crmt_object_name  VALUE 'SCHEDLIN_I',
  service_h     TYPE  crmt_object_name  VALUE 'SERVICE_H',
  service_i     TYPE  crmt_object_name  VALUE 'SERVICE_I',
  service_os    TYPE  crmt_object_name  VALUE 'SERVICE_OS',
  srv_req_h     TYPE  crmt_object_name  VALUE 'SRV_REQ_H',
  serviceplan_i TYPE  crmt_object_name  VALUE 'SERVICEPLAN_I',
  shipping      TYPE  crmt_object_name  VALUE 'SHIPPING',
  srv_prodlist  TYPE  crmt_object_name  VALUE 'SERVICE_PRODLIST',
  status        TYPE  crmt_object_name  VALUE 'STATUS',
  status_h      TYPE  crmt_object_name  VALUE 'STATUS_H',
  struct_i      TYPE  crmt_object_name  VALUE 'STRUCT_I',
  subject       TYPE  crmt_object_name  VALUE 'SUBJECT',
  survey        TYPE  crmt_object_name  VALUE 'SURVEY',
  tax           TYPE  crmt_object_name  VALUE 'TAX',
  tc_tech_res   TYPE  crmt_object_name  VALUE 'TC_TECH_RES',
  tireservice   TYPE  crmt_object_name  VALUE 'TIRESERVICE',
  tolerance     TYPE  crmt_object_name  VALUE 'TOLERANCE',
  texts         TYPE  crmt_object_name  VALUE 'TEXTS',
  ubb_ctr_i     TYPE  crmt_object_name  VALUE 'UBB_CTR_I',
  ubb_cr_i      TYPE  crmt_object_name  VALUE 'UBB_CR_I',
  ubb_vol_i     TYPE  crmt_object_name  VALUE 'UBB_VOL_I',
  ubb_hdper_i   TYPE  crmt_object_name  VALUE 'UBB_HDPER_I',
  ubb_stg_i     TYPE  crmt_object_name  VALUE 'UBB_STG_I',
  fund_plan_h   TYPE  crmt_object_name  VALUE 'FUND_PLAN_H',
END OF gc_object_name.


* object names for reporting purposes
CONSTANTS: BEGIN OF gc_objectname_reporting,
* accounting      TYPE SEOCLSNAME       VALUE 'ACCOUNTING',
* activity_addr   TYPE SEOCLSNAME       VALUE 'ACTIVITY_ADDR',
  activity_h      TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_ACTIVITY_H',
  appointment     TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_APPOINTMENT',
  appointment_i   TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_APPOINT_I',
* attachments     TYPE SEOCLSNAME       VALUE 'ATTACHMENTS',
  billing         TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_BILLING',
  pricing         TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_PRICING',
  pric_item       TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_PRIC_ITEM',
  shipping        TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_SHIPPING',
  billing_item    TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_BILLING_I',
  pricing_item    TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_PRICING_I',
  shipping_item   TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_SHIPPING_I',
  cumulated_item  TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_CUMULATED_I',
  struct_item     TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_STRUCT_I',
  finprod_item    TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_FINPROD_I',
  ipm_rchar       TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_IPM_RCHAR',
  ipm_rchar_item  TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_IPM_RCHAR_I',
  ipm_rctrl_i     TYPE crmt_object_name VALUE 'CL_CRM_REPORT_EXT_IPM_RCTRL_I',
  product_item    TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_PRODUCT_I',
  product_i       TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_PRODUCT_I',
  customer_h      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_CUSTOMER_H',
  customer_i      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_CUSTOMER_I',
  schedlin        TYPE crmt_object_name VALUE 'CL_CRM_REPORT_SET_SCHEDLIN',
* condition_com   TYPE SEOCLSNAME       VALUE 'CONDITION_COM',
* config          TYPE SEOCLSNAME       VALUE 'CONFIG',
* confirm         TYPE SEOCLSNAME       VALUE 'CONFIRM',
* cumulat_h       TYPE SEOCLSNAME       VALUE 'CUMULAT_H',
* customer_h      TYPE SEOCLSNAME       VALUE 'CUSTOMER_H',
* customer_i      TYPE SEOCLSNAME       VALUE 'CUSTOMER_I',
* freightcost     TYPE SEOCLSNAME       VALUE 'FREIGHTCOST',
* limit           TYPE SEOCLSNAME       VALUE 'LIMIT',
* link            TYPE SEOCLSNAME       VALUE 'LINK',
* messages        TYPE SEOCLSNAME       VALUE 'MESSAGES',
  lead_h          TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_LEAD_H',
  opport_h        TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_OPPORT_H',
* order           TYPE SEOCLSNAME       VALUE 'ORDER',
  orderadm_h      TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_ORDERADM_H',
  orderadm_i      TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_ORDERADM_I',
  service_i       TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_SERVICE_I',
  orgman          TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_ORGMAN',
  orgman_i        TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_ORGMAN_I',
  partner         TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_PARTNER',
  partner_item    TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_PARTNER_I',
* payplan         TYPE SEOCLSNAME       VALUE 'PAYPLAN',
* phase           TYPE SEOCLSNAME       VALUE 'PHASE',
* pricing         TYPE SEOCLSNAME       VALUE 'PRICING',
* pridoc_com      TYPE SEOCLSNAME       VALUE 'PRIDOC_COM',
* pricing_i       TYPE SEOCLSNAME       VALUE 'PRICING_I',
* pridoc          TYPE SEOCLSNAME       VALUE 'PRIDOC',
* product_i       TYPE SEOCLSNAME       VALUE 'PRODUCT_I',
  sales           TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SALES',
  sales_item      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SALES_I',
  cancel          TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_CANCEL',
  cancel_item     TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_CANCEL_I',
* schedlin        TYPE SEOCLSNAME       VALUE 'SCHEDLIN',
* schedlin_i      TYPE SEOCLSNAME       VALUE 'SCHEDLIN_I',
* service_h       TYPE SEOCLSNAME       VALUE 'SERVICE_H',
* service_i       TYPE SEOCLSNAME       VALUE 'SERVICE_I',
  service_os      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SRV_SUBJECT',
  srv_refobj      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SRV_REFOBJ',
  srv_refobj_i    TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SRV_REFOBJ_I',
  srv_subject     TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SRV_SUBJECT',
  srv_subject_i   TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_SRV_SUBJ_I',
  service_h       TYPE seoclsname       VALUE  'CL_CRM_REPORT_EXT_SERVICE_H',
  webr_index      TYPE seoclsname       VALUE  'CL_CRM_REPORT_EXT_WEBR_INDEX',
* shipping        TYPE SEOCLSNAME       VALUE 'SHIPPING',
  status          TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_STATUS',
  status_i        TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_REPORTLIST_I',
* struct_i        TYPE SEOCLSNAME       VALUE 'STRUCT_I',
* tax             TYPE SEOCLSNAME       VALUE 'TAX',
* texts           TYPE SEOCLSNAME       VALUE 'TEXTS',
  locatorlist     TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_LOCATORLIST',
  reportlist_item TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_REPORTLIST_I',
  rma_index       TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_RMA_INDEX',
  fund_h          TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT',
  cla_h           TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_CLA_H',
  fund_plan_h     TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT',
  ext_ref         TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_EXT_REF',
  lawref_h        TYPE seoclsname       VALUE 'CL_CRM_REPORT_EXT_LAWREF_H',
  approval_s      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_APPROVAL_S',
  payplan_dp      TYPE seoclsname       VALUE 'CL_CRM_REPORT_SET_PAYPLAN_DP',
*  fmbpo_fnd_fnp_extn TYPE seoclsname    VALUE 'CL_CRM_REPORT_EXT',
END OF gc_objectname_reporting.

* object types for conversion from type to name
CONSTANTS: BEGIN OF gc_object_type_convert,
  orderadm_h TYPE crmt_object_type VALUE '05',
  orderadm_i TYPE crmt_object_type VALUE '06',
  billing    TYPE crmt_object_type VALUE '46',
  billplan   TYPE crmt_object_type VALUE '47',
  sales      TYPE crmt_object_type VALUE '11',
  dates      TYPE crmt_object_type VALUE '44',
  doc_flow   TYPE crmt_object_type VALUE '52',
  shipping   TYPE crmt_object_type VALUE '12',
  orgman     TYPE crmt_object_type VALUE '21',
  pricing    TYPE crmt_object_type VALUE '09',
  appointment TYPE crmt_object_type VALUE '30',
  cumulated_i TYPE crmt_object_type VALUE '56',
  status      TYPE crmt_object_type VALUE '36',
  creditvalues TYPE crmt_object_type VALUE '76',
  partner    TYPE crmt_object_type VALUE '07',
  activity_h TYPE crmt_object_type VALUE '01',
  payplan    TYPE crmt_object_type VALUE '02',
  ordprp_i   TYPE crmt_object_type VALUE '16',
  bri_group  TYPE crmt_object_type VALUE '85',
END OF gc_object_type_convert.

* Contants used in Customer Includes
CONSTANTS:  BEGIN OF gc_ci_name,
  orderadm_h    TYPE  crmt_object_name  VALUE 'CI_EEW_ORDERADM_H',
  orderadm_i    TYPE  crmt_object_name  VALUE 'CI_EEW_ORDERADM_I',
  activity_h    TYPE  crmt_object_name  VALUE 'CI_EEW_ACTIVITY_H',
  opport_h      TYPE  crmt_object_name  VALUE 'CI_EEW_OPPORT_H',
  lead_h        TYPE  crmt_object_name  VALUE 'CI_EEW_LEAD_H',
  product_i     TYPE  crmt_object_name  VALUE 'CI_EEW_PRODUCT_I',
  finprod_i     TYPE  crmt_object_name  VALUE 'CI_EEW_FINPROD_I',
  fund_h        TYPE  crmt_object_name  VALUE 'CI_EEW_FUND_H',
  cla_h         TYPE  crmt_object_name  VALUE 'CI_EEW_CLA_H',
  sales         TYPE  crmt_object_name  VALUE 'CI_EEW_SALES',
  shipping      TYPE  crmt_object_name  VALUE 'CI_EEW_SHIPPING',
  billing       TYPE  crmt_object_name  VALUE 'CI_EEW_BILLING',
  orgman        TYPE  crmt_object_name  VALUE 'CI_EEW_ORGMAN',
  pricing       TYPE  crmt_object_name  VALUE 'CI_EEW_PRICING',
  pricing_i     TYPE  crmt_object_name  VALUE 'CI_EEW_PRICING_I',
  schedlin      TYPE  crmt_object_name  VALUE 'CI_EEW_SCHEDLIN',
  service_i     TYPE  crmt_object_name  VALUE 'CI_EEW_SERVICE_I',
  customer_h    TYPE  crmt_object_name  VALUE 'CI_EEW_CUSTOMER_H',
  customer_i    TYPE  crmt_object_name  VALUE 'CI_EEW_CUSTOMER_I',
*  fmbpo_fnd_fnp_extn TYPE crmt_object_name  VALUE 'CI_EEW_AV',
END OF gc_ci_name.

* Contants used in Customer Includes
CONSTANTS:  BEGIN OF gc_aet_name,
  orderadm_h    TYPE  crmt_object_name  VALUE 'INCL_EEW_ORDERADM_H',
  orderadm_i    TYPE  crmt_object_name  VALUE 'INCL_EEW_ORDERADM_I',
  activity_h    TYPE  crmt_object_name  VALUE 'INCL_EEW_ACTIVITY_H',
  opport_h      TYPE  crmt_object_name  VALUE 'INCL_EEW_OPPORT_H',
  lead_h        TYPE  crmt_object_name  VALUE 'INCL_EEW_LEAD_H',
  product_i     TYPE  crmt_object_name  VALUE 'INCL_EEW_PRODUCT_I',
  fund_h        TYPE  crmt_object_name  VALUE 'INCL_EEW_FUND_H',
  cla_h         TYPE  crmt_object_name  VALUE 'INCL_EEW_CLA_H',
  sales         TYPE  crmt_object_name  VALUE 'INCL_EEW_SALES',
  shipping      TYPE  crmt_object_name  VALUE 'INCL_EEW_SHIPPING',
  billing       TYPE  crmt_object_name  VALUE 'INCL_EEW_BILLING',
  orgman        TYPE  crmt_object_name  VALUE 'INCL_EEW_ORGMAN',
  pricing       TYPE  crmt_object_name  VALUE 'INCL_EEW_PRICING',
  pricing_i     TYPE  crmt_object_name  VALUE 'INCL_EEW_PRICING_I',
  schedlin      TYPE  crmt_object_name  VALUE 'INCL_EEW_SCHEDLIN',
  service_i     TYPE  crmt_object_name  VALUE 'INCL_EEW_SERVICE_I',
  service_h     TYPE  crmt_object_name  VALUE 'INCL_EEW_SERVICE_H',
  customer_h    TYPE  crmt_object_name  VALUE 'INCL_EEW_CUSTOMER_H',
  customer_i    TYPE  crmt_object_name  VALUE 'INCL_EEW_CUSTOMER_I',
  partner       type  crmt_object_name  VALUE 'INCL_EEW_PARTNER_CRM',
  activity_i    TYPE  crmt_object_name  VALUE 'INCL_EEW_ACTIVITY_I',
*  fmbpo_fnd_fnp_extn TYPE crmt_object_name  VALUE 'CI_EEW_AV',
END OF gc_aet_name.
*----------------------------------------------------------------------*
*   INCLUDE CRM_MODE_CON                                               *
*----------------------------------------------------------------------*

CONSTANTS: BEGIN OF gc_mode,
             create     TYPE   crmt_mode   VALUE   'A',
             change     TYPE   crmt_mode   VALUE   'B',
             display    TYPE   crmt_mode   VALUE   'C',
             delete     TYPE   crmt_mode   VALUE   'D',
           END OF gc_mode.

CONSTANTS: gc_template_ui TYPE crmt_ssc_ui_method value 'TEMPLATE'.

CONSTANTS: gc_us          TYPE OTYPE              value 'US'.
*&---------------------------------------------------------------------*
*&  Include           YBCR0042R_CHARMUPDATE_C01
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   03.06.2019 13:11:39
* CR/IN: 8000005813
*----------------------------------------------------------------------*
* Short description:
* ChaRM Mass update
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
*
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column,
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
*
ENDCLASS.                    "lcl_event_handler DEFINITION

CLASS lcl_event_handler IMPLEMENTATION.
*
  METHOD on_link_click.
*
*   Get the value of the checkbox and set the value accordingly
*   Refersh the table
    FIELD-SYMBOLS: <ls_data> LIKE LINE OF gt_data.
    DATA : lt_locked TYPE tty_data,
           ls_locked TYPE ty_data.
    READ TABLE gt_data ASSIGNING <ls_data> INDEX row.
    CHECK sy-subrc IS INITIAL.
    IF <ls_data>-check IS INITIAL.
      <ls_data>-check = 'X'.
    ELSE.
      CLEAR <ls_data>-check.
    ENDIF.
    PERFORM check_if_object_locked TABLES lt_locked.
    IF lt_locked IS NOT INITIAL.
      LOOP AT gt_data ASSIGNING <ls_data> WHERE check = 'X'.
        READ TABLE lt_locked INTO ls_locked WITH KEY guid = <ls_data>-guid.
        IF sy-subrc EQ 0.
          MESSAGE text-017 TYPE 'I'.
          <ls_data>-check = ''.
        ENDIF.
      ENDLOOP.
    ENDIF.
    alv_table->refresh( ).
  ENDMETHOD.                    "on_link_click

  METHOD on_user_command.
    FIELD-SYMBOLS: <ls_data> LIKE LINE OF gt_data.
    DATA : lt_locked TYPE tty_data,
           ls_locked TYPE ty_data.
    CASE e_salv_function.
      WHEN 'SELECTALL'.
        LOOP AT gt_data ASSIGNING <ls_data>.
          <ls_data>-check = 'X'.
        ENDLOOP.
        PERFORM check_if_object_locked TABLES lt_locked.
        IF lt_locked IS NOT INITIAL.
          MESSAGE text-018 TYPE 'I'.
          LOOP AT gt_data ASSIGNING <ls_data>.
            READ TABLE lt_locked INTO ls_locked WITH KEY guid = <ls_data>-guid.
            IF sy-subrc EQ 0.
              <ls_data>-check = ''.
            ENDIF.
          ENDLOOP.
        ENDIF.
      WHEN 'DESELECT'.
        LOOP AT gt_data ASSIGNING <ls_data>.
          <ls_data>-check = ''.
        ENDLOOP.
      WHEN 'TEST'.
        PERFORM update USING 'X'.
        PERFORM change_icon USING 'X'.
      WHEN 'UPDATE'.
        PERFORM update USING ''.
        PERFORM change_icon USING ''.
    ENDCASE.
    alv_table->refresh( ).
  ENDMETHOD.

*
ENDCLASS.                    "lcl_event_handler IMPLEMENTATION
*&---------------------------------------------------------------------*
*&  Include           YBCR0042R_CHARMUPDATE_SEL
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   03.06.2019 13:11:39
* CR/IN: 8000005813
*----------------------------------------------------------------------*
* Short description:
* ChaRM Mass update
*----------------------------------------------------------------------*
* Changes
* Index Name         Date           Short description
* TXT01 Tamas Tatar  2019.08.07     INC0365690 - YBC_BP_MASS_UPDATE - Authorization issue
*----------------------------------------------------------------------*
DATA:  lt_return            TYPE TABLE OF ddshretval WITH HEADER LINE,
       ls_return            LIKE LINE OF lt_return,
       lt_but000            TYPE TABLE OF but000,
       lt_agr_users         TYPE TABLE OF agr_users,
       lt_prog              TYPE TABLE OF ybcr0042t_prog.

* current business partner
PARAMETERS: pa_id1 LIKE but000-partner OBLIGATORY.
* new business partner
PARAMETERS: pa_id2 LIKE but000-partner OBLIGATORY.
* Program
SELECT-OPTIONS: s_prog FOR gs_selscreen-program .
* Stream
SELECT-OPTIONS: s_stream FOR gs_selscreen-stream.
* Module
SELECT-OPTIONS: s_module FOR gs_selscreen-module.
* Status
SELECT-OPTIONS: s_status FOR gs_selscreen-status MATCHCODE OBJECT ybce0012sh_status.
* Workflow role
PARAMETERS: pa_rol TYPE comt_partner_fct MATCHCODE OBJECT ybcr0042h_role.

INITIALIZATION.
* <-- Begin of  TXT01-
** only administrators can use it
*  SELECT *
*  INTO TABLE lt_agr_users
*  FROM agr_users
*  WHERE uname = sy-uname
*    AND agr_name = 'ZSAP_CM_SMAN_ADMINISTRATOR'.
*
*  IF sy-subrc NE 0.
*    CALL FUNCTION 'POPUP_TO_INFORM'
*      EXPORTING
*        titel = 'No Authorization'
*        txt1  = text-014
*        txt2  = ''
*        txt3  = ''
*        txt4  = ''.
*    LEAVE PROGRAM.
*  ENDIF.
* <-- End of  TXT01-
  SELECT ykey yprogram
  INTO CORRESPONDING FIELDS OF TABLE lt_prog
  FROM ybcr0042t_prog.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_prog-low.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'YPROGRAM'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'S_PROG'
      value_org   = 'S'
    TABLES
      value_tab   = lt_prog.

AT SELECTION-SCREEN.
* check for business partners

  SELECT *
  INTO TABLE lt_but000
  FROM but000
  WHERE but000~partner EQ pa_id1.

  IF sy-subrc NE 0.
    MESSAGE text-013 TYPE 'E'.
  ENDIF.

  SELECT *
  INTO TABLE lt_but000
  FROM but000
  WHERE but000~partner EQ pa_id2.

  IF sy-subrc NE 0.
    MESSAGE text-013 TYPE 'E'.
  ENDIF.

  IF pa_id1 EQ pa_id2.
    MESSAGE text-016 TYPE 'E'.
  ENDIF.

START-OF-SELECTION.

  PERFORM prepare_data.
  PERFORM display_alv.
  *&---------------------------------------------------------------------*
*&  Include           YBCR0042R_CHARMUPDATE_F01
*----------------------------------------------------------------------*
* Author: Tamas Tatar
* Date:   03.06.2019 13:11:39
* CR/IN: 8000005813
*----------------------------------------------------------------------*
* Short description:
* ChaRM Mass update
*----------------------------------------------------------------------*
* Changes
* Index Name         Date     Short description
*----------------------------------------------------------------------*
FORM display_alv.

  "alv table
  DATA:
      ref_func      TYPE REF TO cl_salv_functions,
      lv_columns    TYPE REF TO cl_salv_columns,
      lr_columns    TYPE REF TO cl_salv_columns_table,
      lr_column     TYPE REF TO cl_salv_column_table,
      lr_functions  TYPE REF TO cl_salv_functions_list,
      lx_msg        TYPE REF TO cx_salv_msg,
      ir_column     TYPE REF TO cl_salv_column,
      ir_column2    TYPE REF TO cl_salv_column,
      ir_column3    TYPE REF TO cl_salv_column.

  DATA: lo_events        TYPE REF TO cl_salv_events_table.
  DATA: lo_event_handler TYPE REF TO lcl_event_handler.
  DATA: lr_selections    TYPE REF TO cl_salv_selections.
  TRY.
      cl_salv_table=>factory(
           IMPORTING
             r_salv_table = alv_table
           CHANGING
             t_table      = gt_data ).
    CATCH cx_salv_msg INTO lx_msg.
  ENDTRY.

  lr_functions = alv_table->get_functions( ).
  lr_functions->set_default( abap_true ).
  " set column texts and hide certain columns
  TRY.

      lr_columns = alv_table->get_columns( ).
      ir_column ?= lr_columns->get_column( 'GUID' ).
      ir_column->set_visible( value  = if_salv_c_bool_sap=>false ).

      lr_columns = alv_table->get_columns( ).
      ir_column2 ?= lr_columns->get_column( 'ICON' ).
      ir_column2->set_visible( value  = if_salv_c_bool_sap=>false ).

      lr_columns = alv_table->get_columns( ).
      ir_column3 ?= lr_columns->get_column( 'PARTNER_FCT' ).
      ir_column3->set_visible( value  = if_salv_c_bool_sap=>false ).

      alv_table->get_columns( )->get_column( 'OBJECT_ID' )->set_short_text( text-001 ).
      alv_table->get_columns( )->get_column( 'OBJECT_ID' )->set_medium_text( text-001 ).
      alv_table->get_columns( )->get_column( 'OBJECT_ID' )->set_long_text( text-001 ).

      alv_table->get_columns( )->get_column( 'PROGRAM' )->set_short_text( text-002 ).
      alv_table->get_columns( )->get_column( 'PROGRAM' )->set_medium_text( text-002 ).
      alv_table->get_columns( )->get_column( 'PROGRAM' )->set_long_text( text-002 ).

      alv_table->get_columns( )->get_column( 'STREAM' )->set_short_text( text-003 ).
      alv_table->get_columns( )->get_column( 'STREAM' )->set_medium_text( text-003 ).
      alv_table->get_columns( )->get_column( 'STREAM' )->set_long_text( text-003 ).

      alv_table->get_columns( )->get_column( 'MODULE' )->set_short_text( text-004 ).
      alv_table->get_columns( )->get_column( 'MODULE' )->set_medium_text( text-004 ).
      alv_table->get_columns( )->get_column( 'MODULE' )->set_long_text( text-004 ).

      alv_table->get_columns( )->get_column( 'DESCRIPTION' )->set_short_text( text-012 ).
      alv_table->get_columns( )->get_column( 'DESCRIPTION' )->set_medium_text( text-005 ).
      alv_table->get_columns( )->get_column( 'DESCRIPTION' )->set_long_text( text-005 ).

      alv_table->get_columns( )->get_column( 'STATUS' )->set_short_text( text-011 ).
      alv_table->get_columns( )->get_column( 'STATUS' )->set_medium_text( text-011 ).
      alv_table->get_columns( )->get_column( 'STATUS' )->set_long_text( text-011 ).

      alv_table->get_columns( )->get_column( 'NAME_LAN' )->set_short_text( text-010 ).
      alv_table->get_columns( )->get_column( 'NAME_LAN' )->set_medium_text( text-007 ).
      alv_table->get_columns( )->get_column( 'NAME_LAN' )->set_long_text( text-007 ).

      alv_table->get_columns( )->get_column( 'PARTNER' )->set_short_text( text-009 ).
      alv_table->get_columns( )->get_column( 'PARTNER' )->set_medium_text( text-008 ).
      alv_table->get_columns( )->get_column( 'PARTNER' )->set_long_text( text-008 ).

      alv_table->get_columns( )->get_column( 'ROLE' )->set_short_text( text-006 ).
      alv_table->get_columns( )->get_column( 'ROLE' )->set_medium_text( text-006 ).
      alv_table->get_columns( )->get_column( 'ROLE' )->set_long_text( text-006 ).

      alv_table->get_columns( )->get_column( 'CHECK' )->set_short_text( text-020 ).
      alv_table->get_columns( )->get_column( 'CHECK' )->set_medium_text( text-020 ).
      alv_table->get_columns( )->get_column( 'CHECK' )->set_long_text( text-020 ).

      alv_table->get_columns( )->get_column( 'ICON' )->set_short_text( text-021 ).
      alv_table->get_columns( )->get_column( 'ICON' )->set_medium_text( text-022 ).
      alv_table->get_columns( )->get_column( 'ICON' )->set_long_text( text-022 ).

      lr_columns = alv_table->get_columns( ).
      lr_columns->set_optimize( abap_true ).
      lr_column ?= lr_columns->get_column( 'CHECK' ).
      lr_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).

      alv_table->set_screen_status(
                          pfstatus = 'SALV_STATUS'
                          report = sy-repid
                          set_functions = alv_table->c_functions_all ).
* Set up selections.
      lr_selections = alv_table->get_selections( ).
      lr_selections->set_selection_mode( 1 ). "Single


*   Get the event object

      lo_events = alv_table->get_event( ).
*
*   Instantiate the event handler object

      CREATE OBJECT lo_event_handler.
*
*   event handler
      SET HANDLER lo_event_handler->on_link_click FOR lo_events.
      SET HANDLER lo_event_handler->on_user_command FOR lo_events.

    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      alv_table->display( ).
    CATCH cx_salv_not_found.
  ENDTRY.



ENDFORM.

FORM prepare_data.

  FIELD-SYMBOLS: <ls_partner> TYPE crmt_partner_external_wrk.
  DATA: lt_partner_f          TYPE crmt_partner_external_wrkt,
        ls_partner_f          TYPE crmt_partner_external_wrk,
        lv_partner_filter     LIKE but000-partner,
        lt_partner_ft         TYPE TABLE OF crmc_partner_ft,
        ls_parnter_ft         LIKE LINE OF lt_partner_ft,
        lt_header             TYPE crmt_object_guid_tab,
        ls_header             LIKE LINE OF lt_header,
        lv_personid           TYPE  personid,
        lv_guid               TYPE  bu_partner_guid,
        lv_username           TYPE  syuname,
        lv_employee           TYPE  bpemployeet,
        lv_name               TYPE  emnam,
        lt_users              TYPE  swdtuser,
        lt_stat2type          TYPE  bpemployee_stat2_t.

  gv_complete = ''.

  SELECT crmd_orderadm_h~guid
    INTO TABLE lt_header
    FROM crmd_orderadm_h
    JOIN crmd_order_index ON crmd_order_index~header = crmd_orderadm_h~guid
    JOIN  but000 ON crmd_order_index~partner_no = but000~partner
    WHERE but000~partner EQ pa_id1
    AND process_type EQ gc_process_type.

  PERFORM fill_role_range.

  SELECT partner_fct description
   INTO CORRESPONDING FIELDS OF TABLE lt_partner_ft
   FROM crmc_partner_ft
    WHERE spras = 'E'
      AND partner_fct IN grng_partner.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE  gt_but000
  FROM but000
  WHERE but000~partner EQ pa_id1.

  LOOP AT gt_but000 ASSIGNING <gs_but000>.

    CALL FUNCTION 'BP_CENTRALPERSON_GET'
      EXPORTING
        iv_bu_partner_guid   = <gs_but000>-partner_guid
      IMPORTING
        ev_person_id         = lv_personid
        ev_bu_partner_guid   = lv_guid
        ev_username          = lv_username
        et_employee_id       = lv_employee
        ev_name              = lv_name
        et_users             = lt_users
        et_employee_id_stat2 = lt_stat2type.
    CONCATENATE <gs_but000>-name_first <gs_but000>-name_last '(' lv_username ')' INTO gv_name_lan SEPARATED BY space.
  ENDLOOP.

  CALL FUNCTION 'CRM_ORDER_READ'
    EXPORTING
      it_header_guid       = lt_header
      it_requested_objects = gt_req_obj
      iv_no_auth_check     = 'X'
    IMPORTING
      et_orderadm_h        = gt_orderadm_h
      et_text              = gt_text
      et_partner           = gt_partner
      et_subject           = gt_subject
      et_status            = gt_status
      et_doc_flow          = gt_doc_flow
      et_approval          = gt_approval
    CHANGING
      cv_log_handle        = gv_log_handle
    EXCEPTIONS
      document_not_found   = 1
      error_occurred       = 2
      document_locked      = 3
      no_change_authority  = 4
      no_display_authority = 5
      no_change_allowed    = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = pa_id1
    IMPORTING
      output = lv_partner_filter.

  LOOP AT gt_partner ASSIGNING <ls_partner> WHERE partner_no  EQ lv_partner_filter.
    APPEND <ls_partner> TO lt_partner_f.
  ENDLOOP.

  LOOP AT lt_partner_f INTO ls_partner_f.
    READ TABLE lt_header INTO ls_header WITH KEY table_line = ls_partner_f-ref_guid.
    IF sy-subrc EQ 0.
      gs_header-guid = ls_partner_f-ref_guid.
      gs_header-partner_fct = ls_partner_f-ref_partner_fct.
      APPEND gs_header TO gt_header.
    ENDIF.
  ENDLOOP.

  IF pa_rol IS NOT INITIAL.
    DELETE gt_header WHERE partner_fct NE pa_rol.
  ELSE.
    DELETE gt_header WHERE partner_fct NOT IN grng_partner.
  ENDIF.

  LOOP AT gt_header INTO gs_header.
    REFRESH: gt_category.
    CLEAR gs_output.
    PERFORM read_category USING gs_header-guid
      CHANGING gt_category.

    LOOP AT gt_category INTO gs_category.
      CASE sy-tabix.
        WHEN 1.
* Program
          MOVE gs_category-cat_descr TO gs_output-program.
        WHEN 2.
* Stream
          MOVE gs_category-cat_descr TO gs_output-stream.
        WHEN 3.
* Module
          MOVE gs_category-cat_descr TO gs_output-module.
      ENDCASE.
    ENDLOOP.
    READ TABLE gt_orderadm_h INTO gs_orderham WITH KEY guid = gs_header-guid.
    gs_output-object_id = gs_orderham-object_id.
    gs_output-description = gs_orderham-description.
*Status
    LOOP AT gt_status INTO gs_status
        WHERE guid EQ gs_orderham-guid
        AND status IN s_status
        AND user_stat_proc EQ gc_status_profil
        AND active EQ 'X'.
      gs_output-status = gs_status-txt30.
    ENDLOOP.
*new bp to output
    gs_output-partner = pa_id2.
    gs_output-name_lan = gv_name_lan.
    gs_output-guid = gs_header-guid.
    LOOP AT lt_partner_f INTO ls_partner_f
          WHERE ref_guid EQ gs_header-guid
            AND ref_partner_fct EQ gs_header-partner_fct.

      READ TABLE lt_partner_ft INTO ls_parnter_ft WITH KEY partner_fct = ls_partner_f-ref_partner_fct.
      gs_output-role = ls_parnter_ft-description.
      gs_output-partner_fct = ls_parnter_ft-partner_fct.

    ENDLOOP.
    IF gs_output-status IS NOT INITIAL.
      APPEND gs_output TO gt_data.
    ENDIF.
  ENDLOOP.
* delete rows based on criteria
  IF s_prog IS NOT INITIAL.
    DELETE gt_data WHERE program NOT IN s_prog.
  ENDIF.
  IF s_stream IS NOT INITIAL.
    DELETE gt_data WHERE stream NOT IN s_stream.
  ENDIF.
  IF s_module IS NOT INITIAL.
    DELETE gt_data WHERE module NOT IN s_module.
  ENDIF.

  SORT gt_data BY status.
  CLEAR gt_partner.
  MOVE lt_partner_f TO gt_partner.

ENDFORM.
FORM read_category USING iv_guid TYPE crmt_object_guid
      CHANGING ct_category TYPE tty_category.

  DATA:
      lr_aspect    TYPE REF TO if_crm_erms_catego_aspect,
      lr_category  TYPE REF TO if_crm_erms_catego_category,
      lv_ref_guid  TYPE crmt_object_guid,
      lv_asp_guid  TYPE crm_erms_cat_guid,
      lv_cat_guid  TYPE crm_erms_cat_guid,
      lv_sel_level TYPE int4,
      ls_cat       TYPE crmt_erms_cat_ca_buf,
      et_cat_tree  TYPE bsp_wd_dropdown_table,
      ls_cat_tree  TYPE bsp_wd_dropdown_line,
      lv_cat_id    TYPE crm_erms_cat_ca_id,
      lt_category  TYPE tty_category,
      ls_category  TYPE ty_category.

  lv_ref_guid = iv_guid.

  CALL METHOD cl_crm_ml_category_util=>get_categoryfirst
    EXPORTING
      iv_ref_guid     = lv_ref_guid
      iv_ref_kind     = 'A'
      iv_catalog_type = 'D'
    IMPORTING
      er_aspect       = lr_aspect
      er_category     = lr_category.

  IF lr_aspect IS NOT BOUND.
    CALL METHOD cl_crm_ml_category_util=>get_categoryfirst
      EXPORTING
        iv_ref_guid     = lv_ref_guid
        iv_ref_kind     = 'A'
        iv_catalog_type = 'C'
      IMPORTING
        er_aspect       = lr_aspect
        er_category     = lr_category.
  ENDIF.

  IF lr_aspect IS BOUND.
    CALL METHOD lr_aspect->get_asp_guid
      RECEIVING
        rv_asp_guid = lv_asp_guid.
  ENDIF.

  IF lr_category IS BOUND.
    CALL METHOD lr_category->get_details
      IMPORTING
        ev_cat = ls_cat.
  ENDIF.
  lv_cat_guid = ls_cat-cat_guid.

  cl_crm_ml_category_util=>get_selected_category_tree(
  EXPORTING
  iv_selected_cat_guid = lv_cat_guid
  iv_schema_guid       = lv_asp_guid
  IMPORTING
  et_cat_tree          = et_cat_tree
  ev_selected_level    = lv_sel_level  ).

  CLEAR: lv_cat_guid.
  IF et_cat_tree IS NOT INITIAL.
    LOOP AT et_cat_tree INTO ls_cat_tree WHERE key IS NOT INITIAL.
      IF ls_cat_tree IS NOT INITIAL.
        ls_category-cat_guid = ls_cat_tree-key.
        ls_category-cat_descr = ls_cat_tree-value.
        SELECT SINGLE cat_id INTO lv_cat_id FROM crmc_erms_cat_ca WHERE cat_guid = ls_category-cat_guid.
        ls_category-cat_id = lv_cat_id.
        APPEND ls_category TO lt_category.
        ct_category = lt_category.
        CLEAR:ls_cat_tree,ls_category,lv_cat_id.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " READ_CATEGORY
FORM update USING iv_test TYPE flag.

  DATA: ls_partner_com                 TYPE crmt_partner_com,
        lt_partner_attributes          TYPE crmt_partner_attribute_com_tab,
        ls_partner_attribute           TYPE crmt_partner_attribute_com,
        ls_partner_key                 TYPE crmt_partner_logic_partner_key,
        ls_previous_partner_key        TYPE crmt_partner_logic_partner_key,
        lt_current_partner_attributes  TYPE crmt_partner_attribute_com_tab,
        lv_created_partnerset_guid     TYPE crmt_object_guid,
        ls_logical_key                 TYPE crmt_logical_key,
        ls_logic_partner_key           TYPE crmt_partner_logic_partner_key,
        lt_returned_partner_attributes TYPE crmt_partner_attribute_com_tab,
        ls_partner_control             TYPE crmt_partner_control,
        lv_message                     TYPE text255,
        lt_partner_com                 TYPE crmt_partner_comt,
        lt_guid_single                 TYPE crmt_object_guid_tab,
        lv_check_partner_only          TYPE sx_boolean,
        lv_next_partner_index          TYPE i,
        lv_current_partner             TYPE i VALUE 1,
        ls_next_partner_com            TYPE crmt_partner_com,
        ls_com_structure               TYPE string,
        lv_object_guid                 TYPE crmt_object_guid,
        lt_msgidno                     TYPE bal_r_idno,
        ls_msgidno                     TYPE bal_s_idno,
        lt_logical_keys                TYPE comt_partner_logic_key_tab,
        lv_ref_handle                  TYPE numc10,
        lt_input_fields                TYPE crmt_input_field_names_tab,
        ls_input_fields                TYPE crmt_input_field_names,
        lt_partner_f                   TYPE crmt_partner_external_wrkt,
        ls_partner_f                   TYPE crmt_partner_external_wrk,
        lt_header                      TYPE crmt_object_guid_tab,
        ls_orderadm_h                  TYPE crmt_orderadm_h_com,
        lt_orderadm_h                  TYPE crmt_orderadm_h_comt,
        ct_input_fields                TYPE crmt_input_field_tab,
        wa_input_fields                TYPE crmt_input_field,
        lt_but000                      TYPE TABLE OF but000,
        lv_name_first(20)              TYPE c,
        lv_name_last(20)               TYPE c.

  IF gv_complete = ''.

    LOOP AT gt_partner INTO ls_partner_f.
      LOOP AT gt_data ASSIGNING <gs_output> WHERE check = 'X'
                                              AND guid = ls_partner_f-ref_guid.
        REFRESH lt_input_fields.
        CLEAR ls_partner_com.

        ls_partner_com-ref_guid                 = <gs_output>-guid.
        ls_partner_com-ref_kind                 = ls_partner_f-ref_kind.
        ls_partner_com-ref_partner_handle       = ls_partner_f-ref_partner_handle.
        ls_partner_com-kind_of_entry            = 'C'.
        ls_partner_com-partner_fct              = <gs_output>-partner_fct.
        ls_partner_com-partner_no               = pa_id2.
        ls_partner_com-display_type             = 'BP'.
        ls_partner_com-no_type                  = 'BP'.
        ls_partner_com-ref_partner_no           = ls_partner_f-ref_partner_no.
        ls_partner_com-ref_partner_fct          = <gs_output>-partner_fct.
        ls_partner_com-ref_no_type              = ls_partner_f-ref_no_type.
        ls_partner_com-ref_display_type         = ls_partner_f-ref_display_type.
        ls_partner_com-mainpartner              = ls_partner_f-mainpartner.

        ls_input_fields-fieldname = 'REF_GUID'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'REF_KIND'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'REF_PARTNER_HANDLE'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'DISPLAY_TYPE'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'KIND_OF_ENTRY'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'PARTNER_FCT'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'NO_TYPE'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'PARTNER_NO'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'REF_PARTNER_NO'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'REF_PARTNER_FCT'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'REF_NO_TYPE'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'REF_DISPLAY_TYPE'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.
        ls_input_fields-fieldname = 'MAINPARTNER'.
        INSERT ls_input_fields INTO TABLE lt_input_fields.

        CALL FUNCTION 'CRM_PARTNER_MAINTAIN_SINGLE_OW'
          EXPORTING
            is_partner_com       = ls_partner_com
          CHANGING
            ct_input_field_names = lt_input_fields
          EXCEPTIONS
            error_occurred       = 1
            OTHERS               = 2.

        CLEAR ls_input_fields.
        CLEAR lt_input_fields.

        IF <gs_output>-role = 'Process Lead'.
          ls_orderadm_h-guid = <gs_output>-guid.
          ls_orderadm_h-mode  = 'B'.
          ls_input_fields-fieldname = 'ZZ_GBPL'.
          INSERT ls_input_fields INTO TABLE lt_input_fields.
        ENDIF.
        IF <gs_output>-role = 'Team Lead'.
          ls_orderadm_h-guid = <gs_output>-guid.
          ls_orderadm_h-mode  = 'B'.
          ls_input_fields-fieldname = 'ZZ_TL'.
          INSERT ls_input_fields INTO TABLE lt_input_fields.
        ENDIF.

        IF ls_orderadm_h IS NOT INITIAL.

          SELECT SINGLE name_first name_last
          INTO (lv_name_first, lv_name_last)
          FROM but000
          WHERE but000~partner EQ pa_id2.

          CONCATENATE lv_name_first lv_name_last INTO ls_orderadm_h-zz_gbpl SEPARATED BY space.
          CONCATENATE lv_name_first lv_name_last INTO ls_orderadm_h-zz_tl SEPARATED BY space.

          INSERT ls_orderadm_h INTO TABLE lt_orderadm_h.
          wa_input_fields-field_names[] = lt_input_fields[].

          wa_input_fields-ref_guid    = <gs_output>-guid.
          wa_input_fields-ref_kind    = gc_object_kind-orderadm_h.
          wa_input_fields-objectname  = gc_object_name-orderadm_h.
          wa_input_fields-field_names = lt_input_fields.
          INSERT wa_input_fields INTO TABLE ct_input_fields.


          CALL FUNCTION 'CRM_ORDER_MAINTAIN'
            CHANGING
              ct_orderadm_h     = lt_orderadm_h
              ct_input_fields   = ct_input_fields
            EXCEPTIONS
              error_occurred    = 1
              document_locked   = 2
              no_change_allowed = 3
              no_authority      = 4
              OTHERS            = 5.
        ENDIF.

        IF sy-subrc EQ 0 AND  iv_test = 'X'.
          <gs_output>-icon =  icon_green_light.
        ELSEIF sy-subrc <> 0 AND  iv_test = 'X'.
          <gs_output>-icon =  icon_red_light.
        ENDIF.

        IF iv_test = ''.

          INSERT <gs_output>-guid INTO TABLE lt_guid_single.

          CALL FUNCTION 'CRM_ORDER_ENQUEUE'
            EXPORTING
              iv_guid = <gs_output>-guid.

          CALL FUNCTION 'CRM_ORDER_SAVE'
            EXPORTING
              it_objects_to_save = lt_guid_single.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

          SELECT crmd_orderadm_h~guid
          INTO TABLE lt_header
          FROM crmd_orderadm_h
          JOIN crmd_order_index ON crmd_order_index~header = crmd_orderadm_h~guid
          JOIN  but000 ON crmd_order_index~partner_no = but000~partner
          WHERE but000~partner EQ pa_id2
          AND process_type EQ gc_process_type
          AND crmd_orderadm_h~guid EQ <gs_output>-guid.

          IF sy-subrc EQ 0.
            <gs_output>-icon =  icon_green_light.
          ELSE.
            <gs_output>-icon =  icon_red_light.
          ENDIF.

          CALL FUNCTION 'CRM_ORDER_DEQUEUE'
            EXPORTING
              iv_guid = <gs_output>-guid.

          CLEAR lt_guid_single.
        ENDIF.
      ENDLOOP.
    ENDLOOP.


    IF iv_test = ''.
      DELETE gt_data WHERE icon = ''.
      PERFORM log_changes.
      gv_complete = 'X'.
    ENDIF.
  ELSE.
    MESSAGE text-019 TYPE 'E'.
  ENDIF.


ENDFORM.
FORM change_icon USING iv_test TYPE flag.
  DATA:
    ref_func      TYPE REF TO cl_salv_functions,
    lv_columns    TYPE REF TO cl_salv_columns,
    lr_columns    TYPE REF TO cl_salv_columns_table,
    lr_column     TYPE REF TO cl_salv_column_table,
    lr_functions  TYPE REF TO cl_salv_functions_list,
    lx_msg        TYPE REF TO cx_salv_msg,
    ir_column     TYPE REF TO cl_salv_column,
    ir_column2    TYPE REF TO cl_salv_column,
    ls_partner_f  TYPE crmt_partner_external_wrk.

  TRY.

      lr_columns = alv_table->get_columns( ).

      IF iv_test = ''.

        ir_column ?= lr_columns->get_column( 'CHECK' ).
        ir_column->set_visible( value  = if_salv_c_bool_sap=>false ).
      ELSE.
        LOOP AT gt_partner INTO ls_partner_f.
          LOOP AT gt_data ASSIGNING <gs_output> WHERE check = 'X'
                                                  AND guid = ls_partner_f-ref_guid.
            CALL FUNCTION 'CRM_ORDER_DEQUEUE'
              EXPORTING
                iv_guid = <gs_output>-guid.

          ENDLOOP.
        ENDLOOP.
      ENDIF.

      lr_columns = alv_table->get_columns( ).
      ir_column2 ?= lr_columns->get_column( 'ICON' ).
      ir_column2->set_visible( value  = if_salv_c_bool_sap=>true ).

    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.

FORM fill_role_range.
  gsrng_partner-sign = 'I'.
  gsrng_partner-option = 'EQ'.
  gsrng_partner-low = 'SDCR0002'.
  APPEND gsrng_partner TO grng_partner.
  gsrng_partner-low = '00000001'.
  APPEND gsrng_partner TO grng_partner.
  gsrng_partner-low = 'ZTL'.
  APPEND gsrng_partner TO grng_partner.
  gsrng_partner-low = 'ZCHG_MAN'.
  APPEND gsrng_partner TO grng_partner.
  gsrng_partner-low = 'SMCD0003'.
  APPEND gsrng_partner TO grng_partner.

ENDFORM.
FORM log_changes.
  DATA: lv_date(20)  TYPE  c,
        lv_year(6)   TYPE  c,
        lv_month(6)  TYPE  c,
        lv_day(6)    TYPE  c,
        lv_hour(10)  TYPE  c,
        lv_min(10)   TYPE  c,
        lv_sec(10)   TYPE  c,
        lv_personid  TYPE  personid,
        lv_guid      TYPE  bu_partner_guid,
        lv_username  TYPE  syuname,
        lv_employee  TYPE  bpemployeet,
        lv_name      TYPE  emnam,
        lt_users     TYPE  swdtuser,
        lt_stat2type TYPE  bpemployee_stat2_t.

  CLEAR gt_but000.

  SELECT *
   INTO CORRESPONDING FIELDS OF TABLE  gt_but000
   FROM but000
   WHERE but000~partner EQ pa_id2.

  LOOP AT gt_but000 ASSIGNING <gs_but000>.

    CALL FUNCTION 'BP_CENTRALPERSON_GET'
      EXPORTING
        iv_bu_partner_guid   = <gs_but000>-partner_guid
      IMPORTING
        ev_person_id         = lv_personid
        ev_bu_partner_guid   = lv_guid
        ev_username          = lv_username
        et_employee_id       = lv_employee
        ev_name              = lv_name
        et_users             = lt_users
        et_employee_id_stat2 = lt_stat2type.
    CONCATENATE <gs_but000>-name_first <gs_but000>-name_last '(' lv_username ')' INTO gv_name_lan_2 SEPARATED BY space.
  ENDLOOP.

  LOOP AT gt_data  ASSIGNING <gs_output> WHERE check = 'X' AND  icon = icon_green_light.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'YBCR0042'
      IMPORTING
        number      = gv_seq_log.

    lv_year = sy-datum(4).
    lv_month = sy-datum+4(2).
    lv_day = sy-datum+6(2).

    CONCATENATE lv_year '.' lv_month '.' lv_day '.' INTO lv_date.

    lv_hour = sy-uzeit(2).
    lv_min = sy-uzeit+2(2).
    lv_sec = sy-uzeit+4(2).

    CONCATENATE lv_date ' ' lv_hour ':' lv_min ':' lv_sec INTO lv_date.

    gs_log-sequence = gv_seq_log.
    gs_log-timestamp = lv_date.
    gs_log-cr = <gs_output>-object_id.
    gs_log-status = <gs_output>-status.
    gs_log-name_from = <gs_output>-name_lan.
    gs_log-bp_from = pa_id1.
    gs_log-name_to = gv_name_lan_2.
    gs_log-bp_to = pa_id2.
    APPEND gs_log TO gt_log.
    CLEAR gv_seq_log.
    CLEAR gs_log.
    CLEAR lv_date.
  ENDLOOP.

  INSERT ybcr0042t_log FROM TABLE gt_log.

ENDFORM.
FORM check_if_object_locked TABLES p_lt TYPE tty_data.

  FIELD-SYMBOLS: <ls_data> LIKE LINE OF gt_data.

  DATA:lt_seqg3 TYPE TABLE OF seqg3,
       lv_tabix TYPE sy-tabix,
       lv_subrc TYPE sy-subrc,
       lv_garg  LIKE seqg3-garg.

  LOOP AT gt_data ASSIGNING <ls_data> WHERE check = 'X'.
    lv_garg = <ls_data>-guid.
    CONCATENATE sy-mandt lv_garg INTO lv_garg.

    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gclient               = sy-mandt
        gname                 = 'CRMD_ORDERADM_H'
        garg                  = lv_garg
        guname                = ' '
        local                 = ' '
        fast                  = ' '
        gargnowc              = ' '
      IMPORTING
        number                = lv_tabix
        subrc                 = lv_subrc
      TABLES
        enq                   = lt_seqg3
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.
    IF lt_seqg3 IS NOT INITIAL.
      APPEND <ls_data> TO p_lt.
    ENDIF.

    CLEAR lt_seqg3.

  ENDLOOP.
ENDFORM.
