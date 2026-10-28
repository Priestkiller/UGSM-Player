## Spielerclient 0.16.14

Diese Version passt zu Manager 0.15.29 und Mod Studio 0.4.27. Enshrouded-Mods können aus den bestätigten Serveränderungen und den lokal gespeicherten Originaldateien des Spielers vorbereitet werden. Eine zusätzliche Clientinstallation auf dem Server wird dafür nicht benötigt. Es werden keine ursprünglichen Spieldateien von Spielern hochgeladen.

Der Spielerclient prüft die Änderungen lokal und übernimmt sie erst nach erfolgreicher Archivprüfung. Begleiterrezepte erhalten dabei ihre benötigten Clientnamen, Menüs, Symbole und Sprachdaten. Frühere freigegebene Clientpakete bleiben unterstützt; Wiederherstellung und Profilwechsel behalten ihre bisherigen Schutzprüfungen.

Im Spielerclient unter **Einstellungen → Client-Upgrade → GitHub** auf **Nach Updates suchen** und anschließend **Upgrade herunterladen & installieren** klicken. Serverprofile, Einstellungen und Spielordner bleiben erhalten. Enshrouded-Mods danach mit **Synchronisieren & Spielen** abgleichen. Spieler benötigen weder Mod Studio noch eine eigene Node.js-Installation.

Das Paket wird unverändert aus dem freigegebenen GitHub-Build übernommen. Die Veröffentlichung setzt das exakte ZIP aus fest gepinnten öffentlichen Teilen zusammen und prüft jede Teilgröße und SHA256, die vollständige ZIP-Prüfsumme, sechs erlaubte Dateien, sämtliche inneren Prüfsummen und die EXE-Version. Alle Release-Dateien werden vor der Freigabe als Entwurf hochgeladen und anhand ihrer Größe und GitHub-SHA256 geprüft.

Das Paket enthält den Spielerclient mit seinen fest gebündelten lokalen Ressourcenwerkzeugen und den zugehörigen Lizenznachweisen. Spielarchive, ursprüngliche Patcher-Runtime, Serverzugänge und private Referenzdaten sind nicht enthalten. Erfolgreiche Archivprüfung bestätigt die erzeugten Dateien; einzelne Spielmechaniken werden getrennt geprüft.
