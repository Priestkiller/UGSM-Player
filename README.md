# UGSM Spielerclient

Freigegebener Spielerclient: **0.16.24** für **Manager 0.15.40 und Mod Studio 0.4.33**. Das öffentliche ZIP wird unverändert aus dem geprüften privaten Spielerclient-Build übernommen; das Setup enthält genau dieses Paket.

Beim Start prüft und installiert der Client neue öffentliche Programmversionen. Er zeigt die Änderungen an, lässt das Update verschieben und behält Profile sowie Einstellungen. In den Einstellungen lässt sich die Automatik abschalten. Laufende Spiele und Synchronisierungen werden nicht für ein Programmupdate beendet.

[Letztaktuelle Windows-Version herunterladen](https://github.com/Priestkiller/UGSM-Player/releases/latest)

Für eine normale Installation **UGSM-Player-0.16.24-Setup.exe** aus dem Release starten und den Programmordner auswählen. Das Setup legt Startmenüeintrag und Deinstallation für den eigenen Windows-Benutzer an. Alternativ bleibt das vollständig entpackte ZIP nutzbar. Bestehende Serverprofile und Einstellungen werden weiterverwendet. Die manuelle Updateprüfung bleibt unter **Einstellungen → Client-Upgrade** erreichbar.

Bei der ersten Enshrouded-Synchronisierung wählt der Client automatisch ein beschreibbares Arbeits- und Cacheziel: H:, danach `.ugsm-player/storage` im Spielordner, danach den lokalen Benutzer-Cache. Ein vorhandenes, aber unbeschreibbares H: wird übersprungen. Die automatische Speicherwahl und getrennte Ressourcenvorbereitung bleiben erhalten.

Ab 0.16.20 wird die eigentliche Ressourcenvorbereitung in einem getrennten Arbeitsordner außerhalb der Spielinstallation ausgeführt. Dadurch kann die automatische Speicherwahl den eigenen Unterordner im Spiel verwenden, ohne die Schutzprüfung der Ressourcenwerkzeuge zu verletzen. Vorhandene Sicherungsorte und selbst gewählte Speicherpfade bleiben erhalten.

Für Enshrouded den Einladungskey des Betreibers verwenden und den Spielordner bestätigen. Ab 0.16.15 zuerst **Synchronisieren** wählen; nach erfolgreichem Abschluss startet **Spiel starten** das Spiel als eigene Aktion. Jeder Synchronisierungsklick ruft den aktuellen Serverstand neu ab und bereitet das freigegebene Paket auch bei gleicher Revision erneut vor. Geprüfte Downloadteile dürfen aus dem lokalen Cache kommen. Der Betreiber patcht seine verwaltete Serverinstallation im Mod Studio; der Manager übernimmt das bestätigte Clientpaket. Spieler benötigen weder Mod Studio noch Node.js.

Das Patchen im Mod Studio bleibt unabhängig möglich. Zum anschließenden Verteilen und Synchronisieren müssen Manager und Spielerclient das Paketformat der verwendeten Studio-Version unterstützen. Neue Spielversionen und einzelne Spielmechaniken werden getrennt geprüft; erfolgreiche Dateisynchronisation bestätigt die installierten Dateien.

Für die neue serverbasierte Ressourcenübertragung bereitet der Spielerclient die bestätigten Änderungen aus seinen eigenen gespeicherten Originaldateien vor und prüft die erzeugten Archive vor der Übernahme. Der Betreiber benötigt dafür keine zusätzliche Clientinstallation auf dem Server. Die fest gebündelten lokalen Werkzeuge sind im Client enthalten.

Der öffentliche GitHub-Updater prüft Größe, GitHub-SHA256, ZIP-Inventar, innere Dateihashes und Programmversion. Updates vom eigenen Server verwenden zusätzlich die bestehende Herausgebersignatur und die eingeladene Serververbindung. Profile, Betreiberzugänge, ursprüngliche Patcher-Runtime und Spielarchive gehören nicht in dieses öffentliche Repository.

Der Publisher für 0.16.24 übernimmt ausschließlich das unveränderte ZIP aus dem vollständig geprüften privaten Spielerclient-Build. Geordnete öffentliche Git-Blob-Teile enthalten nur die Paketbytes. Quell-Commit, erfolgreicher CI-Lauf, Größen, Teil- und Gesamtprüfsummen sowie ZIP-Inventar, innere Dateihashes und Programmversion werden geprüft. Es werden keine signierten Zugriffslinks oder Zugangsdaten veröffentlicht. Nur ein Push auf `Priestkiller/UGSM-Player` / `main` mit der exakten Commitnachricht `release: UGSM Player 0.16.24` kann veröffentlichen. Der Release bleibt Entwurf, bis alle Dateien hochgeladen und überprüft sind. Frühere Veröffentlichungen bleiben unverändert.
