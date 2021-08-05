#!/bin/bash

inicio=$( cat <<-END
<style>
#customers {
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 45%;
  color: black;
  text-align: center;
}

#customers td, #customers th, li {
  border: 1px groove black;
  padding: 8px;
}

#customers tr:nth-child(even){background-color: #7CC2FF;}

#customers tr:hover {background-color: #0084F8;}

#customers th {
  padding-top: 12px;
  padding-bottom: 12px;
  
  background-color: #0000cd;
  color:  white;}
</style>
END
)

echo "digite o nome do arquivo de entrada"
read entrada 

echo "digite o nome do arquivo de saida"
read saida 


if ! [[ $saida == *".html" ]]; then
	saida=` echo "$saida.html" `
fi

hosts=''
echo -e "$inicio" > $saida
while read line; do
	host=` grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' <<< "$line" `
	hosts=" $hosts $host"
	if [[ "$line" == *"Ports"* ]]; then
		hosts=( "${hosts[@]/$host}" )
		if ! [[ "$host" == "" ]]; then
			echo '<table id="customers" align="center">' >> $saida
			echo "<tr><caption>Host: $host </caption></tr>" >> $saida
			echo "<tr><th>Porta</th><th>Serviço</th><th>Versão</th></th>" >> $saida
		fi
		
		nl=` echo $line | grep -Eo "[0-9]{2,6}/.*" | grep -E -o "[0-9]{2,6}.*[?=\/] " | tr ',' '\n' | tr " " "_" `
		
		for j in $nl
		do
			porta=` awk -F/  '{print $1}' <<< "$j" `
			if [[ ${porta:0:1} == "_" ]]; then
				porta=` echo ${porta:1} `
			fi
			
			versao=` awk -F/  '{print $7}' <<< "$j" ` 
			servico=` awk -F/  '{print $5}' <<< "$j" `  
			
			if [[ $versao == '' ]]; then
				versao=` echo "N/A"` 
			fi

			if ! [[ "$porta" == "" ]]; then
				echo "<tr><td> $porta </td><td> $servico </td><td> $versao </td></tr>  " | tr '_' ' ' >> $saida
			fi
		
		done

	
	echo -e "</table>\n<br/>\n<br/>" >> $saida
	fi 
		
done < $entrada

hosts=` echo "$hosts" | awk '{for (i=1;i<=NF;i++) if (!hosts[$i]++) printf("%s%s",$i,FS)}{printf("\n")}' `
echo -e '<table id="customers" align="center">\n<tr><caption>Hosts encontrados: </caption></tr>' >> $saida
for j in $hosts
do
	echo "<tr><td> $j </td></tr>">> $saida
done

echo -e "</table>\n</ul>\n</html>" >> $saida
