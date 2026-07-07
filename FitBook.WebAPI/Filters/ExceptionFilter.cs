using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using FitBook.Model.Exceptions;
using System.Net;

namespace FitBook.WebAPI.Filters;

public sealed class ExceptionFilter : ExceptionFilterAttribute
{
    private readonly ILogger<ExceptionFilter> _logger;

    public ExceptionFilter(ILogger<ExceptionFilter> logger)
    {
        _logger = logger;
    }

    public override void OnException(ExceptionContext context)
    {
        var statusCode = HttpStatusCode.InternalServerError;
        var errors = new Dictionary<string, List<string>>();
        var message = "Request could not be processed.";

        switch (context.Exception)
        {
            case ValidationException validationException:
                statusCode = HttpStatusCode.BadRequest;
                message = "Validation failed.";
                foreach (var error in validationException.Errors)
                {
                    var key = string.IsNullOrWhiteSpace(error.PropertyName) ? "validation" : error.PropertyName;
                    if (!errors.ContainsKey(key))
                    {
                        errors[key] = [];
                    }

                    errors[key].Add(error.ErrorMessage);
                }

                _logger.LogWarning(context.Exception, "Validation failed.");
                break;

            case BusinessException businessException:
                statusCode = HttpStatusCode.BadRequest;
                message = businessException.Message;
                errors["business"] = [businessException.Message];
                _logger.LogWarning("Business rule failed: {Message}", businessException.Message);
                break;

            case ForbiddenException forbiddenException:
                statusCode = HttpStatusCode.Forbidden;
                message = forbiddenException.Message;
                errors["forbidden"] = [forbiddenException.Message];
                _logger.LogWarning("Forbidden access: {Message}", forbiddenException.Message);
                break;

            case NotFoundException notFoundException:
                statusCode = HttpStatusCode.NotFound;
                message = notFoundException.Message;
                errors["notFound"] = [notFoundException.Message];
                _logger.LogInformation("Resource not found: {Message}", notFoundException.Message);
                break;

            default:
                errors["server"] = ["Server side error. Please check logs."];
                _logger.LogError(context.Exception, "Unhandled exception.");
                break;
        }

        context.HttpContext.Response.StatusCode = (int)statusCode;
        context.Result = new JsonResult(new
        {
            message,
            errors
        });
    }
}
