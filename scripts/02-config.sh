#!/bin/bash

# Cores para facilitar a leitura
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando Validação, Atualização e Backup ---${NC}"

# 1. Testar conexão e DNS
echo -n "Testando conectividade... "
if ping -c 2 8.8.8.8 &> /dev/null && host google.com &> /dev/null; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FALHA]${NC} Verifique a rede antes de prosseguir."
    exit 1
fi

# 2. Atualizar repositórios e Sistema
echo "Atualizando repositórios..."
sudo apt update -y

echo Parar o serviço do Apache
sudo service apache2 stop

echo Remover o Apache e as suas dependências
sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-common

echo Remover demais dependências sem uso
sudo apt-get autoremove

echo Verificar se ainda existe arquivos de configuração
whereis apache2

echo Remova o retorno do comando acima. Ex.: Se o retorno for /etc/apache2
sudo rm -rf /etc/apache2

echo "Instalando dependências e Timeshift..."
# Adicionamos o ppa do timeshift para garantir a versão mais estável
sudo add-apt-repository -y ppa:teejee2008/ppa
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-pip python3-dev vim curl nginx timeshift

# 3. Upgrade do Sistema
echo "Realizando upgrade do sistema..."
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# 4. Configurar e Criar Snapshot com Timeshift
echo -e "${GREEN}Criando Snapshot de segurança (inicial_snapshot)...${NC}"

# Configura o timeshift para usar a partição do sistema (RSYNC) 
# e desabilita backups automáticos (faremos apenas manuais para não encher o disco)
sudo timeshift --check
sudo timeshift --create --comments "inicial_snapshot" --tags D

echo -e "${GREEN}--- Lista de Snapshots Disponíveis ---${NC}"
sudo timeshift --list

# 5. Limpeza final
sudo apt autoremove -y

echo -e "${GREEN}--- Sistema pronto e protegido! ---${NC}"
echo "Para restaurar este estado no futuro, use: sudo timeshift --restore"
