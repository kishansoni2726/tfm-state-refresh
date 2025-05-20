output "EIP" {
    value = aws_eip.nat_eip.address
}

# output "db_endpoint" {
#     value = aws_db_instance.postgres.endpoint
# }

# output "secret_arn" {
#   value = aws_secretsmanager_secret.database_secret.arn
# }

