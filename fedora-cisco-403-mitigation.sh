#!/bin/bash
S_VERSION="v.1.00 (07.11.2025)"; clear
#set -euo pipefail  # Exit on error, unset vars, pipe failures
if [[ "$LANG" =~ ^ru ]]; then
    LNG="RU"
else
    LNG="EN"
fi

# === Language and Message Declarations ===
declare -A S_HEADER=( [EN]="\nCISCO OPENH264 'ERROR 403' GEOBLOCK REMOVAL and \nmultimedia codecs installation script for FEDORA LINUX \nby Andrei Manzhov, " [RU]="Скрипт снятия блокировки обновлений из-за CISCO OPENH264 \nи установки необходимых мультимедиа кодеков для ФЕДОРЫ ЛИНУКС \n  Андрей Маньжов, " )
declare -A MSG_SUCCESS=( [EN]="✅ Installation completed!\n" [RU]="✅ Установка завершена!" )
declare -A MSG_FAILURE_HEADER=( [EN]="❌ Failed Steps:" [RU]="❌ Не удалось:" )
declare -A MSG_FAILURE_FOOTER=( [EN]="  Check system logs or rerun the script for details." [RU]="   Проверьте системные логи или перезапустите скрипт для деталей." )
declare -A MSG_RESULTS_HEADER=( [EN]="INSTALLATION RESULTS:" [RU]="ОТЧЁТ ОБ УСТАНОВКЕ:" )
declare -A STEP_1=( [EN]="Cisco repository disabled (geoblock issue resolved)" [RU]="Отключен репозиторий Cisco (решена проблема с геоблоком)" )
declare -A STEP_2=( [EN]="openh264 replaced with noopenh264" [RU]="Заменён openh264 на noopenh264" )
declare -A STEP_3=( [EN]="System updates installed" [RU]="Установлены системные обновления" )
declare -A STEP_4=( [EN]="RPM Fusion repository enabled" [RU]="Включен репозиторий RPM Fusion" )
declare -A STEP_5=( [EN]="Limited ffmpeg-free replaced with full ffmpeg from RPM Fusion" [RU]="Урезанный ffmpeg-free заменён на полный ffmpeg из RPM Fusion" )
declare -A STEP_6=( [EN]="All GStreamer codecs installed" [RU]="Установлены все GStreamer кодеки" )
declare -A STEP_7=( [EN]="Global openh264 exclusion added (drop-in)" [RU]="Добавлено глобальное исключение openh264 (drop-in)" )
declare -A STEP_8=( [EN]="Cisco openh264 disabled, which was blocking Flatpak updates" [RU]="Отключен openh264, блокировавший обновления Flatpak" )
declare -A STEP_9=( [EN]="Drivers for hardware video acceleration installed" [RU]="Установлены драйвера для аппаратного ускорения видео" )
declare -A STEP_10=( [EN]="Multimedia player VLC installed (plays everything)" [RU]="Установлен мультимедиа-плеер VLC (проигрывает всё)" )
declare -A STEP_11=( [EN]="VLC set as default video player" [RU]="VLC сделан видеоплеером по умолчанию" )
declare -A STEP_12=( [EN]="VLC set as default audio player" [RU]="VLC сделан аудиоплеером по умолчанию" )
declare -A MSG_GPU_INTEL=( [EN]="Intel Media Driver installed (hardware acceleration)" [RU]="Установлен Intel Media Driver (аппаратное ускорение)" )
declare -A MSG_GPU_AMD=( [EN]="mesa-va-drivers-freeworld installed (hardware acceleration)" [RU]="Установлены mesa-va-drivers-freeworld (аппаратное ускорение)" )
declare -A MSG_VLC_DEFAULT=( [EN]="VLC set as default player" [RU]="VLC установлен плеером по умолчанию" )
declare -A MSG_BROWSERS=( [EN]="SUGGESTION: ENABLE HARDWARE ACCELERATION IN APPLICATIONS" [RU]="СОВЕТ: ВКЛЮЧИТЕ HARDWARE ACCELERATION В ПРИЛОЖЕНИЯХ" )
declare -A MSG_DONE_HEADER=( [EN]="What was done:" [RU]="Что было сделано:" ) 
declare -A MSG_OS_WARNING=( [EN]="Warning: This script is designed for Fedora Linux, but detected '%s'." [RU]="Предупреждение: Этот скрипт предназначен для Fedora Linux, но обнаружен '%s'." )
declare -A MSG_EXITING=( [EN]="Exiting." [RU]="Выход." )
declare -A MSG_OS_ERROR=( [EN]="Error: Cannot detect OS. /etc/os-release not found." [RU]="Ошибка: Не удается определить ОС. /etc/os-release не найден." )
declare -A MSG_URL=( [EN]="All finished! For further updates on cisco geoblock issue check the thread at: \n - https://discussion.fedoraproject.org/t/ciscobinary-openh264-org-is-unreachable-in-some-countries-ru-ua-ir/." [RU]="Система готова к использованию! \nВопросы, связанные с этим кодеком, обсуждаются на сайте проекта по адресу: \n - https://discussion.fedoraproject.org/t/dnf-update-interrupted-all-mirrors-were-tried-cisco-openh264-geoblock/170877" )
declare -A MSG_OS_PROMPT=( [EN]="Do you want to continue anyway? (y/N): " [RU]="Хотите продолжить в любом случае? (y/N): " )
declare -A MSG_ATOMIC_WARNING=( [EN]="Warning: Atomic Fedora (%s) detected. Some commands require layering. Continue? (y/N): " [RU]="Предупреждение: Обнаружена Atomic Fedora (%s). Некоторые команды требуют layering. Продолжить? (y/N): " )
# === Color Definitions ===
declare -A CL=( [W]="\e[38;5;255m" [O]="\e[38;5;214m" [Y]="\e[38;5;229m" [G]="\e[38;5;120m" [B]="\e[38;5;117m" [R]="\e[38;5;210m" [P]="\e[38;5;177m" [NC]="\e[0m" )

