<- Kulics.KuKey.Models

-> {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema
    Newtonsoft.Json

    Kulics.KuKey.Services
}

FormatKeyModel : $ me {
    #get #set #JsonProperty("name")
    Name! : ""
    #get #set #JsonProperty("account")
    Account! : ""
    #get #set #JsonProperty("password")
    Password! : ""
    #get #set #JsonProperty("password2")
    Password2! : ""
    #get #set #JsonProperty("url")
    URL! : ""
    #get #set #JsonProperty("note")
    Note! : ""

    ToKeyModel : (->v KeyModel) {
        <- KeyModel{
            Name = Name
            Account = Account
            Password = Password
            SubPassword = Password2
            URL = URL
            Note = Note
        }
    }

    FromKeyModel : (v KeyModel->v FormatKeyModel) {
        Name = v.Name
        Account = v.Account
        Password = v.Password
        Password2 = v.SubPassword
        URL = v.URL
        ? v.SubAccount.Length > 0 {
            Note = v.SubAccount + "\n"
        }
        Note += v.Note
        <- me
    }
}
