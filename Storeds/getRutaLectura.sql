DROP PROCEDURE get_rutalectura;

CREATE PROCEDURE get_rutalectura(
    p_tipo_cliente  char(2),
    p_sucursal      char(4),
    p_partido       char(3),
    p_comuna        char(3),
    p_cod_calle     char(6),
    p_altura        char(5)
)
RETURNING smallint as sector, integer as zona, integer as correlativo_ruta;

DEFINE ret_sector   smallint;
DEFINE ret_zona     integer;
DEFINE ret_correlativo  integer;

DEFINE altura   integer;
DEFINE inicio   integer;
DEFINE fin      integer;
DEFINE nrows    integer;

    LET altura = to_number(nvl(p_altura, 0));
    LET inicio = trunc(altura / 100) * 100;
    LET fin = inicio + 99;

    SELECT FIRST 1 sector, zona, max(correlativo_ruta) + 2
      INTO ret_sector, ret_zona, ret_correlativo
      FROM cliente
     WHERE sucursal = p_sucursal
       AND partido = p_partido
       AND comuna = p_comuna
       AND cod_calle = p_cod_calle
       AND to_number(nvl(nro_dir, 0)) BETWEEN inicio AND fin
       AND estado_cliente = 0
       AND mod(to_number(nvl(nro_dir, 0)), 2) = mod(altura, 2)
     GROUP BY sector, zona;

    RETURN ret_sector, ret_zona, ret_correlativo;

END PROCEDURE;

GRANT EXECUTE ON get_rutalectura TO
superpjp, supersre, supersbl, supersc, corbacho,
guardt1, fuse,
ctousu, batchsyn, procbatc, "UCENTRO", "OVIRTUAL",
pjp, sreyes, sbl, ssalve, gtricoci,
pablop, aarrien, vdiaz, ldvalle, vaz;
