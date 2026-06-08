#!/usr/bin/env python3
"""Inject lot-2 i18n keys into the 8 ARB files.

EN  -> value + @metadata (description, optional placeholders).
FR  -> value only.
others (el/it/ro/tr/es/mk) -> EN value as fallback (repli en), value only.

Idempotent: existing keys are overwritten (kept in original order where present,
appended otherwise). Preserves a deterministic insertion order.
"""
import json
import collections
from pathlib import Path

ARB_DIR = Path(__file__).resolve().parent.parent / "lib" / "l10n" / "arb"
LANGS = ["en", "fr", "el", "it", "ro", "tr", "es", "mk"]

# Each entry: key -> {"en":..., "fr":..., "desc":..., "ph": optional placeholders dict}
KEYS = collections.OrderedDict()


def add(key, en, fr, desc, ph=None):
    KEYS[key] = {"en": en, "fr": fr, "desc": desc, "ph": ph}


# ---------------- Conseils (advice*) ----------------
add("adviceTitle", "Advice", "Conseils", "Advice screen title")
add("adviceEmotionLabel", "Emotion", "Émotion", "Emotion label")
add("adviceDoSectionLabel", "Do", "À faire", "Do section label")
add("adviceAvoidSectionLabel", "Avoid", "À éviter", "Avoid section label")
add("adviceTryBreathing", "Try breathing", "Essayer la respiration", "Try breathing CTA")
add("advicePrev", "previous", "précédent", "Previous control")
add("adviceNext", "next", "suivant", "Next control")
add("adviceApply", "I'll apply this advice", "J'applique ce conseil", "Apply CTA")
add("adviceAppliedConfirmation", "Well done, take care of yourself", "Bien joué, prends soin de toi", "Apply confirmation")
# anger
add("adviceCardTitleAnger", "When you feel angry…", "Quand tu te sens en colère…", "Anger title")
add("adviceDoAnger1", "Take a break before replying", "Fais une pause avant de répondre", "Anger do 1")
add("adviceDoAnger2", "Breathe deeply 3 times", "Respire profondément 3 fois", "Anger do 2")
add("adviceDoAnger3", "Write what you feel — without sending", "Écris ce que tu ressens — sans envoyer", "Anger do 3")
add("adviceAvoidAnger1", "Don't post in the heat of the moment", "Ne poste pas à chaud", "Anger avoid 1")
add("adviceAvoidAnger2", "Avoid online confrontations", "Évite les confrontations en ligne", "Anger avoid 2")
# sadness
add("adviceCardTitleSadness", "When you feel sad…", "Quand tu te sens triste…", "Sadness title")
add("adviceDoSadness1", "Talk to someone you trust", "Parle à quelqu'un de confiance", "Sadness do 1")
add("adviceDoSadness2", "Move your body a little", "Bouge un peu ton corps", "Sadness do 2")
add("adviceDoSadness3", "Do one small kind thing for yourself", "Fais une petite chose douce pour toi", "Sadness do 3")
add("adviceAvoidSadness1", "Don't scroll endlessly", "Ne scrolle pas sans fin", "Sadness avoid 1")
add("adviceAvoidSadness2", "Avoid isolating yourself all day", "Évite de t'isoler toute la journée", "Sadness avoid 2")
# fear
add("adviceCardTitleFear", "When you feel afraid…", "Quand tu as peur…", "Fear title")
add("adviceDoFear1", "Name what scares you", "Nomme ce qui te fait peur", "Fear do 1")
add("adviceDoFear2", "Focus on what you can control", "Concentre-toi sur ce que tu contrôles", "Fear do 2")
add("adviceDoFear3", "Breathe slowly and steadily", "Respire lentement et calmement", "Fear do 3")
add("adviceAvoidFear1", "Don't feed worst-case scenarios", "Ne nourris pas les pires scénarios", "Fear avoid 1")
add("adviceAvoidFear2", "Avoid alarming content online", "Évite les contenus anxiogènes en ligne", "Fear avoid 2")
# stress
add("adviceCardTitleStress", "When you feel stressed…", "Quand tu te sens stressé·e…", "Stress title")
add("adviceDoStress1", "Take things one step at a time", "Avance étape par étape", "Stress do 1")
add("adviceDoStress2", "Take a short screen-free break", "Fais une courte pause sans écran", "Stress do 2")
add("adviceDoStress3", "Drink some water and stretch", "Bois de l'eau et étire-toi", "Stress do 3")
add("adviceAvoidStress1", "Don't take on everything at once", "Ne prends pas tout en même temps", "Stress avoid 1")
add("adviceAvoidStress2", "Avoid skipping sleep", "Évite de sacrifier ton sommeil", "Stress avoid 2")
# loneliness
add("adviceCardTitleLoneliness", "When you feel lonely…", "Quand tu te sens seul·e…", "Loneliness title")
add("adviceDoLoneliness1", "Reach out to one person", "Écris à une personne", "Loneliness do 1")
add("adviceDoLoneliness2", "Join an activity you enjoy", "Rejoins une activité que tu aimes", "Loneliness do 2")
add("adviceDoLoneliness3", "Be gentle with yourself", "Sois doux·ce avec toi-même", "Loneliness do 3")
add("adviceAvoidLoneliness1", "Don't compare yourself online", "Ne te compare pas en ligne", "Loneliness avoid 1")
add("adviceAvoidLoneliness2", "Avoid waiting for others to reach out", "Évite d'attendre que les autres viennent", "Loneliness avoid 2")

