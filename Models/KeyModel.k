Kulics.KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}

<Table("key")>
KeyModel : BaseModel & $(me) {
    <Column("name"); get; set>
    Name! : ""
    <Column("account"); get; set>
    Account! : ""
    <Column("password"); get; set>
    Password! : ""
    <Column("url"); get; set>
    URL! : ""
    <Column("note"); get; set>
    Note! : ""
    <Column("version"); get; set>
    Version! : 0

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
    . Decrypt : (encryptor IEncryptService->v any, b bool) {
        name, success : encryptor.Decrypt(Name)
        ? success {
            <- KeyModel{
                Id = Id
                Name = name
                Account = encryptor.Decrypt(Account).v
                Password = encryptor.Decrypt(Password).v
                URL = encryptor.Decrypt(URL).v
                Note = encryptor.Decrypt(Note).v
                Version = Version
                CreateAt = CreateAt
                UpdateAt = UpdateAt
            }, true
        }
        <- nil, false
    }
}
