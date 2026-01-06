# 🍊 SBC - Diagnostic Phytosanitaire des Agrumes au Maroc

Ce projet consiste en la conception et l'implémentation d'un **Système à Base de Connaissances (SBC)** dédié au diagnostic des pathologies agrumicoles au Maroc. Développé dans le cadre du module **Ingénierie de la Connaissance** à l’**ENSA de Tanger**, ce système modélise l’expertise agronomique afin d’aider les agriculteurs à identifier les principales menaces phytosanitaires affectant les agrumes.

## 🚀 Fonctionnalités Clés
* **Diagnostic Multicritère** : Identification de la **Cératite**, **Gommose**, **Fumagine**, **Greening (HLB)**, **Psorose** et **Stubborn**.
* **Moteur d'Inférence** : Utilisation du **chaînage arrière natif de Prolog (SLD)** pour remonter des symptômes vers les pathologies.
* **Gestion de l'Incertitude** : Chaque diagnostic est associé à un **coefficient de vraisemblance (CV)** basé sur des heuristiques expertes.
* **Alertes Économiques** : Intégration des **seuils de rentabilité (62 800 DH/ha)** avec génération d’alertes en cas de pertes de rendement potentielles.
* **Module d'Explicabilité** : Restitution d’une **trace de raisonnement** justifiant les conclusions du système.

## 🧠 Expertise et Acquisition
La base de connaissances repose sur une démarche d’acquisition rigoureuse impliquant :
1. **Expertise Humaine** : Heuristiques issues des chercheurs de l’**INRA Maroc** (*Dr. Khallou* et *Dr. Smaili*).
2. **Documents Techniques** : Bulletins de veille phytosanitaire de l’**ONSSA** (BVP N°10) et rapports du **C.E.E. Rungs**.
3. **Études de Cas** : Données épidémiologiques de la région de **l’Oriental**, indiquant une **prévalence des viroïdes de 55 %**.

## 🛠️ Structure du Projet

Le système est entièrement consolidé dans un fichier unique **`agrumes.pl`** afin de faciliter son déploiement, sa portabilité et sa prise en main. Ce choix architectural permet de regrouper l’ensemble de l’intelligence du système expert tout en conservant une séparation logique claire entre les différentes composantes.

Le fichier `agrumes.pl` est organisé en **trois couches logiques principales** :

### Base de Connaissances (BC)
- Contient l’**ontologie détaillée** du domaine agrumicole, composée de **31 paramètres discriminants** (aspect des feuilles, symétrie, porte-greffe, écoulement de gomme, présence de fumagine, etc.).
- Intègre les **15 règles de production** reliant les combinaisons de symptômes observés aux pathologies cibles (Cératite, Gommose, Fumagine, Greening, Psorose et Stubborn).
- Définit une **hiérarchie taxonomique de type Frames**, permettant l’héritage des propriétés biologiques et économiques des maladies.

### Moteur d’Inférence
- Exploite le mécanisme de **chaînage arrière (SLD Resolution)** natif de Prolog pour valider ou infirmer les hypothèses diagnostiques.
- Implémente une **stratégie de recherche hiérarchique** sous forme d’arbre de décision afin d’optimiser l’ordre du questionnement  
  *(Organe → Symptôme → Facteur discriminant)*.
- Gère la **pondération des diagnostics** à l’aide de **coefficients de vraisemblance (CV)** ainsi que des règles d’exclusion pour améliorer la précision des résultats.

### Interface et Dialogue
- Assure la **saisie dynamique des faits**, permettant à l’utilisateur d’introduire les observations de terrain de manière interactive.
- Intègre un module d’**explicabilité**, capable de restituer la **trace complète du raisonnement** et de justifier chaque diagnostic à partir des règles activées.
- Déclenche des **alertes économiques** basées sur les seuils de rentabilité (**62 800 DH/ha**) et les pertes de rendement estimées.

Le regroupement de l’ensemble des modules dans le fichier unique **`agrumes.pl`** permet à l’utilisateur de charger l’intégralité du système expert avec une seule commande dans **SWI-Prolog**.  
Ce choix répond à l’objectif d’**évolutivité et de simplicité de déploiement**, tout en facilitant la démonstration et l’évaluation du système lors de la soutenance académique.

  

## 📊 Représentation des Connaissances
Le système adopte une **approche hybride** garantissant cohérence et explicabilité :
* **Règles de Production** :  
  `SI (Symptômes) ALORS (Pathologie)`
* **Arbre de Décision** :  
  Stratégie hiérarchique par organe : **Feuille → Tronc → Fruit**
* **Frames** :  
  Structuration sémantique avec héritage des propriétés biologiques.

## 💻 Installation et Utilisation
1. Téléchargez et installez **SWI-Prolog** :  
   👉 https://www.swi-prolog.org/

2. Clonez le dépôt :
   ```bash
   git clone https://github.com/KenzaAEK/SBC-Agrumes-Maroc.git
   cd SBC-Agrumes-Maroc
   
3. Lancement Automatisé
Le système est conçu pour être prêt à l'emploi dès le chargement afin de respecter l'objectif ONF1 (Utilisabilité).
* Sous Windows : Double-cliquez simplement sur le fichier main.pl (ou le fichier principal de votre projet). SWI-Prolog s'ouvrira et lancera automatiquement le menu de diagnostic.
* Via la console Prolog : Si vous ouvrez d'abord l'interpréteur, chargez le fichier et Grâce à la directive d'initialisation incluse dans le code, le menu principal s'affichera directement sans saisie supplémentaire de votre part.

4. Utilisation du SBC
Une fois le menu lancé :
* Saisie des observations : Répondez aux questions posées par le système en suivant l'ordre expert (Feuille → Tronc → Fruit).
* Consultation du diagnostic : Le système affiche la pathologie identifiée accompagnée de son indice de confiance (CV).
* Justification : Pour chaque résultat, vous pouvez demander la trace du raisonnement pour comprendre quelles règles ont été déclenchées (Objectif OF2).
* Le temps de réponse global est optimisé pour être inférieur à 2 minutes, facilitant une utilisation directe en verger.

## 🎯 Objectifs du Système
* Assister les agriculteurs dans la détection précoce des maladies des agrumes.
* Réduire les pertes économiques liées aux pathologies phytosanitaires.
* Valoriser l’expertise agronomique marocaine via un système intelligent.
* Fournir un outil explicable, structuré et évolutif.

👤 Auteur
ABOU-EL KASEM Kenza
Élève Ingénieur en Génie Informatique 
Encadré par :
Pr. M. El Alami

📅 Année Universitaire : 2025 / 2026
