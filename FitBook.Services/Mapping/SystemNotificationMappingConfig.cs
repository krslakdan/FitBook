using FitBook.Model.Responses.SystemNotifications;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class SystemNotificationMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<SystemNotification, SystemNotificationResponse>();
    }
}
