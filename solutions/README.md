# Solutions

## Gestion de schéma

### Exercice 3.1

Il suffit pour cela de passer l'id en paramètre dans l'URL, avec un PUT ou un POST :

```
# curl -XPOST http://localhost:9200/store/products/2 -d '
{ "code" : "XX-21",
  "name" : "Jetpack (old generation)",
  "count" : 23,
  "date" : "2012-09-12",
  "tags" : ["propulsion", "diesel"]
}'
{"_index":"store","_type":"products","_id":"2","_version":3,"created":true}
# l'id est bien utilisé
```


### Exercice 3.2

Il suffit de réindexer le document, cette fois avec son id:

```
# curl -XPOST http://localhost:9200/store/products/AUzsJpaGLqo_1PEA5m0U -d '
{ "code" : "XX-22",
  "name" : "Jetpack (latest generation)",
  "count" : 12, "date" : "2015-09-12",
  "tags" : ["propulsion", "diesel"]
}'
{
  "_index":"store",
  "_type":"products",
  "_id":"AUzsJpaGLqo_1PEA5m0U",
  "_version":2,
  "created":false
  }
```

On voit que la réponse diffère selon que le document existe déjà ou non : ici, la version a  été incrémentée, et "created" vaut false.

On peut également utiliser un HEAD pour connaitre son existence :

```
# curl -i -XHEAD http://localhost:9200/store/products/AUzsJpaGLqo_1PEA5m0U
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Content-Length: 0

# curl -i -XHEAD http://localhost:9200/store/products/foo
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=UTF-8
Content-Length: 0

```

### Exercice 3.3

On peut également utiliser un GET pour récupérer le document :

```
# curl -XGET http://localhost:9200/store/products/AUzsJpaGLqo_1PEA5m0U?pretty
{
  "_index" : "store",
  "_type" : "products",
  "_id" : "AUzsJpaGLqo_1PEA5m0U",
  "_version" : 2,
  "found" : true,
  "_source":
  { "code" : "XX-22",
    "name" : "Jetpack (latest generation)",
    "count" : 12, "date" : "2015-09-12",
    "tags" : ["propulsion", "diesel"]
  }
}

```

On peut spécifier les champs que l'on souhaite récupérer dans le paramètre *_source* :

```
# curl -XGET http://localhost:9200/store/products/AUzsJpaGLqo_1PEA5m0U?pretty\&_source=code,name
{
  "_index" : "store",
  "_type" : "products",
  "_id" : "AUzsJpaGLqo_1PEA5m0U",
  "_version" : 2,
  "found" : true,
  "_source":{"code":"XX-22","name":"Jetpack (latest generation)"}
}
```

On va utiliser _mget pour récupérer pluseurs documents, avec les documents spécifiés dans le corps de la requête :

```
curl -XGET http://localhost:9200/store/products/_mget?pretty -d '{ "docs" : [ { "_id" : "2" }, { "_id" : "AUzsJpaGLqo_1PEA5m0U"}]}'
```

Il s'agit donc d'un GET avec body : ce sera une technique très utilisée avec le Query DSL.

### Exercice 3.4

On peut modifier partiellement un document (par exemple ajouter un champ) avec la commande _update :

```
# curl -XPOST http://localhost:9200/store/products/2/_update -d '
{
  "doc" : {
    "count": 13
  }
}'
```


### Exercice 3.5

La méthode HTTP DELETE est là pour ça :

```
# curl -XDELETE http://localhost:9200/store/products/AUzsJpaGLqo_1PEA5m0U
{
 "found":true,
 "_index":"store",
 "_type":"products",
 "_id":"AUzsJpaGLqo_1PEA5m0U",
 "_version":2
}
```

### Exercice 3.6

C'est avec le tandem DELETE / PUT qu'on peut réaliser cela.
Le workflow pour supprimer / recréer un mapping serait :
- récupérer le mapping (pour sauvegarde)
- supprimer l'existant
- recréer le mapping après l'avoir modifié

Soit :

```
#pour voir le mapping
curl -XGET http://localhost:9200/store/_mappings/?pretty
# pour sauver la partie "products" du mapping
curl -XGET http://localhost:9200/store/products/_mapping?pretty| jq ".store.mappings" > products.json
# modifier le mapping en passant le champ "count" de long à integer
# supprimer le mapping
curl -XDELETE http://localhost:9200/store/products/
# le recréer
curl -XPUT http://localhost:9200/store/_mappings/products -d @products.json
# vérifier que la modification est là
curl -XGET http://localhost:9200/store/products/_mapping
```

