KuKey.Services . {
    KuKey.Encryptor
}
# 加密服务
EncryptService : $ {
    <get, set>
    MasterPassword! str     # 主密码
    # 加密
    Encrypt : (v str -> v str) {
        <- Encryptor_static.Encrypt(v, MasterPassword)
    }
    # 解密
    Decrypt : (v str -> v str) {
        <- Encryptor_static.Decrypt(v, MasterPassword)
    }
    # 散列
    Hash : (v str -> v str) {
        <- Encryptor_static.Hash(v)
    }
}
