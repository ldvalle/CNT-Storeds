DROP PROCEDURE sfc_tabmotivos;

CREATE PROCEDURE sfc_tabmotivos(
    cod_motivo      like tabla.codigo,
    nom_tabla       like tabla.nomtabla,
    tipo_cliente    smallint
)
RETURNING smallint as codRetorno, char(50) as descripcion, char(1) as gen_ot;

DEFINE retCodigo smallint;
DEFINE retDesc   char(50);
DEFINE retOT     char(50);

DEFINE nrows    int;

    IF TRIM(nom_tabla) = 'OTMORE' THEN    
    
      SELECT descripcion, valor_alf[1,1] 
        INTO retDesc, retOT
      FROM tabla
      WHERE nomtabla = 'OTMORE'
      AND codigo = cod_motivo
      AND valor_alf [ 2, 2 ] = to_char(tipo_cliente)
      AND sucursal = '0000'
      AND fecha_activacion <= TODAY
      AND (fecha_desactivac > TODAY OR fecha_desactivac IS NULL);

    ELIF TRIM(nom_tabla) = 'OTMOMA' THEN
      SELECT  descripcion, valor_alf
        INTO retDesc, retOT      
      FROM tabla 
      WHERE nomtabla = 'OTMOMA'
      AND codigo = cod_motivo 
      AND sucursal = '0000'
      AND fecha_activacion <= TODAY 
      AND (fecha_desactivac IS NULL OR fecha_desactivac > TODAY); 
    
    END IF;
    
    LET nrows = DBINFO('sqlca.sqlerrd2');
    IF nrows = 0 THEN
        RETURN 1, 'Motivo Inexistente', null;
    END IF;
    
    
    RETURN 0, retDesc, retOT;

END PROCEDURE;

GRANT EXECUTE ON sfc_tabmotivos TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
