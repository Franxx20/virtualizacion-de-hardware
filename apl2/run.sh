#!/usr/bin/env bash
echo "Ejecutando..."
bin/ejercicio1 1>output 2>/dev/null &
FIRST_PROCESS=$!

# sleep 2 # Esperamos un segundo a que se creen los nodos...
# echo "Arbol de procesos:"
# pstree -pc $FIRST_PROCESS
# pstree -pc $FIRST_PROCESS >> output

wait $FIRST_PROCESS # Esperamos a que se cierren...

if [ $? -eq 0 ]; then
    echo -e "\nSalida del programa:"
    cat ./output
else
    echo "Proceso termino incorrectamente."
    exit 1
fi