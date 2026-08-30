#!/bin/bash

AMBIENTE=$1

if [[ -z "$AMBIENTE" ]]; then
  echo "Uso: ./limpiar_datos.sh <local|remoto>"
  exit 1
fi

TABLA="Usuarios"
REGION="us-east-1"

if [[ "$AMBIENTE" == "local" ]]; then
  ENDPOINT="--endpoint-url arn:aws:dynamodb:us-east-1:334935450668:table/Usuarios"
else
  ENDPOINT=""
fi

echo "Consultando registros de $TABLA..."

aws dynamodb scan \
  --table-name "$TABLA" \
  --projection-expression "idUsuario,numero_tarjeta" \
  --region "$REGION" \
  $ENDPOINT \
  --output json > /tmp/usuarios_keys.json

TOTAL=$(jq '.Items | length' /tmp/usuarios_keys.json)

echo "Registros encontrados: $TOTAL"

if [[ "$TOTAL" -eq 0 ]]; then
  echo "La tabla ya está vacía."
  exit 0
fi

INICIO_TIEMPO=$(date +%s)

for ((BASE=0; BASE<TOTAL; BASE+=25))
do

  jq \
    --arg tabla "$TABLA" \
    --argjson inicio "$BASE" \
    '{
      RequestItems: {
        ($tabla): [
          .Items[$inicio:$inicio+25][] |
          {
            DeleteRequest: {
              Key: {
                idUsuario: .idUsuario,
                numero_tarjeta: .numero_tarjeta
              }
            }
          }
        ]
      }
    }' /tmp/usuarios_keys.json > /tmp/delete_batch.json

  aws dynamodb batch-write-item \
    --request-items file:///tmp/delete_batch.json \
    --region "$REGION" \
    $ENDPOINT \
    > /dev/null

  PROCESADOS=$((BASE + 25))

  if (( PROCESADOS > TOTAL )); then
    PROCESADOS=$TOTAL
  fi

  echo "Eliminados $PROCESADOS de $TOTAL"

done

FIN_TIEMPO=$(date +%s)

DURACION=$((FIN_TIEMPO - INICIO_TIEMPO))

rm -f /tmp/usuarios_keys.json
rm -f /tmp/delete_batch.json

echo ""
echo "Limpieza finalizada"
echo "Tiempo total: $DURACION segundos"