Attention, les données sont évidemment supprimées avec le mapping.

### Exercice 3.7

On ne peut pas modifier un champ une fois qu'il a été défini.
Pour des modifications lourdes, il faut donc :
- recréer un nouvel index avec ce nouveau mapping
- réindexer de l'un vers l'autre
- supprimer le premier index, et renommer le nouveau
- ou mieux, utiliser un alias pour l'index


### Exercice 3.8

Il existe un endpoint spécial `_analyze` pour tester le résultat d'un analyzer (ici l'analyzer par défaut) :

```
# curl -XPOST http://localhost:9200/store/_analyzer -d 'My Super-Product'
```

On peut également passer un paramètre "analyzer" pour spécifier un analyzer custom.

### Exercice 3.9

Il faut le définir comme *not_analyzed* : il sera conservé tel quel.


### Exercice 4.1

Il n'y pas de requête ou filtre à réaliser : on va donc utiliser la requête `match_all` qui ramène tous les résultats.
Pour obtenir les plus anciennes, on ne dispose pas d'une date de création, mais de trois champs founded_year / founded_month / founded_day sur lesquels on va trier par ordre ascendant.

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "match_all" : {}
  },
  "fields" : [ "name", "founded_year", "founded_month", "founded_day" ],
  "sort" : [
    { "founded_year" : { "order" : "asc" }},
    { "founded_month" : { "order" : "asc" }},
    { "founded_day" : { "order" : "asc" }}
  ],
  "size": 10
}'
```

Ce qui permet de voir que la qualité des dates n'est pas là...

On peut donc filter les sociétés créées après 1990 :

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "filtered": {
      "query": {
        "match_all": {  }
      },
      "filter": {
        "range": { "founded_year": { "gte": 1990 }}
      }
    }
  },
  "fields" : [ "name", "founded_year", "founded_month", "founded_day" ],
  "sort" : [
    { "founded_year" : { "order" : "asc" }},
    { "founded_month" : { "order" : "asc" }},
    { "founded_day" : { "order" : "asc" }}
  ],
  "size": 10
}'
```

### Exercice 4.2

On va utiliser la requête `multi_match` qui permet d'exécuter une requête sur plusieurs champs :

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "multi_match" : {
      "query":    "innovation",
      "fields": [ "name", "tag_list" ]
    }
  },
  "fields" : [ "name", "tag_list" ],
  "size": 10
}'
```

On voit alors que le 1er résultat est :

```
{
  "_index" : "crunchbase",
  "_type" : "companies",
  "_id" : "AU4gQEgoNbHfJKgC88Ff",
  "_score" : 7.9127636,
  "fields" : {
    "name" : [ "Brightidea" ],
    "tag_list" : [ "innovation" ]
  }
}
```

On peut influer sur le scoring en favorisant l'un ou l'autre champ d'un multimatch :

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "multi_match" : {
      "query":    "innovation",
      "fields": [ "name^1.2", "tag_list" ]
    }
  },
  "fields" : [ "name", "tag_list" ],
  "size": 10
}'
```

Le 1er résultat sera alors :

```
 {
  "_index" : "crunchbase",
  "_type" : "companies",
  "_id" : "AU4gQEgMNbHfJKgC86Rs",
  "_score" : 6.8977776,
  "fields" : {
    "name" : [ "CVON Innovation" ],
    "tag_list" : [ "patent, portfolio, mobile, marketing, advertisement" ]
  }
}
```
Le résultat "Brightidea" étant rélégué plus loin.

### Exercice 4.3

On n'a pas ici besoin de scoring: on va donc utiliser des filtres.
Par ailleurs, il faudra filtrer à la fois sur le montant de l'IPO et sur sa currency, à travers l'utilisation d'un filtre `bool`.
On notera qu'on peut naviguer sur un sous-objet (ipo) sans configuration particulière.

