namespace FitBook.Services;

public sealed class KeyedSemaphores
{
    private const int DefaultSlotCount = 64;

    private readonly SemaphoreSlim[] _slots;

    public KeyedSemaphores(int slotCount = DefaultSlotCount)
    {
        _slots = new SemaphoreSlim[slotCount];
        for (var i = 0; i < slotCount; i++)
        {
            _slots[i] = new SemaphoreSlim(1, 1);
        }
    }

    public SemaphoreSlim For(int key)
    {
        return _slots[(uint)key % (uint)_slots.Length];
    }
}
