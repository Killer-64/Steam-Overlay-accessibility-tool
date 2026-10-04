# Steam Overlay Access

Dostępność nakładki Steam (Shift+Tab w grze) dla osób niewidomych na Linuksie
i Windowsie. Bez OCR: nakładka to strona WWW renderowana przez `steamwebhelper`
(Chromium/CEF), więc mod czyta ją wprost z jej DOM i mówi przez speech-dispatcher
(Linux) albo przez NVDA lub SAPI 5 (Windows).

## Jak to działa

- Steam uruchomiony z plikiem `.cef-enable-remote-debugging` wystawia protokół
  DevTools na `127.0.0.1:8080`.
- `soa_daemon.py` łączy się z nim i wstrzykuje `agent.js` do kontekstu
  `SharedJSContext` (do niego należą wszystkie okna nakładki) oraz do stron
  otwartych w przeglądarce nakładki (poradniki, dyskusje, sklep).
- Agent dodaje wirtualny kursor i obsługę klawiatury, a teksty do wypowiedzenia
  odsyła demonowi. Proces gry nie jest w żaden sposób dotykany.

## Instalacja (Linux)

    ./install.sh

Potem jednorazowo zrestartuj Steama. Wymagane: `python3-websockets`,
`python3-speechd` (lub samo `spd-say`). Usunięcie: `./uninstall.sh`.

Ręczne uruchomienie z podglądem tego, co jest mówione: `./soa_daemon.py -v`.

## Instalacja (Windows)

Wymagany Python 3 z python.org. Uruchom `install.bat` (dwuklik), potem
jednorazowo zrestartuj Steama. Instalator sam doinstaluje moduł `websockets`,
włączy port debugowania Steama i doda skrót do Autostartu, więc demon rusza
przy każdym logowaniu. Usunięcie: `uninstall.bat`.

Mowa:

- Domyślnie SAPI 5, czyli głos ustawiony w systemie (Panel sterowania → Mowa).
- Żeby mod mówił przez NVDA, skopiuj obok `soa_daemon.py` plik
  `nvdaControllerClient.dll` w wersji zgodnej z Pythonem (zwykle 64-bitowej);
  jest w paczce „controller client" z nvaccess.org. Gdy NVDA nie działa, mod
  wraca do SAPI.

Ręczne uruchomienie z podglądem: `python soa_daemon.py -v`.

## Klawisze (gdy nakładka jest otwarta)

| Klawisz | Działanie |
| --- | --- |
| Strzałka w dół / w górę | następny / poprzedni element |
| Strzałka w prawo / w lewo, Tab | następna / poprzednia kontrolka (na suwaku: zmiana wartości) |
| H / Shift+H | następny / poprzedni nagłówek |
| Home / End | pierwszy / ostatni element |
| Page Down / Page Up | o 10 elementów |
| Enter, spacja | aktywuj (pole edycji: wejdź do edycji) |
| Klawisz Menu, Shift+F10 | menu kontekstowe elementu |
| F6 / Shift+F6 | następne / poprzednie okno nakładki |
| Backspace | zamknij bieżące okno lub menu |
| F1 | pomoc |
| F2 | gdzie jestem |
| F3 | czytaj od bieżącego miejsca |
| Ctrl | przerwij mowę |
| Tab w polu edycji | wyjdź z pola |
| Shift+Tab, Escape | zamknij nakładkę (to robi sam Steam) |

Dodatkowo czytane są: dymki powiadomień Steama (w grze i na pulpicie),
nowe wiadomości czatu przy otwartej nakładce oraz wpisywane znaki.

Okienka dymków na pulpicie są ukrywane przed systemowym czytnikiem ekranu
(Orca czytała ich techniczną nazwę, np. `notificationtoasts_10016_desktop`);
treść dymka wypowiada sam mod.

## Konfiguracja

Opcjonalny plik `~/.config/steam-overlay-access/config.json`:

    {
      "lang": "pl",        // język komunikatów moda: "pl" lub "en" (domyślnie z systemu)
      "echo": true,        // echo wpisywanych znaków
      "toasts": true,      // czytanie dymków powiadomień
      "chat": true,        // czytanie przychodzących wiadomości czatu
      "rate": null,        // tempo mowy -100..100
      "voice": null,       // głos (Windows: fragment nazwy głosu SAPI, np. "Paulina")
      "module": null,      // moduł speech-dispatchera (tylko Linux)
      "language": null,    // np. "en", jeśli Steam jest po angielsku, a syntezator po polsku
      "screenreader": true, // Windows: mów przez NVDA, gdy jest uruchomiony
      "port": 8080
    }

(Komentarze powyżej są tylko opisem; w prawdziwym pliku JSON ich nie wpisuj.)
Na Windowsie plik leży w `%APPDATA%\steam-overlay-access\config.json`, a
ustawienia `rate`, `voice` i `language` dotyczą tylko SAPI.
Po zmianie: `systemctl --user restart steam-overlay-access` (Linux) albo
ponownie `install.bat` (Windows).

## Uwagi

- Port debugowania słucha tylko na localhost, ale każdy lokalny program może
  przez niego sterować Steamem.
- Aktualizacje Steama mogą zmienić wewnętrzne nazwy, z których mod korzysta
  (`g_PopupManager`, klasy ikon). Sama nawigacja po DOM jest od nich niezależna.
