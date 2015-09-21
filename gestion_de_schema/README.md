# Gestion de schéma

## Comparaison avec une base de données

Les système d'indexation tels Elasticsearch, s'ils sont différents des bases de données dans leur usage, présentent quelques similitudes dans leur organisation des données.

Dans une base de données, une *base* contient des *tables*, qui contiennent des *lignes*, qui elles-mêmes sont composées de *colonnes*.

Dans ElasticSearch, un *index* contient des *types*, qui contiennent des *documents*, qui eux-mêmes sont constitués de *champs*.

On va retrouver cette hiérarchie dans les exemples suivants.

Au-delà de ce parallèle dans l'organisation hiérarchique des données, les deux types de système n'ont pas grand chose en commun.
Les bases de données sont par nature relationnelles, tandis qu'au contraire un index présentera des données à plat : toute relation doit être dénormalisée.

## Représentation d'un document

Dans l'usage d'ElasticSearch, tout est JSON : les documents indexés, les configurations d'index (ou *mapping*), les requêtes, les résultats.

Pour indexer un document, on va donc devoir :
- choisir un index
- choisir un type
- modéliser le document sous forme de JSON , et le fournir à ElasticSearch

ES va ensuite enrichir ce document avec des métadonnées :
- `_id` va être un identifiant unique généré par ES
- `_version` va indiquer le nombre de modifications effectuées sur ce document
- les champs `_index` et `_type` vont refléter les choix faits à l'indexation


## Quelques examples d'indexation

On va retrouver cette hiérarchie dans les exemples suivants.
Ces examples et exercices se basent sur un objet simple : un produit qui possède un code, un nom, une date de création et un compteur de pages vues.

Essayons d'abord d'indexer un document :

```
# curl -XPOST http://localhost:9200/store/products/ -d '
{ "code" : "XX-22",
  "name" : "Jetpack (latest generation)",
  "count" : 12, "date" : "2015-09-12",
  "tags" : ["propulsion", "diesel"]
}'
{
 "_index":"store",
 "_type":"products",
 "_id":"AUzsJpaGLqo_1PEA5m0U",
 "_version":1,
 "created":true
 }
```

Noter que la plupart des requêtes HTTP sont de la forme http://localhost:9200/<index_name>/<type_name>. Certaines se contentent du nom de l'index. 


Pour les exercices suivants, on pourra s'appuyer sur [cette page](http://www.elastic.co/guide/en/elasticsearch/guide/current/data-in-data-out.html).


#### Exercice 3.1 :

- Insérer un autre document (avec le même schéma) en lui préassignant l'id "2"

#### Exercice 3.2 :

- Comment peut-on écraser un document existant ?
- Comment peut-on voir dans la réponse ElasticSearch qu'il existait déjà ?
- Bonus : Quel serait un moyen de tester son existence sans passer par une recherche ou une création ?

#### Exercice 3.3 :

- Récupérer le document créé en 3.1
- Comment peut-on récupérer certains champs de ce document seulement ?
- Bonus : Comment peut-on récupérer plusieurs documents par leurs ID ?

#### Exercice 3.4 :

- Modifier le document créé en 3.1 (en ajoutant un champ "in_stock" par exemple)

#### Exercice 3.5 :

- Supprimer le document créé en 3.1


## Comprendre le mapping

Pour voir la représentation interne d'un type dans ES, on va lui demander son *mapping*:

```
# curl -XGET http://localhost:9200/store/products/_mapping?pretty
{
  "store" : {
    "mappings" : {
      "products" : {
        "properties" : {
          "code" : {
            "type" : "string"
          },
          "count" : {
            "type" : "long"
          },
          "date" : {
            "type" : "date",
            "format" : "dateOptionalTime"
          },
          "name" : {
            "type" : "string"
          },
          "tags" : {
            "type" : "string"
          }
        }
      }
    }
  }
}
```

On voit donc dans la sortie :
- les noms de l'index et du ou des type(s)
- une description de chaque champ (ou "properties")

ES a donc déduit depuis les documents indexés ce qu'il juge être le type adéquat pour chaque champ rencontré. C'est la raison pour laquelle on le dit schemaless : on n'a pas besoin de fournir un schéma pour utiliser l'outil.

Si cela permet de rapidement commencer à jouer avec l'outil, il est difficilement envisageable de déployer une solution en prod sans avoir customisé le mapping, car c'est de sa qualité que dépendra le succès de la recherche.

Les enjeux principaux lorsqu'on définit un champ sont les suivants :
- quel est le type de ce champ ? Un champ numérique ne doit pas être indexé comme une string. Il faut donc spécifier le type correct pour ce champ.
- que veut-on faire de ce champ ? Effectuer une recherche exacte ?  Effectuer une recherche textuelle plus complexe ? Le récupérer ou juste l'utiliser dans une recherche ?  Il faut donc spécifier la manière dont on veut analyser ce champ.
- quelle est la structure de l'objet stocké ? Au delà des types standards JSON (string, boolean, int...), ES peut également gérer des tableaux de ces types, voire utiliser des "nested objects" pour des structures plus complexes.


Pour les exercices suivants, on pourra s'appuyer sur [le guide du mapping](http://www.elastic.co/guide/en/elasticsearch/guide/current/mapping-analysis.html).

#### Exercice 3.6 :

- Supprimer puis recréer le mapping de "products"

#### Exercice 3.7 :

- Comment modifier le mapping d'un champ existant ? (hint : c'est compliqué :) )

#### Exercice 3.8 :

- Comment tester un analyzer sur du texte ?

#### Exercice 3.9 :

- J'ai dans mon mapping un champ "code" correspondant à un code produit, sur lequel réaliser une recherche exacte : comment le définir ?
- J'ai dans mon mapping un champ numérique "count" utilisé pour trier, mais jamais utilisé à l'affichage : comment le définir ?



