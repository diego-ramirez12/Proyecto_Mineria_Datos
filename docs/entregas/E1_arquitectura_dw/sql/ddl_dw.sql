-- E1 | Arquitectura del Data Warehouse de salud municipal
-- Proyecto BigQuery: proyectomineria-511105
-- Dataset: dw
-- DDL primerizo estructural: NO carga ni transforma datos.
-- Las llaves de BigQuery se declaran NOT ENFORCED.
-- Basado en estrella.qmd y en el DDL ejecutado en BigQuery.


-- 1. DIMENSION FECHA 
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.dim_fecha` (
  fecha_sk INT64 NOT NULL,
  anio INT64 NOT NULL,
  inicio_periodo DATE,
  fin_periodo DATE,
  PRIMARY KEY (fecha_sk) NOT ENFORCED)
OPTIONS (
  description = 'Dimension anual del DW. Responde a P1, P2 y P3.');

-- 2. DIMENSION MUNICIPIO 
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.dim_municipio` (
  municipio_sk INT64 NOT NULL,
  cvegeo STRING,
  clave_entidad STRING,
  nombre_entidad STRING,
  clave_municipio STRING,
  nombre_municipio STRING,
  version_territorial STRING,
  vigencia_desde DATE,
  vigencia_hasta DATE,
  es_actual BOOL,
  PRIMARY KEY (municipio_sk) NOT ENFORCED)
OPTIONS (
  description = 'Dimension geografica municipal. Responde a P1, P2 y P3.');

-- 3. DIMENSION CAUSA
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.dim_causa_diagnostico` (
  causa_diagnostico_sk INT64 NOT NULL,
  categoria_cie10 STRING NOT NULL,
  descripcion_categoria STRING,
  capitulo_cie10 STRING,
  descripcion_capitulo STRING,
  version_catalogo STRING,
  PRIMARY KEY (causa_diagnostico_sk) NOT ENFORCED)
OPTIONS (
  description = 'Dimension de causas de muerte y diagnosticos hospitalarios CIE-10. Responde a P1 y P3.');

-- 4. DIMENSION PERFIL DEMOGRAFICO
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.dim_perfil_demografico` (
  perfil_demografico_sk INT64 NOT NULL,
  sexo STRING,
  codigo_grupo_edad STRING,
  grupo_edad STRING,
  edad_minima INT64,
  edad_maxima INT64,
  PRIMARY KEY (perfil_demografico_sk) NOT ENFORCED)
OPTIONS (
  description = 'Dimension de sexo y grupos de edad quinquenales. Responde a P1, P2 y P3.');

-- 5. DIMENSION TIPO DE EVENTO 
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.dim_tipo_evento` (
  tipo_evento_sk INT64 NOT NULL,
  codigo_tipo STRING NOT NULL,
  nombre_tipo STRING,
  fuente STRING,
  interpretacion_causa STRING,
  PRIMARY KEY (tipo_evento_sk) NOT ENFORCED)
OPTIONS (
  description = 'Dimension que distingue defunciones INEGI y egresos hospitalarios DGIS. Responde a P1 y P3.');

-- 6. HECHOS EVENTOS DE SALUD
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.fact_eventos_salud` (
  evento_salud_sk INT64 NOT NULL,
  fecha_sk INT64 NOT NULL,
  municipio_sk INT64 NOT NULL,
  causa_diagnostico_sk INT64 NOT NULL,
  perfil_demografico_sk INT64 NOT NULL,
  tipo_evento_sk INT64 NOT NULL,
  conteo_eventos INT64 NOT NULL,
  dias_estancia_total INT64,
  egresos_estancia_valida INT64,
  egresos_por_defuncion INT64,
  PRIMARY KEY (evento_salud_sk) NOT ENFORCED,
  FOREIGN KEY (fecha_sk)
    REFERENCES `proyectomineria-511105.dw.dim_fecha`(fecha_sk) NOT ENFORCED,
  FOREIGN KEY (municipio_sk)
    REFERENCES `proyectomineria-511105.dw.dim_municipio`(municipio_sk) NOT ENFORCED,
  FOREIGN KEY (causa_diagnostico_sk)
    REFERENCES `proyectomineria-511105.dw.dim_causa_diagnostico`(causa_diagnostico_sk) NOT ENFORCED,
  FOREIGN KEY (perfil_demografico_sk)
    REFERENCES `proyectomineria-511105.dw.dim_perfil_demografico`(perfil_demografico_sk) NOT ENFORCED,
  FOREIGN KEY (tipo_evento_sk)
    REFERENCES `proyectomineria-511105.dw.dim_tipo_evento`(tipo_evento_sk) NOT ENFORCED)
OPTIONS (
  description = 'Tabla de hechos de defunciones INEGI y egresos DGIS, agregados por municipio, anio, causa, sexo, grupo de edad y tipo de evento.');

-- 7. HECHOS POBLACION
CREATE TABLE IF NOT EXISTS `proyectomineria-511105.dw.fact_poblacion` (
  poblacion_sk INT64 NOT NULL,
  fecha_sk INT64 NOT NULL,
  municipio_sk INT64 NOT NULL,
  perfil_demografico_sk INT64 NOT NULL,
  poblacion_estimada INT64 NOT NULL,
  PRIMARY KEY (poblacion_sk) NOT ENFORCED,
  FOREIGN KEY (fecha_sk)
    REFERENCES `proyectomineria-511105.dw.dim_fecha`(fecha_sk) NOT ENFORCED,
  FOREIGN KEY (municipio_sk)
    REFERENCES `proyectomineria-511105.dw.dim_municipio`(municipio_sk) NOT ENFORCED,
  FOREIGN KEY (perfil_demografico_sk)
    REFERENCES `proyectomineria-511105.dw.dim_perfil_demografico`(perfil_demografico_sk) NOT ENFORCED)
OPTIONS (
  description = 'Tabla de hechos de poblacion estimada a mitad de anio de CONAPO, por municipio, anio, sexo y grupo de edad.');
