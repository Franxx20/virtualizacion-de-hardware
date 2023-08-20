#ejercicio3.sh - APL2 - Ejercicio 3 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

<#
    .SYNOPSIS
    Sistema de integracion continua.

    .DESCRIPTION
    Ejecuta la serie de acciones listadas al detectarse un cambio en el directorio.
    
    Acciones:
	    listar      Muestra por pantalla el nombre de los archivos que sufrieron cambios (Creados, Modificados, Renombrados o Borrados).
	    peso        Muestra por pantalla el peso de los archivos que sufrieron cambios.
	    compilar    Compila todos los archivos del directorio en un archivo y lo guarda en ./bin"
	    publicar    Copia el archivo compilado a la direccion de publicacion especificada con '-salida'.

    .PARAMETER codigo
    Ruta a monitorear, puede ser absoluta, relativa o con espacios.

    .PARAMETER acciones
    Lista de acciones a realizar cuando se detecta un cambio, separadas por coma.

    .PARAMETER salida
    Ruta a publicar archivo compilado, puede ser absoluta, relativa o con espacios.

    .EXAMPLE
    PS> ejercicio3.ps1 -codigo ./ -acciones listar,peso,compilar

    .EXAMPLE
    PS> ejercicio3.ps1 -codigo ./ -acciones listar,peso,compilar,publicar -salida '../a publicar'
#>


Param (
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$codigo,
    [Parameter(Mandatory=$true)][String[]]$acciones,
    [ValidateNotNullOrEmpty()][String]$salida
)


$global:codigo = $codigo
$global:acciones = $acciones | Sort-Object
$global:salida = $salida


if ( $acciones.Contains("publicar") -and -not $acciones.Contains("compilar") ) {
    Write-Host "[Error] - No se puede ejecutar la accion 'publicar' sin incluir la accion 'compilar'." -ForegroundColor Red
    exit 2
}

if ( $acciones.Contains("publicar") -and -not $salida ) {
    Write-Host "[Error] - Se requiere una ruta de publicacion." -ForegroundColor Red
    exit 3
}

if ( -not $acciones.Contains("publicar") -and $salida ) {
    Write-Host "[Warning] - Argumento -s innecesario si no contiene la accion 'publicar'." -ForegroundColor Yellow
}


$user = $env:UserName
$permission = (Get-Acl $codigo).Access | Where-Object {$_.IdentityReference -match $user} | Select-Object IdentityReference,FileSystemRights

if ( -not $permission | Where-Object { ($_.FileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::Read) -eq $_.FileSystemRights } ) {
    Write-Host "[Error] - No tienes permiso de lectura para la dir.: $codigo" -ForegroundColor Red
    exit 4
}


try {
    $codigo = (Get-Item $codigo | Select-Object FullName).FullName
    $monitor = New-Object System.IO.FileSystemWatcher
    $monitor.IncludeSubdirectories = $true
    $monitor.Filter = "*.*"
    $monitor.Path = $codigo
    $monitor.NotifyFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite 

    $evento = {
        $details = $Event.SourceEventArgs
        $type = $details.ChangeType
        $path = $details.FullPath

        if( (Get-Item $path) -is [System.IO.DirectoryInfo] ) {
            return
        }

        foreach ($accion in $acciones) {
            switch ($accion) {
                'listar' {
                    switch ($type) {
                        'Renamed' { 
                            $old_path = $details.OldFullPath
                            Write-Host $type " - from " $old_path " to " $path
                        }
                        Default { Write-Host $type " - " $path }
                    } 
                }

                'peso' {
                    switch ($type) {
                        'Deleted' {}
                        Default { Write-Host (Get-Item $path).Length " bytes" }
                    }
                }

                'compilar' {
                    $global:bin_path = "{0}\bin" -f (Get-Location)
                    New-Item -ItemType Directory -Force -Path $bin_path | Out-Null
                    Get-ChildItem -r -File $codigo | ForEach-Object { Get-Content $_.FullName } | Out-File $bin_path\Compilado.txt
                }

                'publicar' {
                    New-Item -ItemType Directory -Force -Path $salida | Out-Null
                    
                    $user = $env:UserName
                    $permission = (Get-Acl $salida).Access | Where-Object {$_.IdentityReference -match $user} | Select-Object IdentityReference,FileSystemRights

                    if ( -not $permission | Where-Object { ($_.FileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::Read) -eq $_.FileSystemRights } ) {
                        Write-Host "[Error] - No tienes permiso de lectura para la dir.: $salida" -ForegroundColor Red
                        exit 4
                    }

                    Copy-Item $bin_path\Compilado.txt $salida\Publicado.txt
                }
            }
        }
    }

    $handlers = . {
        Register-ObjectEvent -InputObject $monitor -EventName Created -Action $evento
        Register-ObjectEvent -InputObject $monitor -EventName Changed -Action $evento
        Register-ObjectEvent -InputObject $monitor -EventName Renamed -Action $evento
        Register-ObjectEvent -InputObject $monitor -EventName Deleted -Action $evento
    }

    $monitor.EnableRaisingEvents = $true

    do {
        Wait-Event -Timeout 1
    } while ($true)
} finally {
    $monitor.EnableRaisingEvents = $false
    $handlers | ForEach-Object {
        Unregister-Event -SourceIdentifier $_.Name
    }
    $handlers | Remove-Job
    $monitor.Dispose()

    Write-Host "[Script Finalizado]" -ForegroundColor Green
}

#FIN DE ARCHIVO