# FitBook

FitBook je aplikacija za fitness centar — rezervacije treninga, članarine sa Stripe plaćanjem, notifikacije i preporuke treninga.

Backend je ASP.NET Core 9 (WebAPI + Worker mikroservis, RabbitMQ, SQL Server), a desktop i mobilna aplikacija su rađene u Flutteru. Dokumentacija sistema preporuke nalazi se u [recommender-dokumentacija.md](recommender-dokumentacija.md).

## Struktura projekta

- `FitBook.WebAPI` — REST API (kontroleri, JWT autentifikacija)
- `FitBook.Services` — poslovna logika, EF Core, migracije, seed
- `FitBook.Model` — DTO, request/response i enum tipovi
- `FitBook.Common.Services` — zajednički kod (hashiranje lozinki, čitanje `.env`)
- `FitBook.Worker` — mikroservis koji sluša RabbitMQ i šalje emailove
- `UI/fitbook_desktop` — admin desktop aplikacija (Flutter)
- `UI/fitbook_mobile` — mobilna aplikacija za klijente i trenere (Flutter)

## Kredencijali za prijavu

| Kontekst                 | Korisničko ime | Lozinka |
| ------------------------ | -------------- | ------- |
| Desktop verzija          | desktop        | test    |
| Mobilna verzija          | mobile         | test    |
| Trener (mobilna verzija) | trainer        | test    |

## Testiranje plaćanja

Plaćanje članarine ide preko Stripe sandbox okruženja. Za testnu uplatu koristiti:

| Podatak              | Vrijednost            |
| -------------------- | --------------------- |
| Broj kartice         | `4242 4242 4242 4242` |
| Datum isteka         | bilo koji budući      |
| CVC                  | bilo koja tri broja   |
| ZIP / poštanski broj | bilo koji             |

Otkazivanjem članarine ili promjenom paketa pokreće se stvarni Stripe refund nad prethodno naplaćenim iznosom.

## Pokretanje backenda

Potreban je Docker. U root direktoriju repozitorija treba postojati `.env` fajl:

- za pregled rada: otpakovati priloženi `.env-tajne.zip` (šifra je predata uz rad)
- inače: kopirati `.env.example` u `.env` i unijeti svoje vrijednosti

Zatim iz root direktorija:

```
docker compose up --build
```

API se podiže na `http://localhost:5121`, Swagger na `http://localhost:5121/swagger`. Migracije i seed podaci se primjenjuju automatski pri startu, a seed uvijek kreira i nekoliko termina u budućnosti radi testiranja rezervacija.

Worker šalje email notifikacije preko SMTP kredencijala iz `.env` fajla. Ako oni nisu postavljeni, aplikacija normalno radi, samo se emailovi ne šalju.

Za razvoj bez Dockera: podići samo bazu i RabbitMQ (`docker compose up fitbook-db fitbook-rabbitmq`) pa pokrenuti `dotnet run --project FitBook.WebAPI`.

## Desktop aplikacija (Windows)

```
cd UI/fitbook_desktop
flutter pub get
flutter run -d windows
```

Adresa API-ja je podrazumijevano `http://localhost:5121/api`, a može se promijeniti komandom:

```
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5121/api
```

Release build: `flutter build windows --release` (exe se generiše u `build/windows/x64/runner/Release/`).

## Mobilna aplikacija (Android)

```
cd UI/fitbook_mobile
flutter pub get
flutter run
```

Podrazumijevana adresa API-ja je `http://10.0.2.2:5121/api` (Android emulator). Za fizički uređaj proslijediti IP računara:

```
flutter run --dart-define=API_BASE_URL=http://<IP-racunara>:5121/api
```

Release build: `flutter build apk --release` (APK se generiše u `build/app/outputs/flutter-apk/app-release.apk`).
