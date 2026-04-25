param(
  [Parameter(Mandatory = $false)]
  [string]$DockerHubUsername = "ayaankhan17",

  [Parameter(Mandatory = $false)]
  [string]$Tag = "latest"
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$images = @(
  @{ Name = "catalog-management"; Context = "$root\backend\catalog-management" },
  @{ Name = "customer-support"; Context = "$root\backend\customer-support" },
  @{ Name = "order-processing"; Context = "$root\backend\order-processing" },
  @{ Name = "frontend"; Context = "$root\frontend" }
)

Write-Host "Building and pushing images for user: $DockerHubUsername with tag: $Tag"

foreach ($image in $images) {
  $fullImage = "$DockerHubUsername/$($image.Name):$Tag"

  Write-Host ""
  Write-Host "[BUILD] $fullImage"
  docker build -t $fullImage $image.Context

  Write-Host "[PUSH]  $fullImage"
  docker push $fullImage
}

Write-Host ""
Write-Host "Done. All images were pushed to Docker Hub."
