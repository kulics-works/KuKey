using System.ComponentModel.DataAnnotations.Schema;
using KuKey.Services;

namespace KuKey.Models
{
    [Table("key_group")]
    public class KeyGroupModel : BaseModel, Model<KeyGroupModel>
    {
        [Column("name")]
        public string Name { get; set; } = "";

        public KeyGroupModel Encrypt(IEncryptService encryptor)
        {
            return new()
            {
                Id = Id,
                Name = encryptor.Encrypt(Name),
                CreateAt = CreateAt,
                UpdateAt = UpdateAt
            };
        }

        public KeyGroupModel? Decrypt(IEncryptService encryptor)
        {
            var name = encryptor.Decrypt(Name);
            if (name is null)
            {
                return null;
            }
            return new KeyGroupModel()
            {
                Id = Id,
                Name = name,
                CreateAt = CreateAt,
                UpdateAt = UpdateAt
            };
        }
    }
}
