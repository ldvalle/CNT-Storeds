DROP PROCEDURE sfc_orden;

CREATE PROCEDURE sfc_orden( 
nro_cliente     like cliente.numero_cliente, 
msg_xnear       like mensaje.mensaje,
sNroOrden       char(16);  
motivo          like tabla.codigo,
idTrx           char(30),
sRolOrigen      like rol.rol,
sAreaOrigen     like rol.area, 
procedimiento char(6))
RETURNING smallint as codRetorno, char(50) as descripcion;

DEFINE retCodigo    smallint;
DEFINE retDesc      char(50);
DEFINE centro_op    char(4);
DEFINE tipoOrden    char(3);

DEFINE nrows    int;
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_orden. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;
    
    IF procedimiento = 'RETCLI' THEN
        LET tipoOrden = 'RET';
        LET sTema = motivo;
        LET sTrabajo = ' ';
    END IF;
       
    SELECT cli_sucursal INTO centro_op FROM sfc_clitecmed_data WHERE trx_proced = idTrx;
    
    INSERT INTO orden (
      tipo_orden,
      numero_orden,
      mensaje_xnear,
      servidor,
      sucursal,
      area_emisora,
      fecha_inicio,
      ident_etapa,
      term_dir,
      area_ejecutora,
      rol_usuario,
      tema,
      trabajo,
      numero_cliente
    )VALUES (
      tipoOrden, 
      sNroOrden, 
      msg_xnear, 
      1, 
      centro_op, 
      sRolOrigen, 
      CURRENT, 
      'RQ', 
      'SALEFORCE', 
      sAreaOrigen, 
      sRolOrigen, 
      sTema, 
      sTrabajo, 
      nro_cliente);	
    
    RETURN 0, 'OK';
END PROCEDURE;

GRANT EXECUTE ON sfc_orden TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
