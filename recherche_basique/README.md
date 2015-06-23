# Recherche basique


## Initialisation des données

On va réaliser un import d'un [jeu de données représentant un ensemble de startups](http://jsonstudio.com/wp-content/uploads/2014/02/companies.zip)(il s'agit d'un export de crunchbase).

On va donc créer le schéma :

```
curl -XPUT http://localhost:9200/companies_db --data-binary @provisioning/files/mappings.json
```

Puis utiliser la bulk api d'ES pour importer les données :

```
curl -XPUT http://localhost:9200/companies_db/companies/_bulk --data-binary @provisioning/files/companies.bulk.json
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
    "mappings" : {
      "companies" : {
        "dynamic" : false,
        "properties" : {
          "acquisition" : {
            "type" : "object",
            "properties" : {
              "acquired_day" : {
                "type" : "long"
              },
              "acquired_month" : {
                "type" : "long"
              },
              "acquired_year" : {
                "type" : "long"
              },
              "acquiring_company" : {
                "type" : "object",
                "properties" : {
                  "name" : {
                    "type" : "string"
                  },
                  "permalink" : {
                    "type" : "string"
                  }
                }
              },
              "price_amount" : {
                "type" : "long"
              },
              "price_currency_code" : {
                "type" : "string"
              },
              "source_description" : {
                "type" : "string"
              },
              "source_url" : {
                "type" : "string"
              },
              "term_code" : {
                "type" : "string"
              }
            }
          },
          "acquisitions" : {
            "type" : "nested",
            "properties" : {
              "acquired_day" : {
                "type" : "long"
              },
              "acquired_month" : {
                "type" : "long"
              },
              "acquired_year" : {
                "type" : "long"
              },
              "company" : {
                "type" : "object",
                "properties" : {
                  "name" : {
                    "type" : "string"
                  },
                  "permalink" : {
                    "type" : "string"
                  }
                }
              },
              "price_amount" : {
                "type" : "long"
              },
              "price_currency_code" : {
                "type" : "string"
              },
              "source_description" : {
                "type" : "string"
              },
              "source_url" : {
                "type" : "string"
              },
              "term_code" : {
                "type" : "string"
              }
            }
          },
          "alias_list" : {
            "type" : "string"
          },
          "blog_feed_url" : {
            "type" : "string"
          },
          "blog_url" : {
            "type" : "string"
          },
          "category_code" : {
            "type" : "string"
          },
          "competitions" : {
            "type" : "nested",
            "properties" : {
              "competitor" : {
                "type" : "object",
                "properties" : {
                  "name" : {
                    "type" : "string"
                  },
                  "permalink" : {
                    "type" : "string"
                  }
                }
              }
            }
          },
          "created_at" : {
            "type" : "string"
          },
          "crunchbase_url" : {
            "type" : "string"
          },
          "deadpooled_day" : {
            "type" : "long"
          },
          "deadpooled_month" : {
            "type" : "long"
          },
          "deadpooled_url" : {
            "type" : "string"
          },
          "deadpooled_year" : {
            "type" : "long"
          },
          "description" : {
            "type" : "string"
          },
          "email_address" : {
            "type" : "string"
          },
          "external_links" : {
            "type" : "nested",
            "properties" : {
              "external_url" : {
                "type" : "string"
              },
              "title" : {
                "type" : "string"
              }
            }
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
          "funding_rounds" : {
            "type" : "nested",
            "properties" : {
              "funded_day" : {
                "type" : "long"
              },
              "funded_month" : {
                "type" : "long"
              },
              "funded_year" : {
                "type" : "long"
              },
              "id" : {
                "type" : "long"
              },
              "investments" : {
                "type" : "nested",
                "properties" : {
                  "company" : {
                    "type" : "object",
                    "properties" : {
                      "name" : {
                        "type" : "string"
                      },
                      "permalink" : {
                        "type" : "string"
                      }
                    }
                  },
                  "financial_org" : {
                    "type" : "object",
                    "properties" : {
                      "name" : {
                        "type" : "string"
                      },
                      "permalink" : {
                        "type" : "string"
                      }
                    }
                  },
                  "person" : {
                    "type" : "object",
                    "properties" : {
                      "first_name" : {
                        "type" : "string"
                      },
                      "last_name" : {
                        "type" : "string"
                      },
                      "permalink" : {
                        "type" : "string"
                      }
                    }
                  }
                }
              },
              "raised_amount" : {
                "type" : "long"
              },
              "raised_currency_code" : {
                "type" : "string"
              },
              "round_code" : {
                "type" : "string"
              },
              "source_description" : {
                "type" : "string"
              },
              "source_url" : {
                "type" : "string"
              }
            }
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
          "investments" : {
            "type" : "nested",
            "properties" : {
              "funding_round" : {
                "type" : "nested",
                "properties" : {
                  "company" : {
                    "properties" : {
                      "name" : {
                        "type" : "string"
                      },
                      "permalink" : {
                        "type" : "string"
                      }
                    }
                  },
                  "funded_day" : {
                    "type" : "long"
                  },
                  "funded_month" : {
                    "type" : "long"
                  },
                  "funded_year" : {
                    "type" : "long"
                  },
                  "raised_amount" : {
                    "type" : "long"
                  },
                  "raised_currency_code" : {
                    "type" : "string"
                  },
                  "round_code" : {
                    "type" : "string"
                  },
                  "source_description" : {
                    "type" : "string"
                  },
                  "source_url" : {
                    "type" : "string"
                  }
                }
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
          "milestones" : {
            "type" : "nested",
            "properties" : {
              "description" : {
                "type" : "string"
              },
              "id" : {
                "type" : "long"
              },
              "source_description" : {
                "type" : "string"
              },
              "source_text" : {
                "type" : "string"
              },
              "source_url" : {
                "type" : "string"
              },
              "stoneable" : {
                "type" : "nested",
                "properties" : {
                  "name" : {
                    "type" : "string"
                  },
                  "permalink" : {
                    "type" : "string"
                  }
                }
              },
              "stoneable_type" : {
                "type" : "string"
              },
              "stoned_day" : {
                "type" : "long"
              },
              "stoned_month" : {
                "type" : "long"
              },
              "stoned_year" : {
                "type" : "long"
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
          "partners" : {
            "type" : "nested",
            "properties" : {
              "homepage_url" : {
                "type" : "string"
              },
              "link_1_name" : {
                "type" : "string"
              },
              "link_1_url" : {
                "type" : "string"
              },
              "link_2_name" : {
                "type" : "string"
              },
              "link_2_url" : {
                "type" : "string"
              },
              "link_3_name" : {
                "type" : "string"
              },
              "link_3_url" : {
                "type" : "string"
              },
              "partner_name" : {
                "type" : "string"
              }
            }
          },
          "permalink" : {
            "type" : "string"
          },
          "phone_number" : {
            "type" : "string"
          },
          "products" : {
            "type" : "nested",
            "properties" : {
              "name" : {
                "type" : "string"
              },
              "permalink" : {
                "type" : "string"
              }
            }
          },
          "providerships" : {
            "type" : "nested",
            "properties" : {
              "is_past" : {
                "type" : "boolean"
              },
              "provider" : {
                "type" : "object",
                "properties" : {
                  "name" : {
                    "type" : "string"
                  },
                  "permalink" : {
                    "type" : "string"
                  }
                }
              },
              "title" : {
                "type" : "string"
              }
            }
          },
          "relationships" : {
            "type" : "nested",
            "properties" : {
              "is_past" : {
                "type" : "boolean"
              },
              "person" : {
                "type" : "object",
                "properties" : {
                  "first_name" : {
                    "type" : "string"
                  },
                  "last_name" : {
                    "type" : "string"
                  },
                  "permalink" : {
                    "type" : "string"
                  }
                }
              },
              "title" : {
                "type" : "string"
              }
            }
          },
          "tag_list" : {
            "type" : "string",
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






