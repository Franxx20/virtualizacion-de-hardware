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
Param(
    [Parameter(Mandatory = $false,Position =1)][string]$entrada,
    [Parameter(Mandatory = $false)]
    [Switch]
    $archivo,
    [Parameter(Mandatory = $false)][string]$salida,
    [Parameter(Mandatory = $false)][switch]$ayuda
)
[int]$global:motor1MasCaliente = -1
[int]$global:motor2MasCaliente = -1
[float]$global:promedio = 0

function get-ayuda {
    Write-Output  "este script toma un archivo CSV con los datos de estacion petrolera, y devuelve un archivo de salida con los datos del archivo procesados"

    Write-Output "la sintaxis es la siguiente:"
    Write-Output "[-e / --entrada] Ruta del archivo de entrada (incluye el nombre del archivo)"
    Write-Output "[-a / --archivo] Si esta presente, indica que la salida va a ser por archivo. Opcional"
    Write-Output "[-e / --entrada] Ruta del archivo de salida (incluye el nombre del archivo). Solo puede estar presente si se usa el parametro -a / --archivo"
    
}


function process-csv {
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


        $totalTemperatura += [int]$_.Temperatura
        $cantRegistros += 1


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

## FUNCION DE AYUDA QUE CORTA EL PROGRAMA SI EL PARAMETRO ESTA PRESENTE
if ($ayuda) {
    get-ayuda
    exit 0
}

## PREGUNTO SI EL ARCHIVO DE ENTRADA ESTA VACIO
if ([string]::IsNullOrWhiteSpace((Get-Content $entrada))) {
    Write-Error "el archivo de entrada esta vacio!"  -ErrorAction Stop
}

## IMPORTO LOS DATOS DEL CSV A UN OBJETO
$archivoCSV = Import-Csv -Path $entrada
## FUNCION QUE PROCESA EL OBJETO Y OBTENGO LOS DATOS NECESARIOS DEL EJERCICIO
process-csv $archivoCSV


## PREGUNTO QUE LA RUTA DE SALIDA SEA UNA RUTA POSIBLE VALIDA
[switch] $valido = Test-Path -LiteralPath $salida -IsValid

## SI ESTA EL SWITCH ARCHIVO QUE ME OBLIGA A ENVIAR LOS DATOS A UN ARCHIVO
if ($archivo) {
    if ($valido) {

        Write-Output "Motor1=$motor1MasCaliente" >> $salida 
        Write-Output "Motor2=$motor2MasCaliente" >> $salida 
        Write-Output "Temperatura=$promedio" >> $salida
    }
## EL SWITCH ESTA PERO ME FALTA LA RUTA DE SALIDA
    else {
        Write-Output "psss... you gotta Supply values for the following parameters:"
        $salidaUsuario = Read-Host "ingrese una ruta de salida"
        ## CHECKEO QUE LA RUTA QUE PASO EL USUARIO SEA VALIDA
        [switch] $validoUsuario = Test-Path -LiteralPath $salidaUsuario -IsValid
        if ($validoUsuario) {
            Write-Output "Motor1=$motor1MasCaliente" >> $salidaUsuario 
            Write-Output "Motor2=$motor2MasCaliente" >> $salidaUsuario 
            Write-Output "Temperatura=$promedio" >> $salidaUsuario
        }
        else {
            ## MANDASTE MACANA 
            Write-Error "no escribio una ruta de salida valida" -ErrorAction Stop
        }
    }

    exit 0 
}
else {
    ## SI PASASTE UN ARCHIVO DE SALIDA VALIDO PERO TE FALTO EL SWITCH -ARCHIVO
    if ($valido) {
        Write-Error "falta el parametro -archivo!" -ErrorAction Stop

    }
}


## SI SOLO PASE LA RUTA DE ENTRADA ENTONCES IMPRIMO EN PANTALLA
Write-Output "i am here"
Write-Output "promedio final $global:promedio"
Write-Output "Mayor Temperatura motor1 $global:motor1MasCaliente"
Write-Output "Mayor Temperatura motor2 $global:motor2MasCaliente"