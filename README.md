# Arquitectura II -- Taller 3

Implementación del taller de **persistencia NoSQL para el Sistema
Integrado de Transporte Público (SITP)** utilizando **Amazon DynamoDB**.

El proyecto contiene la infraestructura como código necesaria para
desplegar las tablas DynamoDB en AWS, scripts para la generación y carga
parametrizada de datos y pruebas de performance de lectura y escritura
utilizando **k6**.

## Objetivo

Diseñar e implementar una solución de persistencia NoSQL para soportar
los patrones de acceso definidos para usuarios, tarjetas, poblaciones,
listas blancas y negras, estaciones y buses del SITP.

La implementación permite:

-   Desplegar las estructuras DynamoDB mediante Terraform.
-   Consultar usuarios por identificador y número de tarjeta.
-   Consultar las tarjetas asociadas a un usuario.
-   Consultar población asociada.
-   Consultar tarjetas en lista negra y lista blanca.
-   Consultar estaciones y buses.
-   Generar y cargar volúmenes parametrizados de información.
-   Ejecutar pruebas de performance de lectura y escritura.

## Estructura del repositorio

``` text
arqui2_taller3/
├── terraform/
│   ├── cloudwatch.tf
│   ├── dynamodb.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
├── scripts_carga/
│   ├── borrar_tablas.sh
│   └── carga_datos.sh
├── performance/
│   ├── lectura.js
│   └── escritura.js
└── .gitignore
```

## Modelo de persistencia

La solución utiliza las siguientes tablas DynamoDB:

  ----------------------------------------------------------------------------
  Tabla             Partition Key        Sort Key           Índice secundario
  ----------------- -------------------- ------------------ ------------------
  `Usuarios`        `idUsuario`          `numero_tarjeta`   GSI por
                                                            `numero_tarjeta`

  `Poblaciones`     `nombre_poblacion`   No aplica          No aplica

  `Listas`          `nombre_lista`       `numero_tarjeta`   No aplica

  `Estaciones`      `id_estacion`        No aplica          No aplica

  `Buses`           `id_bus`             No aplica          No aplica
  ----------------------------------------------------------------------------

### Tabla Usuarios

Atributos utilizados:

-   `idUsuario`
-   `numero_tarjeta`
-   `nombre`
-   `apellido`
-   `direccion`
-   `estado`
-   `poblacion`

La clave primaria está compuesta por:

``` text
PK = idUsuario
SK = numero_tarjeta
```

La tabla incluye el índice:

``` text
GSI1-numero-tarjeta
PK = numero_tarjeta
Projection = ALL
```

Este índice permite consultar la información del usuario cuando
únicamente se conoce el número de tarjeta.

### Tabla Poblaciones

``` text
PK = nombre_poblacion
```

Atributos:

-   `nombre_poblacion`
-   `es_subsidiada`
-   `porcentaje_subsidio`

### Tabla Listas

``` text
PK = nombre_lista
SK = numero_tarjeta
```

Atributos:

-   `nombre_lista`
-   `numero_tarjeta`
-   `idUsuario`
-   `motivo`
-   `estado`
-   `fecha_ingreso_lista`

La estructura soporta tanto listas negras como listas blancas.

### Tabla Estaciones

``` text
PK = id_estacion
```

Atributos:

-   `id_estacion`
-   `nombre`
-   `estado`
-   `ubicacion`

### Tabla Buses

``` text
PK = id_bus
```

Atributos:

-   `id_bus`
-   `nomenclatura`
-   `placa`
-   `fecha_inicio_operacion`
-   `estado`

## Patrones de acceso

  --------------------------------------------------------------------------
  Patrón            Operación         Tabla             Mecanismo
  ----------------- ----------------- ----------------- --------------------
  AP01              Consultar usuario Usuarios          PK `idUsuario`
                    por identificador                   

  AP02              Consultar usuario Usuarios          GSI `numero_tarjeta`
                    por número de                       
                    tarjeta                             

  AP03              Obtener tarjetas  Usuarios          PK `idUsuario`
                    asociadas a un                      
                    usuario                             

  AP04              Consultar         Poblaciones       PK
                    población                           `nombre_poblacion`
                    asociada                            

  AP05              Consultar tarjeta Listas            PK `nombre_lista` +
                    en lista negra                      SK `numero_tarjeta`

  AP06              Consultar tarjeta Listas            PK `nombre_lista` +
                    en lista blanca                     SK `numero_tarjeta`

  AP07              Consultar         Estaciones        PK `id_estacion`
                    estación                            

  AP08              Consultar bus     Buses             PK `id_bus`
  --------------------------------------------------------------------------

