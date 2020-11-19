#!/bin/bash

#Informações da porta de comunicação
PortaFisica="ttyACM0"
PortaVirtual="ttyPIN0"

#Coleta de dados
NameLog="LogLink_"$(date '+%d-%m-%Y')
Num_Link_recriado=0
N_escrita_ACM=0
CaiuLink=0
Flag=0
Criado=0


echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Inicio" >> $NameLog.txt


#Fica executando o comando em loop while infinito
while :; do

        #Verifica se existe um dispositivo no /dev/ttyACM0
        if [ -c "/dev/$PortaFisica" ]
        then

            if [ $Flag -eq 1 ]
            then
                ((N_escrita_ACM++))
                 echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Porta $PortaFisica Encontrada $N_escrita_ACM" >> $NameLog.txt
                 echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Link Criado" >> $NameLog.txt
                 echo -e "" >> $NameLog.txt
                 ((Flag=0))
            fi

            #Verifica se existe um link criado em /dev/ttyPIN0
            if [ -c "/dev/$PortaVirtual" ]
            then
                     if [ $Criado -eq 0 ]
                     then
                           echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Link Criado" >> $NameLog.txt
                           echo -e "" >> $NameLog.txt
                           ((Criado=1))
                           ((CaiuLink=0))
                     fi

            else

                     if [ $CaiuLink -eq 0 ]
                     then
                          #Escreve no log que  caiu o link
                          echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Caiu o Link $PortaVirtual->$PortaFisica $Num_Link_recriado " >> $NameLog.txt
                          ((Num_Link_recriado++))
                          ((CaiuLink=1))
                          ((Criado=0))
                     fi

            fi
       else
            #Limita a quantidade de dados no log
            if [ $Flag -eq 0 ]
            then
              echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Porta $PortaFisica nao encontrada" >> $NameLog.txt
              ((Flag=1))
            fi
fi
#Sleep para 0.25 segundos
sleep  0.25
done
