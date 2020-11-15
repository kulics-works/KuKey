using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using KuKey.Services;

namespace KuKey.Models
{
    public class BaseModel
    {
        [Key, Column("id")]
        public string Id { get; set; } = "";

        [Column("create_at")]
        public int CreateAt { get; set; }

        [Column("update_at")]
        public int UpdateAt { get; set; }
    }

    public interface Model<T>
    {
        string Id { get; set; }
        int CreateAt { get; set; }
        int UpdateAt { get; set; }
        T Encrypt(IEncryptService encryptor);
        T? Decrypt(IEncryptService encryptor);
    }
}
