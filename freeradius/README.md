# FreeRADIUS

## Sumário

- [FreeRADIUS](#freeradius)
  - [Sumário](#sumário)
  - [Diretórios](#diretórios)
  - [Executando](#executando)
    - [Scripts](#scripts)

## Diretórios

| Nome                  | Descrição                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------- |
| /run/radius           | Diretório para armazenamento em tempo de execução (*Runtime*). Ex.: *`.pid, .sock, etc.`* |
| /etc/raddb            | Diretório de configuração.                                                                |
| /var/lib/radius       | Diretório para armazenamento de dados.                                                    |
| /var/cache/radius     | Diretório para armazenamento de cache.                                                    |
| /var/log/radius       | Diretório para armazenamento de logs.                                                     |
| /etc/radiusclient     | Conjunto de dicionários *Radiu Client*.                                                   |
| /usr/share/freeradius | Conjunto de dicionários FreeRADIUS.                                                       |

## Executando

### Scripts

| Variável                               | Descrição                                                                      | Script               |
| -------------------------------------- | ------------------------------------------------------------------------------ | -------------------- |
| PERSISTENT_MODE                        | Quando definido, a aplicação será recarregada após esperá o tempo configurado. | docker-entrypoint.sh |
| HEALTH_HOST                            | Teste de saúde - Host. *`Padrão: 127.0.0.1`*                                   | healthcheck.sh       |
| HEALTH_PORT                            | Teste de saúde - Porta. *`Padrão: 11812`*                                      | healthcheck.sh       |
| HEALTH_PROTOCOL                        | Teste de saúde - Protocolo. *`Padrão: udp`*                                    | healthcheck.sh       |
| HEALTH_USER                            | Teste de saúde - Usuário.                                                      | healthcheck.sh       |
| HEALTH_PASSWORD / HEALTH_PASSWORD_FILE | Teste de saúde - Senha.                                                        | healthcheck.sh       |
| HEALTH_TYPE                            | Teste de saúde - Tipo de autentição. *`Padrão: pap`*                           | healthcheck.sh       |
| HEALTH_NAS_PORT_NUMBER                 | Teste de saúde - Número da porta NAS. *`Padrão: 0`*                            | healthcheck.sh       |
| HEALTH_SECRET / HEALTH_SECRET_FILE     | Teste de saúde - Segredo.                                                      | healthcheck.sh       |

