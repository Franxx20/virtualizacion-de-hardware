#! /bin/bash

main_folder="./test folder"
sub_folder="$main_folder/sub"
subsub_folder="$sub_folder/sub sub"

rm -rf "$main_folder"
rm -rf "./bin"
rm -rf "./archivos publicados"

folders=( "$main_folder" "$sub_folder" "$subsub_folder" )
for folder in "${folders[@]}"
do
	if [ ! -d "$folder" ]; then
		mkdir "$folder"
	fi
done

echo "hola " > "$main_folder/file.txt"
echo "mundo" > "$subsub_folder/file2.txt"


echo "./ej3.sh --help"
./ej3.sh --help


echo -e "\n./ej3.sh -c "$main_folder" -a publicar -s "./archivos publicados""
./ej3.sh -c "$main_folder" -a publicar -s "./archivos publicados"


echo -e "\nchmod 000 "$main_folder""
echo "./ej3.sh -c "$main_folder" -a listar,peso"
chmod 000 "$main_folder"
./ej3.sh -c "$main_folder" -a listar,peso


sleep 0.1
echo -e "\nchmod 755 "$main_folder""
chmod 755 "$main_folder"


echo -e "\n./ej3.sh -c "$main_folder" -a listar,peso,compilar,publicar -s "./archivos publicados""
./ej3.sh -c "$main_folder" -a listar,peso,compilar,publicar -s "./archivos publicados"

sleep 0.01
echo " !!" > "$sub_folder/file3.txt"
sed -i 's/mundo/linux/' "$subsub_folder/file2.txt"

sleep 0.5
mv "$sub_folder/file3.txt" "$sub_folder/archivo tres.txt"

sleep 0.5
rm "$sub_folder/archivo tres.txt"

sleep 1
kill $(pgrep ej3.sh)

echo ""
cat "./archivos publicados/compilado"