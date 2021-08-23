#!/bin/bash


echo "digite o nome do arquivo de entrada"
read entrada 


hosts=''
TIMER='' 

mkdir "t"

while read line; do
	SO=` ggrep -oP "OS:\K.*?(?=Seq)" <<< $line `
	t=` ggrep -oP "initiated\K.*?(?=as)" <<< $line `
	
	if ! [[ $t == "" ]]; then
		TIMER=` echo $t `
	fi
	
	host=` grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' <<< "$line" `
	hosts=" $hosts $host"
	
	if [[ "$line" == *"Ports"* ]]; then
		hosts=( "${hosts[@]/$host}" )
		if ! [[ "$host" == "" ]]; then
			cat "files/host_head.html" >> "t/$host.html"
			echo -e " <strong class=\"card-title\">IP: $host </strong> \n<p style=\"text-align:center\"> SO: $SO </p>" >> "t/$host.html"
			cat "files/host_mid.html" >> "t/$host.html"
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
				ex="<a href=\"https://www.exploit-db.com/search?text=$servico\" target=\"_blank\"><button type=\"button\" class=\"btn btn-sm btn-outline-secondary\">Exploit</button></a>"
			else
				ex="<a href=\"https://www.exploit-db.com/search?text=$versao\" target=\"_blank\"><button type=\"button\" class=\"btn btn-sm btn-outline-secondary\">Exploit</button></a>"
			fi

			if ! [[ "$porta" == "" ]]; then
				echo " <tr> <td> $porta </td> <td> $servico </td> <td> $versao </td> <td>$ex</td> </tr>  " | tr '_' ' ' >> "t/$host.html"
			fi
		
		done
		
		cat "files/host_foo.html" >> "t/$host.html"
	fi 
		
done < $entrada



hosts=` echo "$hosts" | awk '{for (i=1;i<=NF;i++) if (!hosts[$i]++) printf("%s%s",$i,FS)}{printf("\n")}' `

cat "files/index_head.html" > "t/index.html"
echo "<p class=\"lead text-muted\">Relatorio gerado em $TIMER </p>" >> "t/index.html"
cat "files/index_mid.html" >> "t/index.html"

for j in $hosts
do
	if [ ! -f "t/$j.html" ]
	then
		cat "files/host_head.html" >> "t/$j.html"
		echo " <strong class=\"card-title\">IP: $j </strong> " >> "t/$j.html"
		cat "files/host_mid.html" >> "t/$j.html"
		echo " <tr> <td> N/A </td> <td> N/A  </td> <td> N/A </td> <td> N/A </td> </tr>  " >> "t/$j.html"
		cat "files/host_foo.html" >> "t/$j.html"
	fi
	
	echo "
    <div class=\"col\">
          <div class=\"card shadow-sm\">
            <img src=\"host.jpg\">
            <div class=\"card-body\">
              <p class=\"card-text\">Host: $j </p>
              <div class=\"d-flex justify-content-between align-items-center\">
                <div class=\"btn-group\">
                  <a href=$j.html><button type=\"button\" class=\"btn btn-sm btn-outline-secondary\">Acessar relatorio de portas</button></a>
                </div>
              </div>
            </div>
          </div>
        </div>
" >> "t/index.html"
done

cat "files/index_foo.html" >> "t/index.html"


mv "t" "bfnmap $TIMER"
cp "files/favicon.ico" "bfnmap $TIMER"
cp "files/host.jpg" "bfnmap $TIMER"
cp "files/server.py" "bfnmap $TIMER"
python3 "bfnmap $TIMER/server.py"   