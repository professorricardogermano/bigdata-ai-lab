# Desafio Final: Análise de Sentimento de Avaliações de Produtos

## Objetivo

Este desafio final tem como objetivo consolidar o conhecimento adquirido sobre Big Data Analytics e Inteligência Artificial, aplicando as tecnologias configuradas no ambiente de laboratório (`Hadoop`, `Spark`, `Hive`, `MongoDB`, `Kafka` e `Ollama`) para resolver um problema de negócio real: **análise de sentimento de avaliações de produtos**.

Você atuará como um(a) cientista de dados ou engenheiro(a) de Big Data responsável por extrair insights acionáveis para uma empresa de e-commerce.

## Cenário de Negócio

Uma grande empresa de e-commerce, **"TechMarket Online"**, coleta milhares de avaliações de clientes diariamente. Eles percebem que essas avaliações são uma mina de ouro de informações sobre a satisfação do cliente, problemas com produtos e oportunidades de melhoria. No entanto, o volume e a natureza não estruturada desses dados (texto livre) tornam a análise manual impossível.

Seu desafio é construir um pipeline de análise que possa:
1.  Ingerir dados de avaliações de forma eficiente.
2.  Armazenar esses dados para consultas flexíveis.
3.  Processar as avaliações para determinar o sentimento (positivo, negativo, neutro) usando um Large Language Model (LLM).
4.  Gerar relatórios e insights que ajudem a TechMarket a tomar decisões estratégicas.

## Dados

Para simular as avaliações de produtos, você criará um arquivo CSV (ou similar) com dados fictícios.

**Crie um arquivo `product_reviews.csv` no seu ambiente (ex: `/home/aluno/data/product_reviews.csv`) com o seguinte conteúdo:**

```csv
review_id,product_name,category,rating,review_text,timestamp
1,Smartphone X,Eletronicos,5,"Excelente produto! A bateria dura muito e a câmera é incrível.",2024-05-20 10:30:00
2,Fone Bluetooth Y,Eletronicos,2,"O som é bom, mas o fone fica caindo da orelha. Me decepcionei.",2024-05-20 11:15:00
3,Smartwatch Z,Eletronicos,4,"Funcionalidades ótimas, mas a tela poderia ser maior. Recomendo.",2024-05-21 09:00:00
4,Cabo USB C,Acessorios,1,"Parou de funcionar em uma semana. Qualidade péssima.",2024-05-21 14:45:00
5,Webcam Pro,Perifericos,5,"Perfeita para videochamadas! Imagem nítida e fácil de instalar.",2024-05-22 08:00:00
6,Teclado Mecânico K,Perifericos,3,"Teclas boas, mas o software de personalização é confuso.",2024-05-22 16:20:00
7,Mouse Gamer M,Perifericos,5,"Melhor mouse que já usei! Super preciso e confortável.",2024-05-23 10:00:00
8,Roteador Wi-Fi,Redes,2,"Sinal muito fraco, não alcança todos os cômodos. Não vale a pena.",2024-05-23 11:30:00
9,Monitor Curvo,Eletronicos,4,"Imersivo e com cores vibrantes. Ótimo para jogos e trabalho.",2024-05-24 09:10:00
10,Carregador Portatil,Acessorios,3,"Carrega bem, mas é muito pesado para levar na mochila.",2024-05-24 15:00:00