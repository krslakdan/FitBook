# FitBook

FitBook je sistem za digitalizaciju poslovanja fitness centra — rezervacije treninga, upravljanje članarinama, treninzima, trenerima i terminima, sistemske notifikacije i preporuke treninga zasnovane na stvarnoj aktivnosti korisnika. Ovo je seminarski rad iz predmeta Razvoj softvera II (IB230163).

Repozitorij trenutno sadrži backend dio sistema:

| Projekat | Opis |
|---|---|
| `FitBook.WebAPI` | Glavni REST API servis (ASP.NET Core 9, JWT autentifikacija, Swagger). |
| `FitBook.Services` | Poslovna logika, EF Core `DbContext`, entiteti, migracije, validatori. |
| `FitBook.Worker` | Pomoćni mikroservis (odvojen kontejner) koji sluša RabbitMQ i šalje email notifikacije putem SMTP-a. |
| `FitBook.Common.Services` | Dijeljeni infrastrukturni kod bez teških zavisnosti (hashiranje lozinki, čitanje `.env`). |
| `FitBook.Model` | DTO/Request/Response/Enum/Exception tipovi, bez logike. |

Dokumentacija sistema preporuke treninga nalazi se u [`recommender-dokumentacija.md`](recommender-dokumentacija.md).

## Pokretanje (Docker)

Preduslov: instaliran Docker i Docker Compose. Nije potrebno lokalno instalirati .NET SDK niti ručno pokretati migracije — API pri startu sam primjenjuje EF Core migracije na bazu.

1. Postaviti `.env` u root direktorij repozitorija:
   - **Za pregled/predaju**: otpakovati priloženi `.env-tajne.zip` (šifra je predata odvojeno) — rezultat mora biti fajl `.env` u istom folderu gdje je i `docker-compose.yml`.
   - **Za samostalno kloniranje repozitorija**: kopirati `.env.example` u `.env` i po potrebi prilagoditi vrijednosti (lozinke, JWT ključ, Stripe sandbox ključevi).
   - Docker Compose vrijednosti poput hostname-a baze i RabbitMQ-a (`fitbook-db`, `fitbook-rabbitmq`) su eksplicitno postavljene u `docker-compose.yml` i imaju prednost nad onim što piše u `.env`, tako da isti `.env` radi i za lokalno pokretanje i unutar kontejnera.
2. Iz root direktorija pokrenuti:

   ```bash
   docker compose up --build
   ```

3. Nakon što se svi servisi podignu:
   - **API**: `http://localhost:5121` (port konfigurabilan preko `API_HOST_PORT` u `.env`)
   - **Swagger UI**: `http://localhost:5121/swagger`
   - **RabbitMQ Management**: `http://localhost:15672` (podrazumijevano `guest` / `guest`)
   - **SQL Server**: `localhost,1435` (port konfigurabilan preko `SQL_HOST_PORT`)

4. Za zaustavljanje: `docker compose down` (dodati `-v` samo ako se namjerno želi obrisati sadržaj baze/RabbitMQ volumena).

Svi servisi (`fitbook-api`, `fitbook-worker`, `fitbook-db`, `fitbook-rabbitmq`) definisani su u `docker-compose.yml` i imaju `restart: unless-stopped`, tako da povremeni "cold start" (npr. API prije nego baza završi inicijalizaciju) ne zahtijeva ručnu intervenciju.

### Email notifikacije (Worker)

`FitBook.Worker` šalje stvarne email-ove preko SMTP-a za događaje poput registracije, potvrde/otkazivanja rezervacije, uspješnog plaćanja i podsjetnika prije treninga. Da bi ovaj dio radio end-to-end, u `.env` je potrebno postaviti validne SMTP kredencijale (`SMTP__Username`, `SMTP__Password`) — npr. Gmail nalog sa app-password-om. Bez toga, ostatak sistema (rezervacije, plaćanja, in-app notifikacije, izvještaji, preporuke) i dalje radi normalno; samo se slanje email-a neuspješno pokušava (uz retry sa eksponencijalnim backoff-om) i loguje kao upozorenje.

## Pokretanje lokalno (bez Dockera, za razvoj)

1. Podići samo bazu i RabbitMQ iz Docker Compose-a: `docker compose up fitbook-db fitbook-rabbitmq`.
2. Kopirati `.env.example` u `.env` u root direktoriju (isti fajl koriste i `FitBook.WebAPI` i `FitBook.Worker` kad se pokreću lokalno — oba čitaju `.env` iz najbližeg roditeljskog direktorija pri startu).
3. Pokrenuti API: `dotnet run --project FitBook.WebAPI`
4. Pokrenuti Worker (opciono, za email notifikacije): `dotnet run --project FitBook.Worker`

## Test kredencijali

Lozinka za sve seed korisničke naloge je `test`.

| Kontekst | Korisničko ime | Uloga |
|---|---|---|
| Admin / desktop pristup | `desktop` | Admin |
| Klijent / mobilni pristup | `mobile` | User |
| Trener | `johndoe` | Trainer |
| Trener | `janesmith` | Trainer |
| Trener | `mikejones` | Trainer |

## Podaci za testiranje

Baza se puni referentnim i historijskim podacima pri prvoj migraciji (kategorije, treninzi, treneri, sale, članarine, historijske rezervacije i plaćanja). Pošto se rad periodično pregleda, termini treninga koji moraju biti u budućnosti (za testiranje rezervacije, potvrde, otkazivanja i podsjetnika) se **ne** oslanjaju na fiksne datume — API pri svakom startu provjerava postoji li barem jedan zakazan termin u budućnosti i, ako ne postoji, automatski kreira nekoliko novih termina relativno na trenutni datum/vrijeme (uz jednu potvrđenu rezervaciju na najbližem terminu radi odmah testabilnog toka podsjetnika i historije rezervacija). Ovo je implementirano u `FitBook.Services/Database/DatabaseInitializer.cs`.

## Konfiguracija

Svi konfiguracijski podaci (connection string, JWT ključ, RabbitMQ, SMTP, Stripe sandbox ključevi) čitaju se isključivo iz `.env` fajla — ništa nije hardkodirano u kodu niti u `appsettings.json`. Vidi `.env.example` za kompletnu listu potrebnih vrijednosti.
