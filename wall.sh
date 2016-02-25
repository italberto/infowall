#!/bin/bash

IFACE_TYPE=""
IP_ADDR=""
USERNAME=$USER
WALLPAPER=""
WALL_HOME=$HOME"/Dropbox/wall/misc/*.jpg"
LOGO=$HOME"/Dropbox/wall/logo/logo.png"
OUTPUT_FILE=$HOME"/Dropbox/wall/output.jpg"
LOGO_WIDTH=$(identify $LOGO | awk '{print $3}' | awk -Fx '{print $1}')
MONITOR_RESOLUTION=$(xrandr | grep 'primary' | awk '{print $4}' | awk -F+ '{print $1}')

# Configurações de Imagem
TRANSPARENCY="70%"
POSITION_LOGO="south-west"
FONT_SIZE=17
FONT_COLOR="white"
X_POSS=$LOGO_WIDTH
LINE_BASE=800
LINE_SIZE=19


chooseWallpaper()
{
	files=($WALL_HOME)

	n=${#files[@]}
	WALLPAPER="${files[RANDOM % n]}"
	
}


defineIfaceType ()
{
	IFACE_TYPE=$(ifconfig | grep encap | awk '{print $1}' | grep eth0)

	if [ -z $IFACE_TYPE ]; then
		IFACE_TYPE = $(ifconfig | grep encap | awk '{print $1}' | grep wlan0)
	fi
}

getIpAddr ()
{
	# Obtém o endereço IP da máquina.
	IP_ADDR=$(ifconfig $IFACE_TYPE | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')

	if [ -z $IP_ADDR ]; then
		IP_ADDR=$(ifconfig $IFACE_TYPE | grep "inet end" | awk -F: '{print $2}' | awk '{print $1}')
	fi

}

# Realiza as transformações nas imagens.
imageTransformation () 
{

	# Usa o Imagemagick pra converter o arquivo escolhido
	# para a resolução corrente do monitor. O ponto de exclamação é
	# para forçar a transformção da proporção da imagem.
	convert $WALLPAPER -resize $MONITOR_RESOLUTION! $OUTPUT_FILE

	# Posiciona o logo no rodapé da imagem.
	composite -dissolve $TRANSPARENCY -gravity $POSITION_LOGO $LOGO $OUTPUT_FILE $OUTPUT_FILE

	# Escreve o IP na imagem.
	convert $OUTPUT_FILE -pointsize $FONT_SIZE -fill $FONT_COLOR -draw "text $X_POSS,800 'IP: $IP_ADDR'" $OUTPUT_FILE
	convert $OUTPUT_FILE -pointsize $FONT_SIZE -fill $FONT_COLOR -draw "text $X_POSS,819 'IF_TYPE: $IFACE_TYPE'" $OUTPUT_FILE
	convert $OUTPUT_FILE -pointsize $FONT_SIZE -fill $FONT_COLOR -draw "text $X_POSS,838 'USER: $USERNAME'" $OUTPUT_FILE
	convert $OUTPUT_FILE -pointsize $FONT_SIZE -fill $FONT_COLOR -draw "text $X_POSS,857 'HOME: $HOME'" $OUTPUT_FILE

}


setWallpaper()
{
	# Define o arquivo como papel de parede para o Gnome.
	gsettings set org.gnome.desktop.background picture-uri "file://$OUTPUT_FILE"
}


chooseWallpaper
defineIfaceType
getIpAddr
imageTransformation
setWallpaper




