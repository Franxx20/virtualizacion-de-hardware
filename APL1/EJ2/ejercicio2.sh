#!/bin/bash

#ejercicio2.sh - APL1 - Ejercicio 2 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

help (){
	echo -e "\t\t\tAYUDA"
	echo "DESCRIPCION"
	echo "El programa obtiene y muestra
	1. Promedio de tiempo de las llamadas realizadas por dia.
	2. Promedio de tiempo y cantidad por usuarios por dia.
	3. Los 3 usuarios con mas llamadas en la semana.
	4. Cuantas llamadas no superan la media de tiempo por dia.
	5. El usuario que tiene mayor cantidad de llamadas por debajo de la media en la semana (solo dias computados)."
	echo 
	echo "SINTAXIS CORRECTA: $0 --logs <path>"
	echo 
	echo "PARAMETROS DE AYUDA:	 -h, --help, -?"
	echo 
	echo "Valores de retorno:"
	echo -e "1\tError en cantidad de parametros recibidos."
	echo -e "2\tEl archivo no existe o no se tienen permisos de lectura."
	echo 
}

Punto1(){
echo -e "\n1)"
texto=`sort -d -k1 -t" " "$path"`

OIFS=$IFS
IFS=" "
echo -e "Dia\t\tPromedio"

while [ -n "$texto" ]									
do
	line=`echo $texto | head -1`
	fecha=`echo $line | cut -d" " -f1`
	texto2=`echo $texto | grep $fecha|sort -d -k4 -t"-"`	
	
	i=1
	acum=0
	cont=$(echo $texto2 | grep -c $fecha)
	
	IFS=$'\n'
	for linea in $texto2
	do
		if [ `echo "$i%2"| bc` -eq 0 ]
		then
				
				f2=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
				fin=$(date -u -d "$f2" +"%s")
				dif=$(($fin-$inicio))
				((acum+=dif))
		else
				
				f1=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
				inicio=$(date -u -d "$f1" +"%s")
		fi
		((i++))
	done

	((cont/=2))
	prom=$(($acum/$cont))
	echo -e "$fecha\t$prom seg"
	
	IFS=" "
	texto=`echo $texto | grep -v $fecha`
	cont=0
done
}

Punto2(){
echo -e "\n2)"
texto=`sort -d -k1 -t" " "$path"`

OIFS=$IFS
IFS=" "
echo -e "Usuario\tFecha\t\tPromedio\tCantidad"
while [ -n "$texto" ]									
do
	line=`echo $texto | head -1`
	fecha=`echo $line | cut -d" " -f1`
	texto2=`echo $texto | grep $fecha`	
	
	while [ -n "$texto2" ]
	do
		linea=`echo $texto2 | head -1`
		usuario=$(echo $linea | cut -d"-" -f4)
		texto3=`echo $texto2 | grep $usuario`
		acum=0
		cont=0
		while [ -n "$texto3" ]
		do
			linea=`echo $texto3 | head -1`
			h1=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
			linea=`echo $texto3 | sed -n '2p'`
			h2=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
			dif=$(($(date -u -d "$h2" +"%s")-$(date -u -d "$h1" +"%s")))
			((acum+=dif))
			((cont++))
			texto3=`echo $texto3 | sed '1,2 d'`
		done
		prom=$(($acum/$cont))
		echo -e "$usuario\t$fecha\t$prom seg\t\t$cont"
		
		texto2=`echo $texto2 | grep -v $usuario`
	done

	texto=`echo $texto | grep -v $fecha`

done
}

Punto3(){
echo -e "\n3)"
texto=`sort -k4 -t"-" "$path" | uniq -cs 19 | sort -r`
echo "Los 3 usuarios con mas llamadas en la semana son:"
OIFS=$IFS
IFS=" "

for ((i=0; i<3; i++))
do
	cant=$(echo $texto | head -1 | cut -d" " -f1)
	((cant/=2))
	echo -e "$(echo $texto | head -1 | cut -d"-" -f4)\t\t$cant"
	texto=`echo $texto | sed '1 d'`
done

IFS=$OIFS
}

