begin work;
{
create table sfc_interface (
    caso        int,
    nro_orden   int,
    tarifa      char(4),
    tipo_sol    char(15),
    data_in     lvarchar(3000),
    data_out    char(250),
    estado      int,
    descri_estado       char(50),
    fecha_estado        date,
    procedimiento       char(20));

GRANT select ON sfc_interface  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT insert ON sfc_interface  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT delete ON sfc_interface  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT update ON sfc_interface  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;
 }

begin work;

DROP TABLE sfc_clitecmed_data;
 
CREATE TABLE sfc_clitecmed_data (
  trx_proced          char(30) not null,
  numero_cliente      integer  not null,
  dv_numero_cliente   char(1),
  sucursal            char(4),
  nombre              varchar(40),
  nom_calle           varchar(25),
  nro_dir             char(5),
  piso_dir            char(6),
  depto_dir           char(6),
  nom_entre           varchar(25),
  nom_entre1          varchar(25),
  nom_comuna          varchar(25),
  nom_partido         varchar(25),
  nom_provincia       varchar(25),
  telefono            char(9),
  cod_postal          smallint,
  sector              smallint,
  zona                integer,
  correlativo_ruta    integer,
  tipo_empalme        char(4),
  desc_empalme        varchar(50),
  potencia_contrato   float,
  potencia_inst_fp    float,
  obs_dir             varchar(60),
  info_adic_lectura   varchar(24),
  tipo_cliente        char(2),
  tipo_sum            char(2),
  nro_subestacion     varchar(6),
  codigo_voltaje      char(2),
  acometida           char(1),
  tipo_conexion       char(6),
  car_med_princ       char(1),
  numero_medidor      integer, 
  marca_medidor       char(3),
  modelo_medidor      char(2),
  clave_montri        char(1),
  nva_clave_montri    char(1));

CREATE INDEX inx01clidata on sfc_clitecmed_data (trx_proced);

GRANT select ON sfc_clitecmed_data  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT insert ON sfc_clitecmed_data  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT delete ON sfc_clitecmed_data  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT update ON sfc_clitecmed_data  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

commit work;

----------------

create table sfc_roles ()
procedimiento        char(10),
sucursal             integer,
rol                  char(20));

GRANT select ON sfc_roles  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT insert ON sfc_roles  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT delete ON sfc_roles  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;

GRANT update ON sfc_roles  TO
supercal, superfat, supersre, superpjp, supersbl,
supercri, "UCENTRO", batchsyn,pjp, ftejera, sbl,
gtricoci, sreyes, ssalve, pablop, aarrien, vdiaz,
ldvalle, vaz, corbacho, pmf, ctousu, fuse;
 

alter table solicitud add(sfc_caso integer, pod_id integer, sfc_rol char(20));

alter table orden add(sfc_caso integer, sfc_nro_orden integer);

alter table tecni add(pod_id integer);

commit work;