# ---------------- Guide notifications (notifGuide*) ----------------
add("notifGuideBrand", "DigiHarmony", "DigiHarmony", "Brand label")
add("notifGuideTitle", "Mute my notifications", "Couper mes notifications", "Guide title")
add("notifGuideSubtitle", "Fewer notifications, more calm.", "Moins de notifications, plus de calme.", "Guide subtitle")
add("notifGuideTip", "Each notification removed is one less interruption. Take your time.", "Chaque notification en moins, c'est une interruption de moins. Prends ton temps.", "Tip banner")
add("notifGuideOtherPhone", "See for another phone", "Voir pour un autre téléphone", "Toggle platform link")
add("notifGuideMenuTooltip", "Menu", "Menu", "Menu tooltip")
add("notifGuideBackLabel", "Back", "Retour", "Back a11y")
# android steps
add("notifGuideStep1Title", "Open Settings", "Ouvre les Réglages", "Step 1 title android")
add("notifGuideStep1Body", "Find the gear icon on your home screen or in your app library.", "Repère l'icône engrenage sur ton écran d'accueil ou dans ta bibliothèque d'apps.", "Step 1 body android")
add("notifGuideStep2Title", "Tap \"Notifications\"", "Appuie sur « Notifications »", "Step 2 title android")
add("notifGuideStep2Body", "Scroll to the \"Notifications\" section and tap it.", "Fais défiler jusqu'à la section « Notifications » et appuie dessus.", "Step 2 body android")
add("notifGuideStep3Title", "Pick a distracting app", "Choisis une app distrayante", "Step 3 title android")
add("notifGuideStep3Body", "Choose an app that interrupts you often — social media, messaging, games.", "Sélectionne une app qui t'interrompt souvent — réseaux sociaux, messageries, jeux.", "Step 3 body android")
add("notifGuideStep4Title", "Turn off or group", "Désactive ou regroupe", "Step 4 title android")
add("notifGuideStep4Body", "Turn notifications off, or enable \"Scheduled summary\" to get them once a day.", "Désactive les notifications ou active « Résumé programmé » pour les recevoir une seule fois par jour.", "Step 4 body android")
add("notifGuideStep5Title", "Repeat for each app", "Répète pour chaque app", "Step 5 title android")
add("notifGuideStep5Body", "Take 2–3 minutes to go through your apps one by one. Every bit of quiet counts.", "Prends 2–3 minutes pour passer les apps une par une. Chaque silence compte.", "Step 5 body android")
# ios steps
add("notifGuideStep1TitleIos", "Open Settings", "Ouvre les Réglages", "Step 1 title ios")
add("notifGuideStep1BodyIos", "Find the grey \"Settings\" icon on your home screen or via search.", "Repère l'icône grise « Réglages » sur ton écran d'accueil ou via la recherche.", "Step 1 body ios")
add("notifGuideStep2TitleIos", "Tap \"Notifications\"", "Appuie sur « Notifications »", "Step 2 title ios")
add("notifGuideStep2BodyIos", "In Settings, open the \"Notifications\" section.", "Dans Réglages, ouvre la section « Notifications ».", "Step 2 body ios")
add("notifGuideStep3TitleIos", "Pick a distracting app", "Choisis une app distrayante", "Step 3 title ios")
add("notifGuideStep3BodyIos", "Choose an app that interrupts you often — social media, messaging, games.", "Sélectionne une app qui t'interrompt souvent — réseaux sociaux, messageries, jeux.", "Step 3 body ios")
add("notifGuideStep4TitleIos", "Turn off or schedule", "Désactive ou programme", "Step 4 title ios")
add("notifGuideStep4BodyIos", "Turn off \"Allow Notifications\", or use \"Scheduled Summary\" to group them.", "Désactive « Autoriser les notifications » ou utilise le « Résumé programmé » pour les regrouper.", "Step 4 body ios")
add("notifGuideStep5TitleIos", "Repeat for each app", "Répète pour chaque app", "Step 5 title ios")
add("notifGuideStep5BodyIos", "Take 2–3 minutes to go through your apps one by one. Every bit of quiet counts.", "Prends 2–3 minutes pour passer les apps une par une. Chaque silence compte.", "Step 5 body ios")

