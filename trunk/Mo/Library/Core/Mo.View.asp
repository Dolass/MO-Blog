<%
class MoAspEnginer_View
	private mvarDicts, mvarContent,loops,NewHash
	public Property Let Content(byval value)
		mvarContent = value
	end Property
	private sub Class_Initialize()
		loops=";"
	end sub
	
	private sub Class_Terminate()
		
	end sub
	
	public default function V__(byval content)
		content= replace(content,vbcrlf,"--movbcrlf--" & vbcrlf)
		set mvarDicts = server.CreateObject("scripting.dictionary")
		mvarContent = content
		parsePreCombine()
		Mo.TagLib mvarContent
		parseSource()
		getLoops()
		parseVari "#"
		parseVari "@"
		parseLoop()
		parsePage()
		parseForeach()
		parseEmpty()
		parseSwitch()
		parseCompare "lt","<",""
		parseCompare "gt",">",""
		parseCompare "nlt","<","not"
		parseCompare "ngt",">","not"
		parseCompare "eq","=",""
		parseCompare "neq","=","not"
		mvarContent = replace(mvarContent,"</else>","<?MoAsp else MoAsp?>")
		mvarContent = replace(mvarContent,"</switch>","<?MoAsp end select MoAsp?>")
		mvarContent = replace(mvarContent,"<default />","<?MoAsp case else MoAsp?>")
		mvarContent = replaceex(mvarContent,"</(n)?(eq|empty|lt|gt)>","<?MoAsp end if MoAsp?>")
		parseVari ""
		parseAssignName()
		parseMoAsAsp()
		doSomethingToAsp()
		V__ =  mvarContent
	end function
	private function parsePreCombine()
		dim matches,match,value
		set matches = GetMatch(mvarContent,"\{\$\$(.+?)\}")
		for each match in matches
			execute "value=" & match.submatches(0)
			mvarContent = replace(mvarContent,match.value,value)
		next
		set matches = nothing
	end function
	private function doSomethingToAsp()
		if MO_DIRECT_OUTPUT then
			mvarContent = replace(mvarContent,"__Mo__.Echo ","T = T `&&` ")
		else
			mvarContent = "function Temp___()" & vbcrlf & "dim T:T=""""" & vbcrlf & replace(mvarContent,"__Mo__.Echo ","T = T `&&` ") & vbcrlf & "Temp___ = T" & vbcrlf & "end function"
		end if
		mvarContent = replaceex(mvarContent,"\r\nT \= T \`&&` ([^\""](.+?)[^\""])\r\nT \= T \`&&` ([^\""](.+?)[^\""])\r\n",vbcrlf & "T = T `&&` $1 `&&` $3 " & vbcrlf)
		mvarContent = replaceex(mvarContent,"T \= T \`&&` \""(.+)\""\r\nT \= T \`&&` ([^\""](.+?)[^\""])\r\nT \= T `&&` \""","T = T `&&` ""$1"" `&&` $2 `&&` """)
		mvarContent = replaceex(mvarContent,"T \= T \`&&` \""(.+)\""\r\nT \= T \`&&` ([^\""](.+?)[^\""])\r\nT \= T `&&` \""","T = T `&&` ""$1"" `&&` $2 `&&` """)
		mvarContent = replaceex(mvarContent,"T \= T \`&&` \""(.+)\""\r\nT \= T \`&&` ([^\""](.+?)[^\""])\r\nT \= T `&&` \""","T = T `&&` ""$1"" `&&` $2 `&&` """)
		mvarContent = replaceex(mvarContent,"\r\nif (.+?) then\r\nT \= \T `&&` (.+?)\r\nend if\r\n",vbcrlf & "if $1 then T = T `&&` $2" & vbcrlf)
		mvarContent = replaceex(mvarContent,""" `&&` ""","")
		mvarContent = replaceex(mvarContent,"`&&`","&")
		mvarContent = replaceex(mvarContent,"T = T & ""--movbcrlf--""" & vbcrlf,"")
		
		mvarContent = replace(mvarContent,"--movbcrlf--""" & vbcrlf,""" & vbcrlf" & vbcrlf)
		mvarContent = replace(mvarContent,"--movbcrlf--",""" & vbcrlf & """)
		mvarContent = replaceex(mvarContent," & vbcrlf\r\nT \= T & """," & vbcrlf & """)
		if MO_PREETY_HTML then
			mvarContent = replaceex(mvarContent,"(\s*)\"" & vbcrlf & \""(\s*)","")
			mvarContent = replaceex(mvarContent,"\bT \= T & \""(\s+)","T = T & """)
		end if
		if MO_DIRECT_OUTPUT then mvarContent = replace(mvarContent,"T = T & ","Response.Write ")
	end function
	private function parsePage()
		dim matches,match,loopname,vbscript,pageurl,func
		set matches = GetMatch(mvarContent,"\<page for=\""([\w\.]+?)\""( url=\""(.+?)\"")?( function=\""(.+?)\"")?(\s*)/>")
		for each match in matches
			loopname = match.submatches(0)
			pageurl = match.submatches(2)
			func = match.submatches(4)
			if func="" then func = "CreatePageList"
			if instr(loops,";" & loopname & ";")>0 then
				if not MO_COMPILE_STRICT then loopname = "D__" & loopname
				mvarContent = replace(mvarContent,match.value,"<?MoAsp __Mo__.Echo " & func & "(""" & pageurl & """," & loopname &".recordcount," & loopname &".pagesize," & loopname &".currentpage) MoAsp?>")
			else
				mvarContent = replace(mvarContent,match.value,"")
			end if
		next
	end function
	private function getLoops()
		dim matches,match,loopname
		set matches = GetMatch(mvarContent,"\<loop name\=\""([\w\.]+?)\""( eof=\""(.+?)\"")?\>")
		for each match in matches
			loops = loops & match.submatches(0) & ";"
		next
		set matches = nothing
	end function
	private function parseLoop()
		dim matches,match,loopname,vbscript
		set matches = GetMatch(mvarContent,"\<loop name\=\""([\w\.]+?)\""( eof=\""(.+?)\"")?\>")
		for each match in matches
			loopname = match.submatches(0)
			vbscript = "<?MoAsp "
			if not MO_COMPILE_STRICT then vbscript = vbscript & "if Mo.Exists(""" & loopname & """) then" & vbcrlf
			if not MO_COMPILE_STRICT then vbscript = vbscript & "set D__" & loopname & " = Mo.value(""" & loopname & """)" & vbcrlf
			if match.submatches(2)<>"" then
				if not MO_COMPILE_STRICT then 
					vbscript = vbscript & "if D__" & loopname & ".eof() then __Mo__.Echo """ & replace(replace(replace(match.submatches(2),"""",""""""),"&gt;",">"),"&lt;","<") & """" & vbcrlf
				else
					vbscript = vbscript & "if " & loopname & ".eof() then __Mo__.Echo """ & replace(replace(replace(match.submatches(2),"""",""""""),"&gt;",">"),"&lt;","<") & """" & vbcrlf
				end if
			end if
			if not MO_COMPILE_STRICT then 
				vbscript = vbscript & "do while not D__" & loopname & ".eof()" & vbcrlf & "set C__" & loopname & " =  D__" & loopname & ".read() MoAsp?>"
			else
				vbscript = vbscript & "do while not " & loopname & ".eof()" & vbcrlf & "set C__" & loopname & " =  " & loopname & ".read() MoAsp?>"
			end if
			mvarContent = replace(mvarContent,match.value,vbscript)
			dim m_,ms_
			set ms_ = GetMatch(mvarContent,"\{\$" & loopname & "\.(.+?)\}")
			for each m_ in ms_
				dim k,v:k = m_.submatches(0)
				if instr(k,":")<=0 then
					if MO_COMPILE_STRICT then
						mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo C__" & loopname & "." & k & " MoAsp?>")
					else
						mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo C__" & loopname & ".getter__(""" & k & """) MoAsp?>")
					end if
				else
					dim c
					c = mid(k,instr(k,":")+1)
					k = mid(k,1,instr(k,":")-1)
					if MO_COMPILE_STRICT then
						mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo " & replace(parseFormatVari(c),"{{k}}","C__" & loopname & "." & k) & " MoAsp?>")
					else
						mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo " & replace(parseFormatVari(c),"{{k}}","C__" & loopname & ".getter__(""" & k & """)") & " MoAsp?>")
					end if
				end if		
			next
		next
		if not MO_COMPILE_STRICT then 
			mvarContent = replace(mvarContent,"</loop>","<?MoAsp Loop " & vbcrlf & "End If MoAsp?>")	
		else
			mvarContent = replace(mvarContent,"</loop>","<?MoAsp Loop MoAsp?>")	
		end if
	end function
	private function parseForeach()
		dim matches,match,loopname,vbscript,typ,basezero
		set matches = GetMatch(mvarContent,"\<foreach name\=\""([\w\.]+?)\""( type\=\""(.+?)\"")?( basezero\=\""(true)\"")?\>")
		for each match in matches
			dim m_,ms_, k,v,c
			loopname = match.submatches(0)
			typ = match.submatches(2)
			vbscript = "<?MoAsp "
			if not MO_COMPILE_STRICT then vbscript = vbscript & "if Mo.Exists(""" & loopname & """) then" & vbcrlf
			basezero = 0
			if match.submatches(4)="true" then basezero=-1
			if typ="object" then
				if not MO_COMPILE_STRICT then 
					vbscript = vbscript & "K__" & loopname & "=" & basezero & vbcrlf & "for each C__" & loopname & " in Mo.value(""" & loopname & """)" & vbcrlf & "K__" & loopname & "=K__" & loopname & "+1" & vbcrlf & " MoAsp?>" & vbcrlf
				else
					vbscript = vbscript & "K__" & loopname & "=" & basezero & vbcrlf & "for each C__" & loopname & " in " & loopname & vbcrlf & "K__" & loopname & "=K__" & loopname & "+1" & vbcrlf & " MoAsp?>" & vbcrlf
				end if
				mvarContent = replace(mvarContent,match.value,vbscript)
				mvarContent = replace(mvarContent,"{$" & loopname &".Key__}","<?MoAsp __Mo__.Echo K__" & loopname & " MoAsp?>")
				set ms_ = GetMatch(mvarContent,"\{\$" & loopname & "\.(.+?)\}")
				for each m_ in ms_
					k = m_.submatches(0)
					if instr(k,":")<=0 then
						if MO_COMPILE_STRICT then
							mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo C__" & loopname & "." & k & " MoAsp?>")
						else
							mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo C__" & loopname & ".getter__(""" & k & """) MoAsp?>")
						end if
					else
						c = mid(k,instr(k,":")+1)
						k = mid(k,1,instr(k,":")-1)
						if MO_COMPILE_STRICT then
							mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo " & replace(parseFormatVari(c),"{{k}}","C__" & loopname & "." & k) & " MoAsp?>")
						else
							mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo " & replace(parseFormatVari(c),"{{k}}","C__" & loopname & ".getter__(""" & k & """)") & " MoAsp?>")
						end if
					end if		
				next
			else
				if not MO_COMPILE_STRICT then 
					vbscript = vbscript & "K__" & loopname & "=" & basezero & vbcrlf & "for each C__" & loopname & " in Mo.value(""" & loopname & """)" & vbcrlf & "K__" & loopname & "=K__" & loopname & "+1 MoAsp?>"
				else
					vbscript = vbscript & "K__" & loopname & "=" & basezero & vbcrlf & "for each C__" & loopname & " in " & loopname & vbcrlf & "K__" & loopname & "=K__" & loopname & "+1 MoAsp?>"
				end if
				mvarContent = replace(mvarContent,match.value,vbscript)
				mvarContent = replace(mvarContent,"{$" & loopname &".Key__}","<?MoAsp __Mo__.Echo K__" & loopname & " MoAsp?>")
				set ms_ = GetMatch(mvarContent,"\{\$" & loopname & "(\:(.+?))?\}")
				for each m_ in ms_
					k = m_.submatches(1)
					if k="" then
						mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo C__" & loopname & " MoAsp?>")
					else
						mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo " & replace(parseFormatVari(k),"{{k}}","C__" & loopname & "") & " MoAsp?>")
					end if		
				next			
			end if
		next
		if not MO_COMPILE_STRICT then 
			mvarContent = replace(mvarContent,"</foreach>","<?MoAsp Next " & vbcrlf & "End If MoAsp?>")	
		else
			mvarContent = replace(mvarContent,"</foreach>","<?MoAsp Next MoAsp?>")
		end if
	end function	
	private function parseSwitch()
		dim matches,m_
		set matches = GetMatch(mvarContent,"<switch name\=\""((([\w]+?)\.)?(.+?))\"">")
		for each m_ in matches
			mvarContent = replace(mvarContent,m_.value,"<?MoAsp select case " & parseAssign(m_.submatches(0)) & " MoAsp?>")
		next
		parseCase()
	end function
	private function parseCase()
		dim matches,m_,t,quto
		set matches = GetMatch(mvarContent,"<case value=\""(.*?)\""( type\=\""(.+?)\"")? />")
		for each m_ in matches
			quto=""""
			if instr("bool|number|money|date|assign","|" & m_.submatches(2) & "|")>0 then quto=""
			mvarContent = replace(mvarContent,m_.value,"<?MoAsp case " & quto & m_.submatches(0) & quto & " MoAsp?>")
		next
	end function
	
	private function parseCompare(tag,comp,no)
		dim matches,m_,t,quto,g_,v_
		set matches = GetMatch(mvarContent,"<" & tag & " name\=\""((([\w]+?)\.)?(.+?))\"" value=\""(.+?)\""( type\=\""(.+?)\"")?>")
		for each m_ in matches
			quto=""""
			if instr("bool|number|money|date|assign","|" & m_.submatches(6) & "|")>0 then quto=""
			v_ = m_.submatches(4)
			set g_ = getMatch(m_.submatches(4),"\{\$(.+?)\}")
			if g_.count>0 then 
				quto=""
				v_ = "Mo.Value(""" & g_(0).submatches(0) & """)"
			end if
			mvarContent = replace(mvarContent,m_.value,"<?MoAsp if " & no & "(" & parseAssign(m_.submatches(0)) & " " & comp & " " & quto & "" & v_ & "" & quto & ") then MoAsp?>")
		next
	end function
	
	private function parseEmpty()
		dim matches,m_,l,k,v,s
		set matches = GetMatch(mvarContent,"<(n)?empty name\=\""((([\w]+?)\.)?(.+?))\"">")
		for each m_ in matches
			s=""
			if m_.submatches(0)="n" then s=" not"
			mvarContent = replace(mvarContent,m_.value,"<?MoAsp if" & s & " is_empty(" & parseAssign(m_.submatches(1)) & ") then MoAsp?>")
		next
	end function
	
	private function parseAssignName()
		dim matches,m_
		set matches = GetMatch(mvarContent,"<assign name\=\""(\w+?)\"" value=\""(.+?)\"" />")
		for each m_ in matches
			mvarContent = replace(mvarContent,m_.value,"<?MoAsp Mo.Assign """ & m_.submatches(0) & """,""" & replace(m_.submatches(1),"""","""""") & """ MoAsp?>")
		next
	end function
	
	private function parseSource()
		dim matches,m_,id,cs,ext
		set matches = GetMatch(mvarContent,"<(js|css|load) (file|href|src)\=\""(.+?)\""( id\=\""(.+?)\"")?( charset\=\""(.+?)\"")? />")
		for each m_ in matches
			id=""
			cs=""
			if instrrev(m_.submatches(2),".")>0 then ext = lcase(mid(m_.submatches(2),instrrev(m_.submatches(2),".")))
			if m_.submatches(4)<>"" then id=" id=""" & m_.submatches(4) & """"
			if m_.submatches(6)<>"" then cs=" charset=""" & m_.submatches(6) & """"
			if m_.submatches(0)="js" or ext=".js" then
				mvarContent = replace(mvarContent,m_.value,"<script type=""text/javascript"" src=""" & m_.submatches(2) & """" & id & cs & "></script>")
			else
				mvarContent = replace(mvarContent,m_.value,"<link rel=""stylesheet"" type=""text/css"" href=""" & m_.submatches(2) & """" & id & cs & " />")
			end if
		next
	end function
		
	private function parseVari(chars)
		dim matches,m_
		set matches = GetMatch(mvarContent,"\{\$" & chars & "(.+?)\}")
		for each m_ in matches
			if chars="#" then
				mvarContent = replace(mvarContent,m_.value,""" & " & parseAssign(m_.submatches(0)) & " & """)
			elseif chars="@" then
				mvarContent = replace(mvarContent,m_.value,parseAssign(m_.submatches(0)))
			else
				mvarContent = replace(mvarContent,m_.value,"<?MoAsp __Mo__.Echo " & parseAssign(m_.submatches(0)) & " MoAsp?>")	
			end if
		next
	end function
	
	private function parseAssign(byval key)
		dim k,v,m_,ms_,l,c,cf,kn:k=key
		set ms_ = Getmatch(key,"^([\w\.]+?)(\:(.+?))?$")
		if ms_.count>0 then
			l = ms_(0).submatches(0)
			c = ms_(0).submatches(2)
			if c="" then
				if instr(l,".")<=0 then 
					if MO_COMPILE_STRICT then parseAssign = l else parseAssign = "Mo.value(""" & l & """)"
				elseif lcase(left(l,2))="c." or lcase(left(l,2))="g." then
					parseAssign = mid(l,3)
				elseif lcase(left(l,11))="mo.session." then
					parseAssign = "F.session(""" & mid(l,12) & """)"
				elseif lcase(left(l,7))="mo.get." then
					parseAssign = "F.get(""" & mid(l,8) & """)"
				elseif lcase(left(l,8))="mo.post." then
					parseAssign = "F.post(""" & mid(l,9) & """)"
				elseif lcase(left(l,10))="mo.cookie." then
					parseAssign = "F.cookie(""" & mid(l,11) & """)"
				elseif lcase(left(l,10))="mo.server." then
					parseAssign = "F.server(""" & mid(l,11) & """)"
				elseif lcase(left(l,5))="mo.c." then
					cf = mid(l,6)
					if instr(cf,".")>0 then 
						parseAssign = "Mo.C(""" & mid(cf,1,instr(cf,".")-1) & """)." & mid(cf,instr(cf,".")+1)
					end if
				else
					k = mid(l,instr(l,".")+1)
					l = left(l,instr(l,".")-1)
					if instr(loops,";" & l & ";")>0 then
						if MO_COMPILE_STRICT then parseAssign = "C__" & l & "." & k else parseAssign = "C__" & l & ".getter__(""" & k & """)"
					else
						if MO_COMPILE_STRICT then parseAssign = l & "." & k else parseAssign = "Mo.Values(""" & l & """,""" & k & """)"
					end if
				end if
			else
				if instr(l,".")<=0 then 
					if MO_COMPILE_STRICT then parseAssign = replace(parseFormatVari(c),"{{k}}",l) else parseAssign = replace(parseFormatVari(c),"{{k}}","Mo.value(""" & l & """)")
				elseif lcase(left(l,2))="c." or lcase(left(l,2))="g." then
					parseAssign = replace(parseFormatVari(c),"{{k}}",mid(l,3))
				elseif lcase(left(l,11))="mo.session." then
					parseAssign = replace(parseFormatVari(c),"{{k}}","F.session(""" & mid(l,12) & """)")
				elseif lcase(left(l,7))="mo.get." then
					parseAssign = replace(parseFormatVari(c),"{{k}}","F.get(""" & mid(l,8) & """)")
				elseif lcase(left(l,8))="mo.post." then
					parseAssign = replace(parseFormatVari(c),"{{k}}","F.post(""" & mid(l,9) & """)")
				elseif lcase(left(l,10))="mo.cookie." then
					parseAssign = replace(parseFormatVari(c),"{{k}}","F.cookie(""" & mid(l,11) & """)")
				elseif lcase(left(l,10))="mo.server." then
					parseAssign = replace(parseFormatVari(c),"{{k}}","F.server(""" & mid(l,11) & """)")
				elseif lcase(left(l,5))="mo.c." then
					cf = mid(l,6)
					if instr(cf,".")>0 then 
						parseAssign = replace(parseFormatVari(c),"{{k}}","Mo.C(""" & mid(cf,1,instr(cf,".")-1) & """)." & mid(cf,instr(cf,".")+1))
					end if
				else
					k = mid(l,instr(l,".")+1)
					l = left(l,instr(l,".")-1)
					if instr(loops,";" & l & ";")>0 then
						if MO_COMPILE_STRICT then parseAssign = replace(parseFormatVari(c),"{{k}}","C__" & l & "." & k) else parseAssign = replace(parseFormatVari(c),"{{k}}","C__" & l & ".getter__(""" & k & """)")
					else
						if MO_COMPILE_STRICT then parseAssign = replace(parseFormatVari(c),"{{k}}",l & "." & k) else parseAssign = replace(parseFormatVari(c),"{{k}}","Mo.Values(""" & l & """,""" & k & """)")
					end if
				end if
			end if
		end if
	end function
		
	private function parseFormatVari(format)
		parseFormatVari = ""
		if format="" then exit function
		dim func,vars,ret
		func = format
		if instr(func,"=")>0 then 
			vars ="," & mid(func,instr(func,"=")+1)
			func = mid(func,1,instr(func,"=")-1)
		end if
		
		if left(lcase(func),3)="mo." and ubound(split(func,"."))=2 then
			func = "Mo.Static(""" & split(func,".")(1) & """)." & split(func,".")(2)
		elseif left(lcase(func),2)="f." and len(func)>2 then
			func = "F." & mid(func,3)
		end if
		ret=func & "({{k}}" & vars & ")"
		parseFormatVari = ret
	end function
	private sub parseMoAsAsp()
		dim m_,ms_,id
		set ms_ = getmatch(mvarContent,"<\?MoAsp([\s\S]+?)MoAsp\?>")
		for each m_ in ms_
			id = getRndid()
			mvarDicts(id) = m_.value
			mvarContent = replace(mvarContent,m_.value,vbcrlf & "<?MoAsp" & id & "MoAsp?>" & vbcrlf)
		next
		mvarContent = replaceex(mvarContent,"(^(\s+)|(\s+)$)","")
		mvarContent = replaceex(mvarContent,"(\r\n){2,}",vbcrlf)
		mvarContent = replace(mvarContent,"""","""""")
		mvarContent = replaceex(mvarContent,"(^|\r\n)","$1__Mo__.Echo """)
		mvarContent = replaceex(mvarContent,"($|\r\n)","""$1" )
		set ms_ = getmatch(mvarContent,"__Mo__\.Echo ""<\?MoAsp([\w]+?)MoAsp\?>""")
		for each m_ in ms_
			id = m_.submatches(0)
			mvarContent = replace(mvarContent,m_.value,mvarDicts(id))
		next
		mvarContent = replace(mvarContent,"<?MoAsp ","")
		mvarContent = replace(mvarContent," MoAsp?>","")
		'mvarContent = replace(mvarContent,"""" & vbcrlf & "__Mo__.Echo ""","")
		'mvarContent = replace(mvarContent,"""" & vbcrlf & "__Mo__.Echo ",""" & ")
	end sub
	
	private function getRndid()
		dim rid
		rid = RndStr1(10)
		do while mvarDicts.exists(rid)
			rid = RndStr1(10)
		loop
		getRndid = rid
	end function
end class
%>