Punto4(){
echo -e "\n4)"
texto=`sort -d -k1 -t" " "$path"`

OIFS=$IFS
IFS=" "

while [ -n "$texto" ]									
do
	line=`echo $texto | head -1`
	fecha=`echo $line | cut -d" " -f1`
	texto2=`echo $texto | grep $fecha | sort -k4 -t"-"`	
	i=1
	acum=0
	cont=$(echo $texto2 | grep -c $fecha)
	
	while [ -n "$texto2" ]
	do
		linea=`echo $texto2 | head -1`
		texto2=`echo $texto2 | sed '1 d'`
		if [ `echo "$i%2"| bc` -eq 0 ]
		then
				
				f2=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
				fin=$(date -u -d "$f2" +"%s")
				dif=$(($fin-$inicio))
				vector+=($dif)
				((acum+=dif))
		else
				f1=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
				inicio=$(date -u -d "$f1" +"%s")
		fi
		((i++))
		
	done

	((cont/=2))
	prom=$(($acum/$cont))
	cant=0
	for i in ${!vector[@]}
	do
		if [ ${vector[$i]} -le $prom ]
		then
			((cant++))
		fi
	done
	echo "$cant llamadas no superan la media del dia $fecha."
	vector=()
	texto=`echo $texto | grep -v $fecha`
	cont=0
done
}

Punto5(){
echo -e "\n5)"
texto=`sort -d -k4 -t"-" "$path"`

OIFS=$IFS
IFS=" "

cont=$(echo $texto | wc -l)	

i=1
acum=0
	
IFS=$'\n'
for linea in $texto
do
	if [ `echo "$i%2"| bc` -eq 0 ]
	then
			f2=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
			fin=$(date -u -d "$f2" +"%s")
			dif=$(($fin-$inicio))
			((acum+=dif))
	else	
			f1=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
			inicio=$(date -u -d "$f1" +"%s")
	fi
	((i++))
done

((cont/=2))
if [ $cont -ne 0 ];then
	media=$(($acum/$cont))
fi

IFS=" "	
contmax=0

while [ -n "$texto" ]									
do
	line=`echo $texto | head -1`
	usuario=`echo $line | cut -d"-" -f4`
	texto2=`echo $texto | grep $usuario`
	i=1
	cont=0
	IFS=$'\n'
	for linea in $texto2
	do
		if [ `echo "$i%2"| bc` -eq 0 ]
		then
			f2=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
			fin=$(date -u -d "$f2" +"%s")
			dif=$(($fin-$inicio))
			if [ $dif -lt $media ];then
				((cont++))
			fi
		else	
			f1=$(echo $linea | cut -d" " -f2 | cut -d"-" -f1)
			inicio=$(date -u -d "$f1" +"%s")
		fi
		((i++))
	done
	
	if [ $cont -gt $contmax ];then
		contmax=$cont
		usmax=$usuario
	fi

	texto=`echo "$texto" | grep -v $usuario`
	IFS=" "
done

if [ $contmax -ne 0 ];then
	echo "$usmax es el usuario con mayor cantidad de llamadas [$contmax] por debajo de la media de la semana. [$media seg]"
else
	echo "Ningun usuario tiene llamadas por debajo de la media de la semana."
fi
echo -e "\n\n"
}


if [ $# -ne 2 ] && [ $# -ne 1 ]
then
	echo "[ERROR] La cantidad de parametros a pasar es 2."
	exit 1;
fi

if [ $# -eq 1 ]; then
	if (test "$1" == "--help" || test "$1" == "-h" || test "$1" == "-?"); then
		help
		exit;
	else
		echo "[ERROR] Operacion desconocida. Ingrese $0 -h para ayuda."
	fi
fi

if [ "$1" == "--logs" ];then
	if [ -r "$2" ]; then
		for it in "$2"/*
		do
			path="$it"
			if [ -d "$path" ];then
				exit
			fi
			echo "$path"
			Punto1
			Punto2 
			Punto3
			Punto4
			Punto5 
		done
	else
		echo "[ERROR] El archivo no existe o no se tienen permisos de lectura."
		exit 2;
	fi
else
	echo "[ERROR] Operacion desconocida. Ingrese $0 -h para ayuda."
fi

#FIN DE ARCHIVO