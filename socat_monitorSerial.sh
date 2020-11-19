#!/bin/bash

#Informações da porta de comunicação
PortaFisica="ttyACM3"
PortaVirtual="ttyV0"

#Verifica se existe um dispositivo no /dev/ttyACM0
if [ -c "/dev/$PortaFisica" ]
then
   #Fica executando o comando em loop while infinito
    echo "Porta $PortaFisica identificada ..." 
	while :; do
	echo "Rodando..."
	LogSerial=`date +%d%m%y_%H%M%S`
	sudo socat -ly -x -v /dev/$PortaFisica,raw,echo=0 PTY,link=/dev/$PortaVirtual,raw,echo=0,waitslave  2>&1 | tee $LogSerial.txt
	echo -e "Fim...\n"
	done

else
    echo "Porta $PortaFisica não encontrada..." 
fi



