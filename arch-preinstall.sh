#!/bin/bash

# Script de Preinstalación para Arch Linux
# Repositorio: https://github.com/TECNOVISIO-co/arch-installer
# Autor: TECNOVISIO-co

set -e

# Función para mostrar el menú principal
mostrar_menu() {
    clear
    echo "=========================================="
    echo "      Script de Preinstalación Arch Linux"
    echo "=========================================="
    echo "1) Configurar teclado"
    echo "2) Conectarse a Internet"
    echo "3) Sincronizar reloj"
    echo "4) Particionar discos"
    echo "5) Formatear particiones"
    echo "6) Montar particiones"
    echo "7) Actualizar espejos de descarga"
    echo "8) Ejecutar todos los pasos anteriores"
    echo "9) Salir"
    echo "=========================================="
    read -p "Seleccione una opción: " opcion
}

# Función para configurar el teclado
configurar_teclado() {
    echo "Configurando el teclado a español..."
    loadkeys es
    echo "Teclado configurado."
    read -p "Presione Enter para continuar..."
}

# Función para conectarse a Internet
conectar_internet() {
    echo "Conectándose a Internet..."
    iwctl
    echo "Verificando conexión..."
    ping -c 3 archlinux.org
    echo "Conexión establecida."
    read -p "Presione Enter para continuar..."
}

# Función para sincronizar el reloj
sincronizar_reloj() {
    echo "Sincronizando el reloj..."
    timedatectl set-ntp true
    echo "Reloj sincronizado."
    read -p "Presione Enter para continuar..."
}

# Función para particionar los discos
particionar_discos() {
    echo "Listando discos disponibles:"
    lsblk
    read -p "Ingrese el disco para el sistema (ejemplo: /dev/sda): " DISCO_SISTEMA
    read -p "Ingrese el disco para datos (ejemplo: /dev/sdb): " DISCO_DATOS

    echo "Particionando el disco del sistema..."
    parted -s "$DISCO_SISTEMA" mklabel gpt
    parted -s "$DISCO_SISTEMA" mkpart ESP fat32 1MiB 513MiB
    parted -s "$DISCO_SISTEMA" set 1 esp on
    parted -s "$DISCO_SISTEMA" mkpart primary ext4 513MiB 100%

    echo "Particionando el disco de datos..."
    parted -s "$DISCO_DATOS" mklabel gpt
    parted -s "$DISCO_DATOS" mkpart primary ext4 1MiB 100%

    echo "Particionado completado."
    read -p "Presione Enter para continuar..."
}

# Función para formatear las particiones
formatear_particiones() {
    echo "Formateando las particiones..."
    mkfs.fat -F32 "${DISCO_SISTEMA}1"
    mkfs.ext4 "${DISCO_SISTEMA}2"
    mkfs.ext4 "${DISCO_DATOS}1"
    echo "Formateo completado."
    read -p "Presione Enter para continuar..."
}

# Función para montar las particiones
montar_particiones() {
    echo "Montando las particiones..."
    mount "${DISCO_SISTEMA}2" /mnt
    mkdir /mnt/boot
    mount "${DISCO_SISTEMA}1" /mnt/boot
    mkdir /mnt/mnt/datos
    mount "${DISCO_DATOS}1" /mnt/mnt/datos
    echo "Montaje completado."
    read -p "Presione Enter para continuar..."
}

# Función para actualizar los espejos de descarga
actualizar_espejos() {
    echo "Actualizando los espejos de descarga..."
    pacman -Sy reflector
    reflector --country Colombia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    echo "Espejos actualizados."
    read -p "Presione Enter para continuar..."
}

# Función para ejecutar todos los pasos
ejecutar_todo() {
    configurar_teclado
    conectar_internet
    sincronizar_reloj
    particionar_discos
    formatear_particiones
    montar_particiones
    actualizar_espejos
}

# Bucle principal del menú
while true; do
    mostrar_menu
    case $opcion in
        1) configurar_teclado ;;
        2) conectar_internet ;;
        3) sincronizar_reloj ;;
        4) particionar_discos ;;
        5) formatear_particiones ;;
        6) montar_particiones ;;
        7) actualizar_espejos ;;
        8) ejecutar_todo ;;
        9) echo "Saliendo..."; break ;;
        *) echo "Opción inválida. Intente nuevamente." ;;
    esac
done
