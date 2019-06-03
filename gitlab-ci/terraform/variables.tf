variable project {
    description = "Project ID"
}

variable region {
    description = "Region"
    default     = "europe-west1"
}

variable public_key_path {
    description = "Path to the public key used for ssh access"
}

variable private_key_path {
    description = "Path to the private key used for ssh access"
}

variable machine_type {
    description = "Machine type"
}

variable disk_image {
    description = "disk image"
}

variable zone {
    description = "Zone"
    default     = "europe-west1-b"
}


