# 📜 Manifesto de Requisitos: Bare Metal OpenStack (INB)

Este documento define o padrão obrigatório para que qualquer servidor físico (Dell, HP ou Legado) seja aceito pela automação Ansible/Ironic.

---

## 1. Configurações de Firmware (BIOS/UEFI)
O servidor deve ser configurado manualmente antes do ingresso no Ironic:

* **Boot Mode:** Preferencialmente **UEFI**. (Legacy BIOS aceito apenas para máquinas pré-2015).
* **Boot Order:** 1.  **Network Boot (PXE)** via NIC 1.
    2.  **Local Disk** (HDD/SSD/NVMe).
* **Wake on LAN (WoL):** **ENABLED**. (Obrigatório para máquinas sem iDRAC/iLO/IPMI).
* **Virtualização (VT-x / AMD-V):** **ENABLED**.
* **SATA Mode:** **AHCI** (Evite RAID via software/proprietário).

---

## 2. Requisitos de Rede (NICs Físicas)
Todo nó Bare Metal deve possuir, no mínimo, **duas interfaces de rede físicas**:

| Interface | VLAN | Função |
| :--- | :--- | :--- |
| **NIC 1** | **41 (Provisioning)** | PXE Boot, TFTP, iSCSI e comunicação com o MAB. |
| **NIC 2** | **Trunk/External** | Tráfego de dados das instâncias (Neutron) e rede externa. |

> **⚠️ IMPORTANTE:** O MAC Address cadastrado no Ironic **DEVE** ser o da **NIC 1** (a porta que faz o boot PXE).

---

## 3. Especificações Mínimas (Sizing)
Para garantir o funcionamento do Agente Ironic (IPA) e das imagens Noble:

* **CPU:** Mínimo **4 Cores** (x86_64).
* **RAM:** Mínimo **16 GB** (O Agente IPA carrega em RAM e consome ~2GB).
* **Disco:** Mínimo **100 GB** de disco local (Recomendado **4 TB** para Nodes de Produção).

---

## 4. Checklist de Cadastro (all.yml)
Antes de rodar o Ansible, colete os seguintes dados para o `group_vars/all.yml`:
- [ ] Nome único do host (ex: lamina-hp-01).
- [ ] MAC Address da NIC 1.
- [ ] IP da Gerência Remota (se houver).
- [ ] Usuário e Senha da Gerência (iDRAC/iLO/IPMI).
- [ ] Driver pretendido: `idrac`, `ilo`, `ipmi` ou `manual` (WoL).

---
*Gerado automaticamente em: $(date '+%Y-%m-%d %H:%M:%S')*