# ---------------- Temps d'ecran (screenTime*) ----------------
add("screenTimeTitle", "My screen time", "Mon temps d'écran", "Screen time title")
add("screenTimeTodaySubtitle", "Here's your screen time today", "Voici ton temps d'écran aujourd'hui", "Today subtitle")
add("screenTimeTodayLabel", "today", "aujourd'hui", "Today label")
add("screenTimeWeekLabel", "this week", "cette semaine", "Week label")
add("screenTimePrivacyNotice", "This data is read on your phone only. Nothing is sent.", "Ces données sont lues sur ton téléphone uniquement. Rien n'est envoyé.", "Privacy banner")
add("screenTimeNextSection", "And now?", "Et maintenant ?", "Next section label")
add("screenTimeActionBreakTitle", "Take a break", "Faire une pause", "Break action title")
add("screenTimeActionBreakSubtitle", "Start a Detox session now", "Lance une session Détox maintenant", "Break action subtitle")
add("screenTimeActionNotificationsTitle", "Mute my notifications", "Couper mes notifications", "Notif action title")
add("screenTimeActionNotificationsSubtitle", "Quick guide to reduce interruptions", "Guide rapide pour réduire les interruptions", "Notif action subtitle")
add("screenTimePermissionTitle", "Allow screen time access", "Autorise l'accès au temps d'écran", "Permission title")
add("screenTimePermissionBody", "To show your screen time, allow DIGIHARMONY to read your phone usage. Nothing is sent.", "Pour afficher ton temps d'écran, autorise DIGIHARMONY à lire l'usage de ton téléphone. Rien n'est envoyé.", "Permission body")
add("screenTimePermissionCta", "Allow access", "Autoriser l'accès", "Permission CTA")
add("screenTimeUnsupportedTitle", "Available on Android only", "Disponible sur Android uniquement", "Unsupported title")
add("screenTimeUnsupportedBody", "This feature uses a screen time measure available only on Android.", "Cette fonctionnalité utilise une mesure du temps d'écran disponible seulement sur Android.", "Unsupported body")
add("screenTimeErrorBody", "Couldn't read your screen time right now.", "Impossible de lire ton temps d'écran pour le moment.", "Error body")
add("screenTimeRetryCta", "Retry", "Réessayer", "Retry CTA")
add("screenTimeDurationHm", "{hours}h{minutes}m", "{hours}h{minutes}m", "Duration format", {"hours": {"type": "int"}, "minutes": {"type": "int"}})
add("screenTimeWeekday1", "M", "L", "Weekday monday")
add("screenTimeWeekday2", "T", "M", "Weekday tuesday")
add("screenTimeWeekday3", "W", "M", "Weekday wednesday")
add("screenTimeWeekday4", "T", "J", "Weekday thursday")
add("screenTimeWeekday5", "F", "V", "Weekday friday")
add("screenTimeWeekday6", "S", "S", "Weekday saturday")
add("screenTimeWeekday7", "S", "D", "Weekday sunday")
add("screenTimeToolbarBack", "Back", "Retour", "Back a11y")

# ---------------- Parametres (settings*) ----------------
add("settingsTitle", "Settings", "Paramètres", "Settings title")
add("settingsSectionLanguage", "Language", "Langue", "Language section")
add("settingsSectionPrivacy", "Privacy", "Confidentialité", "Privacy section")
add("settingsPrivacyNotice", "No personal data is stored or shared. No account, no sign-in.", "Aucune donnée personnelle n'est enregistrée ni diffusée. Pas de compte, pas d'identification.", "Privacy notice")
add("settingsSectionProject", "The project", "Le projet", "Project section")
add("settingsOpenSourceTitle", "Open source code", "Code open source", "Open source title")
add("settingsOpenSourceSubtitle", "GitHub · GNU GPL License", "GitHub · Licence GNU GPL", "Open source subtitle")
add("settingsWebsiteTitle", "digiharmony.org", "digiharmony.org", "Website title")
add("settingsWebsiteSubtitle", "Official project website", "Site officiel du projet", "Website subtitle")
add("settingsErasmusNotice", "Erasmus+ project — free app, no ads", "Projet Erasmus+ — application gratuite, sans publicité", "Erasmus notice")
add("settingsVersion", "DIGIHARMONY v{version}", "DIGIHARMONY v{version}", "App version footer", {"version": {"type": "String"}})
add("settingsToolbarBack", "Back", "Retour", "Back a11y")


def patch(lang):
    path = ARB_DIR / f"app_{lang}.arb"
    data = json.loads(path.read_text(encoding="utf-8"))
    for key, spec in KEYS.items():
        value = spec["fr"] if lang == "fr" else spec["en"]
        data[key] = value
        meta = "@" + key
        if lang == "en":
            entry = {"description": spec["desc"]}
            if spec["ph"]:
                entry["placeholders"] = spec["ph"]
            data[meta] = entry
        else:
            # non-en files carry no @metadata for our keys; drop any stale one
            data.pop(meta, None)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=4) + "\n", encoding="utf-8"
    )
    print(f"{lang}: {len(data)} entries")


for lang in LANGS:
    patch(lang)
print(f"injected {len(KEYS)} keys")
