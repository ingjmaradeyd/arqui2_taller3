resource "aws_dynamodb_table" "usuarios" {
  name         = "Usuarios"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "idUsuario"
  range_key = "numero_tarjeta"

  attribute {
    name = "idUsuario"
    type = "S"
  }

  attribute {
    name = "numero_tarjeta"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1-numero-tarjeta"
    projection_type = "ALL"

    key_schema {
      attribute_name = "numero_tarjeta"
      key_type       = "HASH"
    }
  }

  tags = {
    Proyecto = "SITP"
    Ambiente = var.environment
  }
}


resource "aws_dynamodb_table" "poblaciones" {
  name         = "Poblaciones"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "nombre_poblacion"

  attribute {
    name = "nombre_poblacion"
    type = "S"
  }

  tags = {
    Proyecto = "SITP"
    Ambiente = var.environment
  }
}


resource "aws_dynamodb_table" "listas" {
  name         = "Listas"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "nombre_lista"
  range_key = "numero_tarjeta"

  attribute {
    name = "nombre_lista"
    type = "S"
  }

  attribute {
    name = "numero_tarjeta"
    type = "S"
  }

  tags = {
    Proyecto = "SITP"
    Ambiente = var.environment
  }
}


resource "aws_dynamodb_table" "estaciones" {
  name         = "Estaciones"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id_estacion"

  attribute {
    name = "id_estacion"
    type = "S"
  }

  tags = {
    Proyecto = "SITP"
    Ambiente = var.environment
  }
}


resource "aws_dynamodb_table" "buses" {
  name         = "Buses"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id_bus"

  attribute {
    name = "id_bus"
    type = "S"
  }

  tags = {
    Proyecto = "SITP"
    Ambiente = var.environment
  }
}
