namespace KuKey.Services
{
    public interface IEncryptService
    {
        string Encrypt(string v);
        string? Decrypt(string v);
        string GeneratePassword(int len, bool number, bool lower, bool upper, bool symbol);
    }
}
