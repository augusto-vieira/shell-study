#!/bin/bash

#Informações da porta de comunicação
PortaFisica="ttyACM0"
PortaVirtual="ttyPIN0"

#Coleta de dados
NameLog="Log_"$(date '+%d-%m-%Y')
Num_Link_recriado=0
N_escrita_ACM=0
Flag=0
Criado=0
ErroCriarLink=0

echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Inicio" >> $NameLog.txt
echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Inicio"


#Fica executando o comando em loop while infinito
while :; do

        #Verifica se existe um dispositivo no /dev/ttyACM0
        if [ -c "/dev/$PortaFisica" ]
        then

            if [ $Flag -eq 1 ]
            then
                ((N_escrita_ACM++))
                echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Porta $PortaFisica Encontrada $N_escrita_ACM"
                echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Link Criado"
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
                           echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Link Criado"
                           ((Criado=1))
                     fi

            else

                     #Cria um Link para a Porta
                     sudo ln -s /dev/$PortaFisica /dev/$PortaVirtual

                     if [ -c "/dev/$PortaVirtual" ]
                     then
                             ((Num_Link_recriado++))
                              echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Caiu o Link $PortaVirtual->$PortaFisica $Num_Link_recriado " >> $NameLog.txt
                              echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Criando um Link $PortaVirtual->$PortaFisica $Num_Link_recriado " >> $NameLog.txt
                              echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Caiu o Link $PortaVirtual->$PortaFisica $Num_Link_recriado "

                             ((Criado=0))
                             ((ErroCriarLink=0))

                     else
                        if [ $N_escrita -eq 0 ]
                        then
                         echo -e "$(date '+%d/%m/%y') - Erro ao criar link $(date '+%H:%M:%S')"
                         echo -e "$(date '+%d/%m/%y') - Erro ao criar link $(date '+%H:%M:%S')" >> $NameLog.txt
                         ((ErroCriarLink=1))
                        fi
                     fi

                fi

        else
            #Limita a quantidade de dados no log
            if [ $Flag -eq 0 ]
            then
              echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Porta $PortaFisica nao encontrada"
              echo -e "$(date '+%d/%m/%y') $(date '+%H:%M:%S') Porta $PortaFisica nao encontrada" >> $NameLog.txt
              ((Flag=1))
            fi
fi
#Sleep para 0.25 segundos
sleep  0.25
done
