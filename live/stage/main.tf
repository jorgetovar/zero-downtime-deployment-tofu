module "zdd_application" {
  source = "../../modules/web-cluster"
  ami    = "sample-app-packer-e6ea32a4-c9b4-45d6-9b19-639e451b9418"
  cluster_name = "aws-builders-zdd"
}