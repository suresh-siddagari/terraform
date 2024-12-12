variable "resource_group_name" {
  default = "SureshSiddagari_RG_Assign2"
}

variable "location" {
  default = "East Europe"
}

variable "app_service_plan_name" {
  default = "sureshappserviceplan"
}

variable "app_service_name" {
  default = "sureshappservice"
}
variable "backup_name" {
  default = "sureshsiddagaribackup"
}

variable "storage_account_url" {
  default = "https://sureshsiddagaristorage.blob.core.windows.net/sureshsiddagaripublic?sv=2022-11-02&ss=bfqt&srt=c&sp=rwdlacupiytfx&se=2024-12-12T21:54:55Z&st=2024-12-12T13:54:55Z&spr=https&sig=aBGzQAfQjWiFf5cVESzmDdCBSz9M6wr5NxEFtJ6l%2BBI%3D"
}

variable "frequency_interval" {
  default = 30
}
variable "frequency_unit" {
  default = "Day"
}

variable "email" {
  default = "suresh.csea5@gmail.com"
}

