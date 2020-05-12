<- Kulics.KuKey.Models

-> {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}

#Table("tag")
TagModel : BaseModel \/ $ me {
    #Column("name") #get #set
    Name! : ""

    . Encrypt : (encryptor IEncryptService->v any) {
        <- TagModel{
            Id = Id
            Name = encryptor.Encrypt(Name)
            CreateAt = CreateAt
            UpdateAt = UpdateAt
        }
    }
    . Decrypt : (encryptor IEncryptService->v any, b bool) {
        name, success : encryptor.Decrypt(Name)
        ? success {
            <- TagModel{
                Id = Id
                Name = name
                CreateAt = CreateAt
                UpdateAt = UpdateAt
            }, true
        }
        <- nil, false
    }
}