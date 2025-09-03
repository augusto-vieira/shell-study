#!/bin/bash

# Config----------------------------------------------------------------------

tpl_dir=./modelos

# Números mágicos
ERR_ARGS=1
ERR_F_EXISTS=2
ERR_EXT=3

# Mensagens de erro
err[ERR_ARGS]='Número incorreto de argumentos.'
err[ERR_F_EXISTS]='Arquivo já existe.'
err[ERR_EXT]='Modelo inválido.'

# Versão e ajuda
version=0.1
help="Esta é uma ajuda."
copy="Versão $version"
list="Lista de modelos"

# Functions-------------------------------------------------------------------

die () {
    echo "${err[$1]}"
    echo "$help"
    exit $1
}

# Listar modelos e editores
list_modelos () {
    echo "Lista os modelos disponíveis e o editor associado:"
    cat config
    echo ""
}

# Exibir ajuda e sair
show_help () {
    cat <<EOF
Uso: ./nf.sh [opções] <arquivo>
Opções:
  -l, --list      Lista os modelos disponíveis e o editor associado
  -h, --help      Exibe esta ajuda de uso
  -v, --version   Exibe a versão do programa

Exemplo:
  ./nf.sh teste.c
EOF
}

menu_modelos () {

# t=(modelos/*)
# echo ${t[0]} ${t[3]} 

# t=($(ls modelos/))
# echo ${t[0]} ${t[3]}  
modelos=($(ls modelos/))
Count=0

for nome in "${modelos[@]}"; do
    echo "[$Count] $nome"
    ((Count++))
done

read -p "Modelo (tecle <q> para sair):" opcao

if [[ $opcao == "q" ]]; then echo "saindo ..."; exit 0; fi

echo "${modelos[$opcao]}"

}

# Parse Options---------------------------------------------------------------

# Evolução 1
# Sem argumentos, o programa deve exibir um menu com os modelos disponíveis.
if [[ $# -eq 0 ]]; then
    menu_modelos
    exit 0
fi

# Selecionar ação conforme opções esperadas
case $1 in
    -l|--list)
        list_modelos
        exit 0
        ;;
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        # Exibir versão e sair
        echo "$copy"
        exit 0
esac

# O arquivo já existe no diretório?
    # Erro
    # Terminar
[[ -f $1 ]] && die $ERR_F_EXISTS
filename=$1
# Extensão é válida?
ext=bash
if [[ $filename =~ ^[^.]+\.[^.]+$ ]]; then
    ext=${filename/*.}
    # Selecionar modelo conforme extensão
    [[ -f $tpl_dir/$ext ]] || die $ERR_EXT
fi

echo $ext

# Main------------------------------------------------------------------------


# Copiar modelo para novo arquivo
cp $tpl_dir/$ext $filename
# Executar editor para abrir novo arquivo
exec nano $filename

