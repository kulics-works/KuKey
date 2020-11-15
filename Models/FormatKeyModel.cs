using Newtonsoft.Json;

namespace KuKey.Models
{
    public class FormatKeyModel
    {
        [JsonProperty("name")]
        public string Name { get; set; } = "";

        [JsonProperty("account")]
        public string Account { get; set; } = "";

        [JsonProperty("password")]
        public string Password { get; set; } = "";

        [JsonProperty("password2")]
        public string Password2 { get; set; } = "";

        [JsonProperty("url")]
        public string URL { get; set; } = "";

        [JsonProperty("note")]
        public string Note { get; set; } = "";

        public KeyModel ToKeyModel()
        {
            return new KeyModel()
            {
                Name = Name,
                Account = Account,
                Password = Password,
                SubPassword = Password2,
                URL = URL,
                Note = Note
            };
        }

        public FormatKeyModel FromKeyModel(KeyModel v)
        {
            Name = v.Name;
            Account = v.Account;
            Password = v.Password;
            Password2 = v.SubPassword;
            URL = v.URL;
            if (v.SubAccount.Length > 0)
            {
                Note = v.SubAccount + "\n";
            }
            Note += v.Note;
            return this;
        }
    }
}
