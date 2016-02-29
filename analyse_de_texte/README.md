# Analyse de texte

On a vu sur ces précédents exemples qu'une chaine de caractère pouvait être "analysée", c'est-à-dire transformée par une série de filtres, ou "non analysée" c'est-à-dire laissée telle quelle.  
Pour l'instant, les chaines analysées l'ont été avec l'`analyzer` `standard` : cet `analyzer` va pour une chaine donnée:
- la découper en termes, avec un `tokenizer`
- passer chaque terme en minuscules : c'est le rôle d'un `tokenfilter`
- supprimer les mots présents dans une liste noire nommée "stopwords", avec un autre `tokenfilter` 

C'est cette chaine d'analyse qui est utilisée par défaut dans ElasticSearch.  
On va voir qu'il est possible de créer des analyzers customs en composant soi-même un `tokenizer` et des `tokensfilters` .

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
curl http://localhost:9200/crunchbase/_analyze?pretty&analyzer=tags -d "tag1, tag2, tag3"
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

La documentation de cet endpoint se trouve [ici](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lang-analyzer.html).

## Analyzers

L'`analyzer` est la brique d'analyse de plus haut niveau : c'est elle que l'on va assigner à un champ du schéma pour en définir l'usage qu'on veut en avoir.


Comme vu plus haut, un `analyzer` se compose:  
- d'un `tokenizer` qui travaille au niveau du texte
- d'une chaine de `tokenfilters` qui travaillent au niveau de chaque terme émis par le `tokenizer`
- de `charfilters` qui permettent de transformer des caractères (on va les laisser de coté)
 
ES propose entre autres les `analyzer`s `standard`, `whitespace`, ainsi que des `analyzer`s [par langage](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lang-analyzer.html), mais la plupart du temps, il va falloir définir soi-même un ou plusieurs analyzers customs.


## Tokenizers

On l'a vu, un `tokenizer` travaille au niveau d'un texte, et le découpe en `tokens`.  
Il faut donc décider qu'est ce qui délimite les `tokens`, et ES propose plusieurs options, dont voici les principales : 
- le tokenizer `standard`, l'option la plus courante, qui va splitter le texte sur les espaces et un certain nombre de délimiteurs de type ponctuation 
- le tokenizer `whitespace`, qui utilise tout espace comme séparateur
- le tokenizer `keyword`, qui considère tout le texte comme un seul token : si c'est le besoin, il vaut mieux déclarer son champ `not_analyzed`
- le tokenizer `ngram`, qui va créer des groupes de lettres correspondant à des tailles données
- le tokenizer `pattern`, vu ci-dessus, qui va s'appuyer sur une expression régulière
- et d'autres encore

La liste complète est disponible [ici](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenizers.html).


## Tokenfilters

