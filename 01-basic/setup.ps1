Write-Host "=== SQL Loop Basic - Setup ==="

# Crear virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "Creating virtual environment..."
    python -m venv .venv
}

# Python del entorno virtual
$python = ".\.venv\Scripts\python.exe"

Write-Host "Installing dependencies..."

& $python -m pip install --upgrade pip
& $python -m pip install -r requirements.txt

Write-Host "Registering Jupyter kernel..."

& $python -m ipykernel install `
    --user `
    --name sql-loop-basic `
    --display-name "SQL Loop Basic"

Write-Host ""
Write-Host "Setup completed."
Write-Host "Open notebooks/01_sql_loop_basic.ipynb"
Write-Host "Select kernel: SQL Loop Basic"