public class Cldy_LandingClass{
    public string LogInUserName {get;set;}
    public Cldy_LandingClass(){
        LogInUserName = [select Id, Name from User where Id=:UserInfo.getUserId()].Name;
    }
}