# FitBook recommender documentation

## Goal

FitBook recommends trainings to mobile users based on their real reservation history and the global popularity of available trainings.

## Input signals

- User reservation history by training category.
- Completed and confirmed reservations.
- Global reservation count per training.
- Training availability and active status.

## Scoring model

RecommendedScore = ContentScore * 0.70 + PopularityScore * 0.30

- ContentScore favors categories the user frequently books.
- PopularityScore favors trainings with more reservations across all users.
- Trainings without available terms are excluded from final recommendations.

## Explanation text

Every recommendation response should include a clear reason, for example:

"Recommended because you often book Strength trainings."

## Implementation notes

- Store all signals used by the scorer; do not collect unused scoring fields.
- Use database queries with GroupBy for popularity and category counts.
- Return typed DTO objects, not EF entities.
- Keep recommendation logic in the service layer, not in controllers.
