# Relatório de Análise de Sentimento de Avaliações de Produtos - TechMarket Online

---

**Aluno(a):** [Seu Nome Completo]
**Data:** 30 de Maio de 2025 (ou a data da sua entrega)
**Disciplina:** MBA em Ciências de Dados e Big Data - Big Data Analytics e Inteligência Artificial
**Professor:** Ricardo Germano

---

## 1. Introdução: Dados em Ação na TechMarket Online

A "TechMarket Online", uma empresa líder no e-commerce, acumula diariamente um vasto volume de avaliações de clientes. Esses textos livres, embora ricos em informações, são desafiadores de analisar manualmente. Este relatório detalha uma solução de Big Data e Inteligência Artificial para processar essas avaliações, identificar o sentimento dos clientes e extrair insights estratégicos que possam guiar a empresa na melhoria de produtos e na satisfação do cliente.

---

## 2. Metodologia: O Pipeline de Big Data & IA

Nosso pipeline de análise de sentimento foi construído utilizando as seguintes tecnologias e um fluxo de trabalho em três etapas principais:

### 2.1. Ingestão e Armazenamento Bruto (HDFS / Hive)

* **Finalidade:** Armazenar os dados de avaliações de produtos (formato CSV) de forma distribuída e resiliente.
* **Ferramentas:**
    * **HDFS (Hadoop Distributed File System):** Utilizado como o Data Lake para guardar o arquivo `product_reviews.csv`.
    * **Apache Hive:** Uma tabela externa (`reviews_raw`) foi criada sobre o HDFS, permitindo acesso via SQL aos dados brutos.

### 2.2. Processamento e Análise de Sentimento (PySpark / Ollama)

* **Finalidade:** Extrair e classificar o sentimento de cada avaliação textual.
* **Ferramentas:**
    * **Apache Spark (PySpark):** Utilizado para carregar os dados do Hive em um DataFrame, processá-los em memória e aplicar a lógica de sentimento em larga escala.
    * **Ollama (com modelo Llama 2):** Integrado via uma User-Defined Function (UDF) do PySpark. O LLM foi consultado para classificar o `review_text` como "positivo", "negativo" ou "neutro", e o resultado foi adicionado como uma nova coluna `sentiment` ao DataFrame.

### 2.3. Armazenamento e Análise de Insights (MongoDB / Spark SQL)

* **Finalidade:** Persistir os dados enriquecidos (com a coluna de sentimento) em um banco de dados NoSQL flexível e realizar consultas avançadas.
* **Ferramentas:**
    * **MongoDB:** O banco de dados orientado a documentos foi escolhido para armazenar os dados processados na coleção `techmarket.reviews_processed`, devido à sua flexibilidade de esquema.
    * **Spark SQL:** Utilizado para realizar consultas analíticas complexas sobre o DataFrame enriquecido (registrado como uma visão temporária ou lido do MongoDB), permitindo extrair os insights apresentados na próxima seção.

---

## 3. Análise de Sentimento e Principais Resultados

Esta seção detalha as descobertas obtidas a partir da análise dos dados de avaliações.

### 3.1. Distribuição Geral de Sentimentos

Após o processamento com o Ollama, a distribuição geral do sentimento das avaliações é a seguinte:

| Sentimento | Contagem | Porcentagem |
|:-----------|:---------|:------------|
| Positivo   | [Número] | [X.X]%      |
| Negativo   | [Número] | [Y.Y]%      |
| Neutro     | [Número] | [Z.Z]%      |
| **Total** | [Número] | **100%** |

* **Observação:** [Comente sobre a predominância de sentimentos, ou qualquer anomalia. Ex: "A maioria das avaliações é positiva, o que é um bom indicativo da satisfação geral do cliente, no entanto, a presença de X% de avaliações negativas merece atenção."].

### 3.2. Produtos com Maior Proporção de Avaliações Negativas

Identificamos os produtos que mais contribuem para o sentimento negativo dos clientes, necessitando de atenção especial:

| Produto             | Categoria   | Total de Avaliações | Avaliações Negativas | % Negativas |
|:--------------------|:------------|:--------------------|:---------------------|:------------|
| [Nome do Produto 1] | [Categoria] | [Num Total]         | [Num Negativas]      | [X.X]%      |
| [Nome do Produto 2] | [Categoria] | [Num Total]         | [Num Negativas]      | [Y.Y]%      |
| [Nome do Produto 3] | [Categoria] | [Num Total]         | [Num Negativas]      | [Z.Z]%      |
| *(Adicione mais, se aplicável)* | | | | |

* **Análise:** [Comente o porquê desses produtos estarem nessa lista. Ex: "O 'Fone Bluetooth Y' se destaca com X% de avaliações negativas, indicando um problema recorrente relacionado ao conforto ou encaixe na orelha, como sugerido nos textos das avaliações."].

### 3.3. Sentimento por Categoria de Produto

