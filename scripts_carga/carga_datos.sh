#!/bin/bash

CANTIDAD=$1
AMBIENTE=$2

if [[ -z "$CANTIDAD" || -z "$AMBIENTE" ]]; then
  echo "Uso: ./cargar_datos.sh <cantidad> <local|remoto>"
  exit 1
fi

TABLA="Usuarios"
REGION="us-east-1"

if [[ "$AMBIENTE" == "local" ]]; then
  ENDPOINT="--endpoint-url arn:aws:dynamodb:us-east-1:334935450668:table/Usuarios"
else
  ENDPOINT=""
fi

echo "Iniciando carga de $CANTIDAD registros en $AMBIENTE..."

INICIO=$(date +%s)

for ((BASE=1; BASE<=CANTIDAD; BASE+=25))
do

  FIN=$((BASE + 24))

  if (( FIN > CANTIDAD )); then
    FIN=$CANTIDAD
  fi

  REQUEST_FILE=$(mktemp)

  echo '{"Usuarios": [' > "$REQUEST_FILE"

  PRIMERO=true

  for ((i=BASE; i<=FIN; i++))
  do
    ID_USUARIO=$(printf "USR%08d" "$i")
    NUMERO_TARJETA=$(printf "100000%08d" "$i")

    if [[ "$PRIMERO" == false ]]; then
      echo "," >> "$REQUEST_FILE"
    fi

    PRIMERO=false

    cat >> "$REQUEST_FILE" <<EOF
{
  "PutRequest": {
    "Item": {
      "idUsuario": {
        "S": "$ID_USUARIO"
      },
      "numero_tarjeta": {
        "S": "$NUMERO_TARJETA"
      },
      "nombre": {
        "S": "Usuario$i"
      },
      "apellido": {
        "S": "Apellido$i"
      },
      "direccion": {
        "S": "Direccion $i"
      },
      "estado": {
        "S": "ACTIVO"
      },
      "poblacion": {
        "S": "GENERAL"
      }
    }
  }
}
EOF

  done

  echo ']}' >> "$REQUEST_FILE"

  aws dynamodb batch-write-item \
    --request-items "file://$REQUEST_FILE" \
    --region "$REGION" \
    $ENDPOINT \
    > /dev/null

  rm "$REQUEST_FILE"

  echo "Cargados $FIN de $CANTIDAD registros"

done

FIN_TIEMPO=$(date +%s)

DURACION=$((FIN_TIEMPO - INICIO))

echo ""
echo "Carga finalizada"
echo "Registros: $CANTIDAD"
echo "Tiempo total: $DURACION segundos"
