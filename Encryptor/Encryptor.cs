using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace KuKey.Encryptor
{
    public static class Encryptor
    {
        public static byte[] ToBytes(this string it)
        {
            return Encoding.UTF8.GetBytes(it);
        }

        public static byte[] SubBytes(this byte[] it, int start, int length)
        {
            return it.Skip(start).Take(length).ToArray();
        }

        public static string ToBase64String(this byte[] it)
        {
            return Convert.ToBase64String(it, 0, it.Length);
        }

        public static byte[] ToBytesByBase64(this string it)
        {
            return Convert.FromBase64String(it);
        }

        public static string ToHex(this byte[] it)
        {
            return BitConverter.ToString(it, 0).Replace("-", string.Empty);
        }

        public static string ToUTF8String(this byte[] it)
        {
            return Encoding.UTF8.GetString(it);
        }

        public static string SHA512Hash(string content)
        {
            using var hash = new SHA512Managed();
            var result = hash.ComputeHash(content.ToBytes());
            return result.ToHex();
        }

        public static string AES256Encrypt(string content, string key)
        {
            byte[] hashKey;
            using var sha = new SHA512Managed();
            hashKey = sha.ComputeHash(key.ToBytes());
            var keyBytes = hashKey.SubBytes(0, 32);
            var valueBytes = content.ToBytes();
            var ivBytes = hashKey.SubBytes(32, 16);
            using var aes = new RijndaelManaged()
            {
                IV = ivBytes,
                Key = keyBytes,
                Mode = CipherMode.CBC,
                Padding = PaddingMode.PKCS7
            };
            var cryptoTransform = aes.CreateEncryptor();
            var result = cryptoTransform.TransformFinalBlock(valueBytes, 0, valueBytes.Length);
            return result.ToBase64String();
        }

        public static string? AES256Decrypt(string content, string key)
        {
            byte[] hashKey;
            using (var sha = new SHA512Managed())
            {
                hashKey = sha.ComputeHash(key.ToBytes());
            }
            var keyBytes = hashKey.SubBytes(0, 32);
            var valueBytes = content.ToBytesByBase64();
            var ivBytes = hashKey.SubBytes(32, 16);
            using var aes = new RijndaelManaged()
            {
                IV = ivBytes,
                Key = keyBytes,
                Mode = CipherMode.CBC,
                Padding = PaddingMode.PKCS7
            };
            try
            {
                var cryptoTransform = aes.CreateDecryptor();
                var result = cryptoTransform.TransformFinalBlock(valueBytes, 0, valueBytes.Length);
                return result.ToUTF8String();
            }
            catch (Exception)
            {
                return null;
            }
        }

        public const string Number = "23456789";
        public const string Lowercase = "abcdefghikjmnopqrstuvwxyz";
        public const string Uppercase = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        public const string Symbol = "~!@#$%^&*()_-+={}:;<,>.?/\\";

        public static string GeneratePasswordByPool(int len, string pool)
        {
            var password = "";
            var rand = new Random();
            for (var i = 0; i < len; i += 2)
            {
                password += pool[rand.Next(pool.Length)];
            }
            return password;
        }
    }
}
