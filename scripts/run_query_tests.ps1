Param(
    [string]$Dsn = $env:DATABASE_URL,
    [string]$SpecPath = "tests/query_test_specs.json",
    [switch]$ContinueOnError
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $Dsn) {
    throw "DATABASE_URL is not set. Pass -Dsn or set `$env:DATABASE_URL first."
}

Write-Host "[1/2] Generating query test specs..."
python scripts/generate_query_test_specs.py --out $SpecPath

Write-Host "[2/2] Running query tests..."
$args = @(
    "scripts/run_query_tests.py",
    "--spec", $SpecPath,
    "--dsn", $Dsn
)

if ($ContinueOnError) {
    $args += "--continue-on-error"
}

python @args
