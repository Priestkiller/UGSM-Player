## Spielerclient 0.16.15

**Synchronisieren** und **Spiel starten** sind im Enshrouded-Bereich eigene Aktionen. Die Synchronisierung lädt den aktuellen Serverstand und bereitet die passenden lokalen Mods vor. Das Spiel startet erst über den eigenen Startknopf.

Jeder Klick auf Synchronisieren prüft den aktuellen Server- und Paketstand neu und wendet das Paket auch bei gleicher Revision erneut an. Bereits geladene Dateiteile werden nur mit gültiger Prüfsumme aus dem Cache verwendet. Gesicherte Originalarchive, kontrollierte Übernahme und Wiederherstellung bleiben erhalten.

Die Schrittanzeige erklärt den laufenden Vorgang und unterscheidet zwischen abgeschlossen, fehlgeschlagen und noch nicht ausgeführt. Ein Fehler bleibt als Fehler sichtbar; Dateikonflikte zeigen die betroffene Datei und Ursache.

Bereits vorhandene originale DAT-Dateien bleiben erhalten, wenn der Archivpacker dafür nur einen leeren Platzhalter ausgibt. Sie werden dabei nicht als verwaltete Moddateien übernommen.

Die Version passt zu Manager 0.15.30 und Mod Studio 0.4.27. Der Betreiber verwendet weiterhin seine vorhandene Serverbasis. Eine zusätzliche Spielinstallation auf dem Server und Uploads ursprünglicher Spielerdateien sind nicht erforderlich.

Aktualisieren: **Einstellungen → Client-Upgrade → GitHub → Nach Updates suchen → Upgrade herunterladen & installieren**. Profile, Einstellungen und Spielordner bleiben erhalten. Danach **Mods & Synchronisation → Synchronisieren** verwenden und nach erfolgreichem Abschluss **Spiel starten** anklicken.

Dieses Paket wird unverändert aus dem geprüften GitHub-Build übernommen. Der Publisher prüft die exakten Dateiteile und die vollständige ZIP-Prüfsumme, die erlaubten ZIP-Dateien, die inneren Prüfsummen und die Programmversion vor der Freigabe. Es enthält keine Spielarchive, ursprüngliche Patcher-Runtime, Zugänge oder privaten Referenzdaten. Die Dateisynchronisierung wird im Hintergrund geprüft; die tatsächliche Spielwirkung bleibt getrennt zu testen.
