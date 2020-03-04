Kulics.KuKey.Services . {
    System
}

IEncryptService : $$ {
    # 加密
    Encrypt (v str -> v str) 
    # 解密
    Decrypt (v str -> v str)
}
