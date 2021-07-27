DROP PROCEDURE sfc_envia_mensaje;

CREATE PROCEDURE sfc_envia_mensaje( 
nro_cliente     like cliente.numero_cliente, 
msg_xnear       integer,
motivo          like tabla.codigo,
desc_motivo     char(50),
envia_sap       char(1),
idTrx           char(30),
sRolOrigen      like rol.rol,
sAreaOrigen     like rol.area,
sRolSalida      like rol.rol,
sAreaSalida     like rol.area,
sucurPadre      char(4), 
procedimiento   char(6),
observaciones   char(10240))
RETURNING smallint as codRetorno, char(50) as descripcion;

DEFINE retCodigo    smallint;
DEFINE retDesc      char(50);

DEFINE cli_dv_numero_cliente    like sfc_clitecmed_data.dv_numero_cliente;
DEFINE cli_nombre               like sfc_clitecmed_data.nombre;
DEFINE cli_nom_calle            like sfc_clitecmed_data.nom_calle;
DEFINE cli_nom_comuna           like sfc_clitecmed_data.nom_comuna;
DEFINE cli_desc_empalme         like sfc_clitecmed_data.desc_empalme;
DEFINE cli_nro_subestacion      like sfc_clitecmed_data.nro_subestacion;
DEFINE cli_potencia_contrato    like sfc_clitecmed_data.potencia_contrato;
DEFINE cli_potencia_inst_fp     like sfc_clitecmed_data.potencia_inst_fp;
DEFINE cli_nom_provincia        like sfc_clitecmed_data.nom_provincia;

DEFINE texton       char(10240);
DEFINE sReferencia  char(100);

DEFINE nrows                integer;
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);
DEFINE sXpro                char(50);
DEFINE sC                   char(1);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_envia_mensaje. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;

    -- Recupero datos del cliente
    SELECT dv_numero_cliente, nombre, nom_calle, nom_comuna, nvl(desc_empalme, ' '), nvl(nro_subestacion, ' '),
        nvl(potencia_contrato, 0), nvl(potencia_inst_fp, 0), nom_provincia
    INTO cli_dv_numero_cliente, cli_nombre, cli_nom_calle, cli_nom_comuna, cli_desc_empalme,
        cli_nro_subestacion, cli_potencia_contrato, cli_potencia_inst_fp, cli_nom_provincia
    FROM sfc_clitecmed_data WHERE trx_proced = idTrx;

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'sfc_envia_mensaje. Perdi data del cliente.';
	END IF;
    
    -- levanto el caracter 'þ'
    SELECT caracter INTO sC FROM tabla_ascii
    WHERE cod_dec = 254;

    IF observaciones is null THEN
        LET observaciones = ' ';
    END IF;
    
    -- Armo TEXTON
    IF trim(procedimiento) = 'RETCLI' THEN
      LET texton = trim(sRolSalida) || sC || sC ||
       'OCP' || sucurPadre || sC || sC ||
       to_char(nro_cliente) || sC || cli_dv_numero_cliente || sC ||
       trim(desc_motivo) || sC ||
       trim(cli_nombre) || sC ||
       trim(cli_nom_calle) || sC ||
       trim(cli_nom_comuna) || sC ||
       trim(sRolOrigen) || ' (' || trim(sAreaOrigen) || ')' || sC ||
       procedimiento || sC ||
       trim(cli_desc_empalme) || sC ||
       trim(cli_nro_subestacion) || sC ||
       to_char(round(cli_potencia_contrato,2)) || sC ||
       to_char(cli_potencia_inst_fp) || sC || sC || sC ||
       trim(cli_nom_provincia) || sC || sC || sC || sC || sC || '-------------\n' || 
       to_char(current, '%d/%m/%Y %H:%M:%S') || ' - ' || trim(sRolOrigen) || ' - ' || '10.240.20.18' || sC || sC ||
       ' - ' || observaciones  || '/\n';
  
    ELIF procedimiento = 'MANSER' THEN
      LET texton = trim(sRolSalida) || sC || sC || sC || sC ||
        to_char(nro_cliente) || sC || cli_dv_numero_cliente || sC ||
        trim(desc_motivo) || sC ||
        trim(cli_nombre) || sC ||
        trim(cli_nom_calle) || sC ||
        trim(cli_nom_comuna) || sC ||
        trim(sRolOrigen) || ' (' || trim(sAreaOrigen) || ')' || sC ||      
        procedimiento || sC ||
        trim(cli_desc_empalme) || sC ||
        trim(cli_nro_subestacion) || sC ||
        to_char(round(cli_potencia_contrato,2)) || sC ||
        to_char(cli_potencia_inst_fp) || sC || sC || sC ||
        trim(cli_nom_provincia) || sC || sC || sC || sC || sC || '-------------\n' || 
        to_char(current, '%d/%m/%Y %H:%M:%S') || ' - ' || trim(sRolOrigen) || ' - ' || '10.240.20.18' || sC || sC ||
        ' - ' || observaciones  || '/\n';
    
    END IF;
        
    LET sReferencia = '(' || procedimiento || ') Cliente: ' || lpad(nro_cliente, 8, '0') || '-' || cli_dv_numero_cliente; 
    
    -- Envio el mensaje
    EXECUTE PROCEDURE xpro_enviar(msg_xnear, trim(procedimiento), 'INICIO', 0, 4, 'N', sReferencia, trim(sRolOrigen), trim(sRolOrigen), trim(sRolSalida), 1, 1, 1, texton)
        INTO sXpro;

    RETURN 0, 'OK';
END PROCEDURE;


GRANT EXECUTE ON sfc_envia_mensaje TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
