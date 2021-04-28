DROP PROCEDURE sfc_gen_ot;

CREATE PROCEDURE sfc_gen_ot( 
nro_cliente     like cliente.numero_cliente, 
msg_xnear       like mensaje.mensaje,
motivo          like tabla.codigo,
envia_sap       char(1),
idTrx           char(30),
sRolOrigen      like rol.rol,
sAreaOrigen     like rol.area,
sRolSalida      like rol.rol,
sAreaSalida     like rol.area,
sucurPadre      char(4), 
procedimiento   char(6))
RETURNING smallint as codRetorno, char(50) as descripcion, char(12) as nro_ot;

DEFINE retCodigo    smallint;
DEFINE retDesc      char(50);
DEFINE iNroOT       integer;
DEFINE sNroOt       char(12);
DEFINE centro_op    char(4);
DEFINE tipoOrden    char(3);

DEFINE cli_nombre               like sfc_clitecmed_data.nombre;
DEFINE cli_sucursal             like sfc_clitecmed_data.sucursal; 
DEFINE cli_sector               like sfc_clitecmed_data.sector;
DEFINE cli_zona                 like sfc_clitecmed_data.zona;
DEFINE cli_correlativo_ruta     like sfc_clitecmed_data.correlativo_ruta; 
DEFINE cli_potencia_contrato    like sfc_clitecmed_data.potencia_contrato; 
DEFINE cli_tipo_empalme         like sfc_clitecmed_data.tipo_empalme;
DEFINE cli_codigo_voltaje       like sfc_clitecmed_data.codigo_voltaje; 
DEFINE cli_acometida            like sfc_clitecmed_data.acometida; 
DEFINE cli_tipo_conexion        like sfc_clitecmed_data.tipo_conexion; 
DEFINE cli_clave_montri         like sfc_clitecmed_data.clave_montri;
DEFINE cli_numero_medidor       like sfc_clitecmed_data.numero_medidor; 
DEFINE cli_marca_medidor        like sfc_clitecmed_data.marca_medidor;
DEFINE cli_modelo_medidor       like sfc_clitecmed_data.modelo_medidor;
DEFINE cli_obs_dir              like sfc_clitecmed_data.obs_dir;
DEFINE cli_info_adic_lectura    like sfc_clitecmed_data.info_adic_lectura;
DEFINE cli_tipo_cliente         like sfc_clitecmed_data.tipo_cliente; 
DEFINE cli_acometida            like sfc_clitecmed_data.acometida;
DEFINE cli_nom_entre            like sfc_clitecmed_data.nom_entre;
DEFINE cli_nom_entre1           like sfc_clitecmed_data.nom_entre1;
DEFINE cli_telefono             like sfc_clitecmed_data.telefono; 
DEFINE cli_nom_calle            like sfc_clitecmed_data.nom_calle;
DEFINE cli_nro_dir              like sfc_clitecmed_data.nro_dir;
DEFINE cli_nom_partido          like sfc_clitecmed_data.nom_partido;
DEFINE cli_piso_dir             like sfc_clitecmed_data.piso_dir;
DEFINE cli_depto_dir            like sfc_clitecmed_data.depto_dir;
DEFINE cli_nom_comuna           like sfc_clitecmed_data.nom_comuna;
DEFINE cli_cod_postal           like sfc_clitecmed_data.cod_postal;
 

DEFINE miTrabajo        char(4);
DEFINE miFechaVto       date;
DEFINE ObsSgn           char(100);
DEFINE cod_bar_mod      char(3);
DEFINE iItem            smallint;
DEFINE sCodBarra        char(12);


DEFINE pre_serie        like sellos.serie_insta; 
DEFINE pre_numero       like sellos.numero_insta; 
DEFINE pre_ubic         like sellos.codigo_ubicacion; 
DEFINE pre_fecha_mov    like sellos.fecha_movimiento; 

DEFINE pre_serie1       like sellos.serie_insta; 
DEFINE pre_numero1      like sellos.numero_insta; 
DEFINE pre_ubic1        like sellos.codigo_ubicacion; 
DEFINE pre_serie2       like sellos.serie_insta; 
DEFINE pre_numero2      like sellos.numero_insta; 
DEFINE pre_ubic2        like sellos.codigo_ubicacion; 
DEFINE pre_serie3       like sellos.serie_insta; 
DEFINE pre_numero3      like sellos.numero_insta; 
DEFINE pre_ubic3        like sellos.codigo_ubicacion; 
DEFINE pre_tipo3        char(1);

DEFINE nrows    int;
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_gen_ot. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info, null;
    END EXCEPTION;

    -- Obtengo datos del cliente
    SELECT nombre, sucursal, sector, zona, correlativo_ruta, potencia_contrato, tipo_empalme,
        codigo_voltaje, acometida, tipo_conexion, clave_montri, numero_medidor, marca_medidor, 
        modelo_medidor, obs_dir, info_adic_lectura, tipo_cliente, acometida, nom_entre, nom_entre1,
        telefono, nom_calle, nro_dir, nom_partido, piso_dir, depto_dir, nom_comuna, cod_postal
        
    INTO cli_nombre, cli_sucursal, cli_sector, cli_zona, cli_correlativo_ruta, cli_potencia_contrato, cli_tipo_empalme,
        cli_codigo_voltaje, cli_acometida, cli_tipo_conexion, cli_clave_montri, cli_numero_medidor, cli_marca_medidor,
        cli_modelo_medidor, cli_obs_dir, cli_info_adic_lectura, cli_tipo_cliente, cli_acometida, cli_nom_entre, cli_nom_entre1,
        cli_telefono, cli_nom_calle, cli_nro_dir, cli_nom_partido, cli_piso_dir, cli_depto_dir, cli_nom_comuna, cli_cod_postal
        
    FROM sfc_clitecmed_data
    WHERE trx_proced = idTrx;
    
    IF cli_clave_montri = 'M' THEN
        LET miTrabajo = 'SR01';
    ELSE
        LET miTrabajo = 'SR02';
    END IF;
     
    LET miFechaVto = TODAY + 10;
       
    -- La barra del medidor
    SELECT lpad(NVL(TRIM(mod_nrocb), 0), 3, '0') INTO cod_bar_mod 
    FROM modelo 
    WHERE mar_codigo = cli_marca_medidor
    AND mod_codigo = cli_modelo_medidor;
    
    LET sCodBarra = cod_bar_mod || lpad(cli_numero_medidor, 9, '0');
    LET sRutaLectura = cli_sucursal || '-' || lpad(cli_sector, 3, '0') || '-' || lpad(cli_zona, 5, '0') || '-' || lpad(cli_correlativo_ruta, 5, '0');
    
    -- Grabo OT_MAC
	INSERT INTO OT_MAC (
		ot_numero_cliente,
		ot_mensaje_xnear,
		ot_proced,
		ot_envia_sap,
		ot_estado,
		ot_fecha_est,
		ot_status,
		ot_fecha_status,
		ot_fecha_inicio,
		ot_sucursal_padre,
		ot_sucursal,
		ot_sector,
		ot_zona,
		ot_corr_ruta,
		ot_tipo_traba,
		ot_area_interloc,
		ot_motivo,
		ot_rol_ejecuta,
		ot_area_ejecuta,
		ot_potencia,
		ot_tension,
		ot_acometida,
		ot_toma,
		ot_conexion,
		ot_fecha_vto
	)VALUES(
        nro_cliente,
        msg_xnear,
        procedimiento,
        envia_sap,
        'C',
        CURRENT,
        'INIC',
        CURRENT,
        CURRENT,
        sucurPadre,
        cli_sucursal,
        cli_sector, 
        cli_zona, 
        cli_correlativo_ruta,
        miTrabajo,
        sAreaSalida,
        motivo,
        sRolOrigen,
        sAreaOrigen,
        cli_potencia_contrato,
        cli_codigo_voltaje,
        cli_acometida,
        cli_tipo_empalme,
        cli_tipo_conexion,
        miFechaVto);
    
    -- Recupero el nro de OT generado
    SELECT ot_nro_orden INTO iNroOT 
    FROM ot_mac 
    WHERE ot_mensaje_xnear = msg_xnear
    AND ot_fecha_inicio = (SELECT max(ot_fecha_inicio) FROM ot_mac 
    WHERE ot_mensaje_xnear = msg_xnear
    AND ot_estado = 'C' )
        
    -- Grabo OT_HISEVEN
    INSERT INTO ot_hiseven 
    (
        ots_nro_orden, 
        ots_numero_cliente,
        ots_status,
        ots_fecha,
        ots_observac,
        ots_fecha_proc
    )VALUES ( 
        iNroOT,
        nro_cliente,
        'INIC',
        CURRENT, 
        'INICIADA',
        CURRENT );
    
    -- Cargo Precintos
    LET iItem=0;
    
    FOREACH
      SELECT FIRST 2 serie_insta, numero_insta, codigo_ubicacion, fecha_movimiento
      INTO pre_serie, pre_numero, pre_ubic, pre_fecha_mov 
      FROM sellos 
      WHERE numero_cliente = nro_cliente
      AND numero_medidor = cli_numero_medidor
      AND marca_medidor  = cli_marca_medidor
      AND estado_insta = '6'
      ORDER BY fecha_movimiento DESC; 
    
      LET iItem=iItem+1;
      
      IF iItem=1 THEN
        LET pre_serie1 = pre_serie; 
        LET pre_numero1 = pre_numero; 
        LET pre_ubic1 = pre_ubic; 
      ELIF iItem=2 THEN
        LET pre_serie2 = pre_serie; 
        LET pre_numero2 = pre_numero; 
        LET pre_ubic2 = pre_ubic;
      END IF;

    END FOREACH

    SELECT  e.serie, e.numero_precinto, '0', 'P'
    INTO pre_serie3, pre_numero3, pre_ubic3, pre_tipo3
    FROM prt_precintos e
    WHERE e.numero_cliente = nro_cliente
    AND e.estado_actual = '08'
    AND e.fecha_estado = (select MAX(e2.fecha_estado)
         FROM prt_precintos e2
         WHERE e.numero_cliente = e2.numero_cliente
         AND e.estado_actual = e2.estado_actual );

    
    IF envia_sap = 'S' THEN
        -- Grabo OT_MAC_SAP
        IF procedimiento = 'RETCLI' THEN
          LET sNroOt = 'SR' || lpad( iNroOrden, 10, '0'); 
          
          LET ObsSgn = sRolSalida || ' - '  || to_char(nro_cliente) || ' - ' || trim(cli_nombre) || current || ' - ' || 
                  trim(sRolOrigen) || ' - 10.240.0.0';    

          LET omsObsError = 'Retcli sin OT';
        END IF;
        
        INSERT INTO ot_mac_sap (
          oms_tipo_ifaz,
          oms_nro_orden,
          oms_tipo_traba,
          oms_sucursal,
          oms_area_ejecuta,
          oms_motivo,
          oms_fecha_ini,    
          oms_obs_dir,
          oms_obs_lectu,
          oms_area_interloc,
          oms_nro_medidor,
          oms_marca_med,
          oms_modelo_med,
          oms_cla_servi,
          oms_potencia,
          oms_tension,
          oms_acometida,
          oms_toma,
          oms_conexion,
          oms_pre1_ubic,
          oms_pre2_ubic,
          oms_pre3_ubic,
          oms_ruta_lectura,
          oms_nombre_cli,
          oms_nro_cli,
          oms_nom_entre,
          oms_nom_entre1,
          oms_telefono,
          oms_nom_calle,
          oms_nro_dir,
          oms_nom_partido,
          oms_piso_dir,
          oms_depto_dir,
          oms_nom_comuna,
          oms_cod_postal,
          oms_fecha_vto,
          oms_codbar,
          oms_serie_prec_ret,
          oms_rol_creador,
          oms_nombre_rol,
          oms_proced,
          oms_nro_proced 
        )VALUES(
          'G001',
          sNroOt,
          miTrabajo,
          sucurPadre,
          sAreaOrigen,
          motivo,
          CURRENT,    
          cli_obs_dir,
          cli_info_adic_lectura,
          sAreaSalida,
          cli_numero_medidor,
          cli_marca_medidor,
          cli_modelo_medidor,
          cli_tipo_cliente,
          cli_potencia_contrato,
          cli_codigo_voltaje,
          cli_acometida,
          cli_tipo_empalme,
          cli_tipo_conexion,
          pre_ubic1,
          pre_ubic2,
          pre_ubic3,
          sRutaLectura,
          cli_nombre,
          nro_cliente,
          cli_nom_entre,
          cli_nom_entre1,
          cli_telefono,
          cli_nom_calle,
          cli_nro_dir,
          cli_nom_partido,
          cli_piso_dir,
          cli_depto_dir,
          cli_nom_comuna,
          cli_cod_postal,
          miFechaVto,
          sCodBarra,
          pre_serie3,
          sRolOrigen,
          sRolOrigen,
          procedimiento,
          msg_xnear ); 
        
    ELSE
        -- Grabo OT_MAC_PEND
      INSERT INTO ot_mac_pend (
        omp_tipo_ifaz, 
        omp_nro_orden,
        omp_sucursal,
        omp_sector,
        omp_zona,
        omp_corr_ruta,    
        omp_acometida,
        omp_tension,
        omp_potencia,       
        omp_numed_retira,
        omp_marmed_retira,
        omp_modmed_retira,
        omp_preci1_retira,
        omp_serie_pre1_ret,
        omp_ubic_pre1_ret,
        omp_preci2_retira,
        omp_serie_pre2_ret,
        omp_ubic_pre2_ret,
        omp_preci3_retira,
        omp_serie_pre3_ret,
        omp_ubic_pre3_ret,
        omp_tipo_pre3_ret,
  
        omp_estado,
        omp_status,
        omp_hora_status,
        omp_fecha_status,
        omp_envia_sap 
      ) VALUES (
        'N001', 
        sNroOt,
        cli_sucursal,
        cli_sector,
        cli_zona,
        cli_correlativo_ruta,    
        cli_acometida,
        cli_codigo_voltaje,
        cli_potencia_contrato,       
        cli_numero_medidor,
        cli_marca_medidor,
        cli_modelo_medidor,
        pre_numero1,
        pre_serie1,
        pre_ubic1,
        pre_numero2,
        pre_serie2,
        pre_ubic2,
        pre_numero3,
        pre_serie3,
        pre_ubic2,
        pre_tipo3,
        'C',
        'INIC',
        CURRENT,
        CURRENT,
        'N' ); 
    END IF;

    RETURN 0, 'OK', sNroOt;
END PROCEDURE;

GRANT EXECUTE ON sfc_gen_ot TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
