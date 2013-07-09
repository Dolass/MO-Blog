<%
if request.QueryString("test")="json" or request.QueryString("test")="" then
Response.Write("{""QueryString"":""" & request.QueryString & """,""Form"":""" & request.Form & """,""Now"":""" & now() & """}")
else
%><?xml version="1.0" encoding="utf-8"?>
<data>
	<QueryString><%=replace(request.QueryString,"&","&amp;")%></QueryString>
	<Form><%=replace(request.Form,"&","&amp;")%></Form>
</data>
<%end if%>