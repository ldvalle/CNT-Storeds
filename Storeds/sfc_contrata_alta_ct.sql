DROP PROCEDURE sfc_contrata_alta_ct;

CREATE PROCEDURE sfc_contrata_alta_ct(
nroClienteNvo	LIKE cliente.numero_cliente,
nroClienteVjo	LIKE cliente.numero_cliente,
nroSolicitud    integer,
nroMensaje      integer
)
RETURNING smallint as codigo, char(100) as descripcion;

DEFINE retCodigo smallint;
DEFINE retDescripcion  char(100);
DEFINE retNroSolicitud  integer;
DEFINE retNroMensaje    integer;
DEFINE retNroOrden      integer;

DEFINE auxCod   smallint;
DEFINE auxDesc  char(50);
DEFINE proc_pend    char(20);
DEFINE sRolOrigen   like rol.rol;
DEFINE sAreaOrigen  like rol.area;
DEFINE nrows        integer;

DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_contrata_alta_ct. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;

    -- Verificar Cliente viejo y procedimientos pendientes
    EXECUTE PROCEDURE sfc_verif_clteviejo(nroClienteVjo) INTO auxCod, auxDesc, proc_pend;
    
    IF auxCod != 0 THEN
        RETURN auxCod, auxDesc;
    END IF; 
    
    -- Rol y Area Origen
    LET nrows=0;
    SELECT s.rol, r.area INTO sRolOrigen, sAreaOrigen 
    FROM cliente c, sucur_centro_op o, sfc_roles s, rol r
    WHERE c.numero_cliente = nroClienteVjo
    AND o.cod_centro_op = c.sucursal 
    AND s.procedimiento = 'INC' 
    AND s.sucursal = o.cod_sucur
    AND r.rol = s.rol;

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'No se encontro Rol/Area Origen.';
	END IF;
    
    -- Mueve Clientes  
    EXECUTE PROCEDURE sfc_mover_clientes(nroClienteVjo, nroClienteNvo, nroSolicitud) INTO auxCod, auxDesc;

    IF auxCod != 0 THEN
        RETURN auxCod, auxDesc;
    END IF; 

    -- Mueve Medidores
    EXECUTE PROCEDURE sfc_mover_medidor(nroClienteVjo, nroClienteNvo, nroSolicitud) INTO auxCod, auxDesc;

    IF auxCod != 0 THEN
        RETURN auxCod, auxDesc;
    END IF; 

    -- Orden CamTit
    EXECUTE PROCEDURE sfc_orden_camtit(nroClienteNvo, nroMensaje, sRolOrigen, sAreaOrigen) INTO auxCod, auxDesc;

    IF auxCod != 0 THEN
        RETURN auxCod, auxDesc;
    END IF; 
    
	RETURN 0, 'OK';

END PROCEDURE;


GRANT EXECUTE ON sfc_contrata_alta_ct TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;


