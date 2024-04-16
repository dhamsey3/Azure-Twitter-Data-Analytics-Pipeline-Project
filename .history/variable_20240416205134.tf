variable "snowflake_user" {
  description = "User name for Snowflake"
  type        = string
}

variable "snowflake_password" {
  description = "Password for Snowflake"
  type        = string
}

variable "snowflake_account" {
  description = "Account identifier for Snowflake"
  type        = string
}

variable "azure_subscription_id" {
  description = "Subscription ID for Azure"
  type        = string
}

variable "twitter_api_key" {
  description = "API Key for Twitter"
  type        = string
}

variable "twitter_api_secret_key" {
  description = "API Secret Key for Twitter"
  type        = string
}

variable "twitter_bearer_token" {
  description = "Bearer Token for Twitter"
  type        = string
}
