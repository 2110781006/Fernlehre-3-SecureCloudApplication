module "weatherApp-1" {
  source = "./modules/weatherApp"
  name = "weatherApp-1"
  weatherstackToken = "${var.weatherstackToken}"
  gitHubToken = "${var.gitHubToken}"
  githubUser = "${var.githubUser}"
  githubClientId = "${var.githubClientId}"
  githubClientSecret = "${var.githubClientSecret}"
}

output "weatherApp-1-url" {
  #value = "${module.weatherApp-1.url}"
  value = "neue url zu finden auf https://github.com/2110781006/fsuWeatherRestApi/issues diese muss auch auf github eingetragen werden"
}


