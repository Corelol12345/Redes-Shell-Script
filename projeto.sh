#!/bin/bash

####Funçoes usadas (dependencias) ######
#testar_conectividade = ping
#descobrir_endereco_ip = host
#ver_portas_abertas = nmap
#varredura_rede_menu 
#testar_velocidade_internet = ookla speedtest
#menu_WIFI 
#detectar_automatico = nmap
#digitar_manual = nmap -sn
#informacoes_rede = iwconfig
#network_manager = nmcli
#status_geral = nmcli general status
#########################

menu_principal() {
    while true; do
        menu_opcao=$(dialog --clear --backtitle "Redes e Conexoes" --title "Menu de Redes" --menu "Escolha uma das opções disponíveis:" 15 45 6 \
            1 "Testar Conectividade" \
            2 "Descobrir endereço IP" \
            3 "Ver portas abertas" \
            4 "Fazer Varredura de Rede"\
            5 "Menu de opções WIFI" \
            6 "Sair" \
            2>&1 >/dev/tty)

        case $menu_opcao in
            1) testar_conectividade ;;
            2) descobrir_endereco_ip ;;
            3) ver_portas_abertas ;;
            4) varredura_rede_menu;;
            5) menu_WIFI ;;
            6) clear && break ;;
            *) echo "Opção inválida" ;;
        esac
    done
}

varredura_rede_menu() {
    while true; do
        submenu=$(dialog --clear --title "Varredura de Rede" --menu "Escolha uma opção:" 20 45 3 \
            1 "Detectar IP automaticamente" \
            2 "Digitar IP manualmente" \
            3 "Sair" \
            2>&1 >/dev/tty)

        case $submenu in
            1) detectar_automatico ;;
            2) digitar_manual ;;
            3) break ;;
        esac
    done
}

detectar_automatico() {
    ip=$(ip addr show | awk '/inet .*brd/ && !/127.0.0.1/ {print $2}' | head -n 1)
    dialog --title "Endereço IP Detectado" --yesno "O endereço IP da sua interface de rede é:\n\n$ip\n\nDeseja confirmar este endereço?" 15 60

    if [ $? -eq 0 ]; then
        detectado=$(nmap -sn $ip)
        dialog --title "Varredura de Rede" --msgbox "$detectado" 30 100
    else
        dialog --title "Endereço IP Não Confirmado" --msgbox "Você optou por não confirmar o endereço IP." 10 40
    fi
}

digitar_manual() {
    endereco=$(dialog --title "Inserir manualmente" --inputbox "Insira o endereço IP manualmente Formato 000.000.000.000/00" 8 40 --stdout)
    detectado=$(nmap -sn $endereco)
    
    dialog --title "Varredura de Rede" --msgbox "$detectado" 30 100
}

testar_conectividade() {
	endereco=$(dialog --inputbox "Digite o endereço para testar a conectividade:" 8 40 --stdout)
	contador=$(dialog --inputbox "Digite o número de pacotes a enviar:" 8 40 --stdout)
    
    ping -c "$contador" "$endereco" > /tmp/ping_output 2>&1 &
    pid=$!
    
    (
        while kill -0 $pid 2>/dev/null; do
            sleep 1
            done=$(grep -c 'bytes from' /tmp/ping_output)
            percentage=$((done * 100 / contador))
            echo "$percentage"
        done
    ) | dialog --title "Testando Conectividade" --gauge "Testando ping para $endereco" 10 70 0
    
    resultado_ping=$(cat /tmp/ping_output)
    rm /tmp/ping_output
    
    dialog --title "Resultado do Ping" --msgbox "$resultado_ping" 30 80
}

descobrir_endereco_ip() {
    hostname=$(dialog --inputbox "Digite o nome de host para descobrir o endereço IP:" 8 40 --stdout)
    resultado_ip=$(host "$hostname" 2>&1)
    dialog --title "Endereço IP" --msgbox "$resultado_ip" 30 80
}

ver_portas_abertas() {
    endereco=$(dialog --inputbox "Digite o endereço para verificar portas abertas:" 8 40 --stdout)
    portas=$(nmap "$endereco" 2>&1)
    dialog --title "Portas Abertas" --msgbox "$portas" 30 80
}

menu_WIFI() {
    while true; do
        menu_wifi_opcao=$(dialog --clear --title "Menu de opções WIFI" --menu "Escolha uma das opções disponíveis:" 15 45 5 \
            1 "Informações sobre Rede (iwconfig)" \
            2 "Listar Redes WIFI (nmcli dwl)" \
            3 "Network Manager (nmcli)" \
            4 "Status geral WIFI (nmcli GS)" \
            5 "Sair" \
            2>&1 >/dev/tty)
        
        case $menu_wifi_opcao in
            1) informacoes_rede ;;
            2) listar_WIFI ;;   
            3) network_manager ;;
            4) status_geral ;;
            5) break ;;
            *) echo "Opção inválida" ;;
        esac
    done
}   
informacoes_rede() {
    informacoes_wifi=$(iwconfig)
	dialog --title "Informacoes do WIFI" --msgbox "$informacoes_wifi" 30 80
}

listar_WIFI() {
    redes_wifi=$(nmcli device wifi list)
    dialog --title "Redes Wi-Fi Disponíveis" --msgbox "$redes_wifi" 30 80
}

network_manager() {
	nmanager=$(nmcli)
	dialog --title "Network Manager" --msgbox "$nmanager" 30 80
}

status_geral() {
	status_geral=$(nmcli general status)
	dialog --title "Status Geral" --msgbox "$status_geral" 30 80

}

menu_principal
