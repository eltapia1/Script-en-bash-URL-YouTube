#!/bin/bash

# Función para verificar e instalar las herramientas necesarias
verificar_dependencias() {
    if ! command -v youtube-dl &> /dev/null; then
        echo "youtube-dl no está instalado. Instalando..."
        sudo apt-get install youtube-dl -y
    fi

    if ! command -v ffmpeg &> /dev/null; then
        echo "ffmpeg no está instalado. Instalando..."
        sudo apt-get install ffmpeg -y
    fi
}

# Función para extraer el audio y comprimir el video
extraer_audio_y_comprimir_video() {
    # Descargar el video
    youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' -o "temp_video.mp4" "$1"

    # Extraer el audio como mp3
    ffmpeg -i "temp_video.mp4" -vn -acodec libmp3lame -q:a 2 "audio.mp3"

    # Comprimir el video sin audio
    echo "Formatos disponibles para el video:"
    ffmpeg -i "temp_video.mp4" 2>&1 | grep Stream | grep Video | awk '{print $2}' | awk -F: '{print $1}'
    read -p "Selecciona el formato para el video (ejemplo: mp4, webm): " formato_video
    ffmpeg -i "temp_video.mp4" -an -c:v copy "video_sin_audio.$formato_video"

    # Eliminar el video temporal
    rm "temp_video.mp4"
}

# Función para mostrar información del audio y del video
mostrar_informacion() {
    echo "Información del audio (audio.mp3):"
    ffprobe -v quiet -print_format json -show_format -show_streams "audio.mp3"

    echo "Información del video (video_sin_audio.$formato_video):"
    ffprobe -v quiet -print_format json -show_format -show_streams "video_sin_audio.$formato_video"
}

# Verificar e instalar dependencias
verificar_dependencias

# Pedir URL de YouTube al usuario
read -p "Introduce la URL de YouTube: " url_youtube

# Extraer audio y comprimir video
extraer_audio_y_comprimir_video "$url_youtube"

# Mostrar información del audio y del video
mostrar_informacion
