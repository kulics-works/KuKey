using static KuKey.Encryptor.Encryptor;

namespace KuKey.Services
{
    public class AESEncryptService : IEncryptService
    {
        readonly string MasterPassword;

        public AESEncryptService(string password)
        {
            MasterPassword = password;
        }

        public string Encrypt(string v)
        {
            if (v.Length > 0)
            {
                v = AES256Encrypt(v, MasterPassword);
            }
            return v;
        }

        public string? Decrypt(string v)
        {
            if (v.Length > 0)
            {
                return AES256Decrypt(v, MasterPassword);
            }
            return v;
        }

        public virtual string GeneratePassword(int len, bool number, bool lower, bool upper, bool symbol)
        {
            var pool = "";
            var count = 0;
            if (number)
            {
                pool += Number;
                count += 1;
            }
            if (lower)
            {
                pool += Lowercase;
                count += 1;
            }
            if (upper)
            {
                pool += Uppercase;
                count += 1;
            }
            if (symbol)
            {
                pool += Symbol;
                count += 1;
            }
            switch (count)
            {
                case 1:
                    if (number)
                    {
                        pool += "01";
                    }
                    else if (lower)
                    {
                        pool += "l";
                    }
                    else if (upper)
                    {
                        pool += "IO";
                    }
                    else if (symbol)
                    {
                        pool += "|";
                    }
                    break;
                case 2:
                    if (number && symbol)
                    {
                        pool += "01";
                    }
                    else if (lower && upper)
                    {
                        pool += "O";
                    }
                    else if (symbol && upper)
                    {
                        pool += "O";
                    }
                    else if (number && lower)
                    {
                        pool += "0";
                    }
                    break;
                case 3:
                    if (number && !upper)
                    {
                        pool += "0";
                    }
                    else if (!number && upper)
                    {
                        pool += "O";
                    }
                    break;
            }
            if (pool == "")
            {
                pool = "01";
            }
            return GeneratePasswordByPool(len, pool);
        }
    }
}