# === Functions ===
SaveResult() {
    local Step_Message="$1"
    local Exit_Code="$2"
    if [[ $Exit_Code -ne 0 ]]; then
        FAILED+=("$Step_Message")
    else
        DONE+=("$Step_Message")
    fi
}
PrintResults() {
    if [[ ${#FAILED[@]} -eq 0 ]]; then
        echo -e "${MSG_SUCCESS[$LNG]}"
    else
        echo -e "${CL[R]}${MSG_FAILURE_HEADER[$LNG]}"
        for step in "${FAILED[@]}"; do
            echo -e "  ❌ $step"
        done
        echo -e "${MSG_FAILURE_FOOTER[$LNG]}\n${CL[NC]}"
    fi

    echo -e "${CL[G]}   ${MSG_DONE_HEADER[$LNG]}"
    for step in "${DONE[@]}"; do
        echo -e "   ${CL[G]}✔${CL[NC]} $step"
    done
    # Add GPU/VLC logic here if needed
}

# === Main Script Logic ===

FAILED=(); DONE=()
# the following 2 lines are dummy, for output testing only 
#LNG="RU" 
#FAILED+=("System update")

echo -e "${CL[P]}${S_HEADER[$LNG]}${S_VERSION}"
echo -e "═══════════════════════════════════════════════════════════${CL[NC]}"
echo -e ""


# Check if running on Fedora and handle dnf/ostree variants
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "$ID" != "fedora" ]]; then
        printf "${CL[R]}${MSG_OS_WARNING[$LNG]}" "$ID"
        echo
        read -p "${MSG_OS_PROMPT[$LNG]}" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "${MSG_EXITING[$LNG]}"
            exit 1
        fi
    elif [[ "$VARIANT_ID" =~ ^(silverblue|kinoite|sericea)$ ]]; then  # Atomic variants
        printf "${CL[Y]}${MSG_ATOMIC_WARNING[$LNG]}${CL[NC]}" "$VARIANT_ID"
        read -p "" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
        IS_ATOMIC=true
    else
        IS_ATOMIC=false  # Traditional Fedora
    fi
else
    echo "${MSG_OS_ERROR[$LNG]}"
    exit 1
fi

echo -e "\n${CL[P]}🟪🟪  01 / 11  🟪🟪  ${STEP_1[$LNG]}...🔧${CL[NC]}\n"

# 1. Disable the Cisco repo that is blocking update chain:
if [[ "$IS_ATOMIC" == true ]]; then
    if [ -f /etc/yum.repos.d/fedora-cisco-openh264.repo ]; then
        CMD="sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/fedora-cisco-openh264.repo"
    else
        CMD="echo 'ℹ️ Cisco repo not found'"
    fi
else
    CMD="sudo dnf config-manager setopt fedora-cisco-openh264.enabled=0"
fi
$CMD
SaveResult "${STEP_1[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  02 / 11  🟪🟪  ${STEP_2[$LNG]}...🔧${CL[NC]}\n"

# 2. Replace openh264 with noopenh264:
if [[ "$IS_ATOMIC" == true ]]; then
  # CMD="rpm-ostree override replace --experimental --from repo=cached openh264 --experimental noopenh264"
    CMD="sudo rpm-ostree override remove '*openh264*' --install noopenh264 -y"    
else
    CMD="sudo dnf swap '*openh264*' noopenh264 --allowerasing -y"
fi
$CMD
SaveResult "${STEP_2[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  03 / 11  🟪🟪  ${STEP_3[$LNG]}...🔧${CL[NC]}\n"

# 3. Update the system:
if [[ "$IS_ATOMIC" == true ]]; then
    CMD="rpm-ostree upgrade -y"  
else
    CMD="sudo dnf update -y"
fi
$CMD
SaveResult "${STEP_3[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  04 / 11  🟪🟪  ${STEP_4[$LNG]}...🔧${CL[NC]}\n"


# 4. Enable RPM Fusion (if not already)
if [[ "$IS_ATOMIC" == true ]]; then
    CMD="rpm-ostree install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
else
    CMD="sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
fi
$CMD
SaveResult "${STEP_4[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  05 / 11  🟪🟪  ${STEP_5[$LNG]}...🔧${CL[NC]}\n"

# 5. Replace limited ffmpeg-free with full-featured ffmpeg from RPM Fusion
if [[ "$IS_ATOMIC" == true ]]; then
    CMD="rpm-ostree override replace -y ffmpeg-free ffmpeg"
else
    CMD="sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y"
fi
$CMD
SaveResult "${STEP_5[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  06 / 11  🟪🟪  ${STEP_6[$LNG]}...🔧${CL[NC]}\n"


# 6. Install necessary GStreamer plugins and codecs
if [[ "$IS_ATOMIC" == true ]]; then
    CMD="rpm-ostree install -y @multimedia --exclude=PackageKit-gstreamer-plugin"
else
    CMD="sudo dnf install @multimedia --exclude=PackageKit-gstreamer-plugin -y"
fi
$CMD
SaveResult "${STEP_6[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  07 / 11  🟪🟪  ${STEP_7[$LNG]}...🔧${CL[NC]}\n"


# 7. Add global exception for openh264, creating a drop-in to the DNF config:
if [[ "$IS_ATOMIC" == true ]]; then
    CMD="echo 'Skipped on Atomic'"
else
    sudo tee /etc/dnf/libdnf5.conf.d/99-exclude-openh264.conf > /dev/null << 'EOF'
[main]
exclude=openh264*
EOF
    CMD="true"  # Since tee is executed above, mark as success
fi
$CMD
SaveResult "${STEP_7[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  08 / 11  🟪🟪  ${STEP_8[$LNG]}...🔧${CL[NC]}\n"


# 8. Disable the Cisco codec that breaks Flatpak updates:
CMD="sudo flatpak mask org.freedesktop.Platform.openh264"
$CMD
SaveResult "${STEP_8[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  09 / 11  🟪🟪  ${STEP_9[$LNG]}...🔧${CL[NC]}\n"


# 9. Install relevant hardware drivers for ~30% better efficiency
GPU_VENDOR=$(lspci | grep -i "vga\|3d" | grep -oE "Intel|AMD|NVIDIA" | head -1 || echo "Unknown")
if [ "$GPU_VENDOR" = "Intel" ]; then
    if [[ "$IS_ATOMIC" == true ]]; then
        CMD="rpm-ostree install -y intel-media-driver libva-vdpau-driver"
    else
        CMD="sudo dnf install -y intel-media-driver libva-vdpau-driver -y"
    fi
elif [ "$GPU_VENDOR" = "AMD" ]; then
    if [[ "$IS_ATOMIC" == true ]]; then
        CMD="rrpm-ostree install -y libva-mesa-driver && rpm-ostree override replace -y mesa-va-drivers mesa-va-drivers-freeworld && rpm-ostree override replace -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld"
    else
        CMD="sudo dnf install -y libva-mesa-driver -y && sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y && sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y"
    fi
    # 32-bit support for Steam, etc.
    if [[ "$IS_ATOMIC" == true ]]; then
        CMD="$CMD && rpm-ostree override replace -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 && rpm-ostree override replace -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686"
    else
        CMD="$CMD && sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 -y 2>/dev/null || true && sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 -y 2>/dev/null || true"
    fi
elif [ "$GPU_VENDOR" = "NVIDIA" ]; then
    CMD="echo '⚠️ Manually install proprietary NVIDIA driver for better performance'"
fi
$CMD
SaveResult "${STEP_9[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  10 / 11  🟪🟪  ${STEP_10[$LNG]}...🔧${CL[NC]}\n"

# 10. Install VLC player (comes with audio/video codecs that play virtually anything)
if [[ "$IS_ATOMIC" == true ]]; then
    CMD="sudo rpm-ostree install -y vlc"
else
    CMD="sudo dnf install vlc -y"
fi
$CMD
SaveResult "${STEP_10[$LNG]}" "$?"

echo -e "\n${CL[P]}🟪🟪  11 / 11  🟪🟪  ${STEP_11[$LNG]}...🔧${CL[NC]}\n"


# 11. Make VLC default player for all video formats
CMD="xdg-mime default vlc.desktop video/mp4 video/x-matroska video/webm video/avi 2>/dev/null || true"
$CMD
SaveResult "${STEP_11[$LNG]}" "$?"


# 12. Make VLC default player for all audio formats
# CMD="grep '^MimeType=' /usr/share/applications/vlc.desktop | cut -d '=' -f 2 | xargs -d ';' -n 1 | grep -e '^audio/' -e '^x-content/audio' | xargs -n 1 -I '{}' xdg-mime default vlc.desktop '{}'"
# $CMD && SaveResult "${STEP_12[$LNG]}" || SaveResult "${STEP_12[$LNG]}"


echo -e "${CL[P]}\n${MSG_RESULTS_HEADER[$LNG]} ${CL[Y]}(GPU $GPU_VENDOR)${CL[P]}"
echo -e "══════════════════════════════════════════════\n${CL[NC]}"

PrintResults

echo -e ""
echo -e "${CL[P]}${MSG_BROWSERS[$LNG]}:"
echo -e "════════════════════════════════════════════════════════${CL[NC]}"
echo -e ""
echo -e "🌐 ${CL[B]}Firefox:${CL[NC]}"
echo -e "   1. about:config"
echo -e "   2. media.ffmpeg.enabled = true"
echo -e "   3. media.navigator.mediadatadecoder_h264_enabled = true"
echo -e ""
echo -e "🌐 ${CL[B]}Chromium:${CL[NC]}"
echo -e "   1. chrome://flags"
echo -e "   2. --> 'hardware video'"
echo -e "   3. Hardware-accelerated video decode = Enabled"
echo -e ""
echo -e "${CL[P]}${MSG_URL[$LNG]}\n"



