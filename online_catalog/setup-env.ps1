$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$envPairs = @(
  @{ Example = "$root\.env.example"; Target = "$root\.env" },
  @{ Example = "$root\frontend\.env.example"; Target = "$root\frontend\.env" },
  @{ Example = "$root\backend\customer-support\.env.example"; Target = "$root\backend\customer-support\.env" },
  @{ Example = "$root\backend\order-processing\.env.example"; Target = "$root\backend\order-processing\.env" },
  @{ Example = "$root\backend\products-service\.env.example"; Target = "$root\backend\products-service\.env" },
  @{ Example = "$root\backend\customers-orders-service\.env.example"; Target = "$root\backend\customers-orders-service\.env" }
)

foreach ($pair in $envPairs) {
  if (-not (Test-Path $pair.Example)) {
    continue
  }

  if (-not (Test-Path $pair.Target)) {
    Copy-Item $pair.Example $pair.Target
    Write-Host "Created $($pair.Target) from example."
  }
}
