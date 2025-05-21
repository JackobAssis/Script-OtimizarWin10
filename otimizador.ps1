# Criado por JackobAssis
# Otimizador de Sistema Windows  
# Requer execução como administrador

# Verifica se está sendo executado como administrador

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Execute este script como Administrador." -ForegroundColor Red
    exit
}

Write-Host "Iniciando otimização do sistema..." -ForegroundColor Cyan

# 1. Limpar arquivos temporários e Lixeira

Write-Host "Limpando arquivos temporários e lixeira..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# 2. Desativar programas na inicialização via registro (exemplo básico)

Write-Host "Desativando programas desnecessários na inicialização..."
$startupPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($path in $startupPaths) {
    Get-Item $path | Get-ItemProperty | ForEach-Object {
        $_.PSObject.Properties.Name | ForEach-Object {
            Write-Host "Desativando: $_"
            Remove-ItemProperty -Path $path -Name $_ -ErrorAction SilentlyContinue
        }
    }
}

# 3. Ativar plano de energia de alto desempenho
Write-Host "Ativando plano de energia de alto desempenho..."
powercfg -setactive SCHEME_MIN  # SCHEME_MAX para desktops

# 4. Desabilitar efeitos visuais (ajuste de desempenho visual)
Write-Host "Desabilitando efeitos visuais..."
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" VisualFXSetting 2

# 5. Limpeza de disco (inicial)
Write-Host "Executando limpeza de disco..."
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait

# 6. Desfragmentação de HD (ignora SSD automaticamente)
Write-Host "Otimizando discos..."
Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'} | ForEach-Object {
    defrag $_.DriveLetter -f
}

# 7. Atualizações do Windows
Write-Host "Forçando verificação de atualizações do Windows..."
UsoClient StartScan  # Windows 10
# (Opcional: use `Install-WindowsUpdate` do módulo PSWindowsUpdate)

# 8. Limpeza de drivers antigos (WinSxS)
Write-Host "Limpando drivers e componentes antigos..."
Dism.exe /Online /Cleanup-Image /StartComponentCleanup

# 9. Finalizando
Write-Host "Otimização concluída. Recomenda-se reiniciar o sistema." -ForegroundColor Green
Pause
