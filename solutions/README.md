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

Cela pourrait donner :

```

```

### Exercice 3.8

Il existe un endpoint spécial pour tester le résultat d'un analyzer :

```

```

### Exercice 3.9

Il faut le définir comme *not_analyzed* : il sera conservé tel quel.