Pour les version pre-2.0 d'Elasticsearch, on utilise une `query` de type `filtered` : 

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "filtered": {
      "filter": {
        "bool": {
          "must" : [
            { "range": { "ipo.valuation_amount": { "gte": 1000000 } } },
            { "term" : { "ipo.valuation_currency_code" : "USD" } }
          ]
        }
      }
    }
  },
  "sort" : [
    { "ipo.valuation_amount" : { "order" : "desc" }}
  ],
  "fields" : [ "name", "ipo.valuation_amount", "ipo.valuation_currency_code" ],
  "size": 10
}
'
```

Post 2.0, cette requête est dépréciée,et on utilisera un élément `filter` sur une `query` `bool` : 

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "bool" : {
      "filter": {
        "bool": {
          "must" : [
            { "range": { "ipo.valuation_amount": { "gte": 1000000 } } },
            { "term" : { "ipo.valuation_currency_code" : "USD" } }
          ]
        }
      }
    }
  },
  "sort" : [
    { "ipo.valuation_amount" : { "order" : "desc" }}
  ],
  "fields" : [ "name", "ipo.valuation_amount", "ipo.valuation_currency_code" ],
  "size": 10
}
```


### Exercice 4.4

Les adresses des sociétés se trouvent dans le champ nested 'offices'. La notion de champ nested permet de gérer des collections d'objets embarqués dans l'objet principal.
Il faut pour les accèder utiliser un nested filter (ou une nested query selon l'usage) :

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "query" : {
    "filtered" : {
      "query" : {
        "match" : { "tag_list" : "video"}
      },
      "filter" : {
        "nested" : {
          "path" : "offices",
          "filter" : {
            "term" : { "offices.state_code" : "CA"}
          }
        }
      }
    }
  },
  "fields" : [ "name", "tag_list", "offices.address1", "offices.city"],
  "size": 50
}'
```

### Exercice 4.5


On reprend donc la même requête en lui ajoutant plusieurs éléments :
- un paramètre de querystring `explain=` qui, pour chaque résultat, va inclure le détail de calcul du score de pertinence 
- un paramètre de query `profile : true` (nouveau en 2.2), donnant le détail des différentes phases d'exécution sur chaque shard
- une section `highlight` qui permet de configurer la restitution du highlight

Ce qui donne :

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty=&explain= -d '{
  "profile" : true,
  "query" : {
    "multi_match" : {
      "query":    "innovation",
      "fields": [ "name^1.2", "tag_list" ]
    }
  },
  "fields" : [ "name", "tag_list" ],
  "size": 10,
  "highlight": {
    "fields": {
      "name" : {},
      "tag_list": {}
    },
    "pre_tags": [ "<b>" ],
    "post_tags": [ "</b>" ]
  }
}
```

### Exercice 4.6

On va utiliser l'endpoint `validate`, avec l'option `explain` : 

```
curl -XGET http://localhost:9200/crunchbase/companies/_validate/query?pretty=&explain= -d '{
  "query" : {
    "multi_match" : {
      "query":    "innovation",
      "fields": [ "name^1.2", "tag_list" ]
    }
  },
  "fields" : [ "name", "tag_list" ],
  "size": 10
}'
```

### Exercice 5.1

Il existe deux agrégations pour des mesures statistiques : `stats` et `extended_stats`. `extended_stats` permet d'obtenir des mesures supplémentaires (variance par exemple).
Pour les percentiles, il va falloir une deuxième agrégation nommée `percentiles`

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "size" : 0,
  "aggs" : {
    "employees_stats" : {
      "extended_stats" : { "field" : "number_of_employees" }
    },
    "employees_percentiles" : {
      "percentiles" : {
         "field" : "number_of_employees",
         "percents" : [1, 5, 25, 50, 75, 95, 99, 99.9]
      }
    }
  }
}'
```

### Exercice 5.2

On va utiliser `histogram` en spécifiant un interval de 1
(note : si on avait un champ date correctement formatté, on pourrait utiliser un `date_histogram`

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "size" : 0,
  "aggs" : {
    "ipo_year" : {
      "histogram" : {
        "field" : "ipo.pub_year",
        "interval" : 1
      }
    }
  }
}'
```

On peut aussi exécuter cette requête avec un intervalle de 10 pour voir les IPO par décennie.

### Exercice 5.3

