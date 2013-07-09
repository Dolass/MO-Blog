<%
'by anlige at www.9fn.net
Class MoLibXMLPack
	Private m_Dom, m_Path, FSO, m_RootPath, s_Dom, Fod, Node, Fi, FilePath, Node_FName, Node_Value, FF, FolderPath, mvarException
	Public Property Let Path(ByVal vData)
		m_Path = vData
	End Property
	
	Public Property Get Exception()
		Exception = mvarException
	End Property
	
	Private Sub Class_Initialize()
		Set m_Dom = Server.CreateObject("Microsoft.XMLDOM") 
		Set s_Dom = Server.CreateObject("Microsoft.XMLDOM")
		Set FSO = Server.CreateObject("Scripting.FileSystemObject")
		mvarException = ""
	End Sub
	Private Sub Class_Terminate()
		Set m_Dom = Nothing
		Set s_Dom = Nothing
		Set FSO = Nothing
	End Sub
	
	Private Function GetFolders()
		Dim DocEle, Folders, i, ReturnStr
		ReturnStr = "["
		m_Dom.load m_Path
		Set DocEle = m_Dom.documentElement
		Set Folders = m_Dom.getElementsByTagName("folder")
		For i = 0 To Folders.length - 1
			ReturnStr = ReturnStr & "{id:" & i & ",name:'" & replace(Folders(i).Text,"\","\\") & "'},"
		Next
		ReturnStr = left(ReturnStr, Len(ReturnStr) - 1)
		ReturnStr = ReturnStr & "]"
		Set Folders = Nothing
		Set DocEle = Nothing
		GetFolders = ReturnStr
	End Function
	
	Private Function GetFiles()
		Dim DocEle, Files, i, ReturnStr, CHD
		ReturnStr = "["
		m_Dom.load m_Path
		Set DocEle = m_Dom.documentElement
		Set Files = m_Dom.getElementsByTagName("file")
		For i = 0 To Files.length - 1
			Set CHD = Files(i).childNodes
			ReturnStr = ReturnStr & "{id:" & i & ",name:'" & replace(CHD(0).Text,"\","\\") & "'},"
		Next
		ReturnStr = left(ReturnStr, Len(ReturnStr) - 1)
		ReturnStr = ReturnStr & "]"
		Set Files = Nothing
		Set DocEle = Nothing
		GetFiles = ReturnStr
	End Function
	Public Function Pack(ByVal vPath)
		If Not FSO.FolderExists(vPath) Then
			mvarException = """" & vPath & """ is not exists!"
			Pack = False
			Exit Function
		End If
		s_Dom.loadXML "<?xml version=""1.0"" ?><root/>"
		s_Dom.documentElement.setAttribute "xmlns:dt", "urn:schemas-microsoft-com:datatypes"
		m_RootPath = vPath
		CompactFolder vPath
		s_Dom.Save m_Path
		Pack = True
	End Function
	
	Private Function CompactFolder(ByVal vPath)
		vPath = vPath & "\"
		Set Fod = FSO.GetFolder(vPath)
		Set Node = s_Dom.createElement("folder")
		Node.Text = Mid(vPath, Len(m_RootPath) + 1)
		s_Dom.documentElement.appendChild Node
		If Fod.Files.Count > 0 Then
		   For Each Fi In Fod.Files
			FilePath = vPath & Fi.Name
			Set Node = s_Dom.createElement("file")
		        
			Set Node_FName = s_Dom.createElement("path")
			Node_FName.Text = Mid(FilePath, Len(m_RootPath) + 1)
			Node.appendChild Node_FName
		        
			Set Node_Value = s_Dom.createElement("value")
			Node_Value.dataType = "bin.base64"
			Node_Value.nodeTypedValue = LoadFile(FilePath)
			Node.appendChild Node_Value
		        
			s_Dom.documentElement.appendChild Node
		   Next
		End If

		If Fod.SubFolders.Count > 0 Then
		   For Each FF In Fod.SubFolders
			FolderPath = vPath & FF.Name
			Call CompactFolder(FolderPath)
		   Next
		End If
	End Function

	Public Function UnPack(ByVal SavePath)
		If Not FSO.FileExists(m_Path) Then
			mvarException = """" & m_Path & """ is not exists!"
			UnPack = False
			Exit Function
		End If
		If Not FSO.FolderExists(SavePath) Then CreateFolder(SavePath)
		Dim DocEle
		Dim Folders
		Dim Files
		Dim i
		Dim CHD
		m_Dom.load m_Path
		Set DocEle = m_Dom.documentElement
		Set Folders = m_Dom.getElementsByTagName("folder")
		For i = 0 To Folders.length - 1
		    CreateFolder SavePath & Folders(i).Text
		Next
		Set Files = m_Dom.getElementsByTagName("file")
		For i = 0 To Files.length - 1
		    Set CHD = Files(i).childNodes
		    SaveFile SavePath & CHD(0).Text, CHD(1).nodeTypedValue
		Next
		UnPack = True
	End Function
	
	Private Function LoadFile(ByVal FileName)
		Dim Stream
		Set Stream = Server.CreateObject("ADODB.Stream")
		Stream.Type = 1
		Stream.Mode = 3
		Stream.Open
		Stream.LoadFromFile FileName
		LoadFile = Stream.Read
		Stream.Close
		Set Stream = Nothing
	End Function 
	
	Private Function SaveFile(ByVal FileName, ByVal FileData)
		On Error Resume Next
		Dim Stream
		Set Stream = Server.CreateObject("ADODB.Stream")
		Stream.Type = 1
		Stream.Mode = 3
		Stream.Open
		Stream.Write FileData
		Stream.SaveToFile FileName, 2
		Stream.Close
		Set Stream = Nothing
	End Function


	Private Function CreateFolder(ByVal FolderPath)
		On error Resume Next
		Dim FolderArray
		Dim i
		Dim DiskName
		Dim Created
		FolderPath = Replace(FolderPath, "/", "\")
		If Mid(FolderPath, Len(FolderPath), 1) = "\" Then FolderPath = Mid(FolderPath, 1, Len(FolderPath) - 1)
		FolderArray = Split(FolderPath, "\")
		DiskName = FolderArray(0)
		Created = DiskName
		For i = 1 To UBound(FolderArray)
			Created = Created & "\" & FolderArray(i)
			If Not FSO.FolderExists(Created) Then FSO.CreateFolder Created
		Next
		Err.Clear
	End Function
End Class
 %>