A análise por categoria revela quais segmentos de produtos performam melhor ou pior em termos de satisfação do cliente:

| Categoria    | % Positivo | % Negativo | % Neutro |
|:-------------|:-----------|:-----------|:---------|
| Eletronicos  | [X.X]%     | [Y.Y]%     | [Z.Z]%   |
| Acessorios   | [A.A]%     | [B.B]%     | [C.C]%   |
| Perifericos  | [D.D]%     | [E.E]%     | [F.F]%   |
| Redes        | [G.G]%     | [H.H]%     | [I.I]%   |
| *(Adicione mais, se aplicável)* | | | | |

* **Análise:** [Comente sobre as categorias que se destacam positiva ou negativamente. Ex: "A categoria 'Perifericos' apresenta um alto índice de avaliações positivas, sugerindo que a TechMarket tem um bom desempenho neste segmento. Por outro lado, a categoria 'Redes' mostra uma proporção maior de avaliações negativas, o que pode indicar a necessidade de revisão de produtos ou suporte."].

### 3.4. Avaliação Média (Rating) por Sentimento

A correlação entre o `rating` numérico e o `sentiment` classificado pelo LLM é crucial para validar os resultados:

| Sentimento | Rating Média |
|:-----------|:-------------|
| Positivo   | [X.X]        |
| Negativo   | [Y.Y]        |
| Neutro     | [Z.Z]        |

* **Análise:** [Comente se a média do `rating` corresponde ao sentimento. Ex: "A média de 'ratings' confirma a classificação de sentimento: avaliações positivas têm uma média alta, enquanto as negativas têm a menor média, validando a eficácia do LLM na detecção de sentimento."].

### 3.5. Exemplos de Avaliações Chave

Para ilustrar os insights, destacamos algumas avaliações que representam bem cada sentimento:

**Avaliações Positivas (Exemplos):**
1.  **Texto:** "Excelente produto! A bateria dura muito e a câmera é incrível." (Produto: Smartphone X, Sentimento: Positivo)
2.  **Texto:** "Perfeita para videochamadas! Imagem nítida e fácil de instalar." (Produto: Webcam Pro, Sentimento: Positivo)
3.  **Texto:** "Melhor mouse que já usei! Super preciso e confortável." (Produto: Mouse Gamer M, Sentimento: Positivo)
*(Substitua pelos seus resultados reais)*

**Avaliações Negativas (Exemplos):**
1.  **Texto:** "O som é bom, mas o fone fica caindo da orelha. Me decepcionei." (Produto: Fone Bluetooth Y, Sentimento: Negativo)
2.  **Texto:** "Parou de funcionar em uma semana. Qualidade péssima." (Produto: Cabo USB C, Sentimento: Negativo)
3.  **Texto:** "Sinal muito fraco, não alcança todos os cômodos. Não vale a pena." (Produto: Roteador Wi-Fi, Sentimento: Negativo)
*(Substitua pelos seus resultados reais)*

---

## 4. Recomendações Estratégicas e Conclusão

A análise de sentimento das avaliações de produtos é uma ferramenta poderosa para a TechMarket Online. Com base nos insights gerados, recomendamos:

* **Investigação de Produtos Problemáticos:** Focar na engenharia e/ou no suporte ao cliente para produtos como o **[Nome do Produto mais negativo]** e **[Nome do Segundo Produto mais negativo]**, buscando resolver as causas das avaliações negativas (Ex: problemas de durabilidade, funcionalidade específica).
* **Foco em Categorias de Sucesso:** Aprimorar o investimento e marketing em categorias como **[Categoria de maior % Positivo]**, que já demonstram alta satisfação do cliente.
* **Monitoramento Contínuo:** Implementar um pipeline de análise de sentimento em tempo real (utilizando Kafka e Spark Streaming) para detectar rapidamente tendências negativas e responder proativamente a problemas.
* **Feedback ao Desenvolvimento de Produto:** Utilizar os textos das avaliações negativas como feedback direto para as equipes de design e desenvolvimento de novos produtos.

**Conclusão:** Este desafio demonstrou como a integração de tecnologias de Big Data (HDFS, Spark, Hive, MongoDB, Kafka) com Inteligência Artificial (LLMs via Ollama) permite transformar dados não estruturados em inteligência de negócio. A capacidade de analisar o sentimento em escala capacita a TechMarket Online a tomar decisões mais informadas, melhorando a qualidade de seus produtos e a experiência de seus clientes, o que se traduz diretamente em maior satisfação e retenção.

---

## 5. Anexos

* **Notebook JupyterLab com o Código:** `[Nome do seu arquivo .ipynb, ex: desafio_analise_sentimento.ipynb]`
* **Scripts Auxiliares:** [Liste quaisquer scripts (`.sh`, `.sql`) adicionais que você tenha criado e que sejam relevantes para a solução.]

---