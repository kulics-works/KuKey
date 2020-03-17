Kulics.KuKey.Services . {
    System
}

IEncryptService : $$ {
    # 加密
    Encrypt (v str -> v str) 
    # 解密
    Decrypt (v str -> v str)
    # 生成密码
    GeneratePassword (lv PasswordLevel, len int->v str)
}

PasswordLevel : .. {
    Number      # 只含数字
    Normal      # 数字+小写字母
    Complex     # 数字+大小写字母
    Mix         # 数字+大小写字母+符号
}
