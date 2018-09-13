public with sharing class EmailJSON {
    public String Email;	//maheshvasamsetty@gmail.com,mahesh.vasamsetty@diligentforcelabs.com
    public string Agreement_User_Lookup_Fields;
	//public String Users;	//Cloudely Admin,Sateesh U
	//public String Queues;	//Contract Committee
	public static EmailJSON parse(String json){
		return (EmailJSON) System.JSON.deserialize(json, EmailJSON.class);
	}
}