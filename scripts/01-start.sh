#!/bin/bash
# ==============================================================================
# 01-START.SH: SETUP MÍNIMO VITAL - PROJETO OPENSTACK-INB (REVISADO)
# ==============================================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# Validação de privilégios
[[ $EUID -ne 0 ]] && echo -e "${RED}Erro: Execute como root.${NC}" && exit 1

clear
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   OPENSTACK-INB: INICIALIZAÇÃO DE NÓ DO ZERO         ${NC}"
echo -e "${BLUE}======================================================${NC}"

# 1. Identificação do Nó via Input
read -p "Hostname (ex: mab, margaret, stephano): " INPUT_HOSTNAME
read -p "IP Gerência/CIDR (ex: 10.25.41.44/25): " INPUT_MGMT_IP

# 2. Configuração de Hostname
hostnamectl set-hostname "$INPUT_HOSTNAME"
sed -i "s/127.0.1.1.*/127.0.1.1\t$INPUT_HOSTNAME/g" /etc/hosts

# 3. Preparação do Netplan
# Backup de segurança das configurações antigas
mkdir -p /etc/netplan/backup_old
mv /etc/netplan/*.yaml /etc/netplan/backup_old/ 2>/dev/null

echo -e "${YELLOW}Configurando interface mgmt e preparando interfaces de dados...${NC}"

cat <<EOF > /etc/netplan/10-mgmt.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1: {optional: true}
    eno2: {optional: true}
  bonds:
    mgmt:
      interfaces: [eno1, eno2]
      addresses: [$INPUT_MGMT_IP]
      routes:
        - to: default
          via: 10.25.41.1
      nameservers:
        addresses: [10.20.20.2, 10.20.20.4]
        search: [inb.gov.br]
      parameters:
        mode: active-backup
        mii-monitor-interval: 100
EOF
# cat <<EOF > /etc/netplan/20-internal.yaml
# network:
#   version: 2
#   renderer: networkd
#   ethernets:
#     enp4s0f0:
#       mtu: 9000
#     enp4s0f1:
#       mtu: 9000
#     iscsi01:
#       addresses: ["192.168.130.24/24"]
#       mtu: 9000
#       critical: true
#     iscsi02:
#       addresses: ["192.168.130.44/24"]
#       mtu: 9000
#       critical: true
#     vlan132:
#       addresses: ["192.168.132.44/24"]
#       mtu: 9000
#       critical: true
# EOF


# 4. Aplicação da Configuração
chmod 600 /etc/netplan/01-netcfg.yaml
echo -e "${YELLOW}Aplicando Netplan...${NC}"
netplan apply

echo -e "\n${GREEN}✔ Nó '$INPUT_HOSTNAME' online na interface 'mgmt'.${NC}"
echo -e "${GREEN}✔ IPs de DNS internos configurados (10.20.20.x).${NC}"
echo -e "${GREEN}✔ MTU 9000 preparado para as interfaces de rede de dados.${NC}"
echo -e "${BLUE}======================================================${NC}"
echo -e "${YELLOW}Próximo passo: Rodar 02-prepare.sh para Update e Timeshift.${NC}"

echo "------------------------------------------------"
read -p "Rede configurada. Deseja reiniciar o servidor agora? (s/n): " CONFIRM
if [[ "$CONFIRM" == "s" || "$CONFIRM" == "S" ]]; then
    reboot
fi