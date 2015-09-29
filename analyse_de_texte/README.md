# Analyse de texte

On a vu sur ces précédentes exemples qu'une chaine de caractère pouvait être "analysée", c'est-à-dire transformée par une série de filtres, ou "non analysée" c'est-à-dire laissée telle quelle.  
Pour l'instant, les chaines analysées l'ont été avec l'`analyzer` `standard` : cet `analyzer` va pour une chaine donnée:
- la découper en termes, avec un `tokenizer`
- passer chaque terme en minuscules : c'est le rôle d'un `tokenfilter`
- supprimer les mots présents dans une liste noire nommée "stopwords", avec un autre `tokenfilter` 

C'est cette chaine d'analyse qui est utilisée par défaut dans ElasticSearch.  
On va voir qu'il est possible de créer des analyzers customs en composant soi-même un `analyzer` et des `tokensfilter`s .

## Visualiser une analyse

Avant d'aller plus loin, on va tester l'endpoint ES qui va permettre de mieux comprendre comment ES analyse un texte donné : `/_analyze`.  
Il prend en paramètres : 
- une chaîne de caractères
- un nom d'`analyzer`, optionnel

Exemple avec l'`analyzer` `standard` : 

```
curl http://localhost:9200/_analyze?pretty -d "Hello there"                      
{
  "tokens" : [ {
    "token" : "hello",
    "start_offset" : 0,
    "end_offset" : 5,
    "type" : "<ALPHANUM>",
    "position" : 1
  }, {
    "token" : "there",
    "start_offset" : 6,
    "end_offset" : 11,
    "type" : "<ALPHANUM>",
    "position" : 2
  } ]
}

```


Quand on veut customiser la configuration d'analyse, celle-ci est définie sur un index : on peut donc appeler `/_analyze` sur un index précis, en référençant un `analyzer` de cet index. Exemple avec l'index précédemment utilisé et l'`analyzer` `tags` : 

```
curl http://localhost:9200/companies_db/_analyze?pretty&analyzer=tags -d "tag1, tag2, tag3"
{
  "tokens" : [ {
    "token" : "tag1",
    "start_offset" : 0,
    "end_offset" : 4,
    "type" : "word",
    "position" : 1
  }, {
    "token" : "tag2",
    "start_offset" : 6,
    "end_offset" : 10,
    "type" : "word",
    "position" : 2
  }, {
    "token" : "tag3",
    "start_offset" : 12,
    "end_offset" : 16,
    "type" : "word",
    "position" : 3
  } ]
}
```

La documentation de cet endpoint se trouve [ici](https://www.elastic.co/guide/en/elasticsearch/reference/1.7/indices-analyze.html).

## Analyzer



## Tokenfilter

## Exercices

