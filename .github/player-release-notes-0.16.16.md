## Spielerclient 0.16.16

Diese Version gehört zu **Manager 0.15.32 und Mod Studio 0.4.28**. Sie enthält die passenden lokalen Ressourcenwerkzeuge und Optionsgrenzen für den aktualisierten Studio-Datenstand. Das bereits veröffentlichte Paket 0.16.15 bleibt unverändert.

Nach dem Update wendet der Betreiber den Serverpatch erneut an. Jeder Spieler schließt Enshrouded und verwendet anschließend **Synchronisieren**. Erst nach erfolgreichem Abschluss startet **Spiel starten** das Spiel. Die beiden Aktionen bleiben getrennt. Ein erneuter Synchronisierungsklick prüft und aktualisiert den freigegebenen Modstand auch bei gleicher Revision.

Fertigkeitspunkte werden als Levelanteil des Budgets berechnet: **(Level - 1) × Punktewert**. Allgemeines Beispiel: Level 26 mit Wert 4 ergibt 100 Punkte aus dem Levelanteil insgesamt. Das bedeutet keine 100 neuen Punkte bei jedem Levelaufstieg. Wissensbelohnungen und bereits ausgegebene Punkte werden getrennt berücksichtigt.

Aktualisieren: **Einstellungen → Client-Upgrade → GitHub → Nach Updates suchen → Upgrade herunterladen & installieren**. Profile, Einstellungen und Spielordner bleiben erhalten.

Das öffentliche ZIP wird unverändert aus dem geprüften Manager-CI-Build übernommen. Die Veröffentlichung prüft seine festen Teile, vollständige Größe und SHA256, das erlaubte Inventar, die inneren Dateihashes und die tatsächliche EXE-Version. Ursprüngliche Spielarchive, Patcher-Runtime, Zugänge und private Referenzdaten sind nicht enthalten. Archivprüfungen und Wiederherstellung laufen im Hintergrund; die tatsächliche Spielwirkung bleibt separat zu testen.
