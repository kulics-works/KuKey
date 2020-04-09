Kulics.KuKey.Services . {
    System
}

IEncryptService : $$ {
    # 加密
    Encrypt (v str -> v str) 
    # 解密
    Decrypt (v str -> v str, b bool)
    # 生成密码
    GeneratePassword (len int, number bool, lower bool, upper bool, symbol bool->v str)
}
