<!--#include file="Mo/Config/Config.asp"-->
<!--#include file="Mo/Library/Core/Mo.Core.asp"-->
<%
MO_APP_NAME = "App"
MO_ROOT = "/"
MO_CORE = "/Mo/"
MO_APP = "/App/"
Dim Mo : Set Mo = New MoAspEnginer : Mo.Run() : Set Mo = Nothing
%>