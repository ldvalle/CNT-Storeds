DROP PROCEDURE sfc_cambio_cond_contra;

CREATE PROCEDURE sfc_cambio_cond_contra(
nroCliente      LIKE cliente.numero_cliente,
sValorTension   LIKE tecni.codigo_voltaje,
sTipoCliente    LIKE cliente.tipo_cliente,
sTarifa         LIKE cliente.tarifa,
sPotencia       LIKE cliente.potencia_cont_hp,
sActEco         LIKE cliente.actividad_economic
)
RETURNING smallint as codigo, char(100) as descripcion;

DEFINE miValorTension   like tecni.codigo_voltaje;
DEFINE miTipoCliente    like cliente.tipo_cliente;
DEFINE miTarifa         like cliente.tarifa;
DEFINE miPotencia       like cliente.potencia_inst_hp;
DEFINE miActeco         like cliente.actividad_economic;
DEFINE nrows            integer;
DEFINE sCodigoMod       like modif.codigo_modif;
DEFINE sValAnterior     char(55);
DEFINE sValNuevo        char(55);
DEFINE codRetorno	    integer;
DEFINE descRetorno      char(100);

DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           CHAR(100);

    ON EXCEPTION SET sql_err, isam_err, error_info
        IF sql_err = -107 OR sql_err = -144 OR sql_err = -113 THEN
            RETURN 1, 'sfc_cambio_cond_contra. Lockeo de tablas. Reintente mas tarde';
        END IF;
        RETURN 1, 'sfc_cambio_cond_contra. sqlErr '  || to_char(sql_err) || ' isamErr ' || to_char(isam_err) || ' ' || error_info;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 10;
    
    SELECT c.tipo_cliente, c.tarifa, c.potencia_cont_hp, t.codigo_voltaje, c.actividad_economic
    INTO miTipoCliente, miTarifa, miPotencia, miValorTension, miActeco
    FROM cliente c, OUTER tecni t
    WHERE c.numero_cliente = nroCliente
    AND t.numero_cliente = c.numero_cliente;

	LET nrows = DBINFO('sqlca.sqlerrd2');
	IF nrows = 0 THEN
		RETURN 1, 'Cliente no existe en MAC.';
	END IF;
    
    IF sPotencia != miPotencia THEN
        LET sCodigoMod = '33';
        LET sValAnterior = to_char(miPotencia);
        LET sValNuevo = to_char(sPotencia);
        
        UPDATE cliente SET
        potencia_inst_hp = sPotencia
        WHERE numero_cliente = nroCliente;
        
    ELIF trim(sTipoCliente) != trim(miTipoCliente) THEN
        LET sCodigoMod = '21';
        LET sValAnterior = trim(miTipoCliente);
        LET sValNuevo = trim(sTipoCliente);

        UPDATE cliente SET
        tipo_cliente = trim(sTipoCliente)
        WHERE numero_cliente = nroCliente;
        
    ELIF trim(sValorTension) != trim(miValorTension) THEN
        LET sCodigoMod = '201';
        LET sValAnterior = trim(miValorTension);
        LET sValNuevo = trim(sValorTension);

        UPDATE tecni SET
        codigo_voltaje = trim(sValorTension)
        WHERE numero_cliente = nroCliente;
        
    ELIF trim(sTarifa) != trim(miTarifa) THEN
        LET sCodigoMod = '16';
        LET sValAnterior = trim(miTarifa);
        LET sValNuevo = trim(sTarifa);

        UPDATE cliente SET
        tarifa = trim(sTarifa)
        WHERE numero_cliente = nroCliente;

    ELIF trim(sActEco) != trim(miActeco) THEN
        LET sCodigoMod = '18';
        LET sValAnterior = trim(miActeco);
        LET sValNuevo = trim(sActEco);

        UPDATE cliente SET
        actividad_economic = trim(sActeco)
        WHERE numero_cliente = nroCliente;
        
    ELSE
        RETURN 0, 'Sin Cambios'; 
    END IF;
    
	EXECUTE PROCEDURE salt_graba_modif(nroCliente, sCodigoMod, 'SALESFORCE', 'CNT-CCC', sValAnterior, sValNuevo)
		INTO codRetorno, descRetorno;
    
    IF codRetorno != 0 THEN
        RETURN codRetorno, descRetorno;
    END IF;
    
	RETURN 0, 'OK';

END PROCEDURE;


GRANT EXECUTE ON sfc_cambio_cond_contra TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
