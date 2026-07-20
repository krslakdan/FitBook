using FitBook.Model.Responses.Payments;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;

namespace FitBook.WebAPI.Controllers;

public class MembershipPaymentsController
    : BaseReadController<MembershipPaymentResponse, MembershipPaymentSearchObject, IMembershipPaymentService>
{
    public MembershipPaymentsController(IMembershipPaymentService service) : base(service)
    {
    }
}