Les `tokenfilters` vont traiter chaque terme émis par les `tokenizers`, pour les modifier, les supprimer, ou ajouter d'autres termes.  
C'est en les combinant que l'on va vraiment pouvoir traiter le texte comme on le veut.  
Les filtres de base incluent :
- `lowercase`, qui transforme le texte en minuscule
- `asciifolding` qui normalise les accents, cédilles...
- `synonym` qui va ajouter des termes
- `keyword` qui va préserver des termes
- `stopwords` qui va supprimer des mots
- `stemming` qui va réduire le mot à sa racine
- et [bien d'autres](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenfilters.html)
 


## Utilisation dans un schéma

Chaque index présente une section `settings`, dans laquelle on va trouver : 
- le paramétrage "global de l'index : réplication, sharding, paramètres techniques de bas niveau
- une section `analysis` dans laquelle on trouverra tous les éléments de la chaine d'analyse, rangés par type.
 

Cela donne : 

```
"settings" : {
  ...
  "analysis" : {
    "filter" : {
      ...
    },
    "tokenizer" : {
      ...
    },
    "analyzer" : {
      ...
    }
  }
}
```

Les `filters` et `tokenizers` vont avoir leur propre nom (ex : `my_custom_stemmer`), référencer les briques de base d'ElasticSearch (ex : `stemmer`), en les paramétrant selon les besoins de l'application (ex : "name" : "light_french")

```
    "filter" : {
      "my_custom_stemmer" : {
        "type" : "stemmer",
        "name" : "light_french"
      }
    },  
```

Un `analyzer` va ensuite référencer un `tokenizer` et plusieurs `tokenfilters`, qui existent dans el schéma ou sont des briques de base d'ES :

```
    "analyzer" : {
      "my_analyzer" : {
        "tokenizer" :  "whitespace",
        "filter"    : [
          "lowercase",
          "my_custom_stemmer"
        ]
      }
    }  
```   

On peut ensuite référencer cet `analyzer` sur un champ du schéma : 

```
   "my_field" : {
     "type"     : "string",
     "analyzer" : "my_analyzer"
   }
```


## Exercices

On va tâcher de créer un `analyzer` en vue d'obtenir des chaines de caractères spécifiques.

Le modèle de création d'`analyzer` sera le suivant : 

```
curl -XPUT http://localhost:9200/my_index -d '
{
  "settings" : {
    "number_of_shards"   : 5,
    "number_of_replicas" : 0,
    "analysis" : {
      "filter" : {
        
      },
      "tokenizer" : {
        
      },
      "analyzer" : {
        "my_analyzer" : {
        
        }
      }
    }
  }    
}    
'
```

#### Exercice 6.1

Créer un `analyzer` qui permettre d'obtenir le résultat suivant : 

```
curl http://localhost:9200/my_index/_analyze?pretty&analyzer=my_analyzer -d "Ivre, il achète une imprimante HP-AA28"
{
  "tokens": [
    {
      "token": "Ivre, il achète une imprimante HP-AA28",
      "start_offset": 0,
      "end_offset": 36,
      "type": "word",
      "position": 0
    }
  ]
}
```

#### Exercice 6.2

Modifier l'`analyzer` précédent pour qu'il transforme le texte en lowercase

```
curl http://localhost:9200/my_index/_analyze?pretty&analyzer=my_analyzer -d "Ivre, il achète une imprimante HP-AA28"
{
  "tokens": [
    {
      "token": "ivre, il achète une imprimante hp-aa28",
      "start_offset": 0,
      "end_offset": 38,
      "type": "word",
      "position": 0
    }
  ]
}
```

#### Exercice 6.3


Modifier l'`analyzer` précédent pour qu'il tokenize sur des espaces, mais en filtrant les caractères de ponctuation (note: on pourrait utiliser le tokenizer par défault, mais on ne va pas le faire :) )

```
curl http://localhost:9200/my_index/_analyze?pretty&analyzer=my_analyzer -d "Ivre, il achète une imprimante HP-AA28"
{
  "tokens": [
    {
      "token": "ivre",
      "start_offset": 0,
      "end_offset": 4,
      "type": "word",
      "position": 0
    },
    {
      "token": "il",
      "start_offset": 6,
      "end_offset": 8,
      "type": "word",
      "position": 1
    },
    {
      "token": "achète",
      "start_offset": 9,
      "end_offset": 15,
      "type": "word",
      "position": 2
    },
    {
      "token": "une",
      "start_offset": 16,
      "end_offset": 19,
      "type": "word",
      "position": 3
    },
    {
      "token": "imprimante",
      "start_offset": 20,
      "end_offset": 30,
      "type": "word",
      "position": 4
    },
    {
      "token": "hp",
      "start_offset": 31,
      "end_offset": 33,
      "type": "word",
      "position": 5
    },
    {
      "token": "aa28",
      "start_offset": 34,
      "end_offset": 38,
      "type": "word",
      "position": 6
    }
  ]
}
```

#### Exercice 6.4

Modifier l'`analyzer` précédent pour qu'il supprime les accents, et indexe le radical des mots (via du stemming)

```
curl http://localhost:9200/my_index/_analyze?pretty&analyzer=my_analyzer -d "Ivre, il achète une imprimante HP-AA28"


```

#### Exercice 6.5

Modifier l'`analyzer` précédent pour qu'il supprime le mot "une", et conserve le mot "imprimante" tel quel.

```
curl http://localhost:9200/my_index/_analyze?pretty&analyzer=my_analyzer -d "Ivre, il achète une imprimante HP-AA28"

```

#### Exercice 6.6

Modifier l'`analyzer` précédent pour qu'il émetter à la fois "hp", "aa", "28" et "hp-aa28"

#### Exercice 6.7

Analyser ce texte avec l'`analyzer` par défaut

#### Exercice 6.8

Analyser ce texte avec l'`analyzer` français

