<%
class MoLibTags
	public sub Class_Initialize()
	end sub
	
	public sub Class_Terminate()
	end sub
	
	public default sub A__(byval str)
		str = trim(str)
		str = ReplaceEx(str,"(\s+)",",")
		dim taglist,i,tag
		taglist = Split(str,",")
		if ubound(taglist)<0 then exit sub
		for i=0 to ubound(taglist)
			tag = F.safe(trim(taglist(i)))
			if Model__("Tags","id").where("name='" & tag & "'").query().fetch().eof() then
				Model__("Tags","id").insert "name",tag,"tag",getTag(tag),"counts",1
			else
				Model__("Tags","id").where("name='" & tag & "'").update "counts",Model__("Diary","id").where("','+Tags+',' like '%," & tag & ",%'").count("id")
			end if
		next
	end sub
	
	public function GetLinks(byval str,byval blank)
		str = F.safe(trim(str))
		str = ReplaceEx(str,"(\s+)",",")
		if blank=true then blank=" target=""_blank""" else blank=""
		if str="" then exit function
		dim taglist,i,tag,D_,T_,ret
		taglist = replace(str,",","','")
		ret = ""
		set D_ = Model__("Tags","id").where("name in ('" & taglist & "')").query().fetch()
		do while not D_.eof()
			set T_ = D_.Read()
			ret = ret & "<a href=""" & MO_ROOT & Mo.Static("TagLib:Tag.Rewrite").parseURI("?m=home&a=tag&keyword=" & T_.getter__("tag")) & """>" & T_.getter__("name") & "</a> "
		loop
		GetLinks = trim(ret)
	end function
	public function GetStaticLinks(byval str)
		str = F.safe(trim(str))
		str = ReplaceEx(str,"(\s+)",",")
		if str="" then exit function
		dim taglist,i,tag,D_,T_,ret
		taglist = replace(str,",","','")
		ret = ""
		set D_ = Model__("Tags","id").where("name in ('" & taglist & "')").query().fetch()
		do while not D_.eof()
			set T_ = D_.Read()
			ret = ret & "<a href=""" & MO_ROOT & "tag/" & T_.getter__("tag") & ".html"">" & T_.getter__("name") & "</a> "
		loop
		GetStaticLinks = trim(ret)
	end function
	
	public sub ReFreashTags(byval str)
		str = trim(str)
		str = ReplaceEx(str,"(\s+)",",")
		dim taglist,i,tag
		taglist = Split(str,",")
		if ubound(taglist)<0 then exit sub
		for i=0 to ubound(taglist)
			tag = F.safe(trim(taglist(i)))
			Model__("Tags","id").where("name='" & tag & "'").update "counts",Model__("Diary","id").where("','+Tags+',' like '%," & tag & ",%'").count("id")
		next	
	end sub
	private function getTag(byval src)
		if src="" then exit function
		dim ret,i,c
		ret=""
		for i=1 to len(src)
			c = (mid(src,i,1))
			if ascw(c)>256 or ascw(c)<0 then
				ret = ret & hex(ascw(c))
			else
				ret = ret & c
			end if
		next
		getTag = ret
	end function
end class
%>