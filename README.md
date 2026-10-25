# Calendula

App Flutter che aiuta le persone anziane nella vita di tutti i giorni:
testo grande, pulsanti ampi, tutto in italiano.

| Funzione | Stato |
| --- | --- |
| Medicine: orari, "L'ho presa", avvisi all'orario | Fatta |
| Torna a casa: percorso a piedi con Google Maps | Fatta |
| Dove sono: mandare la posizione ai familiari | Da fare |
| Ginnastica | Da fare |
| Pasti facili e leggeri | Da fare |
| La mia giornata (routine) | Da fare |

## Avviare il progetto su un altro PC

Serve [Flutter](https://docs.flutter.dev/get-started/install) (stable, 3.47 o più recente)
e, per Android, Android Studio con un emulatore.

```bash
git clone https://github.com/GiovannaSuardi/Calendula.git
cd Calendula
flutter pub get
flutter test
flutter run
```

In VS Code: apri la cartella, `Ctrl+Shift+D`, scegli una configurazione
("Calendula su Chrome" o "Calendula su emulatore Android") e premi `F5`.

## Struttura

- `lib/main.dart` – avvio dell'app
- `lib/app.dart`, `lib/theme/` – tema e lingua
- `lib/screens/home_screen.dart` – schermata principale con i 6 pulsanti
- `lib/features/<funzione>/` – una cartella per ogni funzione
- `test/` – test automatici
