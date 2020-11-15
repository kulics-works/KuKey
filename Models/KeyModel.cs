using System.ComponentModel.DataAnnotations.Schema;
using KuKey.Services;

namespace KuKey.Models
{
    [Table("key")]
    public class KeyModel : BaseModel, Model<KeyModel>
    {
        [Column("name")]
        public string Name { get; set; } = "";

        [Column("account")]
        public string Account { get; set; } = "";

        [Column("password")]
        public string Password { get; set; } = "";

        [Column("sub_account")]
        public string SubAccount { get; set; } = "";

        [Column("sub_password")]
        public string SubPassword { get; set; } = "";

        [Column("url")]
        public string URL { get; set; } = "";

        [Column("note")]
        public string Note { get; set; } = "";

        [Column("key_group")]
        public string KeyGroup { get; set; } = "";

        public KeyModel Encrypt(IEncryptService encryptor)
        {
            return new()
            {
                Id = Id,
                Name = encryptor.Encrypt(Name),
                Account = encryptor.Encrypt(Account),
                Password = encryptor.Encrypt(Password),
                SubAccount = encryptor.Encrypt(SubAccount),
                SubPassword = encryptor.Encrypt(SubPassword),
                URL = encryptor.Encrypt(URL),
                Note = encryptor.Encrypt(Note),
                KeyGroup = KeyGroup,
                CreateAt = CreateAt,
                UpdateAt = UpdateAt
            };
        }

        public KeyModel? Decrypt(IEncryptService encryptor)
        {
            var name = encryptor.Decrypt(Name);
            if (name is null)
            {
                return null;
            }
            return new KeyModel()
            {
                Id = Id,
                Name = name,
                Account = encryptor.Decrypt(Account) ?? "",
                Password = encryptor.Decrypt(Password) ?? "",
                SubAccount = encryptor.Decrypt(SubAccount) ?? "",
                SubPassword = encryptor.Decrypt(SubPassword) ?? "",
                URL = encryptor.Decrypt(URL) ?? "",
                Note = encryptor.Decrypt(Note) ?? "",
                KeyGroup = KeyGroup,
                CreateAt = CreateAt,
                UpdateAt = UpdateAt
            };
        }
    }
}
