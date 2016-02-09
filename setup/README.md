# Installation

Cette formation va s'appuyer sur une machine virtuelle préconfigurée.

## Prérequis

Pour pouvoir lancer cette machine virtuelle, il faut avoir installé :
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [git](http://git-scm.com/)

Il est préférable de télécharger les dernières versions de Vagrant et VirtualBox directement sur les sites des éditeurs.

## Mode opératoire

La VM à utiliser est le produit d'un provisioning réalisé avec Ansible dont on trouvera les détails [ici](https://github.com/fredcons/vagrant-elasticsearch).

Il est possible de suivre le mode opératoire décrit sur ce repository pour lancer l'environnement, mais il est plus simple d'utiliser la VM packagée qui résulte de ce provisioning, [fredcons/elasticsearch-handson](https://atlas.hashicorp.com/fredcons/boxes/elasticsearch-handson), disponible sur [Atlas](https://atlas.hashicorp.com/) (ex-Vagrant Cloud)

Voilà comment initialiser la VM cible en utilisant cette box pré-packagée :

```
mkdir es-handson && cd es-handson
cat <<EOT >> Vagrantfile
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "fredcons/elasticsearch-handson"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "forwarded_port", guest: 9200, host: 9200
  config.vm.network "forwarded_port", guest: 5601, host: 5601
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end
end
EOT
vagrant up
vagrant ssh
```

On dispose maintenant d'une machine Ubuntu sur laquelle sont installés :
- ElasticSearch
- Kibana
- Logstash
- Topbeat et Packetbeat
- quelques packages utilitaires comme [git](http://git-scm.com/), [jq](http://stedolan.github.io/jq/), [es2unix](https://github.com/elastic/es2unix)






