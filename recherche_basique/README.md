# Recherche basique


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
                "fields" : {
                  "raw" : { "type" : "string", "index" : "not_analyzed" }
                }
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

## Première recherche par query string






