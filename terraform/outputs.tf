output "dynamodb_tables" {
  description = "Tablas DynamoDB creadas"

  value = [
    aws_dynamodb_table.usuarios.name,
    aws_dynamodb_table.poblaciones.name,
    aws_dynamodb_table.listas.name,
    aws_dynamodb_table.estaciones.name,
    aws_dynamodb_table.buses.name
  ]
}

output "usuarios_gsi" {
  description = "Índice secundario global utilizado para consultar por número de tarjeta"
  value       = "GSI1-numero-tarjeta"
}
