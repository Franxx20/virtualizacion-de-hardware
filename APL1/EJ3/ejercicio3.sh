#! /bin/bash

#ejercicio3.sh - APL1 - Ejercicio 3 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

function help() {
	echo "Sistema de integracion continua."
	echo -e "Uso: $0 -c <direccion> -a <lista de acciones> [-s] <direccion de publicacion>\n"
	echo "Parametros:"
	echo -e "\t-c\t\tRuta a monitorear, puede ser absoluta, relativa o con espacios."
	echo -e "\t-a\t\tLista de acciones a realizar cuando se detecta un cambio, separadas por coma."
	echo -e "\t-s\t\tRuta a publicar archivo compilado, puede ser absoluta, relativa o con espacios.\n"
	echo "Acciones:"
	echo -e "\tlistar\t\tMuestra por pantalla el nombre de los archivos que sufrieron cambios (Creados, Modificados, Renombrados o Borrados)."
	echo -e "\tpeso\t\tMuestra por pantalla el peso de los archivos que sufrieron cambios."
	echo -e "\tcompilar\tCompila todos los archivos del directorio en un archivo y lo guarda en $(dirname "$0")/bin"
	echo -e "\tpublicar\tCopia el archivo compilado a la direccion de publicacion especificada con \"-s\"."
	exit 5
}


function comprobarPermisos() {
	permisos=$(ls -ld "$1")
	if [[ "${permisos:1:1}" != "r" ]]; then
		echo "[Error] - No tienes permiso de lectura para la dir.: \"$1\""
		exit 2
	fi
}


function capturaEstado() {
	find "$RUTA" -type f -printf '%i,%p\n' > /tmp/$1
}


function huboCambios() {
	AUX=$IFS
	IFS=$'\n'

	for i in $(cat /tmp/nuevo.out)
	do
		inodo=$(echo $i | cut -d "," -f 1)
		nombre=$(echo $i | cut -d "," -f 2)
		
		grep_inodo=$(grep -w "$inodo" /tmp/viejo.out)
		grep_nombre=$(grep -w "$nombre" /tmp/viejo.out)
		
		# Si un nombre de archivo del estado nuevo se encuentra en el estado viejo
		if [[ $grep_nombre != "" ]]; then
			grep_nombre_inodo=$(echo $grep_inodo | cut -d "," -f 1)
			
			# Si el inodo es distinto entonces el archivo fue modificado
			if [[ $grep_nombre_inodo != $inodo ]] ; then
				ARCHIVOS+=("MODIFICADO,$nombre")
			fi
		
		# Si el archivo tiene el mismo numero de inodo pero distinto nombre es porque lo renombraron			    
		elif [[ $grep_inodo != "" ]]; then
			viejo_nombre=$(echo $grep_inodo | cut -d "," -f 2)
			ARCHIVOS+=("RENOMBRADO,$nombre,$viejo_nombre")
		
		# Si no esta el nombre ni el inodo en el estado viejo entonces es un archivo nuevo
		else
			ARCHIVOS+=("CREADO,$nombre")
		fi
	done

	for i in $(cat /tmp/viejo.out)
	do
		inodo=$(echo $i | cut -d "," -f 1)
		nombre=$(echo $i | cut -d "," -f 2)

		grep_inodo=$(grep -w "$inodo" /tmp/nuevo.out)
		grep_nombre=$(grep -w "$nombre" /tmp/nuevo.out)

		# Si no esta el nombre ni el inodo en el estado nuevo entonces es un archivo eliminado
		if [[ $grep_nombre == "" ]] && [[ $grep_inodo == "" ]]; then
			ARCHIVOS+=("ELIMINADO,$nombre")
		fi    
	done

	IFS=$AUX
}


function listar() {
	for archivo in "${ARCHIVOS[@]}"
	do
		echo $archivo
	done
}


function peso() {
	for archivo in "${ARCHIVOS[@]}"
	do
		estado=$(echo $archivo | cut -d "," -f 1)

		if [[ $estado != "ELIMINADO" ]]; then
			nombre=$(echo $archivo | cut -d "," -f 2)
			peso=$(stat --printf="%s" "$nombre")
			echo "$nombre - $peso bytes"
		fi
	done
}


function compilar() {
	BIN_FOLDER=$(dirname "$0")/bin

	if [ ! -d "$BIN_FOLDER" ]; then
		mkdir bin
	fi

	find "$RUTA" -type f -exec sh -c 'cat "{}" >> ./compilado' \;
	mv ./compilado "$BIN_FOLDER/compilado"
	echo "Archivos compilados con exito!"
}


function publicar() {
	if [ ! -d "$PUBLICAR" ]; then
		mkdir "$PUBLICAR"
		comprobarPermisos "$PUBLICAR"
	fi

	cp "$BIN_FOLDER/compilado" "$PUBLICAR/compilado"
	echo "Archivo publicado con exito!"
}


function script() {
	trap finalizar EXIT
	capturaEstado viejo.out

	while true
	do
		sleep 0.1
		capturaEstado nuevo.out
		huboCambios

		if (( ${#ARCHIVOS[@]} != 0 )); then
			for accion in $ACCIONES
			do
				case $accion in
					listar) listar;;
					peso) peso;;
					compilar) compilar;;
					publicar) publicar;;
				esac
			done

			ARCHIVOS=()
			capturaEstado viejo.out
		fi
	done 
}


function finalizar(){
	echo "$0 Finalizado con Exito."
}


# --- Parseo de Argumentos --- #

SHORT=c:,a:,s:,h,?
LONG=help
OPTS=$(getopt -a -n ej3 --options $SHORT --longoptions $LONG -- "$@")

if [ $? != 0 ]; then
	echo "[Error] - Operacion desconocida"
	echo "Intenta $0 --help/-h/-? para descubrir como funciona el programa"
	exit 1
fi

eval set -- "$OPTS"

while :
do
	case "$1" in
		-c)
			RUTA="$2"; shift 2;;
		-a)
			ACCIONES="$2"; shift 2;;
		-s)
			PUBLICAR="$2"; shift 2;;
		-h | --help)
			help;;
		--)
			shift; break;;
		*)
			echo "Opcion invalida: $1";;
	esac
done


# --- Validacion de Datos --- #

if [[ "$RUTA" == "" ]] || [ ! -d "$RUTA" ]; then
	echo "[Error] - Ruta nula o no existente."
	exit 2
fi

# - Permisos en los directorios indicados
dirs=( "$RUTA" "$PUBLICAR" )
for DIR in "${dirs[@]}"
do
	if [[ "$DIR" != "" ]] && [ -d "$DIR" ]; then
		comprobarPermisos "$DIR"
	fi
done

# - Validacion de las acciones
if [[ "$ACCIONES" == *"publicar"* ]] && [[ "$ACCIONES" != *"compilar"* ]]; then
  echo "[Error] - No se puede ejecutar la accion \"publicar\" sin incluir la accion \"compilar\"."
  exit 3
fi

if [[ "$PUBLICAR" != "" ]] && [[ "$ACCIONES" != *"publicar"* ]]; then
	echo "[Warning] - Argumento -s innecesario si no contiene la accion \"publicar\"."
elif [[ "$PUBLICAR" == "" ]] && [[ "$ACCIONES" == *"publicar"* ]]; then
	echo "[Error] - Se requiere una ruta de publicacion."
	exit 4
fi


# -- Parseo de las acciones -- #
ACCIONES=$(echo $ACCIONES | tr ',' ' ')


# -- Ejecucion -- #
script "$@" &
echo "PID: $!"

#FIN DE ARCHIVO