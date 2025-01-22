# OpenLDAP

## Sumário

- [OpenLDAP](#openldap)
  - [Sumário](#sumário)
  - [Projeto](#projeto)
    - [Estrutura](#estrutura)
  - [Executando](#executando)
    - [Scripts](#scripts)
    - [Varíaveis de Ambiente](#varíaveis-de-ambiente)

## Projeto

### Estrutura

| Nome                | Descrição                                                                 |
| ------------------- | ------------------------------------------------------------------------- |
| Dockerfile          | Documento de texto que contém os comandos para montagem da imagem Docker. |
| .dockerignore       | Documento com os arquivos excluídos de serem copiado para imagem.         |
| docker-compose.yml  | Exemplo de como configurar e subir o container.                           |
| scripts (dir)       | Diretórios de scripts copiados para a imagem.                             |
| custom-schema (dir) | Diretórios com esquemas LDAP customizados.                                |
| examples (dir)      | Diretórios com exemplos de configuração do OpenLDAP.                      |

## Executando

### Scripts

| Caminho         | Descrição                                              |
| --------------- | ------------------------------------------------------ |
| /entrypoint.sh  | Inicialização de aplicação/processo/container.         |
| /healthcheck.sh | Verifica a saúde da aplicação/processo/container.      |
| /db-dump.sh     | Gera Dump (.LDIF) dos bancos de dados com **slapcat**. |

**Obs**: consulte mais detalhes executando no terminal "*\<nomeDoScript\>.sh --help*".

### Varíaveis de Ambiente

| Nome                                               | Descrição                                                                     | script         |
| -------------------------------------------------- | ----------------------------------------------------------------------------- | -------------- |
| OLDAP_CONF_DIR                                     | Diretório de configuração do OpenLDAP. *`Padrão: /etc/openldap`*              | entrypoint.sh  |
| OLDAP_LOG_LEVEL                                    | Nível de Log do Deamon. *`Padrão: 0`*                                         | entrypoint.sh  |
| OLDAP_URL                                          | Lista de URL que o server usará. *`Padrão: ldap://127.0.0.1 ldaps://0.0.0.0`* | entrypoint.sh  |
| HEALTHC_URI                                        | URI do servidor alvo.   *`Padrão: ldap://localhost`*                          | healthcheck.sh |
| HEALTHC_BIND_DN                                    | DN de bind.                                                                   | healthcheck.sh |
| HEALTHC_BIND_PASSWORD / HEALTHC_BIND_PASSWORD_FILE | Senha do "DN de bind".                                                        | healthcheck.sh |
| HEALTHC_BASE_DN                                    | DN base da busca. *`Padrão: HEALTHC_BIND_DN`*                                 | healthcheck.sh |
