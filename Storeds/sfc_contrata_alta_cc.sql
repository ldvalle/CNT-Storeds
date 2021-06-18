DROP PROCEDURE sfc_contrata_alta_cc;

CREATE PROCEDURE sfc_contrata_alta_cc(
nroClienteNvo	LIKE cliente.numero_cliente,
nroSolicitud    integer,
nroMensaje      integer
)
RETURNING smallint as codigo, char(100) as descripcion;

DEFINE dv_nvo_cliente       CHAR(1);
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        RETURN 1, 'sfc_contrata_alta_cc. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;

    EXECUTE PROCEDURE sfc_get_dvcliente(nroClienteNvo) INTO dv_nvo_cliente;
    
    INSERT INTO cliente (
    numero_cliente,
    dv_numero_cliente,
    dv_ruta_lectura,
    nombre,
    corr_facturacion,
    cant_estimac_suces,
    cant_estimaciones,
    cod_calle,
    nom_calle,
    nro_dir,
    piso_dir,
    depto_dir,
    cod_postal,
    telefono,
    barrio,
    nom_barrio,
    cod_entre,
    nom_entre,
    cod_entre1,
    nom_entre1,
    tiene_calma,
    tiene_cambios_rest,
    ind_ret_medidor,
    tipo_fpago,
    coseno_phi,
    valor_anticipo,
    sector,
    sucursal,
    nom_sucursal,
    partido,
    nom_partido,
    tipo_vencimiento,
    estado_suministro,
    comuna,
    nom_comuna,
    provincia,
    nom_provincia,
    zona,
    tiene_caduc_manual,
    tipo_cliente,
    tarifa,
    tipo_iva,
    rut,
    tipo_reparto,
    tipo_sum,
    estado_cliente,
    tip_doc,
    nro_doc )
    SELECT 
    nroClienteNvo,
    dv_nvo_cliente,    
    ' ', --dv_ruta_lectura
    trim(s.nombre),
    0, --corr_facturacion
    0, --cant est susec
    0, --cant estimaciones
    s.cod_calle,
    trim(s.nom_calle),
    s.nro_dir,
    s.piso_dir,
    s.depto_dir,
    s.cod_postal,
    s.telefono,
    s.barrio,
    s.nom_barrio,
    s.cod_entre,
    s.nom_entre,
    s.cod_entre1,
    s.nom_entre1,
    ' ', --tiene_calma
    'N', --tiene_cambios_rest
    ' ', --ind_ret_medidor
    'N', --tipo_fpago
    100, --coseno_phi
    0,   --valor anticipo
    s.plan,
    s.sucursal,
    s.nom_sucursal,
    s.partido,
    s.nom_partido,
    s.tipo_venc,
    '1', --estado suministro
    s.localidad,
    s.nom_localidad,
    s.provincia,
    s.nom_provincia,
    '99999', -- zona
    ' ',  -- tiene caduc manual
    s.tipo_cliente,
    s.tarifa,
    s.tipo_iva,
    s.nro_cuit,
    s.tipo_sum,
    0,  -- estado cliente
    s.tip_doc,
    s.nro_doc
    FROM solicitud s
    WHERE s.nro_solicitud = nroSolicitud;
    
	RETURN 0, 'OK';

END PROCEDURE;


GRANT EXECUTE ON sfc_contrata_alta_cc TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
