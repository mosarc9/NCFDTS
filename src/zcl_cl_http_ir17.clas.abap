class ZCL_CL_HTTP_IR17 definition
  public
  create public .

public section.
  interfaces IF_HTTP_SERVICE_EXTENSION .

ENDCLASS.



CLASS ZCL_CL_HTTP_IR17 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA lv_html TYPE string.

    " ================================================================
    " 1. LEER PARAMETROS DEL URL
    " ================================================================
    DATA(lv_periodo)   = request->get_form_field( 'periodo' ).
    DATA(lv_tipo_decl) = request->get_form_field( 'tipo_declaracion' ).
    DATA(lv_s_premios) = request->get_form_field( 'premios' ).
    DATA(lv_s_tpre)    = request->get_form_field( 'tasa_premios' ).
    DATA(lv_s_retc)    = request->get_form_field( 'ret_compl' ).

    IF lv_tipo_decl IS INITIAL.
      lv_tipo_decl = 'NORMAL'.
    ENDIF.

    " Convertir strings a numeros
    DATA: lv_premios   TYPE p LENGTH 8 DECIMALS 2,
          lv_tasa_pre  TYPE p LENGTH 3 DECIMALS 2,
          lv_ret_compl TYPE p LENGTH 8 DECIMALS 2.

    TRY.
        lv_premios   = lv_s_premios.
        lv_tasa_pre  = lv_s_tpre.
        lv_ret_compl = lv_s_retc.
      CATCH cx_root.
    ENDTRY.

    " ================================================================
    " 2. SI NO HAY PERIODO: MOSTRAR FORMULARIO DE ENTRADA
    " ================================================================
    IF lv_periodo IS INITIAL.
      lv_html = |<html><head><meta charset="utf-8">| &&
        |<title>IR-17 - Generar</title>| &&
        |<style>| &&
        |body \{ font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; \}| &&
        |h2 \{ text-align: center; \}| &&
        |label \{ display: block; margin-top: 12px; font-weight: bold; \}| &&
        |input \{ width: 100%; padding: 6px; margin-top: 4px; box-sizing: border-box; \}| &&
        |button \{ margin-top: 20px; padding: 10px 30px; font-size: 14px; cursor: pointer; \}| &&
        |</style></head><body>| &&
        |<h2>Generar IR-17 DGII</h2>| &&
        |<form method="GET">| &&
        |<label>Periodo (MM-YYYY) *</label>| &&
        |<input name="periodo" placeholder="03-2026" required>| &&
        |<label>Tipo Declaracion</label>| &&
        |<input name="tipo_declaracion" value="NORMAL">| &&
        |<label>Premios (monto)</label>| &&
        |<input name="premios" value="0">| &&
        |<label>Tasa Premios (%)</label>| &&
        |<input name="tasa_premios" value="0">| &&
        |<label>Ret. Complementarias (monto)</label>| &&
        |<input name="ret_compl" value="0">| &&
        |<br><button type="submit">Generar IR-17</button>| &&
        |</form></body></html>|.

      response->set_header_field( i_name = 'Content-Type' i_value = 'text/html; charset=utf-8' ).
      response->set_text( lv_html ).
      RETURN.
    ENDIF.

    " ================================================================
    " 3. LEER DATOS DESDE URL PARAMS (enviados por ZCL_CE_IR17_QUERY)
    " No se necesita re-consultar SAP: el List Report ya calculo todo
    " y paso los valores como parametros en la URL del link PDF.
    " ================================================================
    DATA: lv_fecha_lim TYPE c LENGTH 10,
          lv_nombre    TYPE c LENGTH 50,
          lv_rnc       TYPE c LENGTH 11,
          lv_telefono  TYPE c LENGTH 20,
          lv_fax       TYPE c LENGTH 20.

    " fecha_lim llega como YYYYMMDD desde la URL; formatear a DD/MM/YYYY para display
    DATA lv_fecha_raw TYPE c LENGTH 8.
    lv_fecha_raw = request->get_form_field( 'fecha_lim' ).
    IF lv_fecha_raw IS NOT INITIAL.
      lv_fecha_lim = |{ lv_fecha_raw+6(2) }/{ lv_fecha_raw+4(2) }/{ lv_fecha_raw(4) }|.
    ENDIF.
    lv_nombre    = request->get_form_field( 'nombre' ).
    lv_rnc       = request->get_form_field( 'rnc' ).
    lv_telefono  = request->get_form_field( 'tel' ).
    lv_fax       = request->get_form_field( 'fax' ).

    DATA: lv_alq TYPE p LENGTH 8 DECIMALS 2,
          lv_hon TYPE p LENGTH 8 DECIMALS 2,
          lv_pre TYPE p LENGTH 8 DECIMALS 2,
          lv_tra TYPE p LENGTH 8 DECIMALS 2,
          lv_div TYPE p LENGTH 8 DECIMALS 2,
          lv_ine TYPE p LENGTH 8 DECIMALS 2,
          lv_rem TYPE p LENGTH 8 DECIMALS 2,
          lv_rpv TYPE p LENGTH 8 DECIMALS 2,
          lv_ot2 TYPE p LENGTH 8 DECIMALS 2,
          lv_o10 TYPE p LENGTH 8 DECIMALS 2.

    DATA: lv_t_alq TYPE p LENGTH 3 DECIMALS 2,
          lv_t_hon TYPE p LENGTH 3 DECIMALS 2,
          lv_t_pre TYPE p LENGTH 3 DECIMALS 2,
          lv_t_tra TYPE p LENGTH 3 DECIMALS 2,
          lv_t_div TYPE p LENGTH 3 DECIMALS 2,
          lv_t_ine TYPE p LENGTH 3 DECIMALS 2,
          lv_t_rem TYPE p LENGTH 3 DECIMALS 2,
          lv_t_rpv TYPE p LENGTH 3 DECIMALS 2,
          lv_t_ot2 TYPE p LENGTH 3 DECIMALS 2,
          lv_t_o10 TYPE p LENGTH 3 DECIMALS 2.

    TRY.
        lv_alq   = request->get_form_field( 'alq' ).   lv_t_alq = request->get_form_field( 'talq' ).
        lv_hon   = request->get_form_field( 'hon' ).   lv_t_hon = request->get_form_field( 'thon' ).
        lv_pre   = request->get_form_field( 'pre' ).   lv_t_pre = request->get_form_field( 'tpre' ).
        lv_tra   = request->get_form_field( 'tra' ).   lv_t_tra = request->get_form_field( 'ttra' ).
        lv_div   = request->get_form_field( 'div' ).   lv_t_div = request->get_form_field( 'tdiv' ).
        lv_ine   = request->get_form_field( 'ine' ).   lv_t_ine = request->get_form_field( 'tine' ).
        lv_rem   = request->get_form_field( 'rem' ).   lv_t_rem = request->get_form_field( 'trem' ).
        lv_rpv   = request->get_form_field( 'rpv' ).   lv_t_rpv = request->get_form_field( 'trpv' ).
        lv_ot2   = request->get_form_field( 'ot2' ).   lv_t_ot2 = request->get_form_field( 'tot2' ).
        lv_o10   = request->get_form_field( 'o10' ).   lv_t_o10 = request->get_form_field( 'to10' ).
      CATCH cx_root.
    ENDTRY.

    " FIX premios=0: chequear el STRING (lv_s_premios) no el packed (lv_premios).
    " lv_premios packed = 0 tanto si no se envio como si se envio el valor 0,
    " por lo que IS NOT INITIAL no diferencia los casos. El string si lo hace.
    IF lv_s_premios IS NOT INITIAL.
      lv_pre = lv_premios.
    ENDIF.
    IF lv_s_tpre IS NOT INITIAL.
      lv_t_pre = lv_tasa_pre.
    ENDIF.

    " ================================================================
    " 4. CALCULOS
    " ================================================================
    CONSTANTS gc_tasa_rc TYPE p LENGTH 3 DECIMALS 2 VALUE '27.00'.

    DATA: lv_i_alq TYPE p LENGTH 8 DECIMALS 2,
          lv_i_hon TYPE p LENGTH 8 DECIMALS 2,
          lv_i_pre TYPE p LENGTH 8 DECIMALS 2,
          lv_i_tra TYPE p LENGTH 8 DECIMALS 2,
          lv_i_div TYPE p LENGTH 8 DECIMALS 2,
          lv_i_ine TYPE p LENGTH 8 DECIMALS 2,
          lv_i_rem TYPE p LENGTH 8 DECIMALS 2,
          lv_i_rpv TYPE p LENGTH 8 DECIMALS 2,
          lv_i_ot2 TYPE p LENGTH 8 DECIMALS 2,
          lv_i_o10 TYPE p LENGTH 8 DECIMALS 2.

    lv_i_alq = lv_alq * lv_t_alq / 100.
    lv_i_hon = lv_hon * lv_t_hon / 100.
    lv_i_pre = lv_pre * lv_t_pre / 100.
    lv_i_tra = lv_tra * lv_t_tra / 100.
    lv_i_div = lv_div * lv_t_div / 100.
    lv_i_ine = lv_ine * lv_t_ine / 100.
    lv_i_rem = lv_rem * lv_t_rem / 100.
    lv_i_rpv = lv_rpv * lv_t_rpv / 100.
    lv_i_ot2 = lv_ot2 * lv_t_ot2 / 100.
    lv_i_o10 = lv_o10 * lv_t_o10 / 100.

    DATA lv_m21 TYPE p LENGTH 8 DECIMALS 2.
    DATA lv_i21 TYPE p LENGTH 8 DECIMALS 2.
    lv_m21 = lv_alq + lv_hon + lv_pre + lv_tra
           + lv_div + lv_ine + lv_rem + lv_rpv + lv_ot2.
    lv_i21 = lv_i_alq + lv_i_hon + lv_i_pre + lv_i_tra
           + lv_i_div + lv_i_ine + lv_i_rem + lv_i_rpv + lv_i_ot2.

    DATA lv_i22 TYPE p LENGTH 8 DECIMALS 2.
    lv_i22 = lv_ret_compl * gc_tasa_rc / 100.

    DATA lv_i31 TYPE p LENGTH 8 DECIMALS 2.
    lv_i31 = lv_i21 + lv_i22.

    " ================================================================
    " 5. GENERAR HTML DEL FORMULARIO IR-17
    " ================================================================
    " En ABAP Cloud, WRITE...TO no esta permitido.
    " Usamos string templates con DECIMALS embebido: |{ variable DECIMALS = 2 }|
    " Esto genera un string como '20000.00' directamente.

    lv_html =
      |<html><head><meta charset="utf-8">| &&
      |<title>IR-17 DGII</title>| &&
      |<style>| &&
      |@page \{ size: letter; margin: 15mm 20mm; \}| &&
      |body \{ font-family: 'Courier New', monospace; font-size: 11px; color: #000; \}| &&
      |.header \{ text-align: center; margin-bottom: 20px; \}| &&
      |.header h1 \{ font-size: 28px; margin: 0; \}| &&
      |.header h3 \{ font-size: 11px; margin: 2px 0; font-weight: normal; \}| &&
      |.header .title-row \{ display: flex; justify-content: space-between; align-items: center; \}| &&
      |.header .dgii \{ font-size: 24px; font-weight: bold; \}| &&
      |.header .ir17 \{ font-size: 28px; font-weight: bold; \}| &&
      |table \{ width: 100%; border-collapse: collapse; margin-top: 10px; \}| &&
      |th, td \{ border: 1px solid #000; padding: 4px 6px; font-size: 11px; \}| &&
      |th \{ background: #eee; text-align: center; \}| &&
      |.r \{ text-align: right; \}| &&
      |.c \{ text-align: center; \}| &&
      |.b \{ font-weight: bold; \}| &&
      |.total-row td \{ border-top: 2px solid #000; font-weight: bold; \}| &&
      |.no-border \{ border: none; \}| &&
      |@media print \{| &&
      |  .no-print \{ display: none; \}| &&
      |  body \{ margin: 0; \}| &&
      |\}| &&
      |</style></head><body>| &&

      |<div class="no-print" style="text-align:center;margin:10px;">| &&
      |<button onclick="window.print()" style="padding:8px 24px;font-size:14px;cursor:pointer;">| &&
      |Imprimir / Guardar PDF</button></div>| &&

      |<div class="header">| &&
      |<div class="title-row">| &&
      |<span class="dgii">DGII</span>| &&
      |<div>| &&
      |<h3>MINISTERIO DE HACIENDA</h3>| &&
      |<h3><b>DIRECCION GENERAL DE IMPUESTOS INTERNOS</b></h3>| &&
      |<h3>Declaracion y/o Pago De Retenciones y Retribuciones Complementarias</h3>| &&
      |</div>| &&
      |<span class="ir17">IR-17</span>| &&
      |</div></div>| &&

      |<table>| &&
      |<tr><th colspan="2">Otras Retenciones</th>| &&
      |<th>Monto Imponible</th><th>Tasa</th><th>Impuesto</th></tr>| &&

      |<tr><td>1</td><td>Alquileres</td>| &&
      |<td class="r">{ lv_alq DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_alq DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_alq DECIMALS = 2 }</td></tr>| &&

      |<tr><td>2</td><td>Honorarios por Servicios Independientes</td>| &&
      |<td class="r">{ lv_hon DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_hon DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_hon DECIMALS = 2 }</td></tr>| &&

      |<tr><td>3</td><td>Premios</td>| &&
      |<td class="r">{ lv_pre DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_pre DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_pre DECIMALS = 2 }</td></tr>| &&

      |<tr><td>4</td><td>Transferencias de Titulos y Propiedades</td>| &&
      |<td class="r">{ lv_tra DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_tra DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_tra DECIMALS = 2 }</td></tr>| &&

      |<tr><td>5</td><td>Dividendos</td>| &&
      |<td class="r">{ lv_div DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_div DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_div DECIMALS = 2 }</td></tr>| &&

      |<tr><td>6</td><td>Intr. a Int. Cred. del Ext.</td>| &&
      |<td class="r">{ lv_ine DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_ine DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_ine DECIMALS = 2 }</td></tr>| &&

      |<tr><td>10</td><td>Remesas al Exterior</td>| &&
      |<td class="r">{ lv_rem DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_rem DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_rem DECIMALS = 2 }</td></tr>| &&

      |<tr><td>12</td><td>Retenciones por pagos a Proveedores del Estado</td>| &&
      |<td class="r">{ lv_rpv DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_rpv DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_rpv DECIMALS = 2 }</td></tr>| &&

      |<tr><td>16</td><td>Otras Rentas (rentas presuntas 2%)</td>| &&
      |<td class="r">{ lv_ot2 DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_ot2 DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_ot2 DECIMALS = 2 }</td></tr>| &&

      |<tr><td>17</td><td>Otras Rentas (10%)</td>| &&
      |<td class="r">{ lv_o10 DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_t_o10 DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i_o10 DECIMALS = 2 }</td></tr>| &&

      |<tr class="total-row"><td class="b">21</td>| &&
      |<td class="b">Total retenciones (Sumar 1+2+3+4+5+6+10+12+16)</td>| &&
      |<td class="r b">{ lv_m21 DECIMALS = 2 }</td><td></td>| &&
      |<td class="r b">{ lv_i21 DECIMALS = 2 }</td></tr>| &&

      |<tr><td>22</td><td>Retenciones Complementarias</td>| &&
      |<td class="r">{ lv_ret_compl DECIMALS = 2 }</td>| &&
      |<td class="r">{ gc_tasa_rc DECIMALS = 2 }</td>| &&
      |<td class="r">{ lv_i22 DECIMALS = 2 }</td></tr>| &&

      |<tr class="total-row"><td class="b">31</td>| &&
      |<td class="b">Total a Pagar (21+22)</td>| &&
      |<td></td><td></td>| &&
      |<td class="r b">{ lv_i31 DECIMALS = 2 }</td></tr>| &&

      |</table>| &&
      |<script>window.print();</script>| &&
      |</body></html>|.

    "response->set_header_field( i_name = 'Content-Type' i_value = 'text/html; charset=utf-8' ).
    "response->set_text( lv_html ).

    response->set_header_field( i_name = 'Content-Security-Policy'
    i_value = |script-src 'unsafe-inline'| ).
    response->set_header_field( i_name = 'Content-Type'
    i_value = 'text/html; charset=utf-8' ).
    response->set_text( lv_html ).

  ENDMETHOD.
ENDCLASS.
