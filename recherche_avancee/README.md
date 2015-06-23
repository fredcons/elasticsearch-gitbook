# Recherche avancée

La recherche par query string présentée précédemment permet de facilement interroger un index, mais est limitée dans la syntaxe : on va donc explorer le Query DSL, qui permet d'aller beaucoup plus loin, et est la manière recommandée de travailler avc un index.

## Structure d'une recherche

Pour utiliser le Query DSL, on va définir notre requête dans un document JSON, que l'on va envoyer en GET ou POST au serveur ES.

Cette requête sera composée :
- d'une query principale, elle-même composée de sous-queries et filtres.
- de paramètres de sélection : nombre d'éléments souhaités, position de départ, tri, champs souhaités, etc...

Les queries consistent à effectuer une recherche sur un champ, et à évaluer la pertinence d'un document par rapport à cette recherche, qui se traduira donc par un score.
Les filtres permettent de réduire le champ de la recherche, mais ne contribuent pas au score. Les filtres étant rapides et cachés, ils sont à prescrire pour toute recherche ne nécessitant pas de score.

Voci un exemple de requête simple :

```
curl -XGET http://localhost:9200/companies_db/companies/_search?pretty -d '{
  "query" : {
    "term" : { "name" : "web"}
  },
  "_source" : [ "name" ],
  "size": 10
}'
```

Et sa réponse :

```
{
  "took" : 5,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 82,
    "max_score" : 5.784622,
    "hits" : [ {
      "_index" : "companies_db",
      "_type" : "companies",
      "_id" : "AU4fWqxeNbHfJKgC8owo",
      "_score" : 5.784622,
      "_source":{"name":"NewTarget Web"}
    }, {
      "_index" : "companies_db",
      "_type" : "companies",
      "_id" : "AU4fWqxpNbHfJKgC8pgC",
      "_score" : 5.642988,
      "_source":{"name":"Web CEO"}
    }, {
      "_index" : "companies_db",
      "_type" : "companies",
      "_id" : "AU4fWqx-NbHfJKgC8q5t",
      "_score" : 5.642988,
      "_source":{"name":"Wee Web"}
    }, {
      "_index" : "companies_db",
      "_type" : "companies",
      "_id" : "AU4fWqyENbHfJKgC8rTq",
      "_score" : 5.642988,
      "_source":{"name":"Web Funters"}
    }, {
      "_index" : "companies_db",
      "_type" : "companies",
      "_id" : "AU4fWqxVNbHfJKgC8oHA",
      "_score" : 5.4767423,
      "_source":{"name":"Web-Chops"}
    } ]
  }
}
```

Cette réponse contient donc :
- des metadata pour la requête : temps d'exécution, nombre de hits
- une liste de résultats (par défaut : 10) avec les champs spécifiés (par défaut: tous)  dans l'ordre spécifié (par défaut: score descendant)

## Exercices

Pour les questions suivantes, on pourra s'appuyer sur :
- [le guide la recherche](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html) et les pages filles
- [les définitons de queries](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-queries.html)
- [les définitions de filters](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-filters.html)

#### Exercice 5.1 :

Quelles sont les 5 startups les plus anciennes (se baser sur `founded_*`) ?

#### Exercice 5.2 :

Quelles sont les startups dont le nom (`name`) ou les tags (`tag_list`) contiennent le mot "innovation" ? Comment peut-on donner plus d'importance à la recherche dans le nom que dans les tags ?

#### Exercice 5.3 :

Quelles sont les startups dont l'IPO a été réalisée pour plus de 10 millions de dollars champs `ipo.*`, classées par valeur descendante ?

#### Exercice 5.4 :

Quelles sont les startups possédant des bureaux en Californie (`offices.state_code`) et taggées "video" ?








