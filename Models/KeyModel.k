Kulics.KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}

<Table("key")>
KeyModel : BaseModel & $(me) {
    <Column("name"); get; set>
    Name! str
    <Column("account"); get; set>
    Account! str
    <Column("password"); get; set>
    Password! str
    <Column("url"); get; set>
    URL! str
    <Column("note"); get; set>
    Note! str
    <Column("level"); get; set>
    Version! int

    . Encrypt : (encryptor IEncryptService->v any) {
        <- KeyModel{
            Id = Id
            Name = encryptor.Encrypt(Name)
            Account = encryptor.Encrypt(Account)
            Password = encryptor.Encrypt(Password)
            URL = encryptor.Encrypt(URL)
            Note = encryptor.Encrypt(Note)
            Version = Version
            CreateAt = CreateAt
            UpdateAt = UpdateAt
        }
    }
    . Decrypt : (encryptor IEncryptService->v any) {
        <- KeyModel{
            Id = Id
            Name = encryptor.Decrypt(Name)
            Account = encryptor.Decrypt(Account)
            Password = encryptor.Decrypt(Password)
            URL = encryptor.Decrypt(URL)
            Note = encryptor.Decrypt(Note)
            Version = Version
            CreateAt = CreateAt
            UpdateAt = UpdateAt
        }
    }
}
