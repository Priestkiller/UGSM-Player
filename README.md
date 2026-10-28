# UGSM Spielerclient

Freigegebener Stand: **Spielerclient 0.16.13**, Manager 0.15.28 und Enshrouded Mod Studio 0.4.26. Die Veröffentlichung von **Spielerclient 0.16.14** für Manager 0.15.29 und Mod Studio 0.4.27 wird vorbereitet; sie bleibt bis zur Prüfung des exakten CI-Pakets gesperrt.

[Letztaktuelle Windows-Version herunterladen](https://github.com/Priestkiller/UGSM-Player/releases/latest)

Das vollständige ZIP in einen eigenen beschreibbaren Ordner entpacken und `UGSM.Player.exe` starten. Zum Aktualisieren im Client **Einstellungen → Client-Upgrade → GitHub → Nach Updates suchen** wählen. Profile, Einstellungen, Spiele und Spielordner bleiben erhalten.

Für Enshrouded den Einladungskey des Betreibers verwenden, den Spielordner bestätigen und **Synchronisieren & Spielen** wählen. Der Betreiber patcht seine verwaltete Serverinstallation im Mod Studio; der Manager übernimmt das bestätigte Clientpaket. Der Spielerclient wartet auf die Vorbereitung, prüft den Datenstand und installiert die passenden Änderungen. Spieler benötigen weder Mod Studio noch Node.js.

Manager, Studio und Spielerclient müssen die zusammengehörigen Versionen unterstützen. Neue Spielversionen und einzelne Spielmechaniken werden getrennt geprüft; erfolgreiche Dateisynchronisation bestätigt die installierten Dateien.

Für die neue serverbasierte Ressourcenübertragung bereitet der Spielerclient die bestätigten Änderungen aus seinen eigenen gespeicherten Originaldateien vor und prüft die erzeugten Archive vor der Übernahme. Der Betreiber benötigt dafür keine zusätzliche Clientinstallation auf dem Server. Die fest gebündelten lokalen Werkzeuge sind im Client enthalten.

Der öffentliche GitHub-Updater prüft Größe, GitHub-SHA256, ZIP-Inventar, innere Dateihashes und Programmversion. Updates vom eigenen Server verwenden zusätzlich die bestehende Herausgebersignatur und die eingeladene Serververbindung. Profile, Betreiberzugänge, ursprüngliche Patcher-Runtime und Spielarchive gehören nicht in dieses öffentliche Repository.

Der Publisher für 0.16.14 übernimmt ausschließlich das unveränderte ZIP aus dem freigegebenen CI-Build. Seine geordneten öffentlichen Git-Blob-Teile sind jeweils höchstens 15 MiB groß und enthalten in `.github/player-release-0.16.14.json` genau `blob`, `bytes` und `sha256`. Fehlende Gesamtprüfsumme, Größen-, Teil- oder CI-Pins sperren den Ablauf vor jedem GitHub-Aufruf. Nur ein Push auf `Priestkiller/UGSM-Player` / `main` mit der exakten Commitnachricht `release: UGSM Player 0.16.14` kann veröffentlichen. Der Release bleibt Entwurf, bis ZIP, Prüfsummendatei und Prüfnachweis vollständig hochgeladen und verifiziert sind. Die Dateien für 0.16.13 bleiben zur Nachvollziehbarkeit erhalten.
