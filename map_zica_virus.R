getwd()
setwd("/Users/fernando/Google Drive/DSA/BigDataRAzure/Projetos/map_zica-virus")


#Lendo os arquivos.
df1 <- read.csv("Epidemiological_Bulletin-2016-04-02.csv")
df2 <- read.csv("Epidemiological_Bulletin-2016-04-23.csv")
df3 <- read.csv("Epidemiological_Bulletin-2016-04-30.csv")
df4 <- read.csv("Epidemiological_Bulletin-2016-05-07.csv")
df5 <- read.csv("Epidemiological_Bulletin-2016-05-14.csv")
df6 <- read.csv("Epidemiological_Bulletin-2016-05-21.csv")
df7 <- read.csv("Epidemiological_Bulletin-2016-05-28.csv")
df8 <- read.csv("Epidemiological_Bulletin-2016-06-11.csv")


df <- rbind(df1, df2, df3, df4, df5, df6, df7, df8)
View(df)

# Verificando os tipos de cada coluna
str(df)


# Como as colunas time_period e time_period_type têm apenas valores nulos, vou
# excluir-las.
df <- df[, -(6:7)]

# A coluna report_date está como factor. Vou colocá-la como date.
df$report_date <- as.Date(df$report_date)

# Vou modificar os nomes das colunas para ficar mais fácil a manipulação.
library(dplyr)
library(tidyr)

df <- df %>% 
  rename(
    data = report_date,
    local = location,
    tipo_local = location_type,
    dado_reportado = data_field,
    cod_dado_reportado = data_field_code,
    quantidade = value,
    unidade = unit
  )

# Vamos mudar esse data frame para ter uma visualização melhor dos dados.
# Primeiro vou excluir as linhas da variável local que contenha as regiões 
# e o pais (Brasil), pois esses dados acabam ficando redundantes.
# Depois farei o split das coluna local craindo um coluna Pais e outra
# estado.
# E por fim criarei a coluna região. Assim fica mais fácil a manipulação dos
# dados.

# Excluindo linhas
reg <- c('Norte', 'Nordeste', 'Sudeste', 'Sul', 'Centro-Oeste', 'Brazil')
for(i in reg){
  df <- df[df$local != i, ]
}


# Dividindo as colunas por estado e pais
df <- df %>%
  separate(local, c("pais", "estado"), "-")

# Criando a coluna região
norte <- c('Rondonia', 'Amazonas', 'Para', 'Tocantins', 'Acre',
           'Roraima', 'Amapa')
nordeste <- c('Maranhao', 'Piaui', 'Ceara', 'Rio_Grande_do_Norte', 'Paraiba',
              'Pernambuco', 'Alagoas', 'Sergipe', 'Bahia')
sudeste <- c('Minas_Gerais', 'Espirito_Santo', 'Rio_de_Janeiro', 'Sao_Paulo')
sul <- c('Parana', 'Santa_Catarina', 'Rio_Grande_do_Sul')
centro_oeste <- c('Mato_Grosso_do_Sul', 'Mato_Grosso', 'Goias',
                  'Distrito_Federal')
df$regiao <- ifelse(df$estado %in% norte, "norte",
                    (ifelse(df$estado %in% nordeste, "nordeste",
                            (ifelse(df$estado %in% sudeste, "sudeste",
                                     (ifelse(df$estado %in% sul, 'sul',
                                             'centro_oeste')))))))
# Excluindo a coluna tipo_local
df <- df[, -4]

# reorganizando as colunas
df <- df[, c(1,3,8,2,6,4,5,7)]


qnt_por_regiao <- df %>%
  group_by(data, regiao) %>% 
  summarise(quant = sum(quantidade))

View(qnt_por_regiao)


library(ggplot2)
library(hrbrthemes)

ggplot(qnt_por_regiao, aes(x=data, y=quant, color=regiao)) +
  geom_point(size=3) +
  geom_line() +
  labs(title="Crescimento de Casos de Zika Virus por Região", x ="Data",
       y = "Número de Casos", color = "Região") +
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5, vjust=0.5, face='bold'),
        axis.title.x = element_text(hjust=0.5, vjust=0.5, face='bold'),
        axis.title.y = element_text(hjust=0.5, vjust=0.5, face='bold'),
        legend.title =element_text(hjust=0.5, vjust=0.5, face='bold'))

df %>%
  filter(data == max(qnt_por_regiao$data)) %>%
  ggplot(aes(reorder(regiao, -quantidade, sum), quantidade, fill=regiao)) +
    geom_bar(stat = 'identity') +
    scale_fill_brewer(palette = "RdYlBu") +
    labs(title="Total de Casos de Zika Virus por Região", x ="Região",
         y = "Número de Casos") +
    theme(plot.title=element_text(hjust=0.5, vjust=0.5, face='bold'),
          axis.title.x = element_text(hjust=0.5, vjust=0.5, face='bold'),
          axis.title.y = element_text(hjust=0.5, vjust=0.5, face='bold'))

df$sigla_estado <- sapply(df$estado,
                         function(col){
                           if(col == 'Acre')
                             return('AC')
                           else if(col == 'Alagoas')
                             return('AL')
                           else if(col == 'Amazonas')
                             return('AM')
                           else if(col == 'Amapa')
                             return('AP')
                           else if(col == 'Bahia')
                             return('BA')
                           else if(col == 'Ceara')
                             return('CE')
                           else if(col == 'Distrito_Federal')
                             return('DF')
                           else if(col == 'Espirito_Santo')
                             return('ES')
                           else if(col == 'Goias')
                             return('GO')
                           else if(col == 'Maranhao')
                             return('MA')
                           else if(col == 'Minas_Gerais')
                             return('MG')
                           else if(col == 'Mato_Grosso_do_Sul')
                             return('MS')
                           else if(col == 'Mato_Grosso')
                             return('MT')
                           else if(col == 'Para')
                             return('PA')
                           else if(col == 'Paraiba')
                             return('PB')
                           else if(col == 'Pernambuco')
                             return('PE')
                           else if(col == 'Piaui')
                             return('PI')
                           else if(col == 'Parana')
                             return('PR')
                           else if(col == 'Rio_de_Janeiro')
                             return('RJ')
                           else if(col == 'Rio_Grande_do_Norte')
                             return('RN')
                           else if(col == 'Rondonia')
                             return('RO')
                           else if(col == 'Roraima')
                             return('RR')
                           else if(col == 'Rio_Grande_do_Sul')
                             return('RS')
                           else if(col == 'Santa_Catarina')
                             return('SC')
                           else if(col == 'Sergipe')
                             return('SE')
                           else if(col == 'Sao_Paulo')
                             return('SP')
                           else
                             return('TO')
                           })

lat_long_estados <- read.csv("lat_long_estados.csv", sep=";")

lat_long_estados$uf <- as.character(lat_long_estados$uf)

map <- df %>%
  inner_join(lat_long_estados, by=c('sigla_estado' = 'uf')) %>%
  filter(data==max(data))
str(map)
map <- map[, c('estado', 'quantidade', 'latitude', 'longitude')]

num_of_times_to_repeat <- map$quantidade
map <- map[rep(seq_len(nrow(map)),num_of_times_to_repeat),]

library(leaflet)

leaflet(map) %>% 
  addTiles() %>% 
  addMarkers(clusterOptions = markerClusterOptions())







