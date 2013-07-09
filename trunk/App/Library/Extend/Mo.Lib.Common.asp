<%
class MoLibCommon	

	public function ResetImageUri(content)
		ResetImageUri = replace(content,"""" & MO_ROOT & "Images/","""" & Mo.values("System","blog_hostname") & "" & MO_ROOT & "Images/")
		ResetImageUri = replace(ResetImageUri,"""" & MO_ROOT & "?","""" & Mo.values("System","blog_hostname") & "" & MO_ROOT & "?")
	end function
	
	public function IndexRight(content)
		IndexRight = replaceex(content,"\s+","")
		IndexRight = replaceex(IndexRight,"<(.+?)>","")
		IndexRight = left(IndexRight,30)
	end function
	
	public function ActTags(tags,blank)
		if tags="" then exit function
		ActTags = Mo.Static("Tags").GetLinks(tags,blank)
	end function
	public function getCat(catid)
		getCat = Model__("Classes","id").where("ID=" & catid).query().read("Class_Name")
	end function
	public function GetIndexHtml(content)
		if instr(content,"<hr class=""split-pagebreak"" />")>0 then
			GetIndexHtml = mid(content,1,instr(content,"<hr class=""split-pagebreak"" />")-1)
		else
			GetIndexHtml = content
		end if
	end function
end class
%>