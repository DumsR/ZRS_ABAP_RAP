class zrs_aconn_fill definition
  public
  final
  create public .

public section.
     interfaces if_oo_adt_classrun .
protected section.
private section.
endclass.
class zrs_aconn_fill implementation.
**********************************************************************
method if_oo_adt_classrun~main.
    constants table_name type tabname value 'ZRS_ACONN'.
    try.
        data(copier) = new lcl_copy_data( table_name ).
        copier->copy_data( ).
        out->write( |{ table_name } was filled with { copier->dbcnt } lines.| ).

    catch cx_abap_not_a_table.
        out->write( |{ table_name } is not a table of the right type.| ).
        endtry.
endmethod.
**********************************************************************
endclass.
