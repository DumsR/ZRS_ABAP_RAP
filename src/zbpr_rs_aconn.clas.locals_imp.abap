class lhc_zr_rs_aconn1 definition
    inheriting from cl_abap_behavior_handler.

private section.
    constants:
        on        type if_abap_behv=>t_xflag
                         value if_abap_behv=>mk-on "01
    ,   msg_err  type if_abap_behv_message=>t_severity
                         value if_abap_behv_message=>severity-error "E
    .methods:
        get_global_authorizations for global authorization
            importing
                request requested_authorizations for flightconn
                result result
    ,   checksemantickey for validate on save
            importing keys for flightconn~checksemantickey
    ,   grab_syMsg
            importing iv_severity like msg_err optional "default msg_err
            returning value(bhv_msg) type ref to if_abap_behv_message
    ,
        checkairportsdiff for validate on save
              importing keys for flightconn~checkairportsdiff.

            methods checkcarrier for validate on save
              importing keys for flightconn~checkcarrier.
endclass.
class lhc_zr_rs_aconn1 implementation.
**********************************************************************
method get_global_authorizations.
endmethod.
**********************************************************************
method grab_syMsg.
    if iv_severity is supplied and iv_severity is not initial.
        data(lv_severity) = iv_severity.
    else.
        lv_severity = conv #( sy-msgty ).
        endif.

    bhv_msg = new_message(
        id = sy-msgid
        number = sy-msgno
        severity = lv_severity
        v1 = sy-msgv1
        v2 = sy-msgv2
        v3 = sy-msgv3
        v4 = sy-msgv4  ).
endmethod.
**********************************************************************
method checksemantickey.
    data:
        read_keay type table for read import ZR_RS_ACONN1
    ,   connections type table for read result ZR_RS_ACONN1
    .
    read entities of ZR_RS_ACONN1 in local mode
        entity FlightConn
        fields ( uuid CarrierID connectionID )
        with corresponding #( keys )
        result connections.

    loop at connections into data(conn).
        select from zrs_aconn fields uuid
            where carrier_id        = @conn-CarrierID
                and connection_id = @conn-ConnectionID
                and uuid                 <> @conn-Uuid
        UNION
        select from zrs_aconn_d fields uuid
            where carrierID        = @conn-CarrierID
                and connectionID = @conn-ConnectionID
                and uuid                 <> @conn-Uuid
        into table @data(it_check_result).
        check it_check_result is not initial.

*      Flight number &1 &2 already exists
        message e001  into data(syMsg)
            with conn-CarrierId conn-ConnectionId.
        data(msg) = grab_syMsg(  ).

        append initial line to reported-flightconn
            assigning field-symbol(<reported>).
        <reported>-%tky = conn-%tky.
        <reported>-%msg = msg.
        <reported>-%element-carrierid         = on.
        <reported>-%element-connectionid = on.

        append initial line to failed-flightconn
            assigning field-symbol(<failed>).
        <failed>-%tky = conn-%tky.
    endloop.
endmethod.
**********************************************************************
method checkCarrier.
    data:
        read_keay type table for read import ZR_RS_ACONN1
    ,   connections type table for read result ZR_RS_ACONN1
    .
    read entities of ZR_RS_ACONN1 in local mode
        entity FlightConn
        fields ( CarrierID )
        with corresponding #( keys )
        result connections.

    loop at connections into data(conn).
        select count( * ) from /DMO/CARRIER
            where carrier_ID = @conn-CarrierId
            into @data(cnt).
        check cnt = 0.  "Carrier &1 don't exist

*      Airline &1 does not exist --------------------------
       message e002 into data(syMsg)
            with conn-CarrierId.
        data(msg) = grab_syMsg(  ).

        append initial line to reported-flightconn
            assigning field-symbol(<reported>).
        <reported>-%tky = conn-%tky.
        <reported>-%msg = msg.
        <reported>-%element-carrierid = on.

        append initial line to failed-flightconn
            assigning field-symbol(<failed>).
        <failed>-%tky = conn-%tky.
    endloop.
endmethod.
**********************************************************************
method checkAirportsDiff.
    data:
        read_keay type table for read import ZR_RS_ACONN1
    ,   connections type table for read result ZR_RS_ACONN1
    .
    read entities of ZR_RS_ACONN1 in local mode
        entity FlightConn
        fields ( CityFrom CityTo )
        with corresponding #( keys )
        result connections.

    loop at connections into data(conn).
        check conn-CityFrom = conn-CityTo.

*      Departure &1 and destination &2 airports must not be the same
        message e003 into data(syMsg)
            with conn-CityFrom conn-CityTo.
        data(msg) = grab_syMsg(  ).

        append initial line to reported-flightconn
            assigning field-symbol(<reported>).
        <reported>-%tky = conn-%tky.
        <reported>-%msg = msg.
        <reported>-%element-CityFrom = on.
        <reported>-%element-CityTo     = on.

        append initial line to failed-flightconn
            assigning field-symbol(<failed>).
        <failed>-%tky = conn-%tky.
    endloop.
endmethod.
**********************************************************************
endclass.
