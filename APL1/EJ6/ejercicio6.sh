#!/bin/bash

#ejercicio6.sh - APL1 - Ejercicio 6 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

theUser=`whoami`
entrada="$2"

if [  ! -d "/home/$theUser/Papelera.zip" ] 
then
	mkdir /home/$theUser/Papelera.zip
	touch /home/$theUser/Papelera.zip/.lista_papelera
fi

case $1 in
	--listar)
        cat /home/$theUser/Papelera.zip/.lista_papelera
	;;
	--recuperar)
		grep -w $entrada /home/$theUser/Papelera.zip/.lista_papelera >> /home/$theUser/Papelera.zip/dirVuelta.temp
		cantArchivosEncontrados=`wc -l < /home/$theUser/Papelera.zip/dirVuelta.temp`
		
		if [ $cantArchivosEncontrados -eq 0 ]
		then
			echo Ese archivo no esta en la papelera de reciclaje
			exit
		else
			cat /home/$theUser/Papelera.zip/dirVuelta.temp 
			read -p "¿Que archivo desea recuperar? " opcion
			pathOriginal=`grep "$opcion" /home/$theUser/Papelera.zip/dirVuelta.temp | awk '{print $3}'`
			
			mv /home/$theUser/Papelera.zip/$opcion$entrada $pathOriginal/$entrada
			grep -w -v "$opcion $entrada" /home/$theUser/Papelera.zip/.lista_papelera > .listaTemp.temp
			mv .listaTemp.temp /home/$theUser/Papelera.zip/.lista_papelera

			echo El archivo $entrada se ha recuperado con exito
		fi
		rm /home/$theUser/Papelera.zip/dirVuelta.temp
	;;
	--vaciar)
		rm -r /home/$theUser/Papelera.zip

		mkdir /home/$theUser/Papelera.zip
		touch /home/$theUser/Papelera.zip/.lista_papelera
		echo Papelera de reciclaje borrada con exito
	;;
	--eliminar)
		actDir=`pwd`
		if [ -f "$actDir/$entrada" ]
		then
			tipoArgumento=relativo
			nombreArch=`echo $entrada | awk 'BEGIN { FS="/" }{ print $NF}'`
			rutaRelativa=`echo $entrada | awk 'BEGIN { FS="/" ; OFS="/" }{ NF--;print }'`
		elif [ -f "$entrada" ]
		then
			tipoArgumento=absoluto
			nombreArch=`echo $entrada | awk 'BEGIN { FS="/" }{ print $NF}'`
			rutaAbsoluta=`echo $entrada | awk 'BEGIN { FS="/" ; OFS="/" }{ NF--;print }'`
			rutaAbsoluta+="/"
		else
			tipoArgumento=inexistente
		fi

		case $tipoArgumento in
			relativo)
				grep -w $nombreArch /home/$theUser/Papelera.zip/.lista_papelera >> /home/$theUser/Papelera.zip/.sameName.temp
				archivosMismoNombre=`wc -l < /home/$theUser/Papelera.zip/.sameName.temp`
				nuevoIndice=`awk ' END{print $1}' /home/$theUser/Papelera.zip/.sameName.temp`
				((nuevoIndice++))
				if [ $archivosMismoNombre -eq 0 ]
				then
					mv $actDir/"$entrada" /home/$theUser/Papelera.zip/$archivosMismoNombre"$nombreArch"
					echo $archivosMismoNombre "$nombreArch" $actDir/$rutaRelativa >> /home/$theUser/Papelera.zip/.lista_papelera
				else
					mv $actDir/"$entrada" /home/$theUser/Papelera.zip/$nuevoIndice"$nombreArch"
					echo $nuevoIndice "$nombreArch" $actDir/$rutaRelativa >> /home/$theUser/Papelera.zip/.lista_papelera
				fi
				echo Archivo $nombreArch movido a la papelera de reciclaje
				rm /home/$theUser/Papelera.zip/.sameName.temp
			;;
			absoluto)
				grep -w $nombreArch /home/$theUser/Papelera.zip/.lista_papelera >> /home/$theUser/Papelera.zip/.sameName.temp
				archivosMismoNombre=`wc -l < /home/$theUser/Papelera.zip/.sameName.temp`
				nuevoIndice=`awk ' END{print $1}' /home/$theUser/Papelera.zip/.sameName.temp`
				((nuevoIndice++))
				if [ $archivosMismoNombre -eq 0 ]
				then
					mv $entrada /home/$theUser/Papelera.zip/$archivosMismoNombre$nombreArch
					echo $archivosMismoNombre $nombreArch $actDir$rutaRelativa >> /home/$theUser/Papelera.zip/.lista_papelera
				else
					mv $entrada /home/$theUser/Papelera.zip/$nuevoIndice$nombreArch
					echo $nuevoIndice $nombreArch $rutaAbsoluta >> /home/$theUser/Papelera.zip/.lista_papelera
				fi
				echo Archivo $nombreArch movido a la papelera de reciclaje
				rm /home/$theUser/Papelera.zip/.sameName.temp
			;;
			inexistente)
				echo Ese archivo es inexistente
			;;
		esac
	;;
	--borrar)
		grep -w $entrada /home/$theUser/Papelera.zip/.lista_papelera >> /home/$theUser/Papelera.zip/.sameName.temp
		cantMismoNombre=`wc -l < /home/$theUser/Papelera.zip/.sameName.temp`
		if [ $cantMismoNombre -eq 0 ]
		then
			echo El archivo $entrada no esta en la papelera de reciclaje		
		else
			if [ $cantMismoNombre -eq 1 ]
			then
				num=`awk '{print $1}' /home/$theUser/Papelera.zip/.sameName.temp`
				rm /home/$theUser/Papelera.zip/$num$entrada

				grep -v "$num $entrada" /home/$theUser/Papelera.zip/.lista_papelera > .listaTemp.temp
				mv .listaTemp.temp /home/$theUser/Papelera.zip/.lista_papelera 
				echo El archivo $entrada fue borrado con exito de la papelera de reciclaje
			else
				cat /home/$theUser/Papelera.zip/.sameName.temp
				read -p "¿Que archivo desea borrar permanentemente? " opcion
				
				rm /home/$theUser/Papelera.zip/$opcion$entrada

				grep -v "$opcion $entrada" /home/$theUser/Papelera.zip/.lista_papelera > .listaTemp.temp
				mv .listaTemp.temp /home/$theUser/Papelera.zip/.lista_papelera
			fi
		fi
		rm /home/$theUser/Papelera.zip/.sameName.temp
	;;
	-h | --help | -?)
		echo Programa de papelera de reciclaje
		echo
		echo Sintaxis: "$0 [funcion] [archivo]"
		echo Funciones : 'Listar | Eliminar | Borrar | Recuperar | Vaciar | Help'
		echo --listar : Nos permite desplegar una lista de todos los archivos dentro de la papelera, con su codigo interno correspondiente y su direccion original
		echo --eliminar [archivo] : Nos permite eliminar un archivo para moverlo a la papelera de reciclaje
		echo --borrar [archivo] : Nos permite eliminar permanentemente un archivo dentro de la papelera de reciclaje
		echo --recuperar [archivo] : Nos permite recuperar un archivo de la papelera de reciclaje a su ubicacion original
		echo --vaciar : Nos permite eliminar permanentemente todos los archivos dentro de la papelera de reciclaje
		echo '-h | --help | -?': Nos permite desplegar un menu explicativo sobre todos las funcionalidades del programa 
		echo
		echo 'Ejemplo de uso: ./papelera.sh --eliminar miArchivo1 --> Esto movera "miArhivo1" a la papelera'
	;;
	*)
		echo No es un comando valido
	;;
esac

#FIN DE ARCHIVO