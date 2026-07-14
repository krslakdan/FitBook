using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace FitBook.Services.Reports;

internal class TrainingPopularityReportDocument : IDocument
{
    private readonly List<TrainingPopularityReportRow> _rows;
    private readonly DateTime _generatedAtUtc;

    public TrainingPopularityReportDocument(List<TrainingPopularityReportRow> rows, DateTime generatedAtUtc)
    {
        _rows = rows;
        _generatedAtUtc = generatedAtUtc;
    }

    public DocumentMetadata GetMetadata() => DocumentMetadata.Default;
    public DocumentSettings GetSettings() => DocumentSettings.Default;

    public void Compose(IDocumentContainer container)
    {
        container.Page(page =>
        {
            page.Size(PageSizes.A4);
            page.Margin(2, Unit.Centimetre);
            page.DefaultTextStyle(x => x.FontSize(10));

            page.Header().Column(column =>
            {
                column.Item().Text("Izvještaj o popularnosti treninga").FontSize(18).Bold();
                column.Item().Text($"Datum generisanja: {_generatedAtUtc:dd.MM.yyyy. HH:mm} UTC").FontSize(11);
            });

            page.Content().PaddingVertical(10).Column(column =>
            {
                if (_rows.Count == 0)
                {
                    column.Item().Text("Nema treninga za prikaz.");
                    return;
                }

                column.Item().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn(3);
                        columns.RelativeColumn(2);
                        columns.RelativeColumn(1.5f);
                    });

                    table.Header(header =>
                    {
                        header.Cell().Element(HeaderCellStyle).Text("Trening");
                        header.Cell().Element(HeaderCellStyle).Text("Kategorija");
                        header.Cell().Element(HeaderCellStyle).AlignRight().Text("Broj rezervacija");
                    });

                    foreach (var row in _rows)
                    {
                        table.Cell().Element(BodyCellStyle).Text(row.TrainingName);
                        table.Cell().Element(BodyCellStyle).Text(row.CategoryName);
                        table.Cell().Element(BodyCellStyle).AlignRight().Text(row.ReservationCount.ToString());
                    }
                });
            });

            page.Footer().Row(row =>
            {
                row.RelativeItem().Text($"Ukupno treninga: {_rows.Count}   |   Generisano: {_generatedAtUtc:dd.MM.yyyy. HH:mm} UTC");
                row.RelativeItem().AlignRight().Text(x =>
                {
                    x.Span("Stranica ");
                    x.CurrentPageNumber();
                    x.Span(" / ");
                    x.TotalPages();
                });
            });
        });
    }

    private static IContainer HeaderCellStyle(IContainer container) =>
        container
            .DefaultTextStyle(x => x.Bold())
            .Padding(4)
            .Background(Colors.Grey.Lighten2)
            .BorderBottom(1)
            .BorderColor(Colors.Grey.Medium);

    private static IContainer BodyCellStyle(IContainer container) =>
        container
            .Padding(4)
            .BorderBottom(0.5f)
            .BorderColor(Colors.Grey.Lighten1);
}
