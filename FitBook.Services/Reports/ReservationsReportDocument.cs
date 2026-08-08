using FitBook.Common.Services.Time;
using FitBook.Model.Enums;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace FitBook.Services.Reports;

internal class ReservationsReportDocument : IDocument
{
    private readonly List<ReservationReportRow> _rows;
    private readonly DateOnly _fromDate;
    private readonly DateOnly _toDate;
    private readonly DateTime _generatedAtUtc;

    public ReservationsReportDocument(List<ReservationReportRow> rows, DateOnly fromDate, DateOnly toDate, DateTime generatedAtUtc)
    {
        _rows = rows;
        _fromDate = fromDate;
        _toDate = toDate;
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
                column.Item().Text("Izvještaj o rezervacijama").FontSize(18).Bold();
                column.Item().Text($"Termini u periodu: {_fromDate:dd.MM.yyyy.} – {_toDate:dd.MM.yyyy.}").FontSize(11);
                column.Item().Text("Prikazane su sve rezervacije čiji termin pada u odabrani period, bez obzira na to kada su kreirane.")
                    .FontSize(9).Italic().FontColor(Colors.Grey.Darken1);
            });

            page.Content().PaddingVertical(10).Column(column =>
            {
                if (_rows.Count == 0)
                {
                    column.Item().Text("Nema rezervacija za termine u odabranom periodu.");
                    return;
                }

                column.Item().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn(2.2f);
                        columns.RelativeColumn(2.2f);
                        columns.RelativeColumn(2f);
                        columns.RelativeColumn(1.3f);
                        columns.RelativeColumn(2f);
                    });

                    table.Header(header =>
                    {
                        header.Cell().Element(HeaderCellStyle).Text("Korisnik");
                        header.Cell().Element(HeaderCellStyle).Text("Trening");
                        header.Cell().Element(HeaderCellStyle).Text("Termin");
                        header.Cell().Element(HeaderCellStyle).Text("Status");
                        header.Cell().Element(HeaderCellStyle).Text("Rezervisano");
                    });

                    foreach (var row in _rows)
                    {
                        table.Cell().Element(BodyCellStyle).Text(row.UserFullName);
                        table.Cell().Element(BodyCellStyle).Text(row.TrainingName);
                        table.Cell().Element(BodyCellStyle).Text(LocalTimeProvider.FormatDateTime(row.TrainingTermStartUtc));
                        table.Cell().Element(BodyCellStyle).Text(FormatStatus(row.Status));
                        table.Cell().Element(BodyCellStyle).Text(LocalTimeProvider.FormatDateTime(row.ReservedAtUtc));
                    }
                });
            });

            page.Footer().Row(row =>
            {
                row.RelativeItem(4).Text($"Ukupno rezervacija: {_rows.Count}   |   Generisano: {LocalTimeProvider.FormatDateTime(_generatedAtUtc)}");
                row.RelativeItem(1).AlignRight().Text(x =>
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

    private static string FormatStatus(ReservationStatus status) => status switch
    {
        ReservationStatus.Pending => "Na čekanju",
        ReservationStatus.Confirmed => "Potvrđeno",
        ReservationStatus.Cancelled => "Otkazano",
        ReservationStatus.Completed => "Završeno",
        _ => status.ToString(),
    };
}
