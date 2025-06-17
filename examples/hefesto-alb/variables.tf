variable "client" {
  description = "Identificador del cliente usado en la nomenclatura de recursos"
  type        = string
  default     = "pragma"
}

variable "project" {
  description = "Identificador del proyecto usado en la nomenclatura de recursos"
  type        = string
  default     = "hefesto"
}

variable "environment" {
  description = "Entorno de despliegue usado en la nomenclatura de recursos"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], lower(var.environment))
    error_message = "El entorno debe ser uno de: dev, qa, pdn (case insensitive)."
  }
}
