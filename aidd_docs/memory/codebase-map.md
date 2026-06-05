---
name: codebase-structure
description: Project structure documentation
argument-hint: N/A
scope: all
---

# Codebase Structure

```mermaid
flowchart TD
    Root["digiharmony/ (monorepo Melos 7 · pub workspace)"]
    Root --> Pubspec["pubspec.yaml (workspace + melos)"]
    Root --> Apps["apps/"]
    Root --> Pkgs["packages/"]
    Root --> Docs["aidd_docs/"]

    Apps --> App["digiharmony_app/ (very_good_cli)"]
    App --> Lib["lib/"]
    App --> Andr["android/"]
    App --> Plat["ios · macos · linux · windows · web"]
    App --> Assets["assets/ (images · fonts · audio · video)"]
    App --> Test["test/ (app · counter · helpers)"]
    App --> L10nYaml["l10n.yaml · analysis_options.yaml · deploy.sh"]

    Lib --> Entries["main.dart · main_{development,staging,production}.dart"]
    Lib --> Boot["bootstrap.dart"]
    Lib --> AppDir["app/ (app.dart · view/app.dart)"]
    Lib --> Counter["counter/ (cubit · view) — exemple VGC"]
    Lib --> Config["config/legal_urls.dart"]
    Lib --> L10n["l10n/"]
    L10n --> Arb["arb/ (8 langues: en,fr,el,it,ro,tr,es,mk)"]
    L10n --> Gen["gen/ (app_localizations*.dart généré)"]

    Andr --> Gradle["build.gradle.kts · settings.gradle.kts · gradle.properties"]
    Andr --> AndrApp["app/ (src: main,debug,profile,development,staging)"]
    Andr --> Secrets["digiharmony_keystore.jks · key.properties (hors VCS)"]

    Pkgs --> Core["core_package/ (lib/src · test · .github)"]

    Docs --> Mem["memory/ (project-overview · codebase-map · internal · external)"]
    Docs --> Dec["internal/decisions/ (ADR · 0001 · 0002)"]
    Docs --> Rules["rules/ (melos7-pub-workspace · android-gradle-minify-off · permissions-zero-collecte)"]
```
