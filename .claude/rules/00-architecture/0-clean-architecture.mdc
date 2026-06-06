---
description: APPLIQUER les principes de la Clean Architecture LORS de l’organisation du code backend
globs: apps/*_api/**
alwaysApply: false
---
Structure des couches :
- Séparer le code par couche : Domaine, Application, Infrastructure, Présentation
- Les dépendances doivent toujours aller vers l’intérieur uniquement
- Le domaine doit être sans dépendance au framework
- Définir des interfaces à chaque limite de couche

Couche Domaine :
- Placer ici la logique métier et les entités
- Utiliser des modèles purs et sans framework
- Définir des services de domaine pour la logique complexe
- Déclarer uniquement les interfaces de dépôt (repository)

Couche Application :
- Implémenter les cas d’usage comme orchestrateurs
- Services strictement à responsabilité unique
- Utiliser des DTO pour tout transfert de données
- Valider les entrées aux frontières

Couche Infrastructure :
- Implémenter les interfaces de dépôt du domaine
- Isoler tous les systèmes externes (BDD, APIs, fichiers)
- Ne jamais faire entrer l’infrastructure dans la logique métier

Couche Présentation :
- Gérer les requêtes et réponses API
- Utiliser des contrôleurs pour la logique HTTP
- Centraliser la gestion des erreurs et la validation
- Formater toutes les réponses de manière cohérente