Il va falloir imbriquer des agrégations : d'abord agréger via des `terms` sur la `founded_year` (en triant par date), puis pour chaque date agréger via des `terms` sur `tag_list` (en laissant le tri par défaut par valeur décroissante, et en limitant à cinq valeurs).
On va réaliser cela en imbriquant des éléments `aggs`

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{
  "size" : 0,
  "query" : {
    "filtered": {
       "filter": {
        "range": { "founded_year": { "gte": 2000 }, "founded_year": { "lte": 2015 }}
      }
    }
  },
  "aggs" : {
    "founded_year" : {
      "terms" : {
        "field" : "founded_year",
        "order" : { "_term" : "asc" },
        "size" : 30
      },
      "aggs" : {
        "top_tags" : {
          "terms" : {
            "field" : "tag_list",
            "size" : 5
          }
        }
      }
    }
  }
}'
```

### Exercice 5.4

Pour cet exercice , il va falloir dissocier l'agrégation du scope de la query.
On va utiliser l'agrégation `global` : 

```
curl -XGET http://localhost:9200/crunchbase/companies/_search?pretty -d '{ 
  "query" : {
    "term" : {
      "ipo.pub_year":    "2012"
    }
  },
  "fields" : [ "name", "ipo.pub_year" ],
  "size": 10,
  "aggs": {
    "all_companies": {
      "global": {},
      "aggs": {
        "from2000to2015" : {
          "filter": {
            "range": { 
              "founded_year": { "gte": 2000 }, "founded_year": { "lte": 2015 }              
            }
          },
          "aggs": {
            "founded_year" : {
              "terms" : {
                "field" : "founded_year",
                "order" : { "_term" : "desc" },
                "size" : 15
              }
            }
          }
        }
      } 
    }
  }
}
```

### Exercice 6.1

On va utiliser le `tokenizer` `keyword`, qui ne tokenise pas le texte, et le laisse tel quel : 

```
curl -XGET http://localhost:9200/my_index/ -d '{
  "settings" : {
    "analysis" : {
      "analyzer" : {
        "my_analyzer" : {
          "tokenizer" : "keyword"
        }
      }
    }
  }    
} 
'
```

### Exercice 6.2

On va ajouter à l'`analyzer` précédent un `filter` `lowercase` : 

```
curl -XGET http://localhost:9200/my_index/ -d '{
  "settings" : {
    "analysis" : {
      "analyzer" : {
        "my_analyzer" : {
          "tokenizer" : "keyword",
          "filter" : [
            "lowercase"
          ]
        }
      }
    }
  }    
} 
'
```

### Exercice 6.3

On va modifier  l'`analyzer` précédent en utilisant un `tokenizer` `whitespace`, avec un `filter` `word_delimiter` pour éliminer la virgule après "Ivre". On laisse le filtre `lowercase`

```
{
  "settings" : {
    "analysis" : {
      "analyzer" : {
        "my_analyzer" : {
          "tokenizer" : "whitespace",
          "filter" : [
            "lowercase",
            "word_delimiter"
          ]
        }
      }
    }
  }    
}  
```

### Exercice 6.4

On va ajouter à l'`analyzer` précédent un `filter` `asciifolding`, et un `filter` `stemmer`, configuré pour le français : 

```
{
  "settings" : {
    "analysis" : {
      "filter":  {
        "my_french_stemmer" : {
          "type" : "stemmer",
          "name" : "light_french"
        }  
      },
      "analyzer" : {
        "my_analyzer" : {
          "tokenizer" : "whitespace",
          "filter" : [
            "lowercase",
            "word_delimiter",
            "asciifolding",
            "my_french_stemmer"
          ]
        }
      }
    }
  }    
}  
```


### Exercice 6.5

On va ajouter un `filter` `stopwords`, et un `filter` `keyword_marker`, chacun avec la bonne liste de mots.


```
{
  "settings" : {
    "analysis" : {
      "filter":  {
        "my_french_stemmer" : {
          "type" : "stemmer",
          "name" : "light_french"
        },
        "my_stop": {
          "type":       "stop",
          "stopwords": ["une"]
        },
        "my_protected_words" : {
          "type" : "keyword_marker",
          "keywords" : [ "imprimante" ]
        }
      },
      "analyzer" : {
        "my_analyzer" : {
          "tokenizer" : "whitespace",
          "filter" : [
            "lowercase",
            "word_delimiter",
            "stop",
            "asciifolding",
            "my_protected_words",
            "my_french_stemmer"
          ]
        }
      }
    }
  }    
}  

