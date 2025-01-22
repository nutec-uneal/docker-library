# LDAP Account Manager (LAM)

## Sumário

- [LDAP Account Manager (LAM)](#ldap-account-manager-lam)
  - [Sumário](#sumário)
  - [Projeto](#projeto)
    - [Estrutura](#estrutura)
  - [Executando](#executando)
    - [Scripts](#scripts)
    - [Varíaveis de Ambiente](#varíaveis-de-ambiente)

## Projeto

### Estrutura

| Nome               | Descrição                                                                 |
| ------------------ | ------------------------------------------------------------------------- |
| Dockerfile         | Documento de texto que contém os comandos para montagem da imagem Docker. |
| .dockerignore      | Documento com os arquivos excluídos de serem copiado para imagem.         |
| docker-compose.yml | Exemplo de como configurar e subir o container.                           |
| scripts (dir)      | Diretórios de scripts copiados para a imagem.                             |

## Executando

### Scripts

| Caminho         | Descrição                                         |
| --------------- | ------------------------------------------------- |
| /entrypoint.sh  | Inicialização de aplicação/processo/container.    |
| /healthcheck.sh | Verifica a saúde da aplicação/processo/container. |

**Obs**: consulte mais detalhes executando no terminal "*\<nomeDoScript\>.sh --help*".

### Varíaveis de Ambiente

| Nome              | Descrição                                                                            | script         |
| ----------------- | ------------------------------------------------------------------------------------ | -------------- |
| PHP_CONF_DIR      | Diretório de configuração do PHP. *`Padrão: /etc/php`*                               | entrypoint.sh  |
| PHP_FPM_CONF_DIR  | Diretório de configuração do PHP-FPM. *`Padrão: /etc/php-fpm`*                       | entrypoint.sh  |
| LAM_DIR           | Diretório da aplicação. *`Padrão: /var/www/html`*                                    | entrypoint.sh  |
| LAM_DATA_DIR      | Diretório de dados da aplicação. *`Padrão: /var/lib/lam`*                            | entrypoint.sh  |
| HEALTHC_HOST      | IP/Host do servidor alvo. *`Padrão: localhost`*                                      | healthcheck.sh |
| HEALTHC_PORT      | Porta do servidor alvo. *`Padrão: 9000`*                                             | healthcheck.sh |
| HEALTHC_SFILENAME | Nome do arquivos (script). *`Padrão: index.php`*                                     | healthcheck.sh |
| HEALTHC_REQMETHOD | Método HTTP. *`Padrão: GET`*                                                         | healthcheck.sh |
| PHP_INI_SCAN_DIR  | Diretório de configuração adicional do PHP. *`Preferencial: ${PHP_CONF_DIR}/conf.d`* | extra          |
