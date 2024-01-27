variable "credentials_file" {
    description = "Path to GCP Credentials File"
    default = "C:/Main Storage/Documents/data-engineering-zoomcamp-2024/01_docker_and_terraform/01_terraform/keys/my-creds.json"
}

variable "project" {
    description = "Project ID"
    default = "dtc-de-course-412401"

}

variable "region" {
    description = "Project Region"
    default = "us-central1"
}

variable "gcs_bucket_name" {
    description = "Name of GCS Storage Bucket"
    default = "terraform-bucket-dtc-de-course-412401"
}

variable "location" {
    description = "Project location"
    default = "US"
}

variable "gcs_dataset_id" {
    description = "BigQuery Dataset ID"
    default = "demo_dataset"
}