```

### Exercice 6.6

On va configurer le `filter` `word_delimiter` pour qu'il émette aussi la chaine originelle en plus du travail de tokenization réalisé, et qu'il ne splitte pas sur le passage de lettre à chiffre. 

```
{
  "settings" : {
    "analysis" : {
      "filter":  {
        "my_french_stemmer" : {
          "type" : "stemmer",
          "name" : "light_french"
        },
        "my_stop": {
          "type":       "stop",
          "stopwords": ["une"]
        },
        "my_protected_words" : {
          "type" : "keyword_marker",
          "keywords" : [ "imprimante" ]
        },
        "my_word_delimiter" : {
           "type" : "word_delimiter",
           "preserve_original" : true,
           "split_on_numerics" : false
        }
      },
      "analyzer" : {
        "my_analyzer" : {
          "tokenizer" : "whitespace",
          "filter" : [
            "lowercase",
            "my_word_delimiter",
            "stop",
            "asciifolding",
            "my_protected_words",
            "my_french_stemmer"
          ]
        }
      }
    }
  }    
} 
```

### Exercice 6.7

Il suffit pour cela d'utiliser l'endpoint `_analyze` sans paramètre :

```
curl -XGET http://localhost:9200/my_index/_analyze?pretty -d '{
  "text" : "Ivre, il achète une imprimante HP-AB28" 
  {
  "tokens": [
    {
      "token": "ivre",
      "start_offset": 0,
      "end_offset": 4,
      "type": "<ALPHANUM>",
      "position": 0
    },
    {
      "token": "il",
      "start_offset": 6,
      "end_offset": 8,
      "type": "<ALPHANUM>",
      "position": 1
    },
    {
      "token": "achète",
      "start_offset": 9,
      "end_offset": 15,
      "type": "<ALPHANUM>",
      "position": 2
    },
    {
      "token": "une",
      "start_offset": 16,
      "end_offset": 19,
      "type": "<ALPHANUM>",
      "position": 3
    },
    {
      "token": "imprimante",
      "start_offset": 20,
      "end_offset": 30,
      "type": "<ALPHANUM>",
      "position": 4
    },
    {
      "token": "hp",
      "start_offset": 31,
      "end_offset": 33,
      "type": "<ALPHANUM>",
      "position": 5
    },
    {
      "token": "ab28",
      "start_offset": 34,
      "end_offset": 38,
      "type": "<NUM>",
      "position": 6
    }
  ]
}
```

### Exercice 6.8

Il existe pour chaque langage majeur un `analyzer` dédié, nommé comme le langage :

```
curl -XGET http://localhost:9200/my_index/_analyze?pretty&analyzer=french -d '{
  "text" : "Ivre, il achète une imprimante HP-AB28" 
}
{
  "tokens": [
    {
      "token": "ivre",
      "start_offset": 0,
      "end_offset": 4,
      "type": "<ALPHANUM>",
      "position": 0
    },
    {
      "token": "achet",
      "start_offset": 9,
      "end_offset": 15,
      "type": "<ALPHANUM>",
      "position": 2
    },
    {
      "token": "imprimant",
      "start_offset": 20,
      "end_offset": 30,
      "type": "<ALPHANUM>",
      "position": 4
    },
    {
      "token": "hp",
      "start_offset": 31,
      "end_offset": 33,
      "type": "<ALPHANUM>",
      "position": 5
    },
    {
      "token": "ab28",
      "start_offset": 34,
      "end_offset": 36,
      "type": "<NUM>",
      "position": 6
    }
  ]
}
```

Le détail de cet `analyzer` se trouve [ici](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lang-analyzer.html#french-analyzer)

### Exercice 7.1

Pour l'API `cat`, on passera systématiquement le paramètre `v` pour un maximum de lisibilité

```
curl http://localhost:9200/_cat/nodes?v
host      ip        heap.percent ram.percent load node.role master name  
10.0.2.15 10.0.2.15           14          70 0.33 d         *      Sleek 
```

### Exercice 7.2

Sur le même modèle : 

```
curl http://localhost:9200/_cat/indices?v
health status index      pri rep docs.count docs.deleted store.size pri.store.size 
green  open   crunchbase   5   0      35488            0       53mb           53mb 
yellow open   .kibana      1   1          1            0      3.1kb          3.1kb
```

### Exercice 7.3

```
curl -XGET 'http://localhost:9200/_cluster/health?pretty'
```

### Exercice 7.4

```
curl -XGET 'http://localhost:9200/_cluster/stats?pretty'
curl -XGET 'http://localhost:9200/_nodes/stats?pretty'

```

### Exercice 7.5

On va passer les paramètres désirés à l'API d'update d'index.  
Ici, c'est le paramètre `number_of_replicas` qui nous intéresse : 

```
curl -XPUT 'localhost:9200/crunchbase/_settings' -d '
{
    "index" : {
        "number_of_replicas" : 1
    }
}'
```

Immédiatement après, le statut de l'index devrait passer de `green` à `yellow`.

