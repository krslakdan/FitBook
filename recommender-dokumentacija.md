# FitBook — dokumentacija sistema preporuke

## Cilj

FitBook korisnicima mobilne aplikacije preporučuje treninge na osnovu njihove stvarne historije rezervacija (content-based pristup) i globalne popularnosti treninga među svim korisnicima (popularity-based pristup).

## Ulazni signali

Signali se stvarno upisuju u tabelu `RecommendationSignals` kroz korištenje aplikacije:

| Događaj | Težina signala |
|---|---|
| Kreirana rezervacija | 0.3 |
| Potvrđena rezervacija | 0.5 |
| Završena rezervacija | 1.0 |

Svaki signal nosi korisnika, trening i kategoriju treninga. Ako se rezervacija otkaže, njeni signali se brišu, tako da otkazane rezervacije ne utiču na preporuke.

Pored signala, koristi se i globalni broj rezervacija po treningu (svi statusi) — ista metrika kao u izvještaju popularnosti treninga na desktop aplikaciji.

## Model bodovanja

```
Score = ContentScore * 0.70 + PopularityScore * 0.30
```

- `ContentScore` — suma težina signala korisnika po kategoriji treninga, normalizovana u odnosu na njegovu najjaču kategoriju (0–1). Favorizuje kategorije koje korisnik najčešće bira.
- `PopularityScore` — broj rezervacija treninga podijeljen sa brojem rezervacija najpopularnijeg treninga (0–1).

U kandidate ulaze samo aktivni treninzi koji imaju barem jedan aktivan zakazan termin u budućnosti. Isključuju se treninzi koje korisnik već ima rezervisane (neotkazane rezervacije). Vraća se top 5 preporuka sortiranih po score-u.

## Objašnjenje preporuke

Svaka preporuka sadrži razlog. Ako content dio nosi više od 60% ukupnog score-a:

> "Preporučeno jer često birate treninge iz kategorije Kardio."

U suprotnom preporuka dolazi iz popularnosti:

> "Popularan trening među ostalim korisnicima."

## Implementacija

- Logika je u servisnom sloju: `FitBook.Services/RecommendationService.cs`.
- Agregacije (afinitet po kategoriji, popularnost po treningu) rade se `GroupBy` upitima nad bazom.
- Endpoint `GET /api/Recommendations` vraća tipizirani DTO (`TrainingRecommendationResponse`), ne EF entitete.
- Upis i brisanje signala radi `ReservationService` pri promjenama statusa rezervacije.
