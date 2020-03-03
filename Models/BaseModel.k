KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    KuKey.Services
}

BaseModel : $ (me) {
    <Key, Column("id"), DatabaseGenerated(DatabaseGeneratedOption.Identity), get, set>
    Id! ?str

    encrypt : (->v BaseModel) {
        <- me
    }
    decrypt : (->v BaseModel) {
        <- me
    }

    encrypt_content : (v str->v str) {
        <- DependencyService.[Get MasterPasswordStore]()?.Encrypt(v)
    }
    decrypt_content : (v str->v str) {
        <- DependencyService.[Get MasterPasswordStore]()?.Decrypt(v)
    }
}

# 加密模型
[encrypt_model (T BaseModel)] : (item T -> item T) {
    <- item.encrypt() T!
}
# 解密模型
[decrypt_model (T BaseModel)] : (item T -> item T) {
    <- item.decrypt() T!
}
