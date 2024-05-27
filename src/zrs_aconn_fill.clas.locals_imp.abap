class lcl_copy_data definition.

  public section.
    constants:
        yes         type abap_bool value abap_true
    ,   no          type abap_bool value abap_false
    ,   template_table type tabname value 'ZRS_ACONN'
    ,   source_table     type  tabname value '/DMO/CONNECTION'
    . data:
        dbCnt like sy-dbcnt
    .methods:
        constructor
            importing i_target_table TYPE tabname
            raising       cx_abap_not_a_table
    , copy_data
    .
* -------------------------------------------------
  protected section.
* -------------------------------------------------
  private section.
    data:
        connections     type standard table of ZRS_ACONN
            with non-unique default key
    ,   table_name      type tabname
    ,   user                   type abp_creation_user value  'GENERATOR'
    ,   timestamp       type abp_creation_tstmpl
    .
    methods:
        prepare_data
    ,   delete_db
    ,   insert_db
    ,   is_empty_db
            returning value(result) like no
    ,   matches_template
            returning value(result) like yes
    .
endclass.
class lcl_copy_data implementation.
**********************************************************************
  method constructor.
* Store table name
    me->table_name = i_target_table.

    if me->matches_template( ) = no.
        raise exception type cx_abap_not_a_table.
        endif.
  endmethod.
**********************************************************************
  method copy_data.
    prepare_data( ).

* Check if DB is empty
    if me->is_empty_db( ) = no.
        me->delete_db( ).
        endif.

    me->insert_db( ).

endmethod.
**********************************************************************
  method is_empty_db.

    select count( * ) from (table_name)
*        fields @yes   "all fields
        into @dbCnt.

    result = xsdbool( dbCnt = 0 ).
*    if dbCnt = 0.
*        result = yes.
*    else.
*        result = no.
*        endif.
endmethod..
**********************************************************************
method delete_db.
    delete from (table_name).
    if sy-subrc is initial.
        dbCnt = 0.
        endif.
endmethod.
**********************************************************************
method insert_db.
    insert (table_name) from table @connections.

    if sy-subrc is initial.
        dbCnt = sy-dbcnt.
        endif.
endmethod.
**********************************************************************
  METHOD prepare_data.
    data dmoConns type table of /DMO/CONNECTION.
* Fill with data from source
    select from (source_table) fields *
        into corresponding fields of table @dmoConns.

    get time stamp field me->timestamp.

    loop at dmoConns assigning field-symbol(<dmoCon>).
        append initial line to connections assigning field-symbol(<aCon>).

        move-corresponding <dmoCon> to <aCon>.
         <aCon>-uuid   =  CL_SYSTEM_UUID=>create_uuid_x16_static(  ).
       <aCon>-city_from = <dmoCon>-airport_from_id.
        <aCon>-city_to      = <dmoCon>-airport_to_id.

        <aCon>-local_created_by           = user.
        <aCon>-local_created_at            = timestamp.
        <aCon>-local_last_changed_by = user.
        <aCon>-local_last_changed_at  = timestamp.
        <aCon>-last_changed_at            = timestamp.
    endloop..
endmethod.
**********************************************************************
method matches_template.
    result = no.

    cl_abap_typedescr=>describe_by_name(
        exporting p_name     = table_name
        receiving  p_descr_ref = data(typedescr)
        exceptions type_not_found = 1   ).
    check sy-subrc is initial.

    check typedescr->kind = cl_abap_typedescr=>kind_struct
    and  typedescr->is_ddic_type( ) = yes.

    data(typComps) = cast cl_abap_structdescr( typedescr )->components.
    data(tmplTyp)      = cl_abap_typedescr=>describe_by_name( template_table ).
    data(tmplComps) = cast cl_abap_structdescr( tmplTyp )->components.
    check  typComps = tmplComps.

    result = yes.
endmethod.
**********************************************************************
endclass.