## Infraestructura con Terraform

La infraestructura del proyecto se encuentra en `terraform/`.

### Requisitos

-   Terraform
-   AWS CLI
-   Credenciales AWS configuradas
-   Acceso a Amazon DynamoDB
-   k6 para las pruebas de performance

### Configuración AWS

Las credenciales deben configurarse mediante variables de entorno o
mediante la configuración estándar de AWS CLI.

Ejemplo con credenciales temporales:

``` bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
export AWS_REGION="us-east-1"
```

**No almacenar credenciales AWS dentro del repositorio.**

### Inicializar Terraform

``` bash
cd terraform
terraform init
```

### Validar

``` bash
terraform validate
```

### Revisar el plan

``` bash
terraform plan
```

### Desplegar

``` bash
terraform apply
```

Confirmar la ejecución cuando Terraform lo solicite.

### Verificar las tablas

``` bash
aws dynamodb list-tables \
  --region us-east-1
```

Para verificar la tabla `Usuarios`:

``` bash
aws dynamodb describe-table \
  --table-name Usuarios \
  --region us-east-1
```

## Generación y carga de datos

Los scripts se encuentran en:

``` text
scripts_carga/
```

El script de carga permite parametrizar la cantidad de registros y el
ambiente de ejecución.

Los dos volúmenes utilizados en las pruebas son:

``` text
15.000 registros
30.000 registros
```

Ejemplo de carga:

``` bash
chmod +x scripts_carga/carga_datos.sh

./scripts_carga/carga_datos.sh 15000 remote
```

Segundo escenario:

``` bash
./scripts_carga/carga_datos.sh 30000 remote
```

### Validar cantidad de registros

``` bash
aws dynamodb scan \
  --table-name Usuarios \
  --select COUNT \
  --region us-east-1
```

## Pruebas de performance con k6

Los scripts de performance se encuentran en:

``` text
performance/
├── lectura.js
└── escritura.js
```

Las pruebas realizan operaciones de lectura y escritura sobre DynamoDB
utilizando las credenciales AWS configuradas en el ambiente.

### Prueba de lectura

Para el escenario de 15.000 registros:

``` bash
cd performance

DATASET_SIZE=15000 \
AWS_REGION=us-east-1 \
k6 run lectura.js
```

Para el escenario de 30.000 registros:

``` bash
DATASET_SIZE=30000 \
AWS_REGION=us-east-1 \
k6 run lectura.js
```

### Prueba de escritura

``` bash
AWS_REGION=us-east-1 \
k6 run escritura.js
```

Las pruebas permiten observar, entre otras, las siguientes métricas:

-   Latencia promedio.
-   Percentil 95 (`p95`).
-   Percentil 99 (`p99`).
-   Requests por segundo.
-   Porcentaje de errores.
-   Cantidad total de operaciones.

## Flujo de ejecución

``` text
Terraform
   │
   ▼
Creación de tablas DynamoDB
   │
   ▼
Carga de 15.000 registros
   │
   ├──► Prueba k6 lectura
   └──► Prueba k6 escritura
   │
   ▼
Limpieza
   │
   ▼
Carga de 30.000 registros
   │
   ├──► Prueba k6 lectura
   └──► Prueba k6 escritura
   │
   ▼
Análisis de resultados
```

## Monitoreo

La infraestructura incluye configuración de CloudWatch para observar el
comportamiento de DynamoDB durante las pruebas.

Las métricas permiten complementar los resultados obtenidos desde k6 con
la información registrada por AWS durante las operaciones de lectura y
escritura.

## Eliminación de recursos

Una vez finalizadas las pruebas y la revisión del proyecto, los recursos
administrados mediante Terraform pueden eliminarse con:

``` bash
cd terraform
terraform destroy
```

Revisar los recursos que serán eliminados antes de confirmar la
operación.

## Seguridad

No deben versionarse:

``` text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
.env
AWS Access Keys
AWS Secret Access Keys
AWS Session Tokens
```

El archivo `.terraform.lock.hcl` sí debe mantenerse versionado para
conservar las versiones seleccionadas de los providers.

## Tecnologías utilizadas

-   Amazon DynamoDB
-   Amazon CloudWatch
-   Terraform
-   AWS CLI
-   k6
-   Bash

## Repositorio

Proyecto académico correspondiente al Taller 3 de Arquitectura II.
