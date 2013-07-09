<%
class MoPreDefault
	public default sub A__(m,a)
		MO_TEMPLATE_NAME = Model__("System","id").where("id=1").query().assign("System",true).read("blog_template")
		if F.get.safe("view")="yes" then MO_TEMPLATE_NAME = F.get.safe("name")
		if MO_TEMPLATE_NAME="" then MO_TEMPLATE_NAME="default"
	end sub
end class
%>