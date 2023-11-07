#!/bin/pwsh
#################################################################################################
#   Nombre del script: ej1.sh
#   N° APL: 1
#   N° ejercicio: 1
#   N° Entrega: 1
#
#   Integrantes:
#       Cristian Raúl Berrios
#       Pablo Martín Ferreira
#       Franco Javier Garcete
#       Carolina Nuñez
#       Thiago Polito
#################################################################################################

<#
.SYNOPSIS
    Es un script que se usa para obtener información del funcionamiento de una estacion petrolera

.DESCRIPTION
    Es un que analiza los registros de UsoMotor1, UsoMotor2 y Temperatura para obtener:
    • el maximo de porcentaje de uso del Motor 1
    • el maximo de porcentaje de uso de motor 2
    • el promedio de la temperatura.

.PARAMETER entrada
    parametro que indica el archivo a analizar

.PARAMETER archivo
    parametro que indica que la salida va a ser por archivo(opcional)

.PARAMETER salida
    parametro que indica la ruta del archivo de salida. Solo puede estar presente si se usa el parametro -archivo

#>
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "sinSalida",Position=1)]
    [Parameter(Mandatory = $true, ParameterSetName = "salida",Position=1)]
    [string]$entrada,
    [Parameter(Mandatory = $true, ParameterSetName = "salida")][Switch] $archivo,
    [Parameter(Mandatory = $true, ParameterSetName = "salida")][string]$salida
)

[int]$global:motor1MasCaliente = [int]::MinValue
[int]$global:motor2MasCaliente = [int]::MinValue
[float]$global:promedio = 0


function procesar-csv {
    param (
        [Parameter(Mandatory = $True)][PSCustomObject]$archivoCSV
    )


    [int]$totalTemperatura = 0
    [int]$cantRegistros = 0

    $global:motor1MasCaliente = $archivoCSV[0].UsoMotor1
    $global:motor2MasCaliente = $archivoCSV[0].UsoMotor2

    $archivoCSV | ForEach-Object {

        ## CHECKEO QUE EL FORMATO DE HORA SEA EL CORRECTO
        try {
            $hora = [datetime]::ParseExact($_.Horario, 'HH:mm', $null) 
        }
        catch {
            Write-Error "el formato de hora es incorrecto hora" -ErrorAction Stop
        }

        if([int]$_.temperatura -gt 0)
        {
        $totalTemperatura += [int]$_.Temperatura
        $cantRegistros += 1
        }
        else {
            Write-Error "la temperatura no puede ser negativa" -ErrorAction Stop
        }


        if ($_.UsoMotor1 -le 100 && $_.UsoMotor1 -ge 0) {
            if ($_.UsoMotor1 -ge $global:motor1MasCaliente) {
                $global:motor1MasCaliente = $_.UsoMotor1
            }
        }
        else {
            Write-Error "rango de temperatura invalido motor 1[0 ... 100] temp "$_.UsoMotor1"" -ErrorAction Stop
        }

        if ($_.UsoMotor2 -le 100 && $_.UsoMotor2 -ge 0) {
            if ($_.UsoMotor2 -ge $global:motor2MasCaliente) {
                $global:motor2MasCaliente = $_.UsoMotor2
            }
        }
        else {
            Write-Error "rango de temperatura invalido motor 1[0 ... 100] temp "$_.UsoMotor2"" -ErrorAction Stop
        }

        $global:promedio = ($totalTemperatura / $cantRegistros) 

    }
    
}

## ACA ARRANCO CON EL SCRIPT

## PREGUNTO SI EL ARCHIVO DE ENTRADA ES VALIDO
if (-not (Test-Path -Path $entrada )) {
    Write-Error "La ruta al archivo de entrada es invalido. ruta al archivo de entrada ingresado: $entrada" -ErrorAction Stop
}


## PREGUNTO SI EL ARCHIVO DE ENTRADA ESTA VACIO
if ([string]::IsNullOrWhiteSpace((Get-Content $entrada))) {
    # Read-Host "ingrese una ruta de archivo de entrada"
    Write-Error "el archivo de entrada esta vacio!. Ruta al archivo de entrada ingresado: $entrada"  -ErrorAction Stop
}

## IMPORTO LOS DATOS DEL CSV A UN OBJETO
$archivoCSV = Import-Csv -Path $entrada
## FUNCION QUE PROCESA EL OBJETO Y OBTENGO LOS DATOS NECESARIOS DEL EJERCICIO
procesar-csv $archivoCSV



## SI ESTA EL SWITCH ARCHIVO QUE ME OBLIGA A ENVIAR LOS DATOS A UN ARCHIVO
if ($archivo) {
    ## PREGUNTO QUE LA RUTA DE SALIDA SEA UNA RUTA POSIBLE VALIDA
    if (Test-Path -Path $salida -IsValid) {
        ## para que cree una nuevo archivo con sus respectivas carpetas y el casteo es para que no me printee en pantalla el resutlado
        [void](New-Item -Path $salida -ItemType File -Force )
        Write-Output "Motor1=$motor1MasCaliente" | Out-File $salida -Append
        Write-Output "Motor2=$motor2MasCaliente" | Out-File $salida -Append
        Write-Output "Temperatura=$promedio" | Out-File $salida -Append
    }
    else { 
        Write-Error "la ruta de salida es invalida. La ruta ingresada fue: $salida" -ErrorAction Stop
    }

    exit 0 
}


## SI SOLO PASE LA RUTA DE ENTRADA ENTONCES IMPRIMO EN PANTALLA
Write-Output "promedio final $global:promedio"
Write-Output "Mayor Temperatura motor1 $global:motor1MasCaliente"
Write-Output "Mayor Temperatura motor2 $global:motor2MasCaliente"