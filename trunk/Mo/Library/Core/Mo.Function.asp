<%
Function Md5(byval Src)
	Md5 = myMD5.md5(Src)
End function
Function defined(var)
	defined = (vartype(var)<>0)
End Function

Function is_empty(var)
	is_empty = false
	if not isobject(var) then
		if not defined(var) then
			is_empty=true
		elseif isempty(var) then
			is_empty=true
		elseif isnull(var) then
			is_empty=true
		elseif var="" then
			is_empty=true
		end if
	else
		if var is nothing then is_empty=true
	end if
End Function

public sub debug(str)
	Response.Write str
	Response.End()
end sub

Function Rnd_(strSeed,intLength)
    Dim seedLength, pos, Strs, i
    seedLength = Len(strSeed)
    Strs = ""
    For i = 1 To intLength
		randomize timer*1000
        Strs = Strs & Mid(strSeed, Int(seedLength * Rnd) + 1, 1)
    Next
    Rnd_ = Strs
end function
'生成随机字符串
Function RndUCase(intLength)
    RndUCase = Rnd_("IJKLMNOPQRSTUVWXYZABCDEFGH",intLength)
End Function

'生成随机字符串
Function RndLCase(intLength)
    RndLCase = Rnd_("abcdefghijklmnopqrstuvwxyz",intLength)
End Function

'生成随机字符串
Function RndStr(intLength)
    RndStr = Rnd_("abcdefghiIJKLMNOPQRSTUVWXYZjklmnopqrstuvwxyzABCDEFGH",intLength)
End Function

'生成随机字符串
Function RndNumber(intLength)
    RndNumber = Rnd_("12345678906789012678901234534567890126789012345345",intLength)
End Function

'生成随机字符串
Function RndStr1(intLength)
    RndStr1 = Rnd_("abcdefghiIJKLMNOPQRSTUVWXYZjklmnopqrstuvwxyzABCDEFGH12345678906789012678901234534567890126789012345345",intLength)
End Function

Function RegTest(Str,RegStr)
	if isnull(Str) then Str=""
	Dim Reg, Mag
	Set Reg = New RegExp
	With Reg
		.IgnoreCase = True
		.Global = True
		.Pattern = RegStr
		RegTest = .test((str))
	End With
	Set Reg = nothing
End Function

Function ReplaceEx(sourcestr, regString, str)
    dim re
	Set re = new RegExp
	re.IgnoreCase = true
	re.Global = True
	re.pattern = "" & regString & ""
	str = re.replace(sourcestr, str)
    set re = Nothing
    ReplaceEx = str
End Function

Function GetMatch(ByVal Str, ByVal Rex)
	Dim Reg
	Set Reg = New RegExp
	With Reg
		.IgnoreCase = True
		.Global = True
		.Pattern = Rex
		Set GetMatch = .Execute((str))
	End With
	Set Reg = nothing
End Function

'public function LoadAction(filename,byref ModelClass,m,charset)
'	if not MO_DEBUG then on error resume next
'	err.clear
'	execute LoadAsp(filename,charset)
'	if err then
'		LoadAction = false
'	else
'		LoadAction = true
'		execute "Set ModelClass = New Action" & m
'	end if
'end function
public function LoadAsp(filename,charset)
	dim ret
	ret = LoadFile(filename,charset)
	ret = replaceex(ret,"(^(\s+)|(\s+)$)","")
	ret = trim(ret)
	if left(ret,2)="<%" then ret = mid(ret,3)
	if right(ret,2)=replace("% >"," ","") then ret = left(ret,len(ret)-2)
	LoadAsp = ret
end function

public function LoadFile(path,charset)
	if not F.fso.FileExists(path) then
		LoadFile = ""
		exit function
	end if
	dim stream
	set stream = F.stream()
	stream.mode = 3
	stream.type=2
	stream.charset=charset
	stream.open
	stream.loadfromfile path
	LoadFile = stream.readtext()
	stream.close
	set stream = nothing
end function

public function SaveFile(path,content,charset)
	dim stream
	set stream = F.stream()
	stream.mode = 3
	stream.type=2
	stream.charset=charset
	stream.open
	stream.writetext(content)
	stream.savetofile path,2
	stream.close
	set stream = nothing
end function

