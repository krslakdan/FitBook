using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class SeedBosnianTranslations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Početni");

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Srednji");

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Napredni");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Girja");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Set tegova");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Prostirka za jogu");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 4,
                column: "Name",
                value: "Pjenasti valjak");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 5,
                column: "Name",
                value: "Bokserske rukavice");

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "LocationDescription", "Name" },
                values: new object[] { "Prizemlje, Zona A", "Glavna teretana" });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "LocationDescription", "Name" },
                values: new object[] { "Prvi sprat, Zona B", "Studio za jogu i pilates" });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "LocationDescription", "Name" },
                values: new object[] { "Prvi sprat, Zona C", "Sala za spinning" });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "IncludedBenefits", "Name" },
                values: new object[] { "Pristup glavnoj sali, 3 grupna treninga sedmično.", "Mjesečni Osnovni" });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "IncludedBenefits", "Name" },
                values: new object[] { "Neograničeni grupni treninzi, pristup sauni, 1 besplatan personalni trening.", "Tromjesečni Premium" });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "IncludedBenefits", "Name" },
                values: new object[] { "Neograničeni grupni treninzi, pristup sauni, 4 besplatna personalna treninga, prioritetno rezervisanje.", "Godišnji VIP" });

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Content", "Title" },
                values: new object[] { "Sa zadovoljstvom objavljujemo da je naš novi premium studio za jogu i pilates na prvom spratu sada otvoren za rezervacije.", "Veliko otvorenje našeg joga studija!" });

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Content", "Title" },
                values: new object[] { "Od ovog mjeseca u ponudi su dva nova programa: Osnove boksa za sve nivoe i Jutarnji klub trčanja za ljubitelje trčanja. Rezervišite svoje mjesto već danas.", "Uvodimo Osnove boksa i Jutarnji klub trčanja!" });

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 1,
                column: "Reason",
                value: "Automatski potvrđeno nakon uspješne uplate i provjere aktivne članarine");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 2,
                column: "Reason",
                value: "Označeno kao završeno nakon završetka termina");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 3,
                column: "Reason",
                value: "Označeno kao završeno nakon završetka termina");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 4,
                column: "Reason",
                value: "Označeno kao završeno nakon završetka termina");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 5,
                column: "Reason",
                value: "Označeno kao završeno nakon završetka termina");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Snaga i kondicija");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Joga i pilates");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Kardio i HIIT");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 5,
                column: "Name",
                value: "Bodibilding");

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Content", "Title" },
                values: new object[] { "Vaša rezervacija za Vinyasa joga je uspješno potvrđena.", "Rezervacija potvrđena" });

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 5,
                column: "Content",
                value: "Vaš trening za Jutarnji klub trčanja je uspješno završen. Hvala na dolasku!");

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 6,
                column: "Content",
                value: "Vaš trening za Osnove boksa je uspješno završen. Hvala na dolasku!");

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 7,
                column: "Content",
                value: "Vaša rezervacija za Jutarnji klub trčanja je otkazana. Razlog: Promjena rasporeda korisnika.");

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 1,
                column: "Biography",
                value: "Certificirani trener sa preko 8 godina iskustva u atletskom treningu.");

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 2,
                column: "Biography",
                value: "Posvećena pomaganju ljudima da pronađu ravnotežu i fleksibilnost.");

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 3,
                column: "Biography",
                value: "Energični HIIT treninzi koji vas drže u sagorijevanju kalorija.");

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Treninzi za poboljšanje zdravlja srca i izdržljivosti.", "Kardio" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Trening s opterećenjem za izgradnju mišićne mase.", "Snaga" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Joga, istezanje i vježbe svjesnosti.", "Tijelo i um" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Lagani oporavak, istezanje i vježbe mobilnosti.", "Oporavak i mobilnost" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Kondicija inspirisana boksom i borilačkim vještinama.", "Borilački sportovi" });

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 1,
                column: "Note",
                value: "Preporučeno 8kg-16kg");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 2,
                column: "Note",
                value: "Pojasevi su dostupni u sali");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 3,
                column: "Note",
                value: "Prostirke su dostupne u studiju ili ponesite svoju");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 4,
                column: "Note",
                value: "Dostupno u studiju");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 5,
                column: "Note",
                value: "Ponesite svoje ili iznajmite na recepciji");

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Intervalni trening visokog intenziteta za ubrzanje metabolizma.", "HIIT Eksplozija" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Naučite i izvodite pravilnu tehniku dizanja s tegovima.", "Dizanje tegova" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Tečne sekvence joga poza uz kontrolu disanja.", "Vinyasa joga" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Vođeno miofascijalno opuštanje i vježbe mobilnosti zglobova.", "Opuštanje i mobilnost" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Rad nogu, kombinacije i rad na fokuserima za početnike i srednji nivo.", "Osnove boksa" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Vođeni intervalni trening trčanja na otvorenom za početak dana.", "Jutarnji klub trčanja" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Radionica tehnike mrtvog dizanja za sigurno povećanje opterećenja.", "Tehnika mrtvog dizanja" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Beginner");

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Intermediate");

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Advanced");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Kettlebell");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Barbell Set");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Yoga Mat");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 4,
                column: "Name",
                value: "Foam Roller");

            migrationBuilder.UpdateData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 5,
                column: "Name",
                value: "Boxing Gloves");

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "LocationDescription", "Name" },
                values: new object[] { "Ground Floor, Zone A", "Main Gym Hall" });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "LocationDescription", "Name" },
                values: new object[] { "First Floor, Zone B", "Yoga & Pilates Studio" });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "LocationDescription", "Name" },
                values: new object[] { "First Floor, Zone C", "Spinning Room" });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "IncludedBenefits", "Name" },
                values: new object[] { "Access to main hall, 3 group trainings per week.", "1 Month Basic" });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "IncludedBenefits", "Name" },
                values: new object[] { "Unlimited group trainings, sauna access, 1 free personal session.", "3 Month Premium" });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "IncludedBenefits", "Name" },
                values: new object[] { "Unlimited group trainings, sauna access, 4 free personal sessions, priority booking.", "1 Year VIP" });

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Content", "Title" },
                values: new object[] { "We are thrilled to announce that our new premium Yoga & Pilates studio on the first floor is now open for bookings.", "Grand Opening of our Yoga Studio!" });

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Content", "Title" },
                values: new object[] { "Od ovog mjeseca u ponudi su dva nova programa: Boxing Fundamentals za sve nivoe i Morning Run Club za ljubitelje trčanja. Rezervišite svoje mjesto već danas.", "Uvodimo Boxing Fundamentals i Morning Run Club!" });

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 1,
                column: "Reason",
                value: "Auto-confirmed on successful payment and active membership check");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 2,
                column: "Reason",
                value: "Marked as completed after class finish");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 3,
                column: "Reason",
                value: "Marked as completed after class finish");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 4,
                column: "Reason",
                value: "Marked as completed after class finish");

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 5,
                column: "Reason",
                value: "Marked as completed after class finish");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Strength & Conditioning");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Yoga & Pilates");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Cardio & HIIT");

            migrationBuilder.UpdateData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 5,
                column: "Name",
                value: "Bodybuilding");

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Content", "Title" },
                values: new object[] { "Your reservation for Vinyasa Yoga has been successfully confirmed.", "Reservation Confirmed" });

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 5,
                column: "Content",
                value: "Vaš trening za Morning Run Club je uspješno završen. Hvala na dolasku!");

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 6,
                column: "Content",
                value: "Vaš trening za Boxing Fundamentals je uspješno završen. Hvala na dolasku!");

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 7,
                column: "Content",
                value: "Vaša rezervacija za Morning Run Club je otkazana. Razlog: Promjena rasporeda korisnika.");

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 1,
                column: "Biography",
                value: "Certified trainer with 8+ years of experience in athletic training.");

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 2,
                column: "Biography",
                value: "Passionate about helping people find balance and flexibility.");

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 3,
                column: "Biography",
                value: "Energy-packed HIIT workouts to keep you burning calories.");

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Workouts designed to improve heart health and stamina.", "Cardio" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Resistance training designed to build muscle mass.", "Strength" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Yoga, stretching, and mindfulness practices.", "Mind & Body" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Low-impact recovery, stretching, and mobility work.", "Recovery & Mobility" });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Boxing and martial-arts inspired conditioning.", "Combat Sports" });

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 1,
                column: "Note",
                value: "Recommended 8kg-16kg");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 2,
                column: "Note",
                value: "Belts provided in hall");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 3,
                column: "Note",
                value: "Mats are available in studio, or bring your own");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 4,
                column: "Note",
                value: "Provided in studio");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 5,
                column: "Note",
                value: "Bring your own or rent at front desk");

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "Description", "Name" },
                values: new object[] { "High Intensity Interval Training to boost metabolism.", "HIIT Blast" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Learn and execute proper barbell techniques.", "Power Lifting" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Flowing sequences of yoga poses with breath control.", "Vinyasa Yoga" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Guided self-myofascial release and joint mobility drills.", "Foam Rolling & Mobility" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Footwork, combinations, and pad work for beginners and intermediates.", "Boxing Fundamentals" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Coached outdoor interval running session to start the day.", "Morning Run Club" });

            migrationBuilder.UpdateData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "Description", "Name" },
                values: new object[] { "Barbell deadlift form clinic for lifters ready to add weight safely.", "Deadlift Technique" });
        }
    }
}
