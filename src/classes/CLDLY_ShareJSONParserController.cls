public class CLDLY_ShareJSONParserController {
	public String UserIds;
	public String GroupIds;
	public String Object_UserLookUps;
	public static CLDLY_ShareJSONParserController parse(String shareJSON) {
		return (CLDLY_ShareJSONParserController) System.JSON.deserialize(shareJSON, CLDLY_ShareJSONParserController.class);
	}
}