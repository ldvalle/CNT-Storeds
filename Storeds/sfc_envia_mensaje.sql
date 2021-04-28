DROP PROCEDURE sfc_envia_mensaje;

CREATE PROCEDURE sfc_envia_mensaje( 
nro_cliente     like cliente.numero_cliente, 
msg_xnear       like mensaje.mensaje,
motivo          like tabla.codigo,
desc_motivo     char(50),
envia_sap       char(1),
idTrx           char(30),
sRolOrigen      like rol.rol,
sAreaOrigen     like rol.area,
sRolSalida      like rol.rol,
sAreaSalida     like rol.area,
sucurPadre      char(4), 
procedimiento   char(6))
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

DEFINE texton       char(250);
DEFINE sReferencia  char(100);

DEFINE nrows                integer;
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_envia_mensaje. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;

    -- Recupero datos del cliente
    SELECT dv_numero_cliente, nombre, nom_calle, nom_comuna, desc_empalme, nro_subestacion,
        potencia_contrato, potencia_inst_fp, nom_provincia
    INTO cli_dv_numero_cliente, cli_nombre, cli_nom_calle, cli_nom_comuna, cli_desc_empalme,
        cli_nro_subestacion, cli_potencia_contrato, cli_potencia_inst_fp, cli_nom_provincia
    FROM sfc_clitecmed_data WHERE trx_proced = idTrx;

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'sfc_envia_mensaje. Perdi data del cliente.';
	END IF;
    
    -- Armo TEXTON
    LET texton = trim(sRolSalida) || 'þþ';
    LET texton = texton || 'OCP' || sucurPadre || 'þþ';
    LET texton = texton || to_char(nro_cliente) || 'þ' || cli_dv_numero_cliente || 'þ';
    LET texton = texton || trim(desc_motivo) || 'þ';
    LET texton = texton || trim(cli_nombre) || 'þ';
    LET texton = texton || trim(cli_nom_calle) || 'þ';
    LET texton = texton || trim(cli_nom_comuna) || 'þ';
    LET texton = texton || trim(sRolOrigen) || ' (' || trim(sAreaOrigen) || ')' || 'þ';
    LET texton = texton || procedimiento || 'þ';
    LET texton = texton || trim(cli_desc_empalme) || 'þ';
    LET texton = texton || trim(cli_nro_subestacion) || 'þ';
    LET texton = texton || trim(cli_potencia_contrato) || 'þ';
    LET texton = texton || trim(cli_potencia_inst_fp) || 'þþþ';
    LET texton = texton || trim(cli_nom_provincia) || 'þþþþþ-------------\n';
    LET texton = texton || to_char(current, '%d/%m/%Y %H:%M:%S') || ' - ' || sRolOrigen || ' - ' || '10.240.20.18/\n';
    
    LET sReferencia = '(' || procedimiento || ') Cliente: ' || lpad(nro_cliente, 8, '0') || '-' || cli_dv_numero_cliente; 
    
    -- Envio el mensaje
    EXECUTE PROCEDURE xpro_enviar (msg_xnear, trim(procedimiento), 'INICIO', 0, 4, 'N', sReferncia, trim(sRolOrigen),
        trim(sRolOrigen), trim(sRolSalida), 1, 1, 1, texton);


    RETURN 0, 'OK';
END PROCEDURE;


GRANT EXECUTE ON sfc_envia_mensaje TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
