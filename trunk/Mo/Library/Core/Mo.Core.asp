<!--#include file="Mo.Function.Jscript.asp"-->
<!--#include file="Mo.Function.asp"-->
<!--#include file="Mo.List.asp"-->
<!--#include file="Mo.Model.asp"-->
<!--#include file="Mo.Record.asp"-->
<!--#include file="Mo.MD5.asp"-->
<%
class MoAspEnginer
	private mvarDicts, mvarUse,mvarConfig, mvarAction, mvarMethod,mvarCacheFileName,mvarRealAction,mvarRealMethod
	private mvarLibrarys
	public Property Let Action(byval value)
		mvarAction = value
		mvarRealAction = value
	end Property
	public Property Get Action()
		Action = mvarAction
	end Property
	
	public Property Let Method(byval value)
		mvarMethod = value
		mvarRealMethod = value
	end Property
	public Property Get Method()
		Method = mvarMethod
	end Property
	
	public Property Get Version()
		Version = "MoAspEnginer 1.04"
	end Property
	
	private sub Class_Initialize()
		set mvarDicts = F.activex("Scripting.Dictionary")
		set mvarUse = F.activex("Scripting.Dictionary")
		set mvarConfig = F.activex("Scripting.Dictionary")
		set mvarLibrarys = F.activex("Scripting.Dictionary")
		if not defined(MO_APP) or MO_APP="" then debug "未定义应用路径"
		if not defined(MO_CORE) or MO_CORE="" then debug "未定义核心路径"
		if not F.fso.FolderExists(F.MapPath(MO_CORE)) then debug "核心目录不存在"
		if not MO_DEBUG then on error resume next
		err.clear
		if not F.fso.FolderExists(F.MapPath(MO_APP)) then F.fso.CreateFolder F.MapPath(MO_APP)
		if not F.fso.FolderExists(F.MapPath(MO_APP & "Action")) then F.fso.CreateFolder F.MapPath(MO_APP & "Action")
		if not F.fso.FolderExists(F.MapPath(MO_APP & "Compiled")) then F.fso.CreateFolder F.MapPath(MO_APP & "Compiled")
		if not F.fso.FolderExists(F.MapPath(MO_APP & "Library")) then F.fso.CreateFolder F.MapPath(MO_APP & "Library")
		if not F.fso.FolderExists(F.MapPath(MO_APP & "Library/Extend")) then F.fso.CreateFolder F.MapPath(MO_APP & "Library/Extend")
		if not F.fso.FolderExists(F.MapPath(MO_APP & "Templates")) then F.fso.CreateFolder F.MapPath(MO_APP & "Templates")
		if not F.fso.FolderExists(F.MapPath(MO_APP & "Config")) then F.fso.CreateFolder F.MapPath(MO_APP & "Config")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Action")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Action")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Templates")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Templates")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Library")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Library")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Config")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Config")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Library/TagLib")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Library/TagLib")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Library/Extend")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Library/Extend")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Library/PreLib")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Library/PreLib")
		if not F.fso.FolderExists(F.MapPath(MO_CORE & "Library/EndLib")) then F.fso.CreateFolder F.MapPath(MO_CORE & "Library/EndLib")
		if F.fso.FileExists(F.mappath(MO_APP & "Config/Config.asp")) then Execute LoadAsp(F.mappath(MO_APP & "Config/Config.asp"),"utf-8")
	end sub
	
	private sub dispose()
		dim d
		for each d in mvarDicts
			if isobject(mvarDicts(d)) then set mvarDicts(d)=nothing
		next
		for each d in mvarUse
			if isobject(mvarUse(d)) then set mvarUse(d)=nothing
		next
		for each d in mvarConfig
			if isobject(mvarConfig(d)) then set mvarConfig(d)=nothing
		next
		set mvarDicts = nothing
		set mvarUse = nothing
		set mvarConfig = nothing
		set mvarLibrarys = nothing
		Model__.dispose()
		F.dispose()
	end sub
	
	public function [Static](byval lib)
		if not mvarUse.exists(lib) then set mvarUse(lib) = MoAspEnginer__(lib)
		set [Static] = mvarUse(lib)
	end function
	
	public default function MoAspEnginer__(byval lib)
		dim useResult:useResult = Use(lib)
		set MoAspEnginer__ = LoadLibrary("",useResult(0),useResult(1))
	end function
	
	public function Use(byval lib)
		dim path,core,cls,library
		core="Extend"
		cls = lib
		library = "Lib"
		if instr(lib,":")>0 then
			core = mid(lib,1,instr(lib,":")-1)
			cls = mid(lib,instr(lib,":")+1)
		end if
		if instr(cls,".")>0 then
			library = mid(cls,1,instr(cls,".")-1)
			cls = mid(cls,instr(cls,".")+1)
		end if
		if not mvarLibrarys.exists(library & "_" & cls) then
			path = F.MapPath(MO_APP & "Library/" & core & "/Mo." & library & "." & cls & ".asp")
			if not F.fso.fileexists(path) then path = F.MapPath(MO_CORE & "Library/" & core & "/Mo." & library & "." & cls & ".asp")
			if F.fso.fileexists(path) then LoadLibrary path,library,cls
		end if
		Use = Array(library,cls,core)
	end function
	
	public function ClearCompiledCache()
		ClearCompiledCache = [Static]("Folder").Clear(F.MapPath(MO_APP & "Compiled"))
	end function
	public function ClearLibraryCache()
		dim app,count,list,arraylist
		count=0
		Application.Lock()
		for each app in Application.Contents
			if left(app,5+len(MO_APP_NAME))=MO_APP_NAME & "_lib_" then
				list = list & app & ","
			end if
		next
		if list<>"" then list = left(list,len(list)-1)
		arraylist = split(list,",")
		for each app in arraylist
			Application.Contents.Remove(app)
			count=count+1
		next
		Application.UnLock()
		ClearLibraryCache = count
	end function
	private function LoadLibrary(byval path,byval library,byval cls)
		if path="" then
			if mvarLibrarys(library & "_" & cls) = "jscript" then 
				set LoadLibrary = F.import(library,cls)
			elseif mvarLibrarys(library & "_" & cls) = "vbscript" then
				execute "set LoadLibrary = new Mo" & library & cls
			else
				err.raise 2,"类库[Mo" & library & cls & "]不存在或初始化失败，请检查类库是否存在","类库解析失败"
			end if
			exit function
		end if
		if not MO_DEBUG then on error resume next
		err.clear
		dim ret,language,filesum,isnew
		path = F.MapPath(path)
		filesum = library & "." & cls
		isnew = false
		if ((Application(MO_APP_NAME & "_lib_" & filesum & "_lng")<>"jscript" and Application(MO_APP_NAME & "_lib_" & filesum & "_lng")<>"vbscript"))  or (not MO_LIB_CACHE) then
			ret = LoadFile(path,"UTF-8")
			ret = replaceex(ret,"(^(\s+)|(\s+)$)","")
			ret = trim(ret)
			Application.Lock()
			Application(MO_APP_NAME & "_lib_"&filesum & "_cache") =ret
			Application.UnLock() 
			isnew = true
		else
			ret = Application(MO_APP_NAME & "_lib_"&filesum & "_cache")
		end if
		if regtest(ret,"^<script(.+?)runat=""server""(.*?)>") then
			ret = ReplaceEx(ret,"^<script(.+?)>(\s*)","")
			ret = ReplaceEx(ret,"(\s*)</script>","")
			F.executeglobal ret,library,cls
			language = "jscript"
		else
			if left(ret,2)="<%" then ret = mid(ret,3)
			if right(ret,2)=replace("% >"," ","") then ret = left(ret,len(ret)-2)
			executeglobal ret
			language = "vbscript"
		end if
		if err then
			LoadLibrary = false
		else
			LoadLibrary = true
			mvarLibrarys(library & "_" & cls) = language
			if isnew then
				Application.Lock()
				Application(MO_APP_NAME & "_lib_"&filesum & "_lng") =language
				Application.UnLock()
			end if
		end if
		err.clear		
	end function
	public function display(template)
		Response.Status = "200 OK"
		Response.Charset=MO_CHARSET
		Response.AddHeader "Content-Type","text/html; charset=" & MO_CHARSET
		Response.Write fetch(template)
	end function
	public function fetch(byval template)
		dim html,Md5Sum,OldHash,NewHash,usecache,vbscript,cachepath
		usecache =false
		if MO_COMPILE_CACHE then
			Md5Sum = mvarRealMethod & "^" & mvarRealAction & "^" & replace(template,":","^")
			cachepath = F.MapPath(MO_APP & "Compiled/" & Md5Sum & ".asp")
			if F.FSO.FileExists(cachepath) then
				OldHash = F.FSO.GetFile(cachepath).DateLastModified
				usecache = true
				if MO_COMPILE_CACHE_EXPIRED>0 then
					if datediff("s",OldHash,now())>=MO_COMPILE_CACHE_EXPIRED then usecache=false
				end if
				if usecache then vbscript = LoadAsp(cachepath,MO_CHARSET)
			end if
		end if
		if not usecache then
			html = LoadTemplateEx(template)
			if html="" then
				fetch=""
				exit function
			end if
			Execute LoadAsp(F.mappath(MO_CORE & "Library/Core/Mo.View.asp"),"utf-8")
			vbscript = (new MoAspEnginer_View)(html)
			if MO_COMPILE_CACHE then SaveFile cachepath,"<%"&vbscript&"%" &">",MO_CHARSET
		end if
		ExecuteGlobal vbscript
		fetch = Temp___()
		if MO_CACHE=true and MO_CACHE_DIR<>"" then
			if F.fso.folderexists(F.mappath(MO_CACHE_DIR)) then SaveFile F.mappath(MO_CACHE_DIR & mvarCacheFileName & ".cache"),fetch,MO_CHARSET
		end if
	end function
	
	private function LoadTemplateEx(Byval template)
		Dim tempStr,Match,fn,Matches,tfun,resultstr
		dim templatelist,vpath,path,html,vbscript,templatelist2
		
		templatelist = split(template,":")
		if ubound(templatelist)=0 then
			vpath = MO_TEMPLATE_NAME & "/" & mvarMethod & MO_TEMPLATE_SPLIT & template
		elseif ubound(templatelist)=1 then
			vpath = MO_TEMPLATE_NAME & "/" &replace(template,":",MO_TEMPLATE_SPLIT)
		elseif ubound(templatelist)=2 then
			vpath = templatelist(0) & "/" & templatelist(1) & MO_TEMPLATE_SPLIT & templatelist(2)
		end if
		path = MO_APP & "Templates/" & vpath & "." & MO_TEMPLATE_PERX
		if not F.fso.FileExists(F.MapPath(path)) then path = MO_Core & "Templates/" & vpath & "." & MO_TEMPLATE_PERX
		path = F.MapPath(path)
		if not F.fso.FileExists(path) then exit function
		tempStr = LoadFile(path,MO_CHARSET)
		Set Matches = GetMatch(tempStr,"<include file\=\""(.+?)(\." & MO_TEMPLATE_PERX & ")?\"" />")
		if Matches.count>0 Then
			For Each Match In Matches
				templatelist2 = RightCopy(templatelist,split(Match.subMatches(0),":"))
				tempStr=Replace(tempStr, Match.value, LoadTemplateEx(Join(templatelist2,":")), 1, -1, 0)
			Next
		End If
		LoadTemplateEx = tempStr
	End Function

	public function assign(byval key,byref value)
		if typename(value)="JScriptTypeInfo" then
			if MO_COMPILE_STRICT then Execute "set " & key & " = value" else set mvarDicts(key) = value
		else
			if MO_COMPILE_STRICT then Execute key & " = value" else mvarDicts(key) = value
		end if
	end function
	
	public function Exists(byval key)
		Exists = mvarDicts.exists(key)
	end function
	
	public function Value(byval key)
		if MO_COMPILE_STRICT then 
			dim ty:ty = eval("typename(" & key & ")")
			if ty="JScriptTypeInfo" then
				Execute "Set Value = " & key
			else
				Execute "Value = " & key
			end if
			exit function
		end if
		if not mvarDicts.exists(key) then 
			Value = null
			exit function
		end if
		if typename(mvarDicts(key))="JScriptTypeInfo" then
			set Value = mvarDicts(key) 
			if Value.isset__("Reset") then Value.Reset()
		else
			Value = mvarDicts(key) 
		end if
	end function
	
	public function values(byval l,byval k)
		if MO_COMPILE_STRICT then 
			Execute "values = " & l & "." & k
			exit function
		end if
		if not mvarDicts.exists(l) then
			values = ""
			exit function
		end if 
		if typename(mvarDicts(l))="JScriptTypeInfo" then
			if mvarDicts(l).isset__(k) then
				execute "values = mvarDicts(l)." & k
				exit function
			end if
		end if
		values=""
	end function
	
	public function C(byval lib)
		if mvarConfig.exists(lib) then
			set C = mvarConfig(lib)
			exit function
		end if
		dim filepath : filepath = F.MapPath(MO_APP & "Config/Mo.Conf." & lib & ".asp")
		if not F.fso.fileexists(filepath) then filepath = F.MapPath(MO_CORE & "Config/Mo.Conf." & lib & ".asp")
		if F.fso.fileexists(filepath) then
			if LoadLibrary(filepath,"Conf",lib) then
				set mvarConfig(lib) = LoadLibrary("","Conf",lib)
				set C = mvarConfig(lib)
			else
				err.raise 1,"配置文件无法加载,请检查配置文件是否存在"
			end if
		end if
	end function
	public sub TagLib(byref mvarContent)
		if MO_TAG_LIB<>"" then
			dim libs,lib,T__
			libs = split(MO_TAG_LIB,",")
			for each lib in libs
				Call MoAspEnginer__("TagLib:Tag." & lib)(mvarContent)
			next
		end if
	end sub
	private sub Start__()
		if MO_PRE_LIB<>"" then
			dim libs,lib,T__
			libs = split(MO_PRE_LIB,",")
			for each lib in libs
				Call MoAspEnginer__("PreLib:Pre." & lib)(Mo.method,Mo.Action)
			next
		end if
	end sub	
	private sub End__()
		if MO_END_LIB<>"" then
			dim libs,lib,T__
			libs = split(MO_END_LIB,",")
			for each lib in libs
				Call MoAspEnginer__("EndLib:End." & lib)(Mo.method,Mo.Action)
			next
		end if
	end sub
	public sub Debug_()
		if err and MO_SHOW_SERVER_ERROR then
			if err.number=438 then
				debug "动作[" & mvarAction & "]错误：模块[" & mvarMethod & "]的默认动作" & mvarAction & "未定义"
			elseif err.number=13 then
				debug "系统错误：["  & err.number &" = " & err.source & "]请检查是否使用了未定义的函数或过程"
			else
				debug "系统错误：["  & err.number &" = " & err.source & "]" & err.description
			end if
		end if
	end sub
	public sub Run()
		F.parseGet()
		if not RegTest(Mo_METHOD_CHAR,"^(\w+)$") then Mo_METHOD_CHAR = "m"
		if not RegTest(Mo_ACTION_CHAR,"^(\w+)$") then Mo_ACTION_CHAR = "a"
		mvarMethod = Trim(F.get(Mo_METHOD_CHAR))
		mvarAction = Trim(F.get(Mo_ACTION_CHAR))
		If mvarAction = "" Then mvarAction = "Index"
		If mvarMethod = "" Then mvarMethod = "Home"
		if not RegTest(mvarAction,"^(\w+)$") then mvarAction = "Index"
		if not RegTest(mvarMethod,"^(\w+)$") then mvarMethod = "Home"
		mvarCacheFileName = Md5(F.server("URL") & request.QueryString & "")
		if MO_CACHE=true then
			if F.fso.fileexists(F.mappath(MO_CACHE_DIR & mvarCacheFileName & ".cache")) then
				Response.Write LoadFile(F.mappath(MO_CACHE_DIR & mvarCacheFileName & ".cache"),MO_CHARSET)
				exit sub
			end if
		end if
		dim theMethod
		theMethod = mvarMethod
		ModelPath = MO_APP & "Action/Action." & mvarMethod & ".asp"
		if not F.fso.FileExists(F.MapPath(ModelPath)) then
			ModelPath = MO_APP & "Action/Action.Empty.asp"
			theMethod ="Empty"
			if not F.fso.FileExists(F.MapPath(ModelPath)) then
				ModelPath =MO_CORE & "Action/Action." & mvarMethod & ".asp"
				theMethod =mvarMethod
				if not F.fso.FileExists(F.MapPath(ModelPath)) then
					ModelPath = MO_CORE & "Action/Action.Empty.asp"
					theMethod ="Empty"
					if not F.fso.FileExists(F.MapPath(ModelPath)) then debug "模块[" & mvarMethod & "]不存在"
				end if
			end if
		end if
		mvarRealMethod = theMethod
		mvarRealAction = mvarAction
		
		Execute "MO_METHOD = theMethod"
		Execute "MO_ACTION = mvarAction"
		Call Start__()
		if not LoadModel(F.MapPath(ModelPath),theMethod) then debug "模块[" & mvarMethod & "]加载失败"
		if not MO_DEBUG then on error resume next
		err.clear
		dim ModelClass:set ModelClass = LoadModel("",theMethod)
		Execute "Call ModelClass." & mvarAction & "()"
		if err.number=438 then
			err.clear
			mvarRealAction = "Empty"
			Execute "Call ModelClass.Empty(""" & mvarAction & """)"
		end if
		Set ModelClass = Nothing
		Call End__()
		Call dispose()
		Call Debug_()
	end sub
	private function LoadModel(byval path,byval model)
		if path="" then
			if mvarLibrarys("Action" & "_" & model) = "jscript" then 
				set LoadModel = F.import(model,"","Action")
			elseif mvarLibrarys("Action" & "_" & model) = "vbscript" then
				execute "set LoadModel = new Action" & model
			end if
			exit function
		end if
		if not MO_DEBUG then on error resume next
		err.clear
		dim ret,language
		ret = LoadFile(F.MapPath(path),MO_CHARSET)
		ret = replaceex(ret,"(^(\s+)|(\s+)$)","")
		ret = trim(ret)
		if regtest(ret,"^<script(.+?)runat=""server""(.*?)>") then
			ret = ReplaceEx(ret,"^<script(.+?)>(\s*)","")
			ret = ReplaceEx(ret,"(\s*)</script>","")
			F.executeglobal ret,model,"","Action"
			language = "jscript"
		else
			if left(ret,2)="<%" then ret = mid(ret,3)
			if right(ret,2)=replace("% >"," ","") then ret = left(ret,len(ret)-2)
			executeglobal ret
			language = "vbscript"
		end if
		if err then
			LoadModel = false
		else
			LoadModel = true
			mvarLibrarys("Action" & "_" & model) = language
		end if
		err.clear
	end function
end class
%>