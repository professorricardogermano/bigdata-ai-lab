#!/bin/bash

# ==============================================================================
# Script de Configuração Completa do Ambiente Big Data & IA no Debian 12
# Autor: Adaptado por Gemini para Ricardo Germano
# Data: 30 de Maio de 2025
#
# Este script automatiza a instalação e configuração de:
# - OpenJDK (Java Development Kit)
# - Apache Hadoop (Modo Pseudo-Distribuído)
# - Apache Spark
# - Apache Hive
# - Apache Kafka (com Zookeeper)
# - MongoDB
# - Python 3, Pip, PySpark
# - JupyterLab
# - VS Code Server
# - Ollama (com modelo Llama 2)
#
# Deve ser executado em uma máquina virtual Debian 12 limpa (como usuário com sudo).
# Recomendações de VM: Mínimo 8GB RAM, 4 vCPUs, 100GB disco.
# ==============================================================================

# Variáveis de Configuração
JAVA_VERSION="17" # Versão do Java a ser instalada
HADOOP_VERSION="3.3.6"
SPARK_VERSION="3.5.1"
HIVE_VERSION="3.1.3"
KAFKA_VERSION="3.6.1" # A versão do Kafka inclui o Zookeeper
SCALA_VERSION="2.12" # Versão do Scala compatível com Spark 3.5.1
PYTHON_VERSION="3.11" # A versão padrão do Debian 12 é geralmente 3.11 ou superior
USER_HOME="/home/$(logname)" # Pega o diretório home do usuário que executa o script

# URLs de Download (verifique sempre as versões mais recentes nos sites oficiais)
HADOOP_URL="https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
SPARK_URL="https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop3.tgz"
KAFKA_URL="https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz" # Compatível com Scala 2.13, mas funciona
HIVE_URL="https://dlcdn.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz"

# Funções de Log
log_info() {
    echo "INFO: $1"
}
log_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# 1. Atualização do Sistema e Instalação de Ferramentas Essenciais
# ------------------------------------------------------------------------------
log_info "Atualizando o sistema e instalando ferramentas essenciais..."
sudo apt update || log_error "Falha ao executar apt update."
sudo apt upgrade -y || log_error "Falha ao executar apt upgrade."
sudo apt install -y default-jdk wget curl net-tools rsync openssh-server build-essential python3-dev python3-pip python3-venv || log_error "Falha ao instalar pacotes essenciais."

