variable "instances" {
  description = "List of instances with their respective user data"
  type        = list(object({
    name      = string
    user_data = string
  }))
}
