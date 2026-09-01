# Oxipull

Oxipull lädt gespeicherte Messungen eines Checkme O2 unter Linux über USB und
wandelt die VLD-Rohdaten in A4-PDF-Berichte um. Optional können CSV-Dateien
erzeugt werden. Oxipull führt selbst keine Messung durch.

Getestet wurde ein Checkme O2 Max, Modell 1642, mit USB-ID `1915:f33d`,
Firmware 1.3.0 und VLD-Dateiversion 5. Der Parser unterstützt außerdem
VLD-Version 3. Andere Gerätevarianten sind nicht getestet.

## Voraussetzungen

- Linux mit udev und hidraw
- Python 3.10 oder neuer
- Matplotlib 3.6 oder neuer
- GNU Make für Installation und Deinstallation

Oxipull benötigt keine Python-USB-Bibliothek. Das Gerät wird direkt über die
vom Kernel bereitgestellte hidraw-Schnittstelle angesprochen.

## Installation

Abhängigkeiten prüfen und anschließend installieren:

```sh
make check
sudo make install
```

Dabei werden das Programm nach `/usr/local/bin`, die udev-Regel nach
`/etc/udev/rules.d` sowie Completion-Dateien für Bash, Zsh und Fish nach
`/usr/local/share` installiert. Danach das USB-Gerät neu verbinden.

Deinstallation:

```sh
sudo make uninstall
```

Das Programm kann ohne Installation als `./oxipull` ausgeführt werden. Für den
USB-Zugriff muss die udev-Regel dennoch eingerichtet sein.

## Schnellstart

Neue Messungen als Rohdaten und PDF ins aktuelle Verzeichnis übernehmen:

```sh
oxipull pull
```

Rohdaten, PDFs und CSV-Dateien in `data/` ablegen:

```sh
oxipull pull -o data --csv
```

`pull` ergänzt ausschließlich fehlende Dateien. Vorhandene Rohdaten, PDFs und
CSV-Dateien werden nicht überschrieben. `--patient` und `--note` gelten nur für
PDFs, die bei diesem Aufruf neu entstehen.

Die vollständige Hilfe steht in einem Bildschirm:

```sh
oxipull --help
```

## Befehle

| Befehl | Funktion |
| --- | --- |
| `pull` | Fehlende Rohdaten laden und fehlende PDF-Berichte erzeugen |
| `download` | Ausschließlich VLD-Rohdaten laden |
| `report` | PDFs aus vorhandenen VLD-Dateien neu erzeugen |
| `device` | Gerät, Einstellungen und vorhandene Messungen anzeigen oder ändern |
| `completion` | Completion für Bash, Zsh oder Fish ausgeben |

### Berichte neu erzeugen

Nach einer Änderung des Berichtslayouts können PDFs jederzeit aus den
unveränderten VLD-Rohdaten neu erstellt werden:

```sh
oxipull report data/2025-10-13_00-57-37-oximetrie-rohdaten.vld
oxipull report data/*-oximetrie-rohdaten.vld --csv
```

`report` überschreibt gleichnamige PDF- und, mit `--csv`, CSV-Dateien. Ein
anderer Zielordner kann mit `-o ORDNER` gewählt werden.

### Gerät und Einstellungen

`device` zeigt ohne Optionen verständlich bezeichnete Geräteinformationen,
Einstellungen und vorhandene Aufzeichnungen. Geschrieben wird nur bei
ausdrücklich angegebenen Optionen:

```sh
oxipull device
oxipull device --sync-time
oxipull device --spo2-alert 90
oxipull device --hr-low 50 --hr-high 120
oxipull device --vibration 60 --sound 60
oxipull device --screen off
```

Alle verfügbaren Optionen und Werte zeigt `oxipull --help`. Der Aufruf
`device --factory-reset --yes` fordert die Werkseinstellungen an und
löscht nach der Warnung der Herstelleranwendung die Messdaten des Geräts.

## Dateien

Automatisch erzeugte Dateinamen enthalten den Messbeginn und den Inhalt:

```text
2025-10-13_00-57-37-oximetrie-rohdaten.vld
2025-10-13_00-57-37-oximetrie-messdaten.csv
2025-10-13_00-57-37-oximetrie-auswertung.pdf
```

Messdaten können Gesundheitsdaten enthalten. `data/` und die automatisch
erzeugten Dateitypen sind deshalb in `.gitignore` ausgeschlossen.

## Bericht und medizinische Einordnung

Der Bericht zeigt den Gesamtverlauf und Detailkurven für SpO₂, Puls und
Bewegung sowie Zeitanteile unter den SpO₂-Schwellen 90, 88 und 85 Prozent. Bei
VLD-Version 5 übernimmt Oxipull die im Dateikopf gespeicherten Zähler für
Entsättigungen von mindestens 3 beziehungsweise 4 Prozent. Der ODI wird daraus
als Anzahl pro Messstunde berechnet. Bei VLD-Version 3 werden die
Entsättigungsereignisse aus der Messreihe berechnet.

Die ODI3-Bereiche `<5`, `5–<15`, `15–<30` und `≥30` pro Messstunde dienen nur
der oximetrischen Orientierung. Ein Checkme O2 erfasst weder Atemfluss noch
Schlafstadien oder Aufwachreaktionen; der Bericht ist daher keine
Schlafapnoe-Diagnose und keine AHI-Auswertung. Siehe die publizierten
[ODI-Gruppen](https://publications.ersnet.org/content/erj/24/6/987) und eine
[Übersicht zu Möglichkeiten und Grenzen der nächtlichen
Oximetrie](https://pmc.ncbi.nlm.nih.gov/articles/PMC8271129/).

Oxipull ist kein Medizinprodukt.

## Technische Grundlage und Danksagung

Die USB-Übertragung nutzt 64-Byte-HID-Reports. Geräteinformationen,
Einstellungen und Dateidownload verwenden das proprietäre Viatom-Protokoll.
Die USB-Kapselung wurde anhand der Herstelleranwendung und des angeschlossenen
Geräts untersucht. Vollständige Downloads wurden bytegenau mit den von O2
Insight Pro gespeicherten VLD-Dateien verglichen.

Für Protokoll und Dateiformat waren folgende freie Projekte wichtige
Vorarbeiten und Referenzen:

- [viatom-develop/LepuDemo](https://github.com/viatom-develop/LepuDemo)
  dokumentiert die Gerätefelder und Betriebsmodi im Hersteller-SDK.
- [farolone/wellue-o2ring-protocol](https://github.com/farolone/wellue-o2ring-protocol)
  dokumentiert Paketformat, CRC, Dateikommandos und VLD-Version 3.
- [MackeyStingray/o2r](https://github.com/MackeyStingray/o2r) implementiert
  Download und Konfiguration verwandter Viatom-Oximeter über Bluetooth LE.
- Der [Viatom-Loader von
  OSCAR](https://gitlab.com/pholy/OSCAR-code/-/blob/master/oscar/SleepLib/loader_plugins/viatom_loader.cpp)
  dokumentiert und verarbeitet VLD-Versionen 3 und 5 einschließlich Checkme O2
  Max.

Oxipull ist ein unabhängiges Projekt und steht in keiner Verbindung zu
Viatom, Wellue oder den genannten Projekten. Produktnamen sind Eigentum ihrer
jeweiligen Inhaber.

## Lizenz

Oxipull ist unter `GPL-3.0-or-later` veröffentlicht. Der vollständige Text
steht in [LICENSE](LICENSE).
