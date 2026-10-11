# UGSM Spielerclient

[**Spielerclient für Windows herunterladen**](https://github.com/Priestkiller/UGSM-Player/releases/latest)

Natives Windows-x64-Programm für Servereinladungen, den Abgleich freigegebener Mods und den lokalen Spielstart. Windows 10/11 mit .NET Framework 4.8. Keine Administratorrechte und kein GitHub-Konto nötig.

## Starten

1. Bei **Releases** das `UGSM-Player-…-Windows-x64.zip` herunterladen. Die automatisch erzeugten „Source code“-Archive enthalten keinen fertigen Client.
2. Das ZIP vollständig in einen eigenen beschreibbaren Ordner entpacken, z. B. `Dokumente\UGSM-Spielerclient`.
3. `UGSM.Player.exe` starten und die `.ugsm-server`-Einladung deines Serverbetreibers öffnen.
4. Spielordner, Mod-Zielordner und Spiel/Launcher auswählen. Nur einem bekannten Serverbetreiber und dessen Modcode vertrauen.
5. Passende Spielversion, Modloader und manuelle Voraussetzungen vorbereiten; **Synchronisieren & Spielen** wählen.

## Upgrades

Ab 0.10.0 befindet sich **Upgrade** rechts oben. Darüber werden neue stabile Versionen öffentlich von diesem Repository geladen und vor der Installation geprüft. Der Client startet danach neu; gespeicherte Serverprofile, Spiele und Mods bleiben erhalten. Versionen ohne Upgrade-Button einmal manuell durch das vollständige neue ZIP ersetzen.

Der Serverbetreiber benötigt weiterhin den separat verwalteten UGSM-Manager. Dieses öffentliche Repository enthält ausschließlich Client-Downloads und Anleitung, keine Serverdaten oder Einladungen.

## Spielabhängige Grenzen

Die automatische Synchronisierung gilt für im Manager unterstützte und ausdrücklich freigegebene Client-Moddateien. Manche Spiele nutzen ihren eigenen Workshop-Download; andere benötigen manuell installierte Loader oder Mods. UGSM installiert keine gekauften Spiele, liefert keine WoW-Spieldaten und ersetzt keinen erforderlichen TrinityCore-Launcher. Der eigentliche Beitritt erfolgt über die Spieloberfläche. Einzelheiten stehen in `Anleitung.txt` im Download.

Einladungen enthalten private Download-Zugänge. Bitte nicht in Issues hochladen. Drittanbieterhinweise liegen jedem Paket bei.
