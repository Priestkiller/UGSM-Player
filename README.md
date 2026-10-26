# UGSM Spielerclient

Aktueller Stand: **Spielerclient 0.16.13**, Manager 0.15.28 und Enshrouded Mod Studio 0.4.26.

[Letztaktuelle Windows-Version herunterladen](https://github.com/Priestkiller/UGSM-Player/releases/latest)

Das vollständige ZIP in einen eigenen beschreibbaren Ordner entpacken und `UGSM.Player.exe` starten. Zum Aktualisieren im Client **Einstellungen → Client-Upgrade → GitHub → Nach Updates suchen** wählen. Profile, Einstellungen, Spiele und Spielordner bleiben erhalten.

Für Enshrouded den Einladungskey des Betreibers verwenden, den Spielordner bestätigen und **Synchronisieren & Spielen** wählen. Der Betreiber patcht seine verwaltete Serverinstallation im Mod Studio; der Manager übernimmt das bestätigte Clientpaket. Der Spielerclient wartet auf die Vorbereitung, prüft den Datenstand und installiert die passenden Änderungen. Spieler benötigen weder Mod Studio noch Node.js.

Manager, Studio und Spielerclient müssen die zusammengehörigen Versionen unterstützen. Neue Spielversionen und einzelne Spielmechaniken werden getrennt geprüft; erfolgreiche Dateisynchronisation bestätigt die installierten Dateien.

Der öffentliche GitHub-Updater prüft Größe, GitHub-SHA256, ZIP-Inventar, innere Dateihashes und Programmversion. Updates vom eigenen Server verwenden zusätzlich die bestehende Herausgebersignatur und die eingeladene Serververbindung. Profile, Betreiberzugänge, ursprüngliche Patcher-Runtime und Spielarchive gehören nicht in dieses öffentliche Repository.
