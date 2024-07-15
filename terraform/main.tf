module "network" {
  source = "./modules/network"
}

module "nginx" {
  source = "./modules/nginx"
  network_name = module.network.network_name

}

module "application" {
  source = "./modules/application"
  network_name = module.network.network_name
}