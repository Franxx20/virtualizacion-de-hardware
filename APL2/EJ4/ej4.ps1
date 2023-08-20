#ejercicio4.sh - APL2 - Ejercicio 4 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

<#
    .SYNOPSIS
    Contador de lineas de codigo y de comentarios.

    .DESCRIPTION
    Cuenta la cantidad de lineas de codigo y de comentarios de todos los archivos en un directorio recursivamente.

    .PARAMETER ruta
    Ruta a monitorear, puede ser absoluta, relativa o con espacios.

    .PARAMETER ext
    Lista de extensiones a analizar, separadas por coma.

    .EXAMPLE
    PS> ejercicio4.ps1 -ruta ./ -ext java,c

#>


Param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$ruta,
    [Parameter(Mandatory=$true)][String[]]$ext
)


$user = $env:UserName
$permission = (Get-Acl $ruta).Access | Where-Object {$_.IdentityReference -match $user} | Select-Object IdentityReference,FileSystemRights

if ( -not $permission | Where-Object { ($_.FileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::Read) -eq $_.FileSystemRights } ) {
    Write-Host "[Error] - No tienes permiso de lectura para la dir.: $ruta" -ForegroundColor Red
    exit 4
}


$total_archivos = 0
$total_codigo = 0
$prc_codigo = 0.0
$total_coment = 0
$prc_coment = 0.0


foreach ($extension in $ext) {
    $files = @()
    Get-ChildItem -r -File -Filter "*.$extension" $ruta | ForEach-Object { $files += ($_.FullName) }
    $total_archivos += $files.Count

    foreach ($file in $files) {
        $coment = 0 ; $codigo = 0 ; $bloque = 0
        Get-Content $file | ForEach-Object `
        {   
            $line = $_.Trim()
            if ( $line.Length -gt 0  -and $bloque -ne 1 -and $line -notmatch '^\/\/' -and $line -notmatch '^\/\*' ) { $codigo++ }
            if ( $line -match '\/\*' ) { $bloque = 1 }
            if ( $line -match '\/\/' -or $bloque -eq 1 ) { $coment++ }
            if ( $line -match '\*\/' ) { $bloque = 0 }
            if ( $line -match '^\*\/.') { $codigo++ }
        }

        $total_codigo += $codigo
        $total_coment += $coment
    }
}


$total_lineas = $total_codigo + $total_coment
if ($total_lineas -gt 0) {
    $prc_codigo = [math]::round($total_codigo * 100.0 / $total_lineas, 2)
    $prc_coment = [math]::round($total_coment * 100.0 / $total_lineas, 2)
}


Write-Host "Total archivos: $total_archivos"
Write-Host "Total codigo: $total_codigo - %$prc_codigo"
Write-Host "Total comentarios: $total_coment - %$prc_coment"

#FIN DE ARCHIVO