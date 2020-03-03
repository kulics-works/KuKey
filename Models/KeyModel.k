KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema
}

<Table("key")>
KeyModel : BaseModel & $(me) {
    <Column("name"), get, set>
    Name! str : ""
    <Column("account"), get, set>
    Account! str : ""
    <Column("password"), get, set>
    Password! str : ""
    <Column("url"), get, set>
    URL! str : ""
    <Column("note"), get, set>
    Note! str : ""
    <Column("level"), get, set>
    Level! int : 0
    <Column("time"), get, set>
    Time! int : 0
    <Column("hash"), get, set>
    Hash! str : ""

    . encrypt : (->v BaseModel) {
        <- KeyModel{
            Id = me.Id
            Name = encrypt_content(me.Name)
            Account = encrypt_content(me.Account)
            Password = encrypt_content(me.Password)
            URL = encrypt_content(me.URL)
            Note = encrypt_content(me.Note)
            Level = me.Level
            Time = me.Time
            Hash = me.Hash
        }
    }
    . decrypt : (->v BaseModel) {
        <- KeyModel{
            Id = me.Id
            Name = decrypt_content(me.Name)
            Account = decrypt_content(me.Account)
            Password = decrypt_content(me.Password)
            URL = decrypt_content(me.URL)
            Note = decrypt_content(me.Note)
            Level = me.Level
            Time = me.Time
            Hash = me.Hash
        }
    }
}
