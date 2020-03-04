KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    KuKey.Services
}

<Table("key")>
KeyModel : BaseModel & $(me) {
    <Column("name"); get; set>
    Name! str : ""
    <Column("account"); get; set>
    Account! str : ""
    <Column("password"); get; set>
    Password! str : ""
    <Column("url"); get; set>
    URL! str : ""
    <Column("note"); get; set>
    Note! str : ""
    <Column("level"); get; set>
    Level! int : 0
    <Column("time"); get; set>
    Time! int : 0
    <Column("hash"); get; set>
    Hash! str : ""

    . Encrypt : (encryptor IEncryptService->v any) {
        <- KeyModel{
            Id = Id
            Name = encryptor.Encrypt(Name)
            Account = encryptor.Encrypt(Account)
            Password = encryptor.Encrypt(Password)
            URL = encryptor.Encrypt(URL)
            Note = encryptor.Encrypt(Note)
            Level = Level
            Time = Time
            Hash = Hash
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
            Level = Level
            Time = Time
            Hash = Hash
        }
    }
}
