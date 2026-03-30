# Exibe mensagem de início
Write-Host "Iniciando conversão para UTF-8 com BOM e CRLF..." -ForegroundColor Cyan

# Pega o diretório exato onde este script .ps1 está salvo
$diretorioAtual = $PSScriptRoot

# Busca todos os arquivos do Delphi recursivamente a partir da pasta do script
$arquivos = Get-ChildItem -Path $diretorioAtual -Include *.pas, *.dpr, *.dpk -Recurse

foreach ($arq in $arquivos) {
    # Lê o conteúdo original do arquivo
    $conteudo = [System.IO.File]::ReadAllText($arq.FullName)
    
    # Sobrescreve o arquivo forçando o encoding UTF-8 (que no .NET inclui o BOM por padrão)
    [System.IO.File]::WriteAllText($arq.FullName, $conteudo, [System.Text.Encoding]::UTF8)
    
    # Feedback visual no console
    Write-Host "Ajustado: $($arq.Name)" -ForegroundColor Green
}

Write-Host "Todos os arquivos foram verificados e convertidos com sucesso!" -ForegroundColor Cyan