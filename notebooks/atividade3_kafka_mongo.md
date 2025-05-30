# Atividade 3: Introdução ao Kafka e MongoDB

## Objetivo

Esta atividade visa introduzir os conceitos de sistemas de mensageria distribuída com **Apache Kafka** e bancos de dados NoSQL orientados a documentos com **MongoDB**. Iremos explorar seus usos básicos via linha de comando.

## 1. Apache Kafka: Mensageria em Tempo Real

Kafka é uma plataforma distribuída de streaming de eventos, usada para construir pipelines de dados em tempo real e aplicações de streaming.

### Conceitos Chave:
* **Tópico:** Uma categoria ou nome de feed para a qual os registros são publicados.
* **Produtor:** Aplicações que publicam (escrevem) dados em tópicos Kafka.
* **Consumidor:** Aplicações que se inscrevem em tópicos e processam os registros produzidos.
* **Broker:** Servidor Kafka que armazena os dados dos tópicos.
* **Zookeeper:** Serviço que o Kafka usa para gerenciar o cluster (versões mais novas do Kafka estão movendo essa funcionalidade para dentro do próprio Kafka).

### Comandos Básicos (Execute no terminal da sua VM)

Assumimos que Kafka e Zookeeper estão instalados e rodando na sua VM.

#### a) Criar um Tópico

```bash
# Navegue até o diretório bin do Kafka (ex: /opt/kafka/bin)
cd /opt/kafka/bin

# Crie um tópico chamado 'minha_loja_eventos'
./kafka-topics.sh --create --topic minha_loja_eventos --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1