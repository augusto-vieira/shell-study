#!/bin/bash

show_help() {
  cat <<EOF
Uso: $0 <URL da playlist> [<índice inicial>] [opções]

Descrição:
  Calcula a duração total de uma playlist do YouTube, a partir de um vídeo específico (ou do início).

Argumentos:
  URL da playlist          URL da playlist do YouTube (obrigatório).
  índice do vídeo inicial  Índice para iniciar o cálculo (opcional, padrão: 1).

Opções:
  -h, --help               Mostra esta ajuda e sai.
  -c, --clean              Remove o ambiente virtual e arquivos temporários.

Exemplos:
  $0 'https://youtube.com/playlist?list=XYZ'       → calcula duração total
  $0 'https://youtube.com/playlist?list=XYZ' 10    → calcula a partir do vídeo 10 até o fim
  $0 'URL' 10 -c                                   → executa e limpa arquivos temporários 
  $0 --clean                                       → remove arquivos temporários e sai
EOF
}

clean_environment() {
  echo "🧹 Limpando arquivos temporários..."
  [ -d "$ENV_DIR" ] && rm -rf "$ENV_DIR" && echo "✔️ Ambiente virtual removido."
  [ -f "$PY_SCRIPT" ] && rm -f "$PY_SCRIPT" && echo "✔️ Script Python removido."
  echo "✅ Limpeza concluída."
  exit 0
}

# Nomes dos arquivos
ENV_DIR="/tmp/env_playlist"
PY_SCRIPT="/tmp/tempo_playlist.py"

# Inicializa variáveis
CLEAN=false
SHOW_HELP=false
ARGS=()

# Processa todos os argumentos
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      SHOW_HELP=true
      ;;
    -c|--clean)
      CLEAN=true
      ;;
    *)
      ARGS+=("$arg")
      ;;
  esac
done

# Executa ações imediatas
if [ "$SHOW_HELP" = true ]; then
  show_help
  exit 0
fi

if [ "$CLEAN" = true ] && [ ${#ARGS[@]} -eq 0 ]; then
  clean_environment
fi

# Lê argumentos posicionais
PLAYLIST_URL="${ARGS[0]}"
START_INDEX="${ARGS[1]:-1}"

# Verifica se a URL foi fornecida
if [ -z "$PLAYLIST_URL" ]; then
  echo "❌ Erro: URL da playlist não fornecida."
  show_help
  exit 1
fi

# Checa dependências
check_dep() {
  if ! command -v "$1" &> /dev/null; then
    echo "⚠️ Dependência '$1' não encontrada no sistema."
    return 1
  fi
  return 0
}

MISSING_DEPS=()
check_dep "python3" || MISSING_DEPS+=("python3")
check_dep "ffmpeg" || MISSING_DEPS+=("ffmpeg")

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
  echo -e "\n⚠️ Atenção! As seguintes dependências estão faltando:"
  for dep in "${MISSING_DEPS[@]}"; do
    echo "  - $dep"
  done
  echo
  read -rp "Deseja continuar mesmo assim? (s/n): " answer
  case "$answer" in
    [Ss]* ) echo "Continuando...";;
    * ) echo "Abortando."; exit 1;;
  esac
fi

# Cria ambiente virtual se não existir
if [ ! -d "$ENV_DIR" ]; then
  echo "🔧 Criando ambiente virtual Python..."
  python3 -m venv "$ENV_DIR" || { echo "❌ Falha ao criar ambiente virtual"; exit 1; }
fi

# Ativa o ambiente virtual
source "$ENV_DIR/bin/activate"

# Atualiza pip e instala yt-dlp
echo "📦 Instalando/atualizando yt-dlp..."
pip install --quiet --upgrade pip yt-dlp || { echo "❌ Falha ao instalar yt-dlp"; deactivate; exit 1; }

# Gera script Python temporário
cat > "$PY_SCRIPT" <<EOF
import subprocess
import json
from datetime import timedelta
import sys

def get_playlist_videos(playlist_url):
    cmd = ["yt-dlp", "-j", "--flat-playlist", playlist_url]
    output = subprocess.check_output(cmd).decode("utf-8").strip().split("\\n")
    return [json.loads(line) for line in output]

def get_video_duration(video_url):
    cmd = ["yt-dlp", "-j", video_url]
    output = subprocess.check_output(cmd).decode("utf-8")
    data = json.loads(output)
    return data.get("duration", 0)

def calcular_duracao_total(playlist_url, start_index=1):
    try:
        videos = get_playlist_videos(playlist_url)
        total_videos = len(videos)

        if start_index < 1 or start_index > total_videos:
            print(f"❌ Índice inicial inválido. Deve estar entre 1 e {total_videos}")
            return

        total_segundos = 0
        print(f"🎬 Playlist: {playlist_url}")
        print(f"Total de vídeos: {total_videos}")
        print(f"Calculando a partir do vídeo {start_index} até {total_videos}\\n")

        for i, video in enumerate(videos[start_index-1:], start=start_index):
            url = video.get("url") or video.get("id")
            if not url.startswith("http"):
                url = "https://www.youtube.com/watch?v=" + url
            try:
                duracao = get_video_duration(url)
                total_segundos += duracao
                titulo = video.get("title", f"Vídeo {i}")
                print(f"{i}. {titulo} - {timedelta(seconds=duracao)}")
            except Exception as e:
                print(f"⚠️ Erro no vídeo {i} ({url}): {e}")

        duracao_total = timedelta(seconds=total_segundos)
        print("\\n🕒 Duração total (do vídeo {start} até o final): {dur}\\n".format(start=start_index, dur=duracao_total))

    except Exception as e:
        print("❌ Erro ao acessar a playlist:", e)

if __name__ == "__main__":
    if len(sys.argv) not in [2, 3]:
        print("Uso: python tempo_playlist.py <URL da playlist> [<índice do vídeo inicial>]")
        sys.exit(1)

    playlist_url = sys.argv[1]
    start_index = int(sys.argv[2]) if len(sys.argv) == 3 else 1
    calcular_duracao_total(playlist_url, start_index)
EOF

# Executa o script Python
echo "🚀 Calculando duração da playlist com yt-dlp..."
python3 "$PY_SCRIPT" "$PLAYLIST_URL" "$START_INDEX"

# Desativa ambiente virtual
deactivate

# Limpeza pós-execução (se solicitada)
if [ "$CLEAN" = true ]; then
  clean_environment
fi

