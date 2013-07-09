<%
class ActionEmpty
	private sub Class_Initialize()
		MO_TEMPLATE_NAME = Model__("System","id").where("id=1").query().assign("System",true).read("blog_template")
		if F.get.safe("view")="yes" then MO_TEMPLATE_NAME = F.get.safe("name")
		if MO_TEMPLATE_NAME="" then MO_TEMPLATE_NAME="default"
		
		if Mo.Values("System","blog_state_closed") = "yes" then
			Response.Status = "404 Not Found"
			F.exit Mo.Values("System","blog_state_closed_reason")
		end if
		Model__("Tags","id").select("top 20 *").orderby("counts desc").query().assign "TagsCloud"
		Model__("Classes","id").select("*,(select count(id) from Mo_Diary Where ClassID=Mo_Classes.id) as counts").where("Class_Type=28").orderby("Class_Order desc").query().assign "cats"
		Model__("Links","id").where("ischecked=1").select("top 20 title,url,author").orderby("link_order desc").query().assign "Links"
		Model__("Guestbook","id").select("top 10 id,pid as article_id,content,name").where("forarticle=1 and isreplay=0 and secret='no'").orderby("id desc").query().assign "Comments"
		Model__("Guestbook","id").select("top 10 id,pid,Content,name").where("forarticle=0 and isreplay=0 and secret='no'").orderby("id desc").query().assign "Guests"
	end sub
	
	private sub Class_Terminate()
	end sub
	
	public sub [empty](action)
		Response.Status = "404 Not Found"
		Mo.Assign "action",Mo.Action
		Mo.Assign "method",Mo.Method
		Mo.display "Home:Error"
	end sub	
end class
%>