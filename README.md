# UGSM Spielerclient

[**Spielerclient für Windows herunterladen**](https://github.com/Priestkiller/UGSM-Player/releases/latest)

Natives Windows-x64-Programm für deine Spielrunde: freigegebene Server sehen, Mods synchronisieren und das lokal installierte Spiel starten. Windows 10/11 mit .NET Framework 4.8. Kein GitHub-Konto und keine Administratorrechte nötig.

## Starten

1. Unter **Releases** das `UGSM-Player-…-Windows-x64.zip` herunterladen und vollständig in einen eigenen beschreibbaren Ordner entpacken. Die automatisch erzeugten Source-code-Archive sind kein fertiger Client.
2. **UGSM.Player.exe** starten. **Einladungscode eingeben** wählen und den vom Betreiber erhaltenen `UGSM1:`-Code einfügen. Alternativ eine `.ugsm-directory`-Einladungsdatei öffnen. Alle aktuellen und künftig veröffentlichten Spielerprofile dieses Betreibers erscheinen automatisch. Einzelne `.ugsm-server`-Einladungen bleiben nutzbar.
3. **Einrichtung & Mods** wählen. **Installiertes Spiel suchen** erkennt passende Steam-Bibliotheken und WoW-Builds. Eine Installation ausdrücklich übernehmen; abweichende Store-/Launcher-Installationen manuell auswählen.
4. Spielversion, Loader und manuelle Mods vorbereiten. Nur einem bekannten Serverbetreiber und dessen Modcode vertrauen.
5. Beim laufenden Server auf **Spielen** klicken. Der Client prüft das Profil, synchronisiert freigegebene Mods und startet das Spiel. Der eigentliche Beitritt erfolgt über die Spieloberfläche.

## Serverstatus und Spielsuche

Die Liste aktualisiert sich alle 15 Sekunden. Online/Erreichbar stammen aus dem Manager; eine fehlende Verbindung wird ausdrücklich als unbekannt angezeigt. Dafür benötigt der Betreiber **UGSM Manager ab 0.11.0** und den erreichbaren HTTPS-Spielerdienst. Manager 0.12.0 kann die Playit-Tunnel und den gemeinsamen Spielerzugang direkt einrichten. Dies ist kein automatischer Nachweis eines externen Spielbeitritts.

Die Steam-Erkennung unterstützt Enshrouded, ARK SE/ASA, Abiotic Factor, 7 Days to Die, Conan Exiles, Valheim, V Rising, Soulmask, Project Zomboid, Bellwright und LS25. Bei WoW werden nur zum Profil passende Builds vorgeschlagen. Der klassische Minecraft-Launcher wird an üblichen Installationsorten erkannt; die Fabric-Instanz bleibt separat auszuwählen. Es erfolgt keine vollständige Festplattensuche. Vorhandene Pfade werden bei Listenaktualisierungen erhalten.

## WoW direkt herunterladen

Ab Spielerclient **0.12.1** gibt es rechts oben und auf WotLK-Serverkarten **WoW herunterladen**. Zielordner wählen und den Download starten. UGSM lädt **WoW 3.3.5a, Build 12340** direkt aus der [ChromieCraft-Communityquelle](https://chromiecraft.com/en/downloads/), prüft die Downloadteile und entpackt den Client in einen neuen Spielordner. Download: 17,7 GB; bis zu 60 GiB freier Speicher für Archiv und Entpacken.

Abbruch und Fortsetzen sind möglich: danach denselben Zielordner wählen. Bei einem ausgewählten WotLK-Profil werden Spielordner und Wow.exe übernommen; ansonsten findet **Installiertes Spiel suchen** die Installation. Beim Spielen übernimmt UGSM die veröffentlichte WotLK-Loginadresse und sichert die ursprüngliche realmlist.wtf. Ein privater Serveraccount und eine erreichbare Serverinstanz bleiben erforderlich. Ein erfolgreich heruntergeladener Client bestätigt noch keinen Spielbeitritt.

Dieser Download gilt für WotLK. Ein aktuelles TrinityCore-Profil benötigt weiterhin die passende WoW-Version und einen kompatiblen Launcher. Der Download hängt von der Erreichbarkeit der Communityquelle ab. Das UGSM-Paket enthält keine WoW-Spieldateien.

## Upgrades

Ab **0.13.0** kann **Upgrade** direkt vom eigenen UGSM-Manager herunterladen. Bei vorhandener Einladung steht der Betreiber als Downloadquelle zur Auswahl. Der Manager benötigt ebenfalls mindestens 0.13.0 und das enthaltene signierte Clientpaket. Herausgebersignatur, Serverzertifikat, Paket-Prüfsumme, einzelne Dateien und Version werden geprüft. GitHub bleibt eine ausdrücklich wählbare Ersatzquelle. Der Client startet nach dem Upgrade neu; Einladungen, Spielpfade und Modstände bleiben erhalten.

Für die **Erstinstallation ohne GitHub** kann der Betreiber im Manager unter **Spielerclient → Eigene Downloads → Clientpaket für Freunde speichern** das vollständige ZIP exportieren und weitergeben. Freigegebene Mods/Addons werden direkt vom Betreiber synchronisiert. Dieser eigene Downloadbereich enthält UGSM und freigegebene Mods/Addons, keine vollständigen kommerziellen Spiele.

Ab **0.12.2** kann pro Installationsordner nur eine Client-Oberfläche starten. Vor einem Upgrade zusätzliche ältere Client-Fenster schließen. Das Upgrade erkennt offene Kopien und erklärt die Dateisperre; kurze Sperren werden abgewartet. Gespeicherte Einladungen und Spielpfade bleiben erhalten.

## Grenzen

Die Mod-Synchronisierung gilt für im Manager unterstützte und ausdrücklich freigegebene Client-Dateien. Manche Spiele nutzen ihren eigenen Workshop-Download, andere benötigen manuelle Loader oder Mods. Steam-Spiele werden weiterhin über Steam installiert. UGSM ersetzt keinen erforderlichen TrinityCore-Launcher. Die Erkennung von Bellwright oder LS25 bedeutet keine neue Serverintegration. Details stehen in `Anleitung.txt` im Paket.

Dieses öffentliche Repository enthält ausschließlich Client-Downloads und Anleitung. Der Manager bleibt separat privat. Einladungen und Einladungscodes enthalten private Download-Zugänge: bitte nicht in Issues hochladen. Drittanbieterhinweise liegen jedem Paket bei.