# ------------------------------------------------------------------------------
# 2. Configuração de Usuário e SSH
# ------------------------------------------------------------------------------
log_info "Configurando SSH para acesso localhost sem senha..."
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
# Gerar chave SSH se não existir
if [ ! -f "$USER_HOME/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -P '' -f "$USER_HOME/.ssh/id_rsa" || log_error "Falha ao gerar chave SSH."
fi
cat "$USER_HOME/.ssh/id_rsa.pub" >> "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
# Testar SSH localhost
ssh -o StrictHostKeyChecking=no localhost exit || log_error "Falha no teste SSH localhost. Verifique as configurações."

# ------------------------------------------------------------------------------
# 3. Instalação e Configuração do Hadoop
# ------------------------------------------------------------------------------
log_info "Instalando e configurando Apache Hadoop $HADOOP_VERSION..."
cd /opt || log_error "Diretório /opt não encontrado."
sudo wget "$HADOOP_URL" || log_error "Falha ao baixar Hadoop."
sudo tar -xzf hadoop-$HADOOP_VERSION.tar.gz || log_error "Falha ao extrair Hadoop."
sudo mv hadoop-$HADOOP_VERSION hadoop || log_error "Falha ao renomear diretório Hadoop."
sudo rm hadoop-$HADOOP_VERSION.tar.gz

# Configura variáveis de ambiente
echo "export HADOOP_HOME=/opt/hadoop" | sudo tee -a /etc/profile.d/hadoop.sh
echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /etc/profile.d/hadoop.sh
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" | sudo tee -a /etc/profile.d/hadoop.sh
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" | sudo tee -a /etc/profile.d/hadoop.sh
echo "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\"" | sudo tee -a /etc/profile.d/hadoop.sh
source /etc/profile.d/hadoop.sh # Carrega as variáveis de ambiente

# Configurações do Hadoop (core-site.xml, hdfs-site.xml, mapred-site.xml, yarn-site.xml)
# core-site.xml
sudo tee /opt/hadoop/etc/hadoop/core-site.xml > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop-$(logname)</value>
    </property>
</configuration>
EOF

# hdfs-site.xml
sudo tee /opt/hadoop/etc/hadoop/hdfs-site.xml > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///tmp/hadoop-$(logname)/dfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///tmp/hadoop-$(logname)/dfs/data</value>
    </property>
</configuration>
EOF

# mapred-site.xml
sudo tee /opt/hadoop/etc/hadoop/mapred-site.xml > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF

# yarn-site.xml
sudo tee /opt/hadoop/etc/hadoop/yarn-site.xml > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>localhost</value>
    </property>
</configuration>
EOF

# Define JAVA_HOME para o Hadoop
sudo sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=$(readlink -f /usr/bin/java | sed 's/\/bin\/java//')|" /opt/hadoop/etc/hadoop/hadoop-env.sh

# Formatar o NameNode e iniciar o Hadoop
log_info "Formatando NameNode do Hadoop..."
yes | hdfs namenode -format || log_error "Falha ao formatar NameNode."

log_info "Iniciando Hadoop (HDFS e YARN)..."
start-dfs.sh || log_error "Falha ao iniciar DFS."
start-yarn.sh || log_error "Falha ao iniciar YARN."
jps # Verifica se os processos estão rodando

# ------------------------------------------------------------------------------
# 4. Instalação e Configuração do Spark
# ------------------------------------------------------------------------------
log_info "Instalando e configurando Apache Spark $SPARK_VERSION..."
cd /opt || log_error "Diretório /opt não encontrado."
sudo wget "$SPARK_URL" || log_error "Falha ao baixar Spark."
sudo tar -xzf spark-$SPARK_VERSION-bin-hadoop3.tgz || log_error "Falha ao extrair Spark."
sudo mv spark-$SPARK_VERSION-bin-hadoop3 spark || log_error "Falha ao renomear diretório Spark."
sudo rm spark-$SPARK_VERSION-bin-hadoop3.tgz

# Configura variáveis de ambiente
echo "export SPARK_HOME=/opt/spark" | sudo tee -a /etc/profile.d/spark.sh
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" | sudo tee -a /etc/profile.d/spark.sh
echo "export SPARK_CONF_DIR=\$SPARK_HOME/conf" | sudo tee -a /etc/profile.d/spark.sh
echo "export PYSPARK_PYTHON=python$PYTHON_VERSION" | sudo tee -a /etc/profile.d/spark.sh
source /etc/profile.d/spark.sh

# Configurações do Spark (spark-env.sh)
sudo cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
sudo tee -a /opt/spark/conf/spark-env.sh > /dev/null <<EOF
export JAVA_HOME=$(readlink -f /usr/bin/java | sed 's/\/bin\/java//')
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
EOF

# Iniciar Spark (modo standalone)
log_info "Iniciando Spark standalone master..."
start-master.sh || log_error "Falha ao iniciar Spark master."
log_info "Iniciando Spark standalone worker..."
start-worker.sh spark://localhost:7077 || log_error "Falha ao iniciar Spark worker."

# ------------------------------------------------------------------------------
# 5. Instalação e Configuração do Hive
# ------------------------------------------------------------------------------
log_info "Instalando e configurando Apache Hive $HIVE_VERSION..."
cd /opt || log_error "Diretório /opt não encontrado."
sudo wget "$HIVE_URL" || log_error "Falha ao baixar Hive."
sudo tar -xzf apache-hive-$HIVE_VERSION-bin.tar.gz || log_error "Falha ao extrair Hive."
sudo mv apache-hive-$HIVE_VERSION-bin hive || log_error "Falha ao renomear diretório Hive."
sudo rm apache-hive-$HIVE_VERSION-bin.tar.gz

# Configura variáveis de ambiente
echo "export HIVE_HOME=/opt/hive" | sudo tee -a /etc/profile.d/hive.sh
echo "export PATH=\$PATH:\$HIVE_HOME/bin" | sudo tee -a /etc/profile.d/hive.sh
source /etc/profile.d/hive.sh

# Configura Hive (hive-env.sh e hive-site.xml para Derby)
sudo cp /opt/hive/conf/hive-env.sh.template /opt/hive/conf/hive-env.sh
sudo tee -a /opt/hive/conf/hive-env.sh > /dev/null <<EOF
export HADOOP_HOME=/opt/hadoop
export HIVE_CONF_DIR=/opt/hive/conf
export JAVA_HOME=$(readlink -f /usr/bin/java | sed 's/\/bin\/java//')
EOF

sudo tee /opt/hive/conf/hive-site.xml > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:derby:;databaseName=/opt/hive/metastore_db;create=true</value>
        <description>JDBC connect string for a JDBC metastore</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.apache.derby.jdbc.EmbeddedDriver</value>
        <description>Driver for JDBC connection</description>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
        <description>Location of Hive's default warehouse</description>
    </property>
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.cli.print.header</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.cli.print.current.db.only</name>
        <value>true</value>
    </property>
</configuration>
EOF

# Inicializar o Metastore do Hive
log_info "Inicializando o Metastore do Hive..."
schematool -dbType derby -initSchema || log_error "Falha ao inicializar Hive Metastore."

# Criar diretório warehouse no HDFS e dar permissão
log_info "Criando diretório Hive Warehouse no HDFS..."
hdfs dfs -mkdir -p /user/hive/warehouse || log_error "Falha ao criar diretório HDFS para Hive."
hdfs dfs -chmod g+w /user/hive/warehouse || log_error "Falha ao definir permissões para diretório Hive HDFS."

# ------------------------------------------------------------------------------
# 6. Instalação e Configuração do Kafka e Zookeeper
# ------------------------------------------------------------------------------
log_info "Instalando e configurando Apache Kafka $KAFKA_VERSION (com Zookeeper)..."
cd /opt || log_error "Diretório /opt não encontrado."
sudo wget "$KAFKA_URL" || log_error "Falha ao baixar Kafka."
sudo tar -xzf kafka_2.13-$KAFKA_VERSION.tgz || log_error "Falha ao extrair Kafka."
sudo mv kafka_2.13-$KAFKA_VERSION kafka || log_error "Falha ao renomear diretório Kafka."
sudo rm kafka_2.13-$KAFKA_VERSION.tgz

# Configura variáveis de ambiente
echo "export KAFKA_HOME=/opt/kafka" | sudo tee -a /etc/profile.d/kafka.sh
echo "export PATH=\$PATH:\$KAFKA_HOME/bin" | sudo tee -a /etc/profile.d/kafka.sh
source /etc/profile.d/kafka.sh

# Configuração do Zookeeper
sudo mkdir -p /tmp/zookeeper
sudo sed -i 's|dataDir=/tmp/zookeeper|dataDir=/tmp/zookeeper|' /opt/kafka/config/zookeeper.properties

# Configuração do Kafka
sudo sed -i 's|log.dirs=/tmp/kafka-logs|log.dirs=/tmp/kafka-logs|' /opt/kafka/config/server.properties

# Iniciar Zookeeper e Kafka
log_info "Iniciando Zookeeper..."
nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /opt/kafka/zookeeper.log 2>&1 &
sleep 5 # Dá um tempo para o Zookeeper iniciar

log_info "Iniciando Kafka broker..."
nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /opt/kafka/kafka.log 2>&1 &
sleep 5 # Dá um tempo para o Kafka iniciar

# ------------------------------------------------------------------------------
# 7. Instalação do MongoDB
# ------------------------------------------------------------------------------
log_info "Instalando MongoDB..."
# Importar a chave pública GPG do MongoDB
sudo apt-get install -y gnupg curl || log_error "Falha ao instalar gnupg ou curl."
curl -fsSL https://www.mongodb.org/static/pg/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-archive-keyring.gpg --dearmor || log_error "Falha ao importar chave MongoDB."

# Criar o arquivo de lista para MongoDB
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list || log_error "Falha ao criar sources.list MongoDB."

# Instalar MongoDB
sudo apt update || log_error "Falha ao executar apt update para MongoDB."
sudo apt install -y mongodb-org || log_error "Falha ao instalar mongodb-org."

# Iniciar e habilitar MongoDB
sudo systemctl start mongod || log_error "Falha ao iniciar MongoDB."
sudo systemctl enable mongod || log_error "Falha ao habilitar MongoDB no boot."
sudo systemctl status mongod | grep "active (running)" || log_error "MongoDB não está rodando."

# ------------------------------------------------------------------------------
# 8. Configuração de Python e JupyterLab
# ------------------------------------------------------------------------------
log_info "Configurando Python, Pip e JupyterLab..."
sudo apt install -y python3-venv || log_error "Falha ao instalar python3-venv."
# Cria e ativa um ambiente virtual Python (opcional, mas boa prática)
python3 -m venv "$USER_HOME/venv-bigdata"
source "$USER_HOME/venv-bigdata/bin/activate" || log_error "Falha ao ativar ambiente virtual Python."

# Instala bibliotecas Python
pip install --upgrade pip
pip install pyspark jupyterlab notebook pandas pymongo kafka-python requests || log_error "Falha ao instalar bibliotecas Python."

# Cria diretório para notebooks
mkdir -p "$USER_HOME/bigdata-ai-lab/notebooks"
# Crie um arquivo de configuração Jupyter para acesso remoto
jupyter lab --generate-config -y
echo "c.ServerApp.allow_origin = '*'" >> "$USER_HOME/.jupyter/jupyter_lab_config.py"
echo "c.ServerApp.ip = '0.0.0.0'" >> "$USER_HOME/.jupyter/jupyter_lab_config.py"
echo "c.ServerApp.port = 8888" >> "$USER_HOME/.jupyter/jupyter_lab_config.py"
echo "c.ServerApp.open_browser = False" >> "$USER_HOME/.jupyter/jupyter_lab_config.py"
echo "c.ServerApp.password = 'sha1:a211e4001d81b312781b4b73b5df5b5e3240212f' # Senha 'bigdata'" | sudo tee -a "$USER_HOME/.jupyter/jupyter_lab_config.py"

# Define um alias para iniciar o JupyterLab
echo "alias start_jupyter='source $USER_HOME/venv-bigdata/bin/activate && jupyter lab --port=8888 --no-browser --ip=0.0.0.0'" | tee -a "$USER_HOME/.bashrc"
echo "alias start_vs_code_server='code-server --bind-addr 0.0.0.0:8080 --auth password'" | tee -a "$USER_HOME/.bashrc"

# ------------------------------------------------------------------------------
# 9. Instalação do VS Code Server
# ------------------------------------------------------------------------------
log_info "Instalando VS Code Server..."
curl -fsSL https://code-server.dev/install.sh | sh || log_error "Falha ao instalar VS Code Server."

# ------------------------------------------------------------------------------
# 10. Instalação do Ollama
# ------------------------------------------------------------------------------
log_info "Instalando Ollama e baixando modelo llama2..."
curl -fsSL https://ollama.com/install.sh | sh || log_error "Falha ao instalar Ollama."
# Baixa um modelo básico para o Ollama
ollama pull llama2 || log_error "Falha ao baixar modelo llama2 do Ollama. Verifique a conexão ou tente outro modelo."
log_info "Modelo llama2 baixado para Ollama."

# ------------------------------------------------------------------------------
# 11. Finalização e Ajustes
# ------------------------------------------------------------------------------
log_info "Ajustando permissões de diretórios..."
sudo chown -R $(logname):$(logname) /opt/hadoop /opt/spark /opt/hive /opt/kafka "$USER_HOME/venv-bigdata" "$USER_HOME/.jupyter" || log_error "Falha ao ajustar permissões."

log_info "Adicionando alias de ambiente ao .bashrc para o usuário atual..."
# As variáveis de ambiente já foram adicionadas a /etc/profile.d, mas adicionamos aliases úteis.
echo "" | tee -a "$USER_HOME/.bashrc"
echo "# Variáveis de ambiente para Big Data e IA" | tee -a "$USER_HOME/.bashrc"
echo "export HADOOP_HOME=/opt/hadoop" | tee -a "$USER_HOME/.bashrc"
echo "export SPARK_HOME=/opt/spark" | tee -a "$USER_HOME/.bashrc"
echo "export HIVE_HOME=/opt/hive" | tee -a "$USER_HOME/.bashrc"
echo "export KAFKA_HOME=/opt/kafka" | tee -a "$USER_HOME/.bashrc"
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$SPARK_HOME/bin:\$SPARK_HOME/sbin:\$HIVE_HOME/bin:\$KAFKA_HOME/bin" | tee -a "$USER_HOME/.bashrc"
echo "export JAVA_HOME=$(readlink -f /usr/bin/java | sed 's/\/bin\/java//')" | tee -a "$USER_HOME/.bashrc"
echo "export PYSPARK_PYTHON=python$PYTHON_VERSION" | tee -a "$USER_HOME/.bashrc"
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" | tee -a "$USER_HOME/.bashrc"
echo "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\"" | tee -a "$USER_HOME/.bashrc"

# Cria diretório de dados para as atividades
mkdir -p "$USER_HOME/data"

log_info "Configuração concluída!"
log_info "Por favor, REINICIE o terminal ou execute 'source ~/.bashrc' para carregar as variáveis de ambiente."
log_info "Serviços iniciados: HDFS, YARN, Zookeeper, Kafka, MongoDB, Spark Master/Worker."
log_info "Para iniciar JupyterLab, digite 'start_jupyter' no terminal."
log_info "Para iniciar VS Code Server, digite 'start_vs_code_server' no terminal."
log_info "Para interagir com Ollama, digite 'ollama run llama2' no terminal."
log_info "Se o usuário 'aluno' não existir, crie-o: sudo adduser aluno"
log_info "Se for usar outro usuário, lembre-se de ajustar 'USER_HOME' e as permissões."