public function CreatePageList(Byval URL,ByVal RecordCount, ByVal PageSize, ByVal CurrentPage)
	Dim PageCount ,PageStr, I
	if URL="" then
		URL="?" & replaceEx(request.QueryString & "&page={#page}","(\&)?page\=(\d+)","")
		URL = replace(URL,"?&","?")
	end if
	CurrentPage = int(CurrentPage)
	RecordCount = int(RecordCount)
	PageSize = int(PageSize)
	If RecordCount Mod PageSize =0 Then
		Pagecount = RecordCount / PageSize
	Else
		Pagecount = Int(RecordCount / PageSize) + 1
	End If
	if Pagecount<=1 then exit function
	PageStr = "共[" & RecordCount & "]条记录 <a>[" & PageSize & "]</a>条/页 当前[" & CurrentPage & "/" & PageCount & "]页&nbsp; "
	If CurrentPage = 1 Or PageCount = 0 Then
		PageStr = PageStr & "首页&nbsp;"
		PageStr = PageStr & "上页&nbsp;"
	Else
		PageStr = PageStr & "<a href=""" & Replace(URL, "{#page}", 1) & """>首页</a>&nbsp;"
		PageStr = PageStr & "<a href=""" & Replace(URL, "{#page}", CurrentPage-1) & """>上页</a>&nbsp;"
	End If
	If CurrentPage = Pagecount  Or PageCount = 0 Then
		PageStr = PageStr & "下页&nbsp;"
		PageStr = PageStr & "尾页&nbsp; "
	Else
		PageStr = PageStr & "<a href=""" & Replace(URL, "{#page}", CurrentPage + 1) & """>下页</a>&nbsp;"
		PageStr = PageStr & "<a href=""" & Replace(URL, "{#page}", Pagecount) & """>尾页</a>&nbsp; "
	End If
	CreatePageList = PageStr
end function

function FormatDate(sDateTime, sReallyDo)
    if not IsDate(sDateTime) Then sDateTime = Now()
    sDateTime = CDate(sDateTime)
    select case UCase(sReallyDo & "")
        case "0", "1", "2", "3", "4"
            FormatDate = FormatDateTime(sDateTime, sReallyDo)
        case "00"
            FormatDate = FormatDate(sDateTime, "YYYY-MM-DD hh:mm:ss")
        case "01"
            FormatDate = FormatDate(sDateTime, "YYYY年MM月DD日")
        case "02"
            FormatDate = FormatDate(sDateTime, "YYYY-MM-DD")
        case "03"
            FormatDate = FormatDate(sDateTime, "hh:mm:ss")
        case "04"
            FormatDate = FormatDate(sDateTime, "hh:mm")
        case else
            FormatDate = sReallyDo
            FormatDate = Replace(FormatDate, "YYYY", Year(sDateTime))
            FormatDate = Replace(FormatDate, "DD", Right("0" & Day(sDateTime), 2))
            FormatDate = Replace(FormatDate, "hh", Right("0" & Hour(sDateTime), 2))
            FormatDate = Replace(FormatDate, "mm", Right("0" & Minute(sDateTime), 2))
            FormatDate = Replace(FormatDate, "ss", Right("0" & Second(sDateTime), 2))
            FormatDate = Replace(FormatDate, "YY", Right(Year(sDateTime), 2))
            FormatDate = Replace(FormatDate, "D", Day(sDateTime))
            FormatDate = Replace(FormatDate, "h", Hour(sDateTime))
            FormatDate = Replace(FormatDate, "m", Minute(sDateTime))
            FormatDate = Replace(FormatDate, "s", Second(sDateTime))
			FormatDate = Replace(FormatDate, "W", WeekdayName(Weekday(sDateTime), False))
			FormatDate = Replace(FormatDate, "w", WeekdayName(Weekday(sDateTime), True))
			FormatDate = Replace(FormatDate, "MM", Right("0" & Month(sDateTime), 2))
			FormatDate = Replace(FormatDate, "M", Month(sDateTime))
    end select
end function

function UnShift(Byref Ary,item)
	redim preserve Ary(ubound(Ary)+1) 
	dim i
	for i=ubound(Ary) to 1 step -1
		if typename(Ary(i-1))="JScriptTypeInfo" then
			Set Ary(i) = Ary(i-1)
		else
			Ary(i) = Ary(i-1)
		end if
	next
	if typename(item)="JScriptTypeInfo" then
		set Ary(0) = item
	else
		Ary(0) = item
	end if
end function
function Push(Byref Ary,item)
	redim preserve Ary(ubound(Ary)+1) 
	if typename(item)="JScriptTypeInfo" then
		set Ary(ubound(Ary)) = item
	else
		Ary(ubound(Ary)) = item
	end if
end function

function Pop(Byref Ary)
	redim preserve Ary(ubound(Ary)-1) 
end function

function UnPop(Byref Ary)
	dim i
	for i=0 to ubound(Ary)-1
		if typename(Ary(i+1))="JScriptTypeInfo" then
			Set Ary(i) = Ary(i+1)
		else
			Ary(i) = Ary(i+1)
		end if
	next
	redim preserve Ary(ubound(Ary)-1) 
end function
function Join(Byref Ary,byval spli)
	dim ret
	for i=0 to ubound(Ary)
		ret = ret & Ary(i) & spli
	next
	Join = left(ret,len(ret)-len(spli))
end function
function RightCopy(Ary,Ary2)
	if ubound(Ary2)>=ubound(Ary) then
		RightCopy = Ary2
	else
		dim i,j
		j = ubound(Ary)-ubound(Ary2)
		for i=0 to ubound(Ary2)
			Ary(i+j) = Ary2(i)
		next
		RightCopy = Ary
	end if
end function
%>