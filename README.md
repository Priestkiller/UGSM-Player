# UGSM-Spielerclient 0.16.8

Die Enshrouded-Einrichtung ist einfacher: Im **Manager 0.15.23** einmal
**Automatisch verbinden** wählen. Ein vorhandenes **Mod Studio 0.4.22**
und dessen Paketpfade werden übernommen. Nur bei fehlender oder mehrdeutiger
Installation ist eine einmalige Auswahl nötig. Die erweiterten Pfade bleiben
für eigene Einstellungen aufklappbar.

Im Mod Studio die Änderungen anwenden; danach im Spielerclient
**Enshrouded → Mods & Synchronisation → Synchronisieren & Spielen** wählen.
Vorhandene oder eindeutig erkannte Spielordner werden genutzt. Neue Arbeits-
und Cachepfade werden automatisch gewählt; eigene Pfade und vorhandene
Sicherungsorte bleiben erhalten. Der Spieler-PC benötigt weder Node.js noch
Mod Studio. Der Betreiber benötigt zur Paketerstellung weiterhin eine
separate normale Clientbasis.

[Downloads und Releasehinweise](https://github.com/Priestkiller/UGSM-Player/releases/tag/v0.16.8).
Das vollständige Windows-x64-ZIP entpacken und `UGSM.Player.exe` ohne
Administratorrechte starten. Das Client-Upgrade ist über GitHub oder den
aktualisierten Manager verfügbar.

Die Datei- und Wiederherstellungsprüfungen belegen keine tatsächliche
Multiplayer-Spielwirkung. Echte Studio-/Dienstkonto-Einrichtung und
Multiplayer-Spieltests bleiben offen.

## Bisherige Dokumentation und Funktionen

# UGSM Spielerclient

[**Spielerclient für Windows herunterladen**](https://github.com/Priestkiller/UGSM-Player/releases/latest)

Natives Windows-x64-Programm für deine Spielrunde: Server auswählen, lokale Spiele finden, freigegebene Mods synchronisieren und das Spiel starten. Windows 10/11 mit .NET Framework 4.8. Kein GitHub-Konto und keine Administratorrechte nötig.

## Neu in 0.16.2

Die sechs Reiter haben getrennte Aufgaben: **Übersicht** zeigt den ausgewählten Server, den nächsten Schritt und zuletzt gespielte Server. **Spiele & Server** dient der Serverauswahl mit Suche, Filtern und Favoriten. **Lokale Erkennung** enthält den Scan und die vollständige Liste gefundener Spiele. **Serverprofile** verwaltet Spielordner, Startprogramm, Mod-Ziel und Vertrauen. **Mods & Synchronisation** zeigt Dateivergleiche, Fortschritt und die aufklappbare Verbindungsanleitung. **Einstellungen** verwaltet den Client und Manager-Verbindungen.

Es gibt nur einen festen „Synchronisieren & Spielen“-Button je Spielansicht. Überbreite Hilfsbuttons, doppelte Einrichtungsformulare und der zusätzliche Werbetext im Kopfbereich wurden entfernt. Beim Wechsel des Reiters beginnt die Seite oben. Die Darstellung wurde bei 1020, 1440 und 1672 Pixeln Breite geprüft.

## Manager-Verbindung und Spielsuche

**Manager verbinden** steht dauerhaft oben im Spielerclient. Die **Manager-Nummer (UGSM2-…)** wird einmal eingegeben und lädt alle freigegebenen Server. Sie steht im Manager ab 0.15.3 direkt im Hauptfenster mit Kopierbutton und Dateiexport. Erneutes Verbinden erhält lokale Spielordner. Einstellungskarten sind je Zeile gleich hoch, bei kleinen Fenstern in zwei Spalten. WotLK und Retail haben unterschiedliche, scharf skalierte native UGSM-Symbole; quadratische Spielicons werden proportional vollständig angezeigt.

Die Oberfläche folgt den Spielerclient-Referenzen: dunkles Fantasy-Motiv, Cyan und Violett, Spielbilder, Serverkarten und sechs Bereiche: **Übersicht**, **Spiele & Server**, **Lokale Erkennung**, **Serverprofile**, **Mods & Synchronisation**, **Einstellungen**.

Beim Start fragt UGSM nach deiner Erlaubnis zur lokalen Spielsuche. Erst nach Zustimmung sucht der Client in Steam-Bibliotheken und auf lokalen Festplatten nach unterstützten Spielen. Die Entscheidung kann optional gespeichert und unter Einstellungen widerrufen werden. Suchergebnisse bleiben auf deinem PC. Systemordner, Verknüpfungen, Netzwerk- und Wechselmedien werden übersprungen. Die Suche ist abbrechbar; eigene Suchordner sind wählbar. Bei großen Laufwerken wird ein erreichtes Suchlimit als Teilergebnis angezeigt.

Eine eindeutig passende Installation wird automatisch einem noch leeren Serverprofil zugeordnet. Vorhandene Spielpfade bleiben erhalten. Bei mehreren Installationen wählst du selbst. Die Erkennung bestätigt noch keine passende Spielversion oder einen vollständigen Mod-Loader.

## Starten

1. Das **aktuelle Windows-x64-ZIP** unter Releases herunterladen und vollständig in einen eigenen beschreibbaren Ordner entpacken. Die Source-code-Archive sind kein fertiger Client.
2. **UGSM.Player.exe** starten und die Spielsuche erlauben oder ablehnen.
3. Oben **Manager verbinden** wählen und einmal die **Manager-Nummer (UGSM2-…)** deines Betreibers einfügen. Alternativ seine .ugsm-manager-Datei über **Einstellungen → Manager-Verbindungen → Vorhandene Einladungen importieren** auswählen. Alle freigegebenen Server erscheinen automatisch. Alte UGSM1:-Codes und .ugsm-directory/.ugsm-server-Dateien bleiben nutzbar.
4. Server auswählen. Eine erkannte Installation verwenden oder unter **Serverprofile → Lokale Einrichtung** Spielordner, Mod-Ziel und Startprogramm auswählen.
5. **Profil prüfen** und einem bekannten Server und dessen Modcode ausdrücklich vertrauen. Bei Profilen mit manuellen Mods oder Loadern die passende Vorbereitung bestätigen; reine Mod-Studio-Pakete werden automatisch geprüft.
6. **Synchronisieren & Spielen**: UGSM prüft und synchronisiert freigegebene Dateien und startet das lokal gewählte Spiel. Der eigentliche Beitritt erfolgt im Spiel.

## Spiele, Server und Mods

Die Liste aktualisiert sich alle 15 Sekunden. Serverstatus stammt aus dem Manager; fehlende oder veraltete Verbindung wird entsprechend angezeigt. Suche, Spiel-/Statusfilter und Favoriten erleichtern die Auswahl. Es ist die Serverliste deiner Betreiber-Einladung, kein erfundener öffentlicher Communitykatalog.

Unterstützte Erkennung: Minecraft Java, Enshrouded, ARK SE/ASA, Abiotic Factor, 7 Days to Die, Conan Exiles, Valheim, V Rising, Soulmask, Project Zomboid, Bellwright, LS25 sowie passende WotLK- und TrinityCore-Clients. Steam-Installationslisten und bekannte lokale Programme werden genutzt. Abweichende Launcher und nicht gefundene Installationen bleiben manuell wählbar. Minecraft benötigt eine eigene Mod-Instanz; TrinityCore eine kompatible lokale Startkomponente.

**Mods prüfen** vergleicht veröffentlichte Dateien per SHA-256 mit dem lokalen Stand. Tabellen zeigen identische, fehlende, abweichende und früher verwaltete Dateien. Fortschritt und Schritte stammen aus dem tatsächlichen Vorgang. Fremde Dateien und lokale Änderungen werden geschützt; eine unterbrochene Synchronisation lässt sich wiederherstellen. Beliebiger Modcode und manuelle Loader werden dadurch nicht automatisch auf Spielkompatibilität geprüft.

Für Manager-Nummern benötigt der Betreiber UGSM Manager **ab 0.15.3** mit einem erreichbaren öffentlichen HTTPS-IPv4-Spielerzugang. Alte Einladungen funktionieren weiterhin mit Manager ab 0.11.0. Manager 0.12.0 kann die Playit-Tunnel und den gemeinsamen Spielerzugang einrichten. Die Erkennung von Bellwright oder LS25 bedeutet keine neue Serverintegration.

## WoW

WotLK benötigt einen vollständigen Client **3.3.5a, Build 12340**. UGSM setzt die veröffentlichte Loginadresse in realmlist.wtf und sichert die vorherige Konfiguration. Der separate Community-Download ist unter **Einstellungen → WoW 3.3.5a herunterladen** erreichbar. Abbruch und Fortsetzen mit demselben Zielordner bleiben möglich.

TrinityCore benötigt **12.1.0.69933** und eine kompatible lokale Startkomponente. UGSM setzt die Portaladresse in WTF/Config.wtf und sichert die ursprüngliche Datei. UGSM ersetzt diesen erforderlichen Launcher nicht. Eine Vorbereitung bestätigt keinen WoW-Login oder Spielbeitritt.

Das UGSM-Paket enthält keine WoW-Spieldateien. Vollständige kommerzielle Spiele werden nicht über den eigenen UGSM-Downloadbereich verteilt. Steam-Spiele werden weiterhin über Steam installiert.

Der erste Start ohne bisherigen Scan wird in 0.16.1 korrekt angezeigt; ein fehlender Scan-Zeitstempel führt zu keinem Objektverweisfehler mehr.

## Upgrades und gespeicherte Daten

**Einstellungen → Client-Upgrade** öffnet die Updateprüfung. Bei vorhandener Einladung steht dein Betreiber als Quelle zur Auswahl; **GitHub · öffentliches UGSM-Release** liefert das aktuelle öffentliche Release. Ein älterer Manager kann noch sein früheres Clientpaket anbieten. Einladungen, Spielpfade und Modstände bleiben beim Upgrade erhalten.

Pro Installationsordner startet nur eine Client-Oberfläche. Zusätzliche ältere Fenster vor einem Upgrade schließen. Der Client erklärt Dateisperren und wartet kurze Sperren ab. Betreiberpakete werden mit Herausgebersignatur und Serverzertifikat geprüft; das öffentliche GitHub-Paket mit Release-Prüfsumme, Dateimanifest und Versionsprüfung.

Manager-Nummern gelten pro Manager-Dateninstallation und bleiben beim Upgrade erhalten. Sie enthalten den öffentlichen Endpunkt und einen zufälligen Lesezugang; acht Gruppen mit fünf Buchstaben/Ziffern ersetzen die lange JSON-Einladung. Eine Prüfsumme erkennt Tippfehler. Beim Widerruf werden bisherige Nummern ungültig. Ändert sich die öffentliche Adresse, muss die neue Nummer erneut geteilt werden.

Einladungen sind mit deinem Windows-Konto verschlüsselt. Suchergebnisse und Einstellungen liegen lokal im Benutzerprofil. Einladungen und Codes enthalten private Zugänge: bitte nicht in Issues hochladen.

Dieses öffentliche Repository enthält Client-Downloads und Anleitung. Der Manager bleibt privat. Drittanbieterhinweise und ausführliche Anleitung liegen jedem ZIP bei.

