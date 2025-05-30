-- Atividade 2: Análise de Dados com Hive e Spark SQL

-- Objetivo:
-- Familiarizar os alunos com a criação de tabelas no Hive e a execução de consultas SQL
-- para análise de grandes volumes de dados.

-- Pré-requisito:
-- Assegure-se de que o Hive esteja configurado e que o HDFS esteja acessível.
-- Para esta atividade, considere que teremos um arquivo de dados no HDFS.

-- Cenário de Dados:
-- Vamos usar um conjunto de dados de log de acessos a um website.
-- Crie um diretório no HDFS e adicione um arquivo 'access_logs.csv' com o seguinte conteúdo:
-- (Exemplo: Salve este conteúdo em /home/aluno/data/access_logs.csv na sua VM e depois copie para o HDFS)

-- Conteúdo de /home/aluno/data/access_logs.csv:
-- ID,Timestamp,IP_Origem,Pagina_Acessada,Status_HTTP,Bytes_Enviados,Metodo_HTTP
-- 1,2024-01-01 10:00:00,192.168.1.1,homepage,200,1024,GET
-- 2,2024-01-01 10:00:05,192.168.1.2,products/1,200,2048,GET
-- 3,2024-01-01 10:00:10,192.168.1.1,homepage,304,0,GET
-- 4,2024-01-01 10:00:15,192.168.1.3,contact,404,512,GET
-- 5,2024-01-01 10:00:20,192.168.1.2,products/2,200,1536,GET
-- 6,2024-01-01 10:00:25,192.168.1.4,homepage,200,1024,GET
-- 7,2024-01-01 10:00:30,192.168.1.1,about_us,200,768,GET
-- 8,2024-01-01 10:00:35,192.168.1.5,products/1,500,0,GET
-- 9,2024-01-01 10:00:40,192.168.1.3,homepage,200,1024,GET
-- 10,2024-01-01 10:00:45,192.168.1.4,products/3,200,1800,GET

-- Copie o arquivo para o HDFS:
-- hdfs dfs -mkdir -p /user/hive/warehouse/access_logs
-- hdfs dfs -put /home/aluno/data/access_logs.csv /user/hive/warehouse/access_logs/

-- 1. Criação da Tabela Externa no Hive
-- A tabela externa referencia dados que já existem no HDFS e não são gerenciados pelo Hive.
CREATE EXTERNAL TABLE IF NOT EXISTS access_logs (
    ID INT,
    Timestamp STRING,
    IP_Origem STRING,
    Pagina_Acessada STRING,
    Status_HTTP INT,
    Bytes_Enviados INT,
    Metodo_HTTP STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/access_logs'
TBLPROPERTIES ('skip.header.line.count'='1'); -- Ignora a linha de cabeçalho

-- Verifique se a tabela foi criada e os dados estão visíveis:
SELECT * FROM access_logs LIMIT 5;

-- 2. Consultas Básicas com HiveQL

-- a) Contar o número total de acessos
SELECT COUNT(*) FROM access_logs;

-- b) Listar as 5 páginas mais acessadas
SELECT Pagina_Acessada, COUNT(*) AS Total_Acessos
FROM access_logs
GROUP BY Pagina_Acessada
ORDER BY Total_Acessos DESC
LIMIT 5;

-- c) Encontrar acessos com status HTTP de erro (4xx ou 5xx)
SELECT ID, Timestamp, IP_Origem, Pagina_Acessada, Status_HTTP
FROM access_logs
WHERE Status_HTTP >= 400;

-- d) Calcular o total de bytes enviados por IP de origem
SELECT IP_Origem, SUM(Bytes_Enviados) AS Total_Bytes_Enviados
FROM access_logs
GROUP BY IP_Origem
ORDER BY Total_Bytes_Enviados DESC;

-- 3. Utilizando Spark SQL para Consultar Tabelas Hive (Opcional, se o ambiente Spark estiver integrado com Hive Metastore)
-- No JupyterLab (Python), você pode usar o SparkSession para consultar as tabelas Hive.
-- Basta iniciar a SparkSession com suporte ao Hive:
--
-- from pyspark.sql import SparkSession
-- spark = SparkSession.builder \
--     .appName("SparkHiveIntegration") \
--     .enableHiveSupport() \
--     .getOrCreate()
--
-- df_logs = spark.sql("SELECT * FROM access_logs")
-- df_logs.show(5)
--
-- spark.sql("SELECT Pagina_Acessada, COUNT(*) FROM access_logs GROUP BY Pagina_Acessada").show()

-- Exercícios Práticos:
-- Utilize os comandos HiveQL (ou Spark SQL, se preferir) para responder:
-- 1. Qual o dia e hora (apenas a hora) com o maior número de acessos?
--    (Dica: Use funções de string ou data para extrair a hora do campo Timestamp)
-- 2. Quantos acessos cada IP de origem fez, mas apenas para status HTTP 200 (sucesso)?
-- 3. Liste todas as páginas acessadas com o método HTTP 'POST'.
-- 4. Encontre o IP de origem que enviou a maior quantidade de bytes em uma única requisição.

-- Limpeza (Opcional):
-- DROP TABLE IF EXISTS access_logs;