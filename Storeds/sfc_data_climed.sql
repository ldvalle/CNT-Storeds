DROP PROCEDURE sfc_data_climed;

CREATE PROCEDURE sfc_data_climed( nro_cliente like cliente.numero_cliente, fase_nvo_medidor char(1),  procedimiento char(6))
RETURNING smallint as codRetorno, char(50) as descripcion, char(30) as transaccion;
DEFINE retCodigo smallint;
DEFINE retDesc   char(50);

DEFINE fmtDateTime char(14);
DEFINE fmtCliente   char(10);
DEFINE trxProced    char(30); -- proced + fmtCliente + fmtDateTime
-- Data Cliente
DEFINE cli_dv_numero_cliente char(1);
DEFINE cli_sucursal like cliente.sucursal;
DEFINE cli_nombre like cliente.sucursal;
DEFINE cli_nom_calle like cliente.nom_calle;
DEFINE cli_nro_dir like cliente.nro_dir;
DEFINE cli_piso_dir like cliente.piso_dir;
DEFINE cli_depto_dir like cliente.depto_dir;
DEFINE cli_nom_entre like cliente.nom_entre;
DEFINE cli_nom_entre1 like cliente.nom_entre1;
DEFINE cli_nom_comuna like cliente.nom_comuna;
DEFINE cli_nom_partido like cliente.nom_partido;
DEFINE cli_nom_provincia like cliente.nom_provincia;
DEFINE cli_telefono like cliente.telefono;
DEFINE cli_cod_postal like cliente.cod_postal;
DEFINE cli_sector like cliente.sector;
DEFINE cli_zona like cliente.zona;
DEFINE cli_correlativo_ruta like cliente.correlativo_ruta;
DEFINE cli_tipo_empalme like cliente.tipo_empalme;
DEFINE cli_desc_empalme     like tabla.descripcion;
DEFINE cli_potencia_contrato like cliente.potencia_contrato;
DEFINE cli_potencia_inst_fp like cliente.potencia_inst_fp;
DEFINE cli_obs_dir like cliente.obs_dir;
DEFINE cli_info_adic_lectura like cliente.info_adic_lectura;
DEFINE cli_tipo_cliente  like cliente.tipo_cliente;
DEFINE cli_tipo_sum like cliente.tipo_sum;
-- Data Tecni
DEFINE tec_nro_subestacion  like tecni.nro_subestacion;
DEFINE tec_codigo_voltaje   like tecni.codigo_voltaje;
DEFINE tec_acometida    like tecni.acometida;
DEFINE tec_tipo_conexion    like tecni.tipo_conexion;
DEFINE tec_car_med_princ    like tecni.car_med_princ;
-- Data Medidor
DEFINE med_numero_medidor   like medid.numero_medidor; 
DEFINE med_marca_medidor    like medid.marca_medidor;
DEFINE med_modelo_medidor   like medid.modelo_medidor;
DEFINE med_clave_montri     like medid.clave_montri;

