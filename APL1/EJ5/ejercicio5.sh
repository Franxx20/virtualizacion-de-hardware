#! /bin/bash

#ejercicio5.sh - APL1 - Ejercicio 5 - ENTREGA
#Ezequiel Sebastian Catania - 43.323.210
#Augusto Martin Coronati - 43.572.601
#Agustin Marcelo Marco - 41.572.925
#Mariano Lionel Rodriguez - 39.336.952
#Ignacio Romero - 44.209.416

ayuda(){
echo -e "\t\t\tAYUDA"
echo "Descripcion 
Obtener un archivo con las estadisticas de aprobacion y desercion del alumnado en cada materia."
echo
echo "Sintaxis: $0 --notas <archivo> --materias <archivo>"
echo
echo "Parametros:"
echo "--notas <archivo> : Ruta del archivo a procesar. Puede ser relativa o absoluta."
echo "--materias <archivo> : Ruta del archivo con los datos de las materias. Puede ser relativa o absoluta."
echo "Parametros de ayuda: -h, -?, --help"
echo
}

cond1p() {
if [ $p1 -ge 7 -a $p2 -ge 7 ]; then
	echo 1
else
	echo 0
fi
}

cond2p() {
if [ $p2 -ge 7 -a $r -ge 7 ]; then
	echo 1
else
	echo 0
fi
}

cond3p() {
if [ $p1 -ge 7 -a $r -ge 7 ]; then
	echo 1
else
	echo 0
fi
}

cond1f() {
if [ $p1 -ge 4 -a $p2 -ge 4  ]; then
	echo 1
else
	echo 0
fi
}
cond2f() {
if [ $p2 -ge 4 -a $r -ge 4  ]; then
	echo 1
else
	echo 0
fi
}
cond3f() {
if [ $p1 -ge 4 -a $r -ge 4 ]; then
	echo 1
else
	echo 0
fi
}


if [ $# -ne 1 -a $# -ne 4 ]; then
	echo "[ERROR] La cantidad de parametros a pasar es 4."
	exit
fi

if [ $# -eq 1 ];then
	if [ $1 = "-h"  ] || [ $1 = "-?" ] || [ $1 = "--help" ]; then
		ayuda
		exit
	else
		echo "[ERROR] Ingrese $0 -h/-?/--help para obtener ayuda."
		exit
	fi
fi

if [ $1 == "--notas" -a $3 == "--materias" ];then
	if [ -r "$2" ] && [ -r "$4" ]
	then
		notas=$(cat "$2")
		materias=$(cat "$4")
		
		notas=$(echo "$notas" | sed '1d' | sort -k2 -t"|")
		notas=$(echo "$notas" | cut -d"|" -f2,3,4,5,6 ) 
		materias=$(echo "$materias" | sed '1d' | sort -k3 -t"|") 
	
		prom=0
		final=0
		aband=0
		recur=0
		deptoviejo=$(echo "$materias" | head -1 | cut -d "|" -f3)
		
		echo "{" > estadisticas.txt
		echo -e " \t\"departamentos\":  [" >> estadisticas.txt
		echo -e "\t\t{" >> estadisticas.txt
		echo -e "\t\t\t\"id\": $deptoviejo" >> estadisticas.txt
		echo -e "\t\t\t\"notas\":  [" >> estadisticas.txt
		
		while [ -n "$materias" ]
		do
				linea=$(echo "$materias" | head -1)
				depto=$(echo $linea | cut -d "|" -f3)
				id=$(echo $linea | cut -d "|" -f1)
				desc=$(echo $linea | cut -d "|" -f2)
				
				if [ "$depto" == "$deptoviejo" ]; then
					
					line=$(echo "$notas" | head -1)
					id2=$(echo $line | cut -d "|" -f1)
					notasmateria=$(echo "$notas" | grep "^$id2")
					
					while [ -n "$notasmateria" ]
					do
						Alumno=$(echo "$notasmateria" | head -1)
						
						p1=$(echo $Alumno | cut -d"|" -f2)
						if [ -z $p1 ];then 
							p1=0 
						fi
						p2=$(echo $Alumno | cut -d"|" -f3)
						if [ -z $p2 ];then 
							p2=0 
						fi
						r=$(echo $Alumno | cut -d"|" -f4)
						if [ -z $r ];then 
							r=0 
						fi
						f=$(echo "$Alumno" | cut -d"|" -f5)
						if [ -z $f ];then 
							f=0 
						fi
						id2=$(echo $Alumno | cut -d"|" -f1)
						
						if [ $(cond1p) -eq 1 ] || [ $(cond2p) -eq 1 ] || [ $(cond3p) -eq 1 ]
						then
								(( prom++ ))
						elif [ $f -eq 0 ] && [ $(cond1f) -eq 1 ] || [ $(cond2f) -eq 1 ] || [ $(cond3f) -eq 1 ]
						then
								(( final++ ))	
						elif [ $p1 -eq 0 -a $r -eq 0 ] || [ $p2 -eq 0 -a $r -eq 0 ]
						then
								(( aband++ ))
						elif [ $f -lt 4 ] || [ $p1 -lt 4 -a $p2 -lt 4 ] || [ $p1 -lt 4 -a $r -lt 4 ] || [ $r -lt 4 -a $p2 -lt 4 ]
						then
								(( recur++ ))
						fi
		
						notasmateria=$(echo "$notasmateria" | sed '1d')
						notas=$(echo "$notas" | sed '1d' )
					done
						
					echo -e "\t\t\t\t {" >> estadisticas.txt
					echo -e "\t\t\t\t\t \"id_materia\": $id2 ," >> estadisticas.txt
					echo -e "\t\t\t\t\t \"descripcion\": $desc," >> estadisticas.txt
					echo -e "\t\t\t\t\t \"final\": $final," >> estadisticas.txt
					echo -e "\t\t\t\t\t \"recursan\": $recur," >> estadisticas.txt
					echo -e "\t\t\t\t\t \"abandonaron\": $aband," >> estadisticas.txt
					echo -e "\t\t\t\t\t \"promocionan\": $prom" >> estadisticas.txt
					echo -e "\t\t\t\t }," >> estadisticas.txt
					prom=0
					final=0
					aband=0
					recur=0
					materias=$(echo "$materias" | sed '1d')
				else
					echo -e "\t\t\t]" >> estadisticas.txt		
					echo -e "\t\t\t\"id\": $depto ," >> estadisticas.txt
					echo -e "\t\t\t\"notas\":  [" >> estadisticas.txt
				fi
				deptoviejo=$depto
					
		done
		echo -e "\t\t\t]" >> estadisticas.txt
		echo -e "\t\t}" >> estadisticas.txt
		echo -e "\t ]" >> estadisticas.txt
		echo -e "}" >> estadisticas.txt
	
	else
		echo "[ERROR] Alguno de los archivos no existe o no tiene permiso de lectura."
		exit
	fi
else
	echo "[ERROR] Operacion desconocida. Ingrese $0 -h/-?/--help para obtener ayuda."
fi

#FIN DE SCRIPT