<%
'=========================================================
 'Class: MoLibUpload
 'Author: Anlige
 'Version:MoLibUpload V1.0
 'CreationDate: 2008-04-12
 'ModificationDate: 2013-03-02
 'Homepage: http://dev.mo.cn
 'Email: zhanghuiguoanlige@126.com
'=========================================================
Class MoLibUpload
	Private Form, Fils,StreamT,mvarClsName, mvarClsDescription,mvarSavePath
	Private vCharSet, vMaxSize, vSingleSize, vErr, vVersion, vTotalSize, vExe, vErrExe,vboundary, vLostTime, vFileCount,StreamOpened
	private vMuti,vServerVersion,mvarDescription
	
	Public Property Let AllowMaxSize(ByVal value)
		vMaxSize = value
	End Property
	
	Public Property Let AllowMaxFileSize(ByVal value)
		vSingleSize = value
	End Property
	
	Public Property Let AllowFileTypes(ByVal value)
		vExe = LCase(value)
		vExe = replace(vExe,"*.","")
		vExe = replace(vExe,";","|")
	End Property
	
	Public Property Let CharSet(ByVal value)
		vCharSet = value
	End Property
	
	Public Property Let SavePath(ByVal value)
		mvarSavePath = value
	End Property
	
	Public Property Get FileCount()
		FileCount = Fils.count
	End Property
	
	Public Property Get Description()
		Description = mvarDescription
	End Property
	
	Public Property Get Version()
		Version = vVersion
	End Property
	
	Public Property Get TotalSize()
		TotalSize = vTotalSize
	End Property
	
	Public Property Get LostTime()
		LostTime = vLostTime
	End Property
	
	Private Sub Class_Initialize()
		Dim T__
		Set Form = Server.CreateObject("Scripting.Dictionary")
		Set Fils = Server.CreateObject("Scripting.Dictionary")
		Set StreamT = Server.CreateObject("Adodb.stream")
		vVersion = "MoLibUpload V1.0"
		vMaxSize = -1
		vSingleSize = -1
		vErr = -1
		vExe = ""
		vTotalSize = 0
		vCharSet = "gb2312"
		StreamOpened=false
		vMuti="_" & Getname() & "_"
		vServerVersion = 6.0
		T__ = lcase(Request.ServerVariables("SERVER_SOFTWARE"))
		T__ = replace(T__,"microsoft-iis/","")
		if isnumeric(T__) then vServerVersion = cdbl(T__)
		mvarClsName = "MoLibFileExtern_"+Getname()
		mvarClsDescription="Class {ClsName}\nPublic ContentType,Size,UserSetName,Path,Position,FormName,TempFormName, NewName,FileName,LocalName,IsFile,Extend,Succeed,Exception\nEnd Class"
		mvarClsDescription = Replace(mvarClsDescription,"{ClsName}",mvarClsName)
		mvarClsDescription = Replace(mvarClsDescription,"\n",vbcrlf)
		ExecuteGlobal mvarClsDescription
	End Sub
	
	Private Sub Class_Terminate()
		Dim f
		Form.RemoveAll()
		For each f in Fils
			Set Fils(f) = Nothing
		Next
		Fils.RemoveAll()
		Set Form = Nothing
		Set Fils = Nothing
		if StreamOpened then StreamT.close()
		Set StreamT = Nothing
	End Sub
	
	Private Function ParseSizeLimit(byval SizeLimit)
		dim unit,value,multiplier,limit
		If Not isnumeric(SizeLimit) Then
			multiplier = 1
			SizeLimit = ReplaceEx(lcase(SizeLimit),"\s","")
			value = replaceex(SizeLimit,"[^\d]+","")
			if isnumeric(value) then
				value = clng(value)
				if right(SizeLimit,2)="gb" then multiplier = 1073741824
				if right(SizeLimit,2)="mb" then multiplier = 1048576
				if right(SizeLimit,2)="kb" then multiplier = 1024
				limit = value * multiplier
			else
				limit=-1
			end if
		else
			limit = SizeLimit
		End If	
		if limit<-1 then limit=-1
		ParseSizeLimit = limit
	End Function
		
	Public function GetData()
		GetData =false
		vMaxSize = ParseSizeLimit(vMaxSize)
		vSingleSize = ParseSizeLimit(vSingleSize)
		Dim time1
		time1 = timer()
		Dim value, str, bcrlf, fpos, sSplit, slen, istart,ef
		Dim TotalBytes,tempdata,BytesRead,ChunkReadSize,PartSize,DataPart,formend, formhead, startpos, endpos, formname, FileName, fileExe, valueend, NewName,localname,type_1,contentType
		TotalBytes = Request.TotalBytes
		ef = false
		If checkEntryType = false Then ef = true : mvarDescription = "ERROR_INVALID_ENCTYPEOR_METHOD"
		If vServerVersion>=6 Then
			If Not ef Then
				If vMaxSize > 0 And TotalBytes > vMaxSize Then ef = true : mvarDescription = "ERROR_FILE_EXCEEDS_MAXSIZE_LIMIT"
			End If
		End If
		If ef Then Exit function
		vTotalSize = 0 
		StreamT.Type = 1
		StreamT.Mode = 3
		StreamT.Open
		StreamOpened = true
		BytesRead = 0
		ChunkReadSize = 1024 * 16
		Do While BytesRead < TotalBytes
			PartSize = ChunkReadSize
			If PartSize + BytesRead > TotalBytes Then PartSize = TotalBytes - BytesRead
			DataPart = Request.BinaryRead(PartSize)
			StreamT.Write DataPart
			BytesRead = BytesRead + PartSize
		Loop
		StreamT.Position = 0
		tempdata = StreamT.Read
		bcrlf = ChrB(13) & ChrB(10)
		fpos = InStrB(1, tempdata, bcrlf)
        sSplit = MidB(tempdata, 1, fpos - 1)
		slen = LenB(sSplit)
		istart = slen + 2
        Do
            formend = InStrB(istart, tempdata, bcrlf & bcrlf)
            formhead = MidB(tempdata, istart, formend - istart)
            str = Bytes2Str(formhead)
            startpos = InStr(str, "name=""") + 6
            endpos = InStr(startpos, str, """")
            formname = LCase(Mid(str, startpos, endpos - startpos))
            valueend = InStrB(formend + 3, tempdata, sSplit)
			If InStr(str, "filename=""") > 0 Then
				formname = formname & vMuti & "0"
				startpos = InStr(str, "filename=""") + 10
				endpos = InStr(startpos, str, """")
				type_1=instr(endpos,lcase(str),"content-type")
				contentType=trim(mid(str,type_1+13))
				FileName = Mid(str, startpos, endpos - startpos)
				If Trim(FileName) <> "" Then
					FileName = Replace(FileName, "/", "\")
					FileName = Replace(FileName, chr(0), "")
					LocalName = FileName
					FileName = Mid(FileName, InStrRev(FileName, "\") + 1)
					If instr(FileName,".")>0 Then
						fileExe = Split(FileName, ".")(UBound(Split(FileName, ".")))
					else
						fileExe = ""
					End If
					If vExe <> "" Then
						If checkExe(fileExe) = True Then
							mvarDescription = "ERROR_INVALID_FILETYPE(." & ucase(fileExe) & ")"
							vErrExe = fileExe
							tempdata = empty
							Exit function
						End If
					End If
					NewName = Getname()
					NewName = NewName & "." & fileExe
					vTotalSize = vTotalSize + valueend - formend - 6
					If vSingleSize > 0 And (valueend - formend - 6) > vSingleSize Then
						mvarDescription = "ERROR_FILE_EXCEEDS_SIZE_LIMIT"
						tempdata = empty
						Exit function
					End If
					If vMaxSize > 0 And vTotalSize > vMaxSize Then
						mvarDescription = "ERROR_FILE_EXCEEDS_MAXSIZE_LIMIT"
						tempdata = empty
						Exit function
					End If
					If Fils.Exists(formname) Then formname = GetNextFormName(formname)
					Dim fileCls:set fileCls= NewFile()
					fileCls.ContentType=contentType
					fileCls.Size= (valueend - formend - 6)
					fileCls.Position = (formend + 3)
					fileCls.FormName = mid(formname,instr(formname,vMuti)-1)
					fileCls.TempFormName = formname
					fileCls.NewName = NewName
					fileCls.FileName = FileName
					fileCls.LocalName = FileName
					fileCls.IsFile = true
					fileCls.Extend=split(NewName,".")(ubound(split(NewName,".")))
					Fils.Add formname, fileCls
				End If
			Else
				value = MidB(tempdata, formend + 4, valueend - formend - 6)
				If Form.Exists(formname) Then
					Form(formname) = Form(formname) & "," & Bytes2Str(value)
				Else
					Form.Add formname, Bytes2Str(value)
				End If
			End If
            istart = valueend + 2 + slen
        Loop Until (istart + 2) >= LenB(tempdata)
		tempdata = empty
		vLostTime = FormatNumber((timer-time1)*1000,2)
		GetData =true
	End Function
	
	Private Function CheckExe(ByVal ex)
		Dim notIn: notIn = True
		If vExe="*" then
			notIn=false 
		elseIf InStr(1, vExe, "|") > 0 Then
			Dim tempExe: tempExe = Split(vExe, "|")
			Dim I: I = 0
			For I = 0 To UBound(tempExe)
				If LCase(ex) = tempExe(I) Then
					notIn = False
					Exit For
				End If
			Next
		Else
			If vExe = LCase(ex) Then
				notIn = False
			End If
		End If
		checkExe = notIn
	End Function
	
	Private Function Bytes2Str(ByVal byt)
		If LenB(byt) = 0 Then
			Bytes2Str = ""
			Exit Function
		End If
		Dim mystream, bstr
		Set mystream =Server.CreateObject("ADODB.Stream")
		mystream.Type = 2
		mystream.Mode = 3
		mystream.Open
		mystream.WriteText byt
		mystream.Position = 0
		mystream.CharSet = vCharSet
		mystream.Position = 2
		bstr = mystream.ReadText()
		mystream.Close
		Set mystream = Nothing
		Bytes2Str = bstr
	End Function
	
	Private Function Getname()
		Dim y, m, d, h, mm, S, r
		Randomize
		y = Year(Now)
		m = right("0" & Month(Now),2)
		d = right("0" & Day(Now),2)
		h = right("0" & Hour(Now),2)
		mm =right("0" & Minute(Now),2)
		S = right("0" & Second(Now),2)
		r = CInt(Rnd() * 10000)
		r = right("0000" & r,4)
		Getname = y & m & d & h & mm & S & r
	End Function
	
	Private Function checkEntryType()
		Dim ContentType, ctArray, bArray,RequestMethod
		RequestMethod=trim(LCase(Request.ServerVariables("REQUEST_METHOD")))
		if RequestMethod="" or RequestMethod<>"post" then
			checkEntryType = False
			exit function
		end if
		ContentType = LCase(Request.ServerVariables("HTTP_CONTENT_TYPE"))
		ctArray = Split(ContentType, ";")
		if ubound(ctarray)>=0 then
			If Trim(ctArray(0)) = "multipart/form-data" Then
			checkEntryType = True
			vboundary = Split(ContentType,"boundary=")(1)
			Else
			checkEntryType = False
			End If
		else
			checkEntryType = False
		end if
	End Function
	
	Public Function Post(ByVal formname)
		If trim(formname) = "-1" Then
			Set Post = Form
		Else
			If Form.Exists(LCase(formname)) Then
				Post = Form(LCase(formname))
			Else
				Post = ""
			End If
		End If
	End Function
	
	Public Default Function Files(ByVal formname)
		If trim(formname) = "-1" Then
			Set Files = Fils
		Else
			dim vname
			vname = LCase(formname) & vMuti & "0"
			if instr(formname,vMuti)>0 then vname = formname
			If Fils.Exists(vname) Then
				Set Files = Fils(vname)
			Else
				Set Files = NewFile()
				Files.IsFile = false
			End If
		End If
	End Function
	
	Public Function Search(ByVal formname)
		if formname="*" or formname="-1" then
			Set Search = Fils
			Exit Function
		end if
		Dim TempFormName
		TempFormName = formname & vMuti
		Dim FileCollection
		Set FileCollection = Server.CreateObject("Scripting.Dictionary")
		Dim v
		For Each v In Fils
			If lcase(left(v,len(TempFormName))) = lcase(TempFormName) Then
				FileCollection.Add v,Fils(v)
			End If
		Next
		Set Search = FileCollection
	End Function
	
	
	Public Function QuickSave(ByVal formname)
		Dim FC,SucceedCount,File
		SucceedCount = 0
		Set FC = Search(formname)
		For Each File In FC
			If Save(File,0,True).Succeed Then SucceedCount = SucceedCount + 1
		Next
		QuickSave = SucceedCount
	End Function
	
	
	Public Function Save(Byref Name,byval tOption, byval OverWrite)
		Dim File
		if not isobject(name) then
			Set File = Files(Name)
			If Not File.IsFile Then
				File.Succeed = false
				File.Exception="ERROR_FILE_NO_FOUND"
				Set Save = File
				Exit Function
			End If
		else
			Set File = Name
		end if
		If Not File.IsFile Then
			File.Succeed = false
			File.Exception="ERROR_FILE_NO_FOUND"
			Set Save = File
			Exit Function
		End If
		On Error Resume Next
		Err.clear
		Dim IsP,Path
		Path = mvarSavePath
		IsP = (InStr(mvarSavePath, ":") = 2)
		If Not IsP Then Path = Server.MapPath(mvarSavePath)
		Path = Replace(Path, "/", "\")
		If Mid(Path, Len(Path) - 1) <> "\" Then Path = Path + "\"
		CreateFolder Path
		File.Path= Replace(Replace(Path,Server.MapPath("/"),""),"\","/")
		If tOption = 1 Then
			Path = Path & File.LocalName: File.FileName =File.LocalName
		Else
			If tOption = -1 And File.UserSetName <> "" Then
				Path = Path & File.UserSetName & "." & File.Extend: File.FileName = File.UserSetName & "." & File.Extend
			Else
				Path = Path & File.NewName: File.FileName = File.NewName
			End If
		End If
		If Not OverWrite Then
			Path = GetFilePath(File)
		End If
		Dim tmpStrm
		Set tmpStrm =Server.CreateObject("ADODB.Stream")
		tmpStrm.Mode = 3
		tmpStrm.Type = 1
		tmpStrm.Open
		StreamT.Position = File.Position
		StreamT.copyto tmpStrm,File.Size
		tmpStrm.SaveToFile Path, 2
		tmpStrm.Close
		Set tmpStrm = Nothing
		If Not Err Then
			File.Succeed = true
		Else
			Err.clear()
			File.Succeed = false
			File.Exception=Err.Description
		End If
		Set Save = File
	End Function
	
	Public Function GetBinary(byval Name)
		Dim File
		Set File = Files(Name)
		If Not File.IsFile Then
			GetBinary = chrb(0)
			Exit Function
		End If
		StreamT.Position = File.Position
		GetBinary = StreamT.read(File.Size)
	End Function 
	
	Private Function GetNextFormName(byval formname)
		Dim formStart,currentIndex
		formStart = left(formname,instr(formname,vMuti)+len(vMuti)-1)
		currentIndex = mid(formname,instr(formname,vMuti)+len(vMuti))
		currentIndex =cint(currentIndex)
		do while Fils.Exists(formname)
			currentIndex = currentIndex + 1
			formname = formStart & currentIndex
		loop
		GetNextFormName = formname
	End Function
	Private Function ReplaceEx(sourcestr, regString, str)
		if isnull(sourcestr) then sourcestr=""
		dim re
		Set re = new RegExp
		re.IgnoreCase = true
		re.Global = True
		re.pattern = "" & regString & ""
		str = re.replace(sourcestr, str)
		set re = Nothing
		ReplaceEx = str
	End Function
	Private Function CreateFolder(ByVal folderPath )
		Dim oFSO
		Set oFSO = Server.CreateObject("Scripting.FileSystemObject")
		Dim sParent 
		sParent = oFSO.GetParentFolderName(folderPath)
		If sParent = "" Then Exit Function
		If Not oFSO.FolderExists(sParent) Then CreateFolder (sParent)
		If Not oFSO.FolderExists(folderPath) Then oFSO.CreateFolder (folderPath)
		Set oFSO = Nothing
	End Function
	
	Private Function GetFilePath(Byref File) 
		Dim oFSO, Fname , FNameL , i 
		i = 0
		Set oFSO = Server.CreateObject("Scripting.FileSystemObject")
		Fname = Server.MapPath(File.Path & File.FileName)
		FNameL = Mid(File.FileName, 1, InStr(File.FileName, ".") - 1)
		Do While oFSO.FileExists(Fname)
			Fname = Server.MapPath(File.Path & FNameL & "(" & i & ")." & File.Extend)
			File.FileName = FNameL & "(" & i & ")." & File.Extend
			i = i + 1
		Loop
		Set oFSO = Nothing
		GetFilePath = Fname
	End Function
	
	Private Function NewFile()
		Execute "Set NewFile = new " & mvarClsName
	End Function
End Class
%>