# Recherche

Ce chapitre va rentrer dans le détail du Query DSL, en se basant sur un dataset que nous allons auparavant importer.

## Initialisation des données

On va réaliser un import d'un [jeu de données représentant un ensemble de startups](http://jsonstudio.com/wp-content/uploads/2014/02/companies.zip) (il s'agit d'un export de crunchbase).

On va donc créer le schéma :

```
curl -XPUT http://localhost:9200/crunchbase \
    --data-binary @/etc/crunchbase/mappings.json
```

Puis utiliser la bulk api d'ES pour importer les données :

```
curl -XPUT http://localhost:9200/crunchbase/companies/_bulk \
     --data-binary @/etc/crunchbase/companies.bulk.json
```

On vérifie le nombre de documents dans l'index :

```
curl -XGET http://localhost:9200/crunchbase/companies/_count
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
            "type" : "string",
            "indexed" : "no"
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
curl -XGET "http://localhost:9200/crunchbase/_mapping?pretty"
```

puis les `settings` : 

```
curl -XGET "http://localhost:9200/crunchbase/_settings?pretty"
```


## Recherche simple par query string

Egalement nommé "URI search", ce système permet d'effectuer des recherches basiques sur un index.

Exemple de recherche de société dont ne nom est 'Twitter' : 

```
curl -XGET 'http://localhost:9200/crunchbase/companies/_search?q=name:Twitter&pretty'
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
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
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
  "took" : 6,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 82,
    "max_score" : 4.4781237,
    "hits" : [ {
      "_index" : "crunchbase",
      "_type" : "companies",
      "_id" : "AU_wei3kCYcZ42ux1O1s",
      "_score" : 4.4781237,
      "_source":{"name":"NewTarget Web"}
    }, {
      "_index" : "crunchbase",
      "_type" : "companies",
      "_id" : "AU_wei4DCYcZ42ux1Q2Y",
      "_score" : 4.4781237,
      "_source":{"name":"Web Momentum"}
    }, {
      "_index" : "crunchbase",
      "_type" : "companies",
      "_id" : "AU_wei4FCYcZ42ux1Q9_",
      "_score" : 4.4781237,
      "_source":{"name":"Web Styler"}
    }, {
      "_index" : "crunchbase",
      "_type" : "companies",
      "_id" : "AU_wei4MCYcZ42ux1Rac",
      "_score" : 4.4781237,
      "_source":{"name":"Web Piston"}
    }, {
      "_index" : "crunchbase",
      "_type" : "companies",
      "_id" : "AU_wei4LCYcZ42ux1RYu",
      "_score" : 4.263787,
      "_source":{"name":"Web Funters"}
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

#### Exercice 4.2 :

Quelles sont les startups dont le nom (`name`) ou les tags (`tag_list`) contiennent le mot "innovation" ? Comment peut-on donner plus d'importance à la recherche dans le nom que dans les tags ?  
Hint : il s'agit d'une recherche _multi_-champs

#### Exercice 4.3 :

Quelles sont les startups dont l'IPO a été réalisée pour plus de 10 millions de dollars (champs `ipo.*`), classées par valeur descendante ?
Hint : on ne fait que _filtrer_ les données

#### Exercice 4.4 :

Quelles sont les startups possédant des bureaux en Californie (soit `offices.state_code` == 'CA') et taggées "video" ?
Hint : le champ `offices` est `nested`

#### Exercice 4.5 :

Reprendre la requête 4.2 : 
- en ajoutant aux résultats des informations sur le calcul du score
- en ajoutant aux résultats des informations sur le temps d'exécution
- en ajoutant un `highlight` en italique sur les résultats 

#### Exercice 4.6 :

Reprendre la requête 4.2, et demander à ES : 
- de la valider
- de détailler la requête qu'il va exécuter

## Features additionnelles

Outre la recherche "classique" par DSL, Elasticsearch fournit des fonctionalités annexes qu'il est bon de connaitre.

### Geosearch

Elasticsearch propose des types de données permettant de modéliser différentes informations géographiques : un point particulier avec `geopoint`, des zones entières avec `geo_shape`.  
On peut ensuite filter / rechercher / agréger des documents en se basant sur leur localisation géographique.

### Suggest

La fonctionnalité [`suggest`](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters.html) permet de trouver des chaines de caractères proches du texte recherché.
Elle peut être utilisée : 
- pour de la correction orthographique

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "size": 0,
  "suggest" : {
    "name_suggestion" : {
      "text" : "tiwtter",
      "term" : {
        "size" : 3,
        "field" : "name"
      }
    }
  }
}
{
  ...
  "suggest": {
    "name_suggestion": [
      {
        "text": "tiwtter",
        "offset": 0,
        "length": 7,
        "options": [
          {
            "text": "twitter",
            "score": 0.85714287,
            "freq": 6
          }
        ]
      }
    ]
  }
}
```

- pour de l'autocomplétion (ce qui nécessite un mapping spécial).



### Scoring avancé

On n'a fait que survoler la notion de score. Actuellement basé sur TFIDF, le score par défaut sera bientôt calculé avec BM25.  
Mais au-delà de ces formules basées sur la fréquence des termes dans les documents et le corpus entier, il est possible d'utiliser la valeur des champs des documents pour recalculer / influencer le score.  
Des exemples possibles d'usage sont : 
- favoriser les documents les plus récents dans un moteur de recherche d'articles de presse
- favoriser les produits les plus vendus sur un site e-commerce 
On utilisera pour cela la `query` [`function_score`](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html).

### Percolator

Le [`percolator`](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html) inverse le mécanisme de recherche standard : 
- on enregistre des requêtes
- on regarde ensuite pour un document donné si des requêtes enregistrées matchent ou pas ce document
Ce système peut être utilisé pour construire un mécanisme d'alerting.











