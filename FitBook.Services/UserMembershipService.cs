using FitBook.Common.Services.Time;
using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Messages;
using FitBook.Model.Requests.UserMemberships;
using FitBook.Model.Responses.Payments;
using FitBook.Model.Responses.UserMemberships;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Stripe;

namespace FitBook.Services;

public class UserMembershipService
    : BaseCRUDService<UserMembership, UserMembershipResponse, MembershipSearchObject, UserMembershipInsertRequest, UserMembershipUpdateRequest>,
      IUserMembershipService
{
    private static readonly Dictionary<MembershipStatus, MembershipStatus[]> _allowedTransitions = new()
    {
        [MembershipStatus.Pending] = [MembershipStatus.Active, MembershipStatus.Cancelled],
        [MembershipStatus.Active] = [MembershipStatus.Cancelled, MembershipStatus.Expired],
        [MembershipStatus.Cancelled] = [],
        [MembershipStatus.Expired] = [],
    };

    private static readonly MembershipStatus[] _activeStatuses =
    [
        MembershipStatus.Pending,
        MembershipStatus.Active,
    ];

    private readonly ICurrentUserService _currentUserService;
    private readonly IValidator<UserMembershipCancelRequest> _cancelValidator;
    private readonly IStripePaymentService _stripePaymentService;
    private readonly IEmailNotificationPublisher _emailNotificationPublisher;

    public UserMembershipService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService,
        IValidator<UserMembershipInsertRequest> insertValidator,
        IValidator<UserMembershipUpdateRequest> updateValidator,
        IValidator<UserMembershipCancelRequest> cancelValidator,
        IStripePaymentService stripePaymentService,
        IEmailNotificationPublisher emailNotificationPublisher)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _currentUserService = currentUserService;
        _cancelValidator = cancelValidator;
        _stripePaymentService = stripePaymentService;
        _emailNotificationPublisher = emailNotificationPublisher;
    }

    protected override IQueryable<UserMembership> ApplyFilter(IQueryable<UserMembership> query, MembershipSearchObject search)
    {
        query = query.Where(x => !x.IsDeleted);

        if (!_currentUserService.IsAdmin())
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(x => x.UserAccountId == currentUserId);
        }
        else if (search.UserAccountId.HasValue)
        {
            query = query.Where(x => x.UserAccountId == search.UserAccountId.Value);
        }

        if (search.MembershipPackageId.HasValue)
        {
            query = query.Where(x => x.MembershipPackageId == search.MembershipPackageId.Value);
        }

        if (search.Status.HasValue)
        {
            query = query.Where(x => x.Status == search.Status.Value);
        }

        if (search.ActiveFromUtc.HasValue)
        {
            query = query.Where(x => x.StartDateUtc >= search.ActiveFromUtc.Value);
        }

        if (search.ActiveToUtc.HasValue)
        {
            query = query.Where(x => x.StartDateUtc <= search.ActiveToUtc.Value);
        }

        return query;
    }

    protected override IQueryable<UserMembership> ApplySearch(IQueryable<UserMembership> query, MembershipSearchObject search)
    {
        if (string.IsNullOrWhiteSpace(search.Search))
        {
            return query;
        }

        var term = search.Search.Trim().ToLowerInvariant();
        return query.Where(x =>
            x.UserAccount!.FirstName.ToLower().Contains(term) ||
            x.UserAccount.LastName.ToLower().Contains(term) ||
            x.UserAccount.Email.ToLower().Contains(term) ||
            x.MembershipPackage!.Name.ToLower().Contains(term));
    }

    protected override async Task ValidateInsert(UserMembershipInsertRequest request, CancellationToken cancellationToken)
    {
        var package = await _dbContext.MembershipPackages
            .FirstOrDefaultAsync(x => x.Id == request.MembershipPackageId && !x.IsDeleted, cancellationToken);

        if (package is null)
        {
            throw new NotFoundException($"Paket članarine sa ID {request.MembershipPackageId} nije pronađen.");
        }

        if (!package.IsActive)
        {
            throw new BusinessException("Odabrani paket članarine nije aktivan.");
        }

        var currentUserId = _currentUserService.GetRequiredUserId();
        var hasActiveMembership = await _dbContext.UserMemberships
            .AnyAsync(
                x => x.UserAccountId == currentUserId &&
                     !x.IsDeleted &&
                     _activeStatuses.Contains(x.Status),
                cancellationToken);

        if (hasActiveMembership)
        {
            throw new BusinessException("Korisnik već ima aktivnu ili članarinu u obradi (Pending).");
        }
    }

    protected override Task BeforeInsert(UserMembershipInsertRequest request, UserMembership entity, CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();

        entity.UserAccountId = currentUserId;
        entity.Status = MembershipStatus.Pending;
        entity.IsActive = false;

        entity.StartDateUtc = DateTime.UtcNow;
        entity.EndDateUtc = DateTime.UtcNow;

        return Task.CompletedTask;
    }

    public override Task<UserMembershipResponse> UpdateAsync(int id, UserMembershipUpdateRequest request, CancellationToken cancellationToken = default)
    {
        throw new BusinessException("Članarine se ne mogu mijenjati putem generičkog Update endpointa.");
    }

    public override Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        throw new BusinessException("Članarine se ne brišu (čuvaju istoriju). Status se mijenja kroz namjenske endpointe.");
    }

    public async Task<UserMembershipResponse> CancelAsync(int id, UserMembershipCancelRequest request, CancellationToken cancellationToken = default)
    {
        await _cancelValidator.ValidateAndThrowAsync(request, cancellationToken);

        var membership = await _dbContext.UserMemberships
            .Include(x => x.Payments)
            .Include(x => x.UserAccount)
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        if (membership is null)
        {
            throw new NotFoundException($"Članarina sa ID {id} nije pronađena.");
        }

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isOwner = membership.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isOwner)
        {
            throw new BusinessException("Nemate pravo otkazati ovu članarinu.");
        }

        EnsureValidTransition(membership.Status, MembershipStatus.Cancelled);

        var completedPayment = membership.Payments.FirstOrDefault(p => p.Status == PaymentStatus.Completed);
        var refundIssued = false;
        if (completedPayment != null)
        {
            try
            {
                await _stripePaymentService.CreateRefundAsync(completedPayment.PaymentIntentId, completedPayment.Amount, cancellationToken);
                completedPayment.Status = PaymentStatus.Refunded;
                completedPayment.RefundedAtUtc = DateTime.UtcNow;
                completedPayment.RefundAmount = completedPayment.Amount;
                refundIssued = true;
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex,
                    "Stripe refund failed for Payment {PaymentId} (PaymentIntent {PaymentIntentId}) while cancelling Membership {MembershipId}. Cancellation proceeds without refund.",
                    completedPayment.Id,
                    completedPayment.PaymentIntentId,
                    membership.Id);
            }
        }

        membership.Status = MembershipStatus.Cancelled;
        membership.IsActive = false;
        membership.UpdatedAtUtc = DateTime.UtcNow;

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = membership.UserAccountId,
            NotificationType = NotificationType.MembershipCancelled,
            Title = "Članarina je otkazana",
            Content = $"Vaša članarina je otkazana. Razlog: {request.Reason}{(refundIssued ? " Izvršen je povrat sredstava." : "")}",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        if (membership.UserAccount is not null)
        {
            var refundNote = refundIssued
                ? $" Izvršen je povrat sredstava u iznosu od {completedPayment!.Amount:0.00} {completedPayment.Currency}."
                : string.Empty;

            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = membership.UserAccount.Email,
                ToName = $"{membership.UserAccount.FirstName} {membership.UserAccount.LastName}",
                Subject = "Vaša članarina je otkazana",
                Body = $"Poštovani, Vaša članarina je otkazana. Razlog: {request.Reason}{refundNote}",
            }, cancellationToken);
        }

        _logger.LogInformation(
            "Membership {MembershipId} cancelled by user {UserId}. Reason: {Reason}. Refunded: {IsRefunded}",
            membership.Id,
            _currentUserService.GetRequiredUserId(),
            request.Reason,
            refundIssued);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<UserMembershipResponse> ExpireAsync(int id, CancellationToken cancellationToken = default)
    {
        var membership = await _dbContext.UserMemberships
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        if (membership is null)
        {
            throw new NotFoundException($"Članarina sa ID {id} nije pronađena.");
        }

        if (!_currentUserService.IsAdmin())
        {
            throw new BusinessException("Samo administratori mogu ručno isteći članarinu.");
        }

        EnsureValidTransition(membership.Status, MembershipStatus.Expired);

        if (membership.EndDateUtc > DateTime.UtcNow)
        {
            throw new BusinessException("Članarina još nije istekla (EndDateUtc je u budućnosti).");
        }

        membership.Status = MembershipStatus.Expired;
        membership.IsActive = false;
        membership.UpdatedAtUtc = DateTime.UtcNow;

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = membership.UserAccountId,
            NotificationType = NotificationType.MembershipExpired,
            Title = "Članarina je istekla",
            Content = "Vaša članarina je istekla.",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Membership {MembershipId} expired manually by Admin {UserId}.",
            membership.Id,
            _currentUserService.GetRequiredUserId());

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<CreatePaymentIntentResponse> CreatePaymentIntentAsync(int id, CancellationToken cancellationToken = default)
    {
        var membership = await _dbContext.UserMemberships
            .Include(x => x.MembershipPackage)
            .Include(x => x.Payments)
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        if (membership is null)
        {
            throw new NotFoundException($"Članarina sa ID {id} nije pronađena.");
        }

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isOwner = membership.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isOwner)
        {
            throw new BusinessException("Nemate pravo platiti ovu članarinu.");
        }
        
        if (membership.Status != MembershipStatus.Pending && membership.Status != MembershipStatus.Active)
        {
            throw new BusinessException("Nije moguće plaćanje za članarinu u trenutnom statusu.");
        }

        var existingActivePayment = membership.Payments.FirstOrDefault(p => p.Status == PaymentStatus.Pending || p.Status == PaymentStatus.Completed);
        MembershipPayment? paymentToMarkFailed = null;

        if (existingActivePayment != null)
        {
            if (existingActivePayment.Status == PaymentStatus.Completed)
            {
                throw new BusinessException("Ova članarina je već uspješno plaćena.");
            }

            var existingIntent = await _stripePaymentService.GetPaymentIntentAsync(existingActivePayment.PaymentIntentId, cancellationToken);

            if (existingIntent.Status == "succeeded")
            {
                await MarkPaymentSuccessfulAsync(existingActivePayment.PaymentIntentId, cancellationToken);
                throw new BusinessException("Ova članarina je već uspješno plaćena.");
            }
            else if (existingIntent.Status == "canceled")
            {
                paymentToMarkFailed = existingActivePayment;
            }
            else
            {
                return new CreatePaymentIntentResponse
                {
                    ClientSecret = existingIntent.ClientSecret,
                    PaymentId = existingActivePayment.Id
                };
            }
        }

        var amountToPay = membership.MembershipPackage!.Price;
        var idempotencyKey = Guid.NewGuid().ToString();

        var intent = await _stripePaymentService.CreatePaymentIntentAsync(amountToPay, PaymentConstants.Currency, idempotencyKey, cancellationToken);

        if (paymentToMarkFailed != null)
        {
            paymentToMarkFailed.Status = PaymentStatus.Failed;
            paymentToMarkFailed.UpdatedAtUtc = DateTime.UtcNow;
        }

        var payment = new MembershipPayment
        {
            Amount = amountToPay,
            Currency = PaymentConstants.Currency.ToUpperInvariant(),
            PaymentProvider = "Stripe",
            PaymentIntentId = intent.Id,
            Status = PaymentStatus.Pending,
            UserMembershipId = id,
            UserAccountId = membership.UserAccountId,
            CreatedAtUtc = DateTime.UtcNow
        };

        _dbContext.MembershipPayments.Add(payment);

        try
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            if (await HasActivePaymentAsync(id, payment.Id, cancellationToken))
            {
                throw new BusinessException("Za ovu članarinu je upravo kreirano plaćanje u drugom zahtjevu. Osvježite stranicu i pokušajte ponovo.");
            }

            throw;
        }

        _logger.LogInformation(
            "PaymentIntent created for Membership {MembershipId} by user {UserId}. PaymentIntentId: {PaymentIntentId}",
            id,
            currentUserId,
            intent.Id);

        return new CreatePaymentIntentResponse
        {
            ClientSecret = intent.ClientSecret,
            PaymentId = payment.Id
        };
    }

    public async Task<UserMembershipResponse> ConfirmPaymentAsync(int id, CancellationToken cancellationToken = default)
    {
        var membership = await _dbContext.UserMemberships
            .Include(x => x.Payments)
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        if (membership is null)
        {
            throw new NotFoundException($"Članarina sa ID {id} nije pronađena.");
        }

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isOwner = membership.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isOwner)
        {
            throw new BusinessException("Nemate pravo potvrditi plaćanje ove članarine.");
        }

        var pendingPayment = membership.Payments
            .Where(p => p.Status == PaymentStatus.Pending)
            .OrderByDescending(p => p.CreatedAtUtc)
            .FirstOrDefault();

        if (pendingPayment is not null)
        {
            var intent = await _stripePaymentService.GetPaymentIntentAsync(pendingPayment.PaymentIntentId, cancellationToken);

            if (intent.Status == "succeeded")
            {
                await MarkPaymentSuccessfulAsync(pendingPayment.PaymentIntentId, cancellationToken);
            }
            else if (intent.Status == "canceled")
            {
                await MarkPaymentFailedAsync(pendingPayment.PaymentIntentId, cancellationToken);
            }
            else
            {
                _logger.LogInformation(
                    "ConfirmPayment for Membership {MembershipId}: PaymentIntent {PaymentIntentId} still in status {Status}.",
                    id,
                    pendingPayment.PaymentIntentId,
                    intent.Status);
            }
        }

        return await GetByIdAsync(id, cancellationToken);
    }

    private async Task<bool> HasActivePaymentAsync(int userMembershipId, int excludePaymentId, CancellationToken cancellationToken)
    {
        return await _dbContext.MembershipPayments.AsNoTracking().AnyAsync(
            p => p.UserMembershipId == userMembershipId &&
                 p.Id != excludePaymentId &&
                 (p.Status == PaymentStatus.Pending || p.Status == PaymentStatus.Completed),
            cancellationToken);
    }

    private async Task MarkPaymentSuccessfulAsync(string paymentIntentId, CancellationToken cancellationToken = default)
    {
        var payment = await _dbContext.MembershipPayments
            .Include(x => x.UserMembership)
                .ThenInclude(um => um!.MembershipPackage)
            .Include(x => x.UserMembership)
                .ThenInclude(um => um!.UserAccount)
            .FirstOrDefaultAsync(x => x.PaymentIntentId == paymentIntentId, cancellationToken);

        if (payment == null)
        {
            _logger.LogWarning("PaymentIntentSucceeded for unknown PaymentIntentId: {Id}", paymentIntentId);
            return;
        }

        if (payment.Status == PaymentStatus.Completed)
        {
            _logger.LogInformation("Idempotency: Payment {PaymentId} is already Completed.", payment.Id);
            return;
        }

        var membership = payment.UserMembership;
        if (membership == null) return;

        payment.Status = PaymentStatus.Completed;
        payment.PaidAtUtc = DateTime.UtcNow;
        payment.UpdatedAtUtc = DateTime.UtcNow;

        if (membership.Status == MembershipStatus.Cancelled || membership.Status == MembershipStatus.Expired)
        {
            _logger.LogWarning("Payment succeeded for Membership {MembershipId} which is already {Status}. Refunding automatically.", membership.Id, membership.Status);
            await _stripePaymentService.CreateRefundAsync(paymentIntentId, payment.Amount, cancellationToken);
            payment.Status = PaymentStatus.Refunded;
            payment.RefundedAtUtc = DateTime.UtcNow;
            payment.RefundAmount = payment.Amount;
        }
        else
        {
            EnsureValidTransition(membership.Status, MembershipStatus.Active);

            membership.Status = MembershipStatus.Active;
            membership.IsActive = true;
            membership.StartDateUtc = DateTime.UtcNow;
            if (membership.MembershipPackage != null)
            {
                membership.EndDateUtc = DateTime.UtcNow.AddDays(membership.MembershipPackage.DurationDays);
            }
            
            membership.UpdatedAtUtc = DateTime.UtcNow;

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = membership.UserAccountId,
                NotificationType = NotificationType.MembershipPaid,
                Title = "Plaćanje članarine uspješno",
                Content = $"Vaša članarina je uspješno plaćena i sada je aktivna do {LocalTimeProvider.FormatDate(membership.EndDateUtc)} Hvala!",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        _logger.LogInformation("Payment {PaymentId} marked as Completed. Membership {MembershipId} processed.", payment.Id, membership.Id);

        if (membership.Status == MembershipStatus.Active && membership.UserAccount is not null)
        {
            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = membership.UserAccount.Email,
                ToName = $"{membership.UserAccount.FirstName} {membership.UserAccount.LastName}",
                Subject = "Plaćanje članarine uspješno",
                Body = $"Poštovani, Vaša članarina je uspješno plaćena i sada je aktivna do {LocalTimeProvider.FormatDate(membership.EndDateUtc)} Hvala!",
            }, cancellationToken);
        }
    }

    private async Task MarkPaymentFailedAsync(string paymentIntentId, CancellationToken cancellationToken = default)
    {
        var payment = await _dbContext.MembershipPayments
            .Include(x => x.UserAccount)
            .FirstOrDefaultAsync(x => x.PaymentIntentId == paymentIntentId, cancellationToken);

        if (payment == null)
        {
            _logger.LogWarning("PaymentIntentFailed for unknown PaymentIntentId: {Id}", paymentIntentId);
            return;
        }

        if (payment.Status != PaymentStatus.Pending)
        {
            _logger.LogInformation(
                "Idempotency: Payment {PaymentId} is already {Status}, skipping fail transition.",
                payment.Id,
                payment.Status);
            return;
        }

        payment.Status = PaymentStatus.Failed;
        payment.UpdatedAtUtc = DateTime.UtcNow;

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = payment.UserAccountId,
            NotificationType = NotificationType.MembershipPaymentFailed,
            Title = "Plaćanje članarine nije uspjelo",
            Content = "Vaše plaćanje članarine nije uspjelo. Molimo pokušajte ponovo.",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        if (payment.UserAccount is not null)
        {
            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = payment.UserAccount.Email,
                ToName = $"{payment.UserAccount.FirstName} {payment.UserAccount.LastName}",
                Subject = "Plaćanje članarine nije uspjelo",
                Body = "Poštovani, Vaše plaćanje članarine nije uspjelo. Molimo pokušajte ponovo.",
            }, cancellationToken);
        }

        _logger.LogInformation("Payment {PaymentId} marked as Failed.", payment.Id);
    }

    private void EnsureValidTransition(MembershipStatus from, MembershipStatus to)
    {
        if (!_allowedTransitions.TryGetValue(from, out var allowed) || !allowed.Contains(to))
        {
            throw new BusinessException(
                $"Nije moguća tranzicija statusa članarine iz '{from}' u '{to}'.");
        }
    }
}
