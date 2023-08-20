#! /bin/bash


function help() {
	echo "Cuenta la cantidad de lineas de codigo y de comentarios de todos los archivos en un directorio recursivamente."
	echo -e "Uso: $0 --ruta <direccion> --ext <lista de extensiones>\n"
	echo "Parametros:"
	echo -e "\t--ruta\t\tRuta a analizar, puede ser absoluta, relativa o con espacios"
	echo -e "\t--ext\t\tLista de extensiones a analizar, separadas por coma"
	exit 2
}


SHORT=h,?
LONG=ruta:,ext:,help
OPTS=$(getopt -a -n ej4 --options $SHORT --longoptions $LONG -- "$@")

if [ $? != 0 ]; then
	echo "[Error] - Operacion desconocida"
	echo "Intenta $0 --help/-h/-? para descubrir como funciona el programa"
	exit 1
fi

eval set -- "$OPTS"

while :
do
	case "$1" in
		--ruta)
			RUTA="$2"; shift 2;;
		--ext)
			EXTENSIONES="$2"; shift 2;;
		-h | --help)
			help;;
		--)
			shift; break;;
		*)
			echo "Opcion invalida: $1";;
	esac
done

if [[ "$RUTA" == "" ]] || [ ! -d "$RUTA" ]; then
	echo "[Error] - Ruta nula o no existente."
	exit 2
fi

TOTAL_ARCHIVOS=0
TOTAL_CODIGO=0
PRC_CODIGO=0.0
TOTAL_COMENTARIOS=0
PRC_COMENTARIOS=0.0

IFS=","
for EXT in $EXTENSIONES
do
	for FILE in $(find $RUTA -type f -name "*.${EXT}" -printf '%p,') #-printf '%p,' separa la lista de archivos con una coma, en lugar de un espacio
	do	
		read COMENTARIOS CODIGO <<< $( awk '
			function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
			function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
			function trim(s)  { return rtrim(ltrim(s)); }
			
			{
				$0 = trim($0)

				# Si no esta vacia, no comienza con // o /* esta dentro de un bloque de comentario
				if (length($0) && !(/^\/\// || /^\/\*/) && bloque != 1) { codigo++ }
				if (/\/\*/) { bloque = 1 }	# Inicia bloque de comentarios
				if (/\/\// || bloque == 1) { comentarios++ }
				if (/\*\//) { bloque = 0 }	# Termina bloque de comentarios
				if (/^\*\/./) { codigo++ }	# Si comienza con */ y luego sigue conteniendo texto
			}
			
			END {
				print comentarios","codigo # Separamos con coma por el estado del IFS
			}
		' $FILE )

		TOTAL_ARCHIVOS=$(( TOTAL_ARCHIVOS + 1 ))
		TOTAL_CODIGO=$(( TOTAL_CODIGO + CODIGO ))
		TOTAL_COMENTARIOS=$(( TOTAL_COMENTARIOS + COMENTARIOS ))
	done
done

TOTAL_LINEAS=$(( TOTAL_CODIGO + TOTAL_COMENTARIOS ))
if [ $TOTAL_LINEAS -gt 1 ]; then
	PRC_CODIGO=$(echo "scale=2;${TOTAL_CODIGO} * 100.0 / ${TOTAL_LINEAS}" | bc)
	PRC_COMENTARIOS=$(echo "scale=2;${TOTAL_COMENTARIOS} * 100.00 / ${TOTAL_LINEAS}" | bc)
fi


STR_ARCHIVOS="Total archivos: ${TOTAL_ARCHIVOS}"
STR_CODIGO="Total codigo: ${TOTAL_CODIGO} - %${PRC_CODIGO}"
STR_COMENTARIOS="Total comentarios: ${TOTAL_COMENTARIOS} - %${PRC_COMENTARIOS}"

echo $STR_ARCHIVOS
echo $STR_CODIGO
echo $STR_COMENTARIOS