DEFINE nrows    int;
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_data_climed. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info, null;
    END EXCEPTION;

    SELECT c.dv_numero_cliente,
      c.sucursal,
      c.nombre,
      c.nom_calle,
      c.nro_dir,
      c.piso_dir,
      c.depto_dir,
      c.nom_entre,
      c.nom_entre1,
      c.nom_comuna,
      c.nom_partido,
      c.nom_provincia,
      c.telefono,
      c.cod_postal,
      c.sector,
      c.zona,
      c.correlativo_ruta,
      c.tipo_empalme,
      t1.descripcion,
      c.potencia_contrato,
      c.potencia_inst_fp,
      c.obs_dir,
      c.info_adic_lectura,
      c.tipo_cliente,
      c.tipo_sum
    INTO
      cli_dv_numero_cliente,
      cli_sucursal,
      cli_nombre,
      cli_nom_calle,
      cli_nro_dir,
      cli_piso_dir,
      cli_depto_dir,
      cli_nom_entre,
      cli_nom_entre1,
      cli_nom_comuna,
      cli_nom_partido,
      cli_nom_provincia,
      cli_telefono,
      cli_cod_postal,
      cli_sector,
      cli_zona,
      cli_correlativo_ruta,
      cli_tipo_empalme,
      cli_desc_empalme,
      cli_potencia_contrato,
      cli_potencia_inst_fp,
      cli_obs_dir,
      cli_info_adic_lectura,
      cli_tipo_cliente,
      cli_tipo_sum
    FROM cliente c, OUTER tabla t1
    WHERE c.numero_cliente = nro_cliente
    AND t1.nomtabla = 'EMPAL'
    AND t1.codigo = c.tipo_empalme
    AND t1.sucursal = '0000'
    AND t1.fecha_activacion <= TODAY
    AND (t1.fecha_desactivac IS NULL OR t1.fecha_desactivac > TODAY);
    
	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro Cliente.', null;
	END IF;

    IF trim(cli_tipo_sum) != '5' AND trim(cli_tipo_sum) != '5' THEN
        
        SELECT nro_subestacion,
         codigo_voltaje,
         acometida,
         tipo_conexion,
         car_med_princ
        INTO
         tec_nro_subestacion,
         tec_codigo_voltaje,
         tec_acometida,
         tec_tipo_conexion,
         tec_car_med_princ
        FROM tecni
        WHERE tecni.numero_cliente = nro_cliente;
    
    END IF; 


    SELECT numero_medidor, marca_medidor, modelo_medidor, clave_montri
    INTO med_numero_medidor, med_marca_medidor, med_modelo_medidor, med_clave_montri
    FROM medid
    WHERE numero_cliente = nro_cliente
    AND estado = 'I';

    LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro Medidor Instalado.', null;
	END IF;

    LET fmtDateTime = to_char(current, '%Y%m%d%H%M%S');
    LET fmtCliente = lpad(nro_cliente, 10, '0');
    LET trxProced = procedimiento || fmtCliente || fmtDateTime;
    
    IF trim(procedimiento) = 'RETCLI' THEN
        LET fase_nvo_medidor = med_clave_montri;
    END IF;
    
    INSERT INTO sfc_clitecmed_data(
        trx_proced,
        numero_cliente,
        dv_numero_cliente,
        sucursal,
        nombre,
        nom_calle,
        nro_dir,
        piso_dir,
        depto_dir,
        nom_entre,
        nom_entre1,
        nom_comuna,
        nom_partido,
        nom_provincia,
        telefono,
        cod_postal,
        sector,
        zona,
        correlativo_ruta,
        tipo_empalme,
        desc_empalme,
        potencia_contrato,
        potencia_inst_fp,
        obs_dir,
        info_adic_lectura,
        tipo_cliente,
        tipo_sum,
        nro_subestacion,
        codigo_voltaje,
        acometida,
        tipo_conexion,
        car_med_princ,
        numero_medidor, 
        marca_medidor,
        modelo_medidor,
        clave_montri,
        nva_clave_montri
    )VALUES(
        trxProced,
        nro_cliente,
        cli_dv_numero_cliente,
        cli_sucursal,
        cli_nombre,
        cli_nom_calle,
        cli_nro_dir,
        cli_piso_dir,
        cli_depto_dir,
        cli_nom_entre,
        cli_nom_entre1,
        cli_nom_comuna,
        cli_nom_partido,
        cli_nom_provincia,
        cli_telefono,
        cli_cod_postal,
        cli_sector,
        cli_zona,
        cli_correlativo_ruta,
        cli_tipo_empalme,
        cli_desc_empalme,
        cli_potencia_contrato,
        cli_potencia_inst_fp,
        cli_obs_dir,
        cli_info_adic_lectura,
        cli_tipo_cliente,
        cli_tipo_sum,
        tec_nro_subestacion,
        tec_codigo_voltaje,
        tec_acometida,
        tec_tipo_conexion,
        tec_car_med_princ,
        med_numero_medidor, 
        med_marca_medidor, 
        med_modelo_medidor,
        med_clave_montri,
        fase_nvo_medidor
    );

    RETURN 0, 'OK', trxProced;
END PROCEDURE;

GRANT EXECUTE ON sfc_data_climed TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
