# Recherche

Ce chapitre va rentrer dans le détail du Query DSL, en se basant sur un dataset que nous allons auparavant importer.

## Initialisation des données

On va réaliser un import d'un [jeu de données représentant un ensemble de startups](http://jsonstudio.com/wp-content/uploads/2014/02/companies.zip) (il s'agit d'un export de crunchbase).

On va donc créer le schéma :

```
curl -XPUT http://localhost:9200/companies_db \
    --data-binary @/etc/crunchbase/mappings.json
```

Puis utiliser la bulk api d'ES pour importer les données :

```
curl -XPUT http://localhost:9200/companies_db/companies/_bulk \
     --data-binary @/etc/crunchbase/companies.bulk.json
```

On vérifie le nombre de documents dans l'index :

```
curl -XGET http://localhost:9200/companies_db/companies/_count
```

On peut donc commencer à requêter cet index.

## Présentation du schéma

Le schéma va donc représenter des startups, avec pour chacune différentes informations : informations de bases, fondateurs, acquisitions, évènements marquants, etc...

Voilà l'intégralité du schéma :

```
{
    "settings" : {
      "number_of_shards"   : 5,
      "number_of_replicas" : 0,
      "analysis" : {
        "tokenizer" : {
          "tags" : {
            "type"    : "pattern",
            "pattern" : ", "
          }
        },
        "analyzer" : {
          "tags" : {
            "tokenizer" :  "tags",
            "filter"    : [
              "lowercase"
            ]
          }
        }
      }
    },
    "mappings" : {
      "companies" : {
        "dynamic" : false,
        "properties" : {
          "category_code" : {
            "type" : "string"
          },
          "created_at" : {
            "type" : "string"
          },
          "crunchbase_url" : {
            "type" : "string"
          },
          "description" : {
            "type" : "string"
          },
          "email_address" : {
            "type" : "string"
          },
          "founded_day" : {
            "type" : "long"
          },
          "founded_month" : {
            "type" : "long"
          },
          "founded_year" : {
            "type" : "long"
          },
          "homepage_url" : {
            "type" : "string"
          },
          "id" : {
            "properties" : {
              "$oid" : {
                "type" : "string"
              }
            }
          },
          "ipo" : {
            "type" : "object",
            "properties" : {
              "pub_day" : {
                "type" : "long"
              },
              "pub_month" : {
                "type" : "long"
              },
              "pub_year" : {
                "type" : "long"
              },
              "stock_symbol" : {
                "type" : "string"
              },
              "valuation_amount" : {
                "type" : "long"
              },
              "valuation_currency_code" : {
                "type" : "string",
                "index" : "not_analyzed"
              }
            }
          },
          "name" : {
            "type" : "string",
            "fields" : {
              "raw" : { "type" : "string", "index" : "not_analyzed" }
            }
          },
          "number_of_employees" : {
            "type" : "long"
          },
          "offices" : {
            "type" : "nested",
            "properties" : {
              "address1" : {
                "type" : "string"
              },
              "address2" : {
                "type" : "string"
              },
              "city" : {
                "type" : "string"
              },
              "country_code" : {
                "type" : "string"
              },
              "description" : {
                "type" : "string"
              },
              "latitude" : {
                "type" : "double"
              },
              "longitude" : {
                "type" : "double"
              },
              "state_code" : {
                "type" : "string",
                "index" : "not_analyzed"
              },
              "zip_code" : {
                "type" : "string"
              }
            }
          },
          "overview" : {
            "type" : "string"
          },
          "phone_number" : {
            "type" : "string"
          },
          "tag_list" : {
            "type" : "string",
            "analyzer" : "tags",
            "fields" : {
              "raw" : { "type" : "string", "index" : "not_analyzed" }
            }
          },
          "total_money_raised" : {
            "type" : "string"
          },
          "twitter_username" : {
            "type" : "string"
          },
          "updated_at" : {
            "type" : "string"
          }
        }
      }
    }
}
```

Noter que l'on peut retrouver ces informations séparément en demandant d'une part le `mapping` : 

```
curl -XGET "http://localhost:9200/companies_db/_mapping?pretty"
```

puis les `settings` : 

```
curl -XGET "http://localhost:9200/companies_db/_settings?pretty"
```


## Recherche simple par query string

Egalement nommé "URI search", ce système permet d'effectuer des recherches basiques sur un index.

Exemple de recherche de société dont ne nom est 'Twitter' : 

```
curl -XGET 'http://localhost:9200/companies_db/companies/_search?q=name:Twitter&pretty'
```

Ce système de recherche propose une syntaxe qui permet d'effectuer des OR/AND sur un ou plusieurs champs : on en trouvera la description [ici](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax).

On trouvera également plus de détails sur [cette page](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-uri-request.html) concernant le paramètrage de l'URI search.

Ce type de recherche permet donc de facilement interroger un index, mais est limité dans la syntaxe : on va donc explorer le Query DSL, qui permet d'aller beaucoup plus loin, et est la manière recommandée de travailler avc un index.

## Recherche par Query DSL

Pour utiliser le Query DSL, on va définir notre requête dans un document JSON, que l'on va envoyer en GET ou POST au serveur ES.

Cette requête sera composée :
- d'une query principale, elle-même composée de sous-queries et filtres.
- de paramètres de sélection : nombre d'éléments souhaités, position de départ, tri, champs souhaités, etc...

Les queries consistent à effectuer une recherche sur un ou plusieurs champs, et à évaluer la pertinence d'un document par rapport à cette recherche, pertinence qui se traduira donc par un score.  
Les filtres permettent de réduire le champ de la recherche, mais ne contribuent pas au score. Les filtres étant rapides et cachés, ils sont à prescrire pour toute recherche ne nécessitant pas de score.

Voci un exemple de requête simple : afficher le champ `name` de 5 documents dont le champ `name` contient `web`, et formatter le résultat (avec `?pretty`)

```
curl -XGET http://localhost:9200/companies_db/companies/_search?pretty -d '{
  "query" : {
    "match" : { "name" : "web"}
  },
  "_source" : [ "name" ],
  "size": 5
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
- des metadata pour la requête : temps d'exécution en millisecondes, nombre de hits, nombre de shards interrogés
- une liste de résultats (par défaut : 10) avec les champs spécifiés (par défaut: tous)  dans l'ordre spécifié (par défaut: score descendant)

## Exercices

Pour les questions suivantes, on pourra s'appuyer sur :
- [le guide de la recherche](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html) et ses pages filles
- [les définitions de queries](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-queries.html)
- [les définitions de filters](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-filters.html)

#### Exercice 4.1 :

Quelles sont les 5 startups les plus anciennes (se baser sur `founded_*`) ?
Hint : on ne fait que _filtrer_ les données

#### Exercice 4.2 :

Quelles sont les startups dont le nom (`name`) ou les tags (`tag_list`) contiennent le mot "innovation" ? Comment peut-on donner plus d'importance à la recherche dans le nom que dans les tags ?  
Hint : il s'agit d'une recherche _multi_-champs

#### Exercice 4.3 :

Quelles sont les startups dont l'IPO a été réalisée pour plus de 10 millions de dollars (champs `ipo.*`), classées par valeur descendante ?

#### Exercice 4.4 :

Quelles sont les startups possédant des bureaux en Californie (soit `offices.state_code` == 'CA') et taggées "video" ?
Attention : le champ `offices` est `nested`













