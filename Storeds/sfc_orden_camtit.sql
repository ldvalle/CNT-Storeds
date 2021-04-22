DROP PROCEDURE sfc_orden_camtit;

CREATE PROCEDURE sfc_orden_camtit(
nroClienteNvo	LIKE cliente.numero_cliente,
nroMensaje    integer)
RETURNING smallint as codigo, char(100) as descripcion;

DEFINE retCodigo smallint;
DEFINE retDescripcion  char(100);
DEFINE nrows        integer;
DEFINE codRetorno   integer;
DEFINE descRetorno  char(100);
DEFINE sAreaRol     char(20);

DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfcMoverCliente. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;

    SELECT area INTO sAreaRol
    FROM rol
    WHERE rol = 'SALESFORCE';

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
      prioridad,
      estado, 
      tema, 
      trabajo,
      numero_cliente
    )VALUES (
      'OC',
      nroClienteNvo,
      nroMensaje,
      1,
      sAreaRol,
      'SALESFORCE',
      CURRENT,
      'RQ',
      'SALESFORCE',
      'N',
      '0',
      '020',
      '700',
      nroClienteNvo);

    RETURN 0, 'OK';

END PROCEDURE;


GRANT EXECUTE ON sfc_orden_camtit TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;

