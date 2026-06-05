# Règle : Android release — minify / shrinkResources désactivés

Le build type `release` doit garder **`isMinifyEnabled = false`** et
**`isShrinkResources = false`** (surcharge le défaut very_good qui active minify + proguard).

## Pourquoi

R8/proguard strippe sinon les libs natives de **Drift / sqlite3_flutter_libs**, provoquant
des crashs SQLite au runtime en release.

## À appliquer

`android/app/build.gradle.kts` :
```kotlin
buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
```

> Quand `isMinifyEnabled = false`, déclarer **explicitement** `isShrinkResources = false`
> (sinon Gradle erreur : shrinkResources requiert minify).
>
> Si un jour minify est réactivé pour réduire la taille : fournir des règles
> `proguard-rules.pro` qui gardent sqlite3/Drift au lieu de tout désactiver.
