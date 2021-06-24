DROP PROCEDURE sfc_manser;

CREATE PROCEDURE sfc_manser(
    cod_motivo      like tabla.codigo,
    nro_cliente     like cliente.numero_cliente,
    nvaClaveMontri  char(1),
    msg_xnear       integer,
    sNroOrden       char(16)
)
RETURNING smallint as codRetorno, char(50) as descRetorno, char(12) as orden_ot;

DEFINE retCodigo smallint;
DEFINE retDesc   char(50);
DEFINE ordenOt      char(12);

DEFINE mc_estado_cliente    like cliente.estado_cliente;
DEFINE mc_sucursal          like cliente.sucursal;
DEFINE sucurPadreSAP        char(4);
DEFINE auxCod   smallint;
DEFINE auxDesc  char(50);
DEFINE enviaSAP char(1);
DEFINE sRolOrigen   like rol.rol;
DEFINE sAreaOrigen  like rol.area;
DEFINE sCarpetaSalida   like ot_xpro_accion.otx_carpeta;
DEFINE sAreaSalida      like rol.area;

DEFINE idTrx        char(30);
DEFINE nrows    int;
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_manser. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info, null;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 10;
    
    -- Validamos cliente
    SELECT estado_cliente, sucursal INTO mc_estado_cliente, mc_sucursal 
    FROM cliente WHERE numero_cliente = nro_cliente;
    
	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'Cliente no existe.', null;
	END IF;

    -- validamos el motivo    
    EXECUTE PROCEDURE sfc_tabmotivos(cod_motivo, 'OTMOMA', mc_estado_cliente)
        INTO auxCod, auxDesc, enviaSAP;
        
    IF auxCod != 0 THEN
        RETURN 1, 'Motivo Invalido', null;
    END IF;

    -- Sucur Padre SAP
    SELECT suc_padre INTO sucurPadreSap FROM ot_sucursal
    WHERE suc_hijo = mc_sucursal;

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro OT_SUCURSAL.suc_padre.', null;
	END IF;
    
    -- Origen
    SELECT s.rol, r.area  INTO sRolOrigen, sAreaOrigen
    FROM sucur_centro_op o, sfc_roles s, rol r
    WHERE o.cod_centro_op = mc_sucursal 
    AND s.procedimiento = 'MAN'
    AND s.sucursal = o.cod_sucur 
    AND r.rol = s.rol;

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro Rol Origen.', null;
	END IF;
    
    -- Destino
	SELECT otx_carpeta INTO sCarpetaSalida
	FROM ot_xpro_accion
	WHERE otx_proced = 'MANSER'
	AND otx_sucursal = mc_sucursal
    AND otx_accion   = '10';

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro Carpeta Salida.', null;
	END IF;
    
    SELECT area INTO sAreaSalida
    FROM rol WHERE rol = sCarpetaSalida;
    
	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro Area Salida.', null;
	END IF;
    
    -- Obtenemos Data Gral del cliente
    EXECUTE PROCEDURE sfc_data_climed( nro_cliente, nvaClaveMontri, 'MANSER')
        INTO retCodigo, retDesc, idTrx;

    IF retCodigo != 0 THEN
        RETURN retCodigo, retDesc, null;
    END IF;

    -- Grabar Retcli
    INSERT INTO retcli (numero_cliente, codigo) VALUES (nro_cliente, 'C');
    
    -- Grabar Orden
    EXECUTE PROCEDURE sfc_orden(nro_cliente, msg_xnear, sNroOrden, cod_motivo, idTrx, sRolOrigen, sAreaOrigen, 'MANSER')
        INTO retCodigo, retDesc;

    IF retCodigo != 0 THEN
        RETURN retCodigo, retDesc, null;
    END IF;

    -- Cargar Tablas de OT
    EXECUTE PROCEDURE sfc_gen_ot(nro_cliente, msg_xnear, cod_motivo, enviaSAP, idTrx, sRolOrigen, sAreaOrigen, sCarpetaSalida, sAreaSalida, sucurPadreSAP, 'MANSER')
        INTO retCodigo, retDesc, ordenOt;
        
    IF retCodigo != 0 THEN
        RETURN retCodigo, retDesc, null;
    END IF;
    
    -- Cargar y enviar Mensaje
    EXECUTE PROCEDURE sfc_envia_mensaje(nro_cliente, msg_xnear, cod_motivo, auxDesc, enviaSAP, idTrx, sRolOrigen, sAreaOrigen, sCarpetaSalida, sAreaSalida, sucurPadreSAP, 'MANSER')
        INTO retCodigo, retDesc;

    IF retCodigo != 0 THEN
        RETURN retCodigo, retDesc, null;
    END IF;

    -- Borramos data cliente
    DELETE sfc_clitecmed_data WHERE trx_proced = idTrx;

    RETURN 0, 'OK', ordenOt;

END PROCEDURE;

GRANT EXECUTE ON sfc_manser TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
