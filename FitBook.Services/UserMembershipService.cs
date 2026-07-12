using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.UserMemberships;
using FitBook.Model.Responses.Payments;
using FitBook.Model.Responses.UserMemberships;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

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

    public UserMembershipService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService,
        IValidator<UserMembershipInsertRequest> insertValidator,
        IValidator<UserMembershipUpdateRequest> updateValidator,
        IValidator<UserMembershipCancelRequest> cancelValidator,
        IStripePaymentService stripePaymentService)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _currentUserService = currentUserService;
        _cancelValidator = cancelValidator;
        _stripePaymentService = stripePaymentService;
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

    protected override async Task ValidateInsert(UserMembershipInsertRequest request, CancellationToken cancellationToken)
    {
        var package = await _dbContext.MembershipPackages
            .FirstOrDefaultAsync(x => x.Id == request.MembershipPackageId && !x.IsDeleted, cancellationToken);

        if (package is null)
        {
            throw new NotFoundException($"MembershipPackage with id {request.MembershipPackageId} was not found.");
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

    protected override async Task BeforeInsert(UserMembershipInsertRequest request, UserMembership entity, CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();

        entity.UserAccountId = currentUserId;
        entity.Status = MembershipStatus.Pending;
        entity.IsActive = false;

        entity.StartDateUtc = DateTime.UtcNow;
        entity.EndDateUtc = DateTime.UtcNow;
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
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        if (membership is null)
        {
            throw new NotFoundException($"UserMembership with id {id} was not found.");
        }

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isOwner = membership.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isOwner)
        {
            throw new BusinessException("Nemate pravo otkazati ovu članarinu.");
        }

        EnsureValidTransition(membership.Status, MembershipStatus.Cancelled);

        var completedPayment = membership.Payments.FirstOrDefault(p => p.Status == PaymentStatus.Completed);
        if (completedPayment != null)
        {
            
            await _stripePaymentService.CreateRefundAsync(completedPayment.PaymentIntentId, completedPayment.Amount, cancellationToken);
            completedPayment.Status = PaymentStatus.Refunded;
            completedPayment.RefundedAtUtc = DateTime.UtcNow;
            completedPayment.RefundAmount = completedPayment.Amount;
        }

        membership.Status = MembershipStatus.Cancelled;
        membership.IsActive = false;
        membership.UpdatedAtUtc = DateTime.UtcNow;

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = membership.UserAccountId,
            NotificationType = NotificationType.MembershipCancelled,
            Title = "Članarina je otkazana",
            Content = $"Vaša članarina je otkazana. Razlog: {request.Reason}{(completedPayment != null ? " Izvršen je povrat sredstava." : "")}",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Membership {MembershipId} cancelled by user {UserId}. Reason: {Reason}. Refunded: {IsRefunded}",
            membership.Id,
            _currentUserService.GetRequiredUserId(),
            request.Reason,
            completedPayment != null);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<UserMembershipResponse> ExpireAsync(int id, CancellationToken cancellationToken = default)
    {
        var membership = await _dbContext.UserMemberships
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);

        if (membership is null)
        {
            throw new NotFoundException($"UserMembership with id {id} was not found.");
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
            throw new NotFoundException($"UserMembership with id {id} was not found.");
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
        if (existingActivePayment != null)
        {
            if (existingActivePayment.Status == PaymentStatus.Completed)
            {
                throw new BusinessException("Ova članarina je već uspješno plaćena.");
            }

            var existingIntent = await _stripePaymentService.GetPaymentIntentAsync(existingActivePayment.PaymentIntentId, cancellationToken);

            if (existingIntent.Status == "succeeded")
            {
                throw new BusinessException("Uplata je već zabilježena kao uspješna na Stripe-u. Sistem će se uskoro automatski ažurirati.");
            }
            else if (existingIntent.Status == "canceled")
            {
                existingActivePayment.Status = PaymentStatus.Failed;
                existingActivePayment.UpdatedAtUtc = DateTime.UtcNow;
                await _dbContext.SaveChangesAsync(cancellationToken);
                // Fall through to create new intent
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

        var intent = await _stripePaymentService.CreatePaymentIntentAsync(amountToPay, "usd", idempotencyKey, cancellationToken);

        var payment = new MembershipPayment
        {
            Amount = amountToPay,
            Currency = "USD",
            PaymentProvider = "Stripe",
            PaymentIntentId = intent.Id,
            Status = PaymentStatus.Pending,
            UserMembershipId = id,
            UserAccountId = membership.UserAccountId,
            CreatedAtUtc = DateTime.UtcNow
        };

        _dbContext.MembershipPayments.Add(payment);
        await _dbContext.SaveChangesAsync(cancellationToken);

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

    public async Task MarkPaymentSuccessfulAsync(string paymentIntentId, CancellationToken cancellationToken = default)
    {
        var payment = await _dbContext.MembershipPayments
            .Include(x => x.UserMembership)
                .ThenInclude(um => um!.MembershipPackage)
            .FirstOrDefaultAsync(x => x.PaymentIntentId == paymentIntentId, cancellationToken);

        if (payment == null)
        {
            _logger.LogWarning("PaymentIntentSucceeded for unknown PaymentIntentId: {Id}", paymentIntentId);
            return;
        }

        if (payment.Status == PaymentStatus.Completed)
        {
            _logger.LogInformation("Webhook idempotency: Payment {PaymentId} is already Completed.", payment.Id);
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
            
            // Recalculate dates so user gets full duration starting from payment moment!
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
                Content = $"Vaša članarina je uspješno plaćena i sada je aktivna do {membership.EndDateUtc:dd.MM.yyyy}. Hvala!",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        _logger.LogInformation("Payment {PaymentId} marked as Completed. Membership {MembershipId} processed.", payment.Id, membership.Id);
    }

    private void EnsureValidTransition(MembershipStatus from, MembershipStatus to)
    {
        if (!_allowedTransitions.TryGetValue(from, out var allowed) || !allowed.Contains(to))
        {
            throw new BusinessException(
                $"Nije moguća tranzicija statusa članarine iz '{from}' u '{to}'.");
        }
    }

    public async Task HandlePaymentIntentSucceededAsync(string paymentIntentId, CancellationToken cancellationToken = default)
    {
        var payment = await _dbContext.MembershipPayments
            .Include(p => p.UserMembership)
            .FirstOrDefaultAsync(p => p.PaymentIntentId == paymentIntentId, cancellationToken);

        if (payment is null)
        {
            _logger.LogWarning("Webhook payment_intent.succeeded za nepoznat PaymentIntentId: {Id}", paymentIntentId);
            return;
        }

        if (payment.Status == PaymentStatus.Completed)
        {
            _logger.LogInformation("Webhook idempotency: Payment {PaymentId} je već Completed.", payment.Id);
            return;
        }

        if (payment.Status != PaymentStatus.Pending)
        {
            _logger.LogWarning("Webhook payment_intent.succeeded za Payment {PaymentId} u neočekivanom statusu {Status}.", payment.Id, payment.Status);
            return;
        }

        payment.Status = PaymentStatus.Completed;
        payment.PaidAtUtc = DateTime.UtcNow;
        payment.UpdatedAtUtc = DateTime.UtcNow;

        if (payment.UserMembership is not null)
        {
            EnsureValidTransition(payment.UserMembership.Status, MembershipStatus.Active);
            payment.UserMembership.Status = MembershipStatus.Active;
            payment.UserMembership.IsActive = true;
            payment.UserMembership.StartDateUtc = DateTime.UtcNow;
            payment.UserMembership.EndDateUtc = DateTime.UtcNow.AddDays(payment.UserMembership.MembershipPackage!.DurationDays);
            payment.UserMembership.UpdatedAtUtc = DateTime.UtcNow;

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = payment.UserMembership.UserAccountId,
                NotificationType = NotificationType.MembershipPaid,
                Title = "Plaćanje članarine uspješno",
                Content = $"Vaša članarina je uspješno plaćena u iznosu od {payment.Amount} {payment.Currency}.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        _logger.LogInformation("Payment {PaymentId} označen kao Completed. Membership {MembershipId} aktiviran.", payment.Id, payment.UserMembershipId);
    }
}
