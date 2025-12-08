# PROJET_MOBILE

Projet Flutter mobile. Ce dépôt contient une application Flutter prête à être exécutée sur un émulateur Android.

## Description
Ce projet consiste à développer une application mobile de vente de vêtements en Flutter, utilisant GetX pour une architecture modulaire et une base SQflite embarquée pour garantir un fonctionnement autonome sans serveur externe. L’application, versionnée avec Git et enrichie d’API pour des fonctions avancées comme le paiement, offre une expérience complète couvrant tout le parcours utilisateur, du catalogue jusqu’à la gestion des commandes. Le détail des fonctionnalités et des contraintes est décrit dans `documents/Cahier des charges app-mobile.docx`.

## Aperçu rapide
- Framework: `Flutter`
- Plateformes: `Android` (émulateur ou appareil), iOS/macOS/Linux/Windows générés par défaut
- Langage: `Dart`

## Prérequis
- Installer `Flutter SDK` (version récente 3.x) et l’ajouter au `PATH`.
- Installer `Android Studio` avec l’Android SDK, Platform Tools (ADB) et l’Émulateur.
- Installer `JDK 17` et définir `JAVA_HOME` vers le JDK 17.
- Installer `Git` pour cloner le projet.

## Installation du projet
1. Cloner le dépôt:
   
   ```bash
   git clone git@github.com:godshelllive/PROJET_MOBILE.git
   cd PROJET_MOBILE
   ```

2. Vérifier votre environnement Flutter:
   
   ```bash
   flutter doctor
   ```

3. Récupérer les dépendances:
   
   ```bash
   flutter pub get
   ```

## Configuration Android (émulateur)
1. Ouvrir `Android Studio` et installer les composants requis dans `SDK Manager`:
   - Android SDK Platform dernière version
   - Android SDK Build-Tools
   - Android Emulator
   - Android Platform-Tools (ADB)

2. Créer un AVD (émulateur) via `Tools > Device Manager` puis `Create Device`.

3. Démarrer l’émulateur depuis `Device Manager` ou en ligne de commande:
   
   ```bash
   emulator -list-avds
   emulator -avd <nom_avd>
   ```

4. Fichier `android/local.properties` (si absent): s’assurer qu’il contient le chemin vers votre Flutter SDK. Ce projet Android lit `flutter.sdk`:
   
   ```properties
   flutter.sdk=C:\\chemin\\vers\\flutter
   ```

   Vérifiez aussi que `ANDROID_HOME`/`ANDROID_SDK_ROOT` et `JAVA_HOME` sont correctement définis.

## Lancer l’application sur l’émulateur
1. Vérifier les devices détectés:
   
   ```bash
   flutter devices
   ```

2. Lancer l’app:
   
   ```bash
   flutter run
   ```

   - Pour cibler un device spécifique:
   
   ```bash
   flutter run -d <device_id>
   ```

3. Pendant l’exécution:
   - `r` pour hot reload
   - `R` pour hot restart

## Commandes utiles
- Nettoyer le build:
  
  ```bash
  flutter clean && flutter pub get
  ```

- Construire un APK release:
  
  ```bash
  flutter build apk
  ```

## Dépannage
- AGP 8.x requiert `JDK 17`. Si la construction échoue côté Android, vérifiez `JAVA_HOME` pointe vers JDK 17.
- Si l’émulateur n’apparaît pas, démarrez-le via Android Studio (`Device Manager`) ou ADB/`emulator` et re-exécutez `flutter devices`.
- Si `flutter doctor` signale des éléments manquants (ex. Android licenses), exécutez:
  
  ```bash
  flutter doctor --android-licenses
  ```

## Références
- Documentation Flutter: https://docs.flutter.dev/
- Installation Flutter: https://docs.flutter.dev/get-started/install
- Configuration Android Studio: https://developer.android.com/studio
