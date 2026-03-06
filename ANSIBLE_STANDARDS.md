Cada playbook deve ter:
✅ --check funcionando (teste final se toda a configuração foi aplicada)
✅ nunca aplicar atualizações e correções diretamente nos hosts, sempre via playbook
✅ toda a solução será em HA, então a configuração sempre aplicada nos três hosts iguais
✅ Handlers para restarts
✅ sempre que possível gere todo o playbook com um único comando usando " cat <<'EOF'>> "
✅ sempre utilize o arquivo de variáveis para manter a configuração personalizada em um único arquivo, facilitando a reinstalação futura.
✅ A solução ao final tem que ser replicavel e escalavel
✅ Utilizamos o Postgres e o NGINX
✅ Nunca utilizar o MariaDB, MySQL ou o Apache ou Apache2
✅ Sempre seguir a estrutura de playbook de colocar a chamada na pasta playbooks, e dentro da roles correspondente o handler, task e template
✅ Usar o LDAP INB, com os administradores com poderes totais sobre toda a solução
✅ O Skyline é primeira opção, deve ser configurado em 10.25.41.85/, mas o Horizon também deve ser instalado, em 10.25.41.85/horizon
✅ sempre utilizar a rede mgmt (vlan70) para acesso a página e gerenciamento
✅ sempre utilizar a vlan130 para acesso exclusivo ao storage
✅ semrpe utilizar a vlan132 para comunicação entre os hosts
✅ Links para considerar:
    https://docs.openstack.org/cinder/rocky/configuration/block-storage/config-options.html