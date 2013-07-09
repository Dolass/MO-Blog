<%
class ActionAdmin
	private M,D
	private sub Class_Initialize()
		if F.session(MO_APP_NAME & "_Status")<>"yes" then
			F.redirect MO_ROOT & "?m=login&a=login"
			set Mo = nothing
			F.exit()
		else
			Mo.assign "CoreVersion", Mo.Version
			Model__("System","id").where("id=1").query().assign()
			Mo.assign "blog_block_white",Replace(trim(Mo.Value("blog_block_white")),",",vbcrlf)
			Mo.assign "blog_block_black",Replace(trim(Mo.Value("blog_block_black")),",",vbcrlf)
			Mo.assign "C_Count",Model__("Guestbook","id").where("forarticle=1 and isreplay=0").count()
			Mo.assign "G_Count",Model__("Guestbook","id").where("forarticle=0 and isreplay=0").count()
			Mo.assign "L_Count",Model__("Links","id").where("ischecked=0").count()
		end if
	end sub
	
	private sub Class_Terminate()
	end sub
	
	'管理首页
	public sub Index
		Mo.display "admin:Admin:Index"
	end sub
	public sub [empty](a)
		Mo.assign "Method",a
		Mo.display "admin:Admin:empty"
	end sub
	public sub main
		Mo.display "admin:Admin:main"
	end sub
	'保存博客信息
	public sub savesystem
		dim wlist,blist
		wlist = F.post("blog_block_white")
		blist = F.post("blog_block_black")
		if wlist<>"" then
			wlist = ReplaceEx(wlist,"([^\d\.\r\n\,\/]+)","")
			wlist = Replace(wlist,vbcrlf,",")
			wlist = Replace(wlist,vbcr,",")
			wlist = Replace(wlist,vblf,",")
			F.post "blog_block_white", wlist
		end if
		if blist<>"" then
			blist = ReplaceEx(blist,"([^\d\.\r\n\,\/]+)","")
			blist = Replace(blist,vbcrlf,",")
			blist = Replace(blist,vbcr,",")
			blist = Replace(blist,vblf,",")
			F.post "blog_block_black", blist
		end if
		Model__("System","id").update()
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改博客信息","ip",F.server("REMOTE_ADDR"),"status","成功"
		if F.get.safe("refer")<>"" then
			F.goto F.server("HTTP_REFERER")
		else
			F.goto MO_ROOT & "?m=admin&a=Index&msg=" & F.encode("已保存")
		end if
	end sub
	
	'类别列表
	public sub catlist
		'F.cookie "uname.s","我不是测试"
		dim pid,id,d_,r_,pathlist : pid = F.get.int("pid"): id =  F.get.int("id")
		Mo.Assign "pid",pid
		Mo.Assign "id",id
		pathlist=array()
		set d_ = Model__("Classes","ID").where("ID=" & pid).query().fetch()
		do while not d_.Eof() : set r_ = d_.Read()
			UnShift pathlist,r_
			set d_ = Model__("Classes","ID").where("ID=" & r_.Class_Type).query().fetch()
		loop
		Mo.Assign "pathlist",pathlist
		if id>0 then Model__("Classes","ID").where("ID=" & id).query().assign()
		Model__("Classes","ID").where("Class_Type=" & pid).orderby("Class_Order desc,id desc").query().assign("classes")
		Mo.display "admin:Admin:catlist"
	end sub
	
	'保存类别
	public sub savecat
		if F.post.int("ID")=0 then
			Model__("Classes","ID").insert()
		else
			Model__("Classes","ID").update()
			Model__("Diary","id").where("ClassID=" & F.post.int("ID")).update "ClassName",F.post("Class_Name")
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改/增加分类信息【" & F.post("Class_Name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.redirect MO_ROOT & "?m=admin&a=catlist&pid=" & F.post("Class_Type"),"已保存"
	end sub
	
	public sub deletecat
		dim id : id =  F.get.int("id")
		if Model__("Classes","ID").where("Class_Type=" & id).query().fetch().Eof() then
			if Model__("Diary","id").where("ClassID=" & id).query().fetch().Eof() then
				Set M = Model__("Classes","ID").where("id=" & id).query()
				Set D = M.fetch()
				if D.Eof() then
					F.redirect MO_ROOT & "?m=admin&a=catlist&pid=" & F.get.int("pid"),"记录不存在"
				else
					Set D = D.read()
					if D.getter__("Class_Type")<>0 then
						Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除分类信息【" & D.getter__("Class_Name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
						M.delete()
						F.redirect MO_ROOT & "?m=admin&a=catlist&pid=" & F.get.int("pid"),"已删除"
					else
						F.redirect MO_ROOT & "?m=admin&a=catlist&pid=" & F.get.int("pid"),"根节点不允许删除"
					end if
				end if
			else
				F.redirect MO_ROOT & "?m=admin&a=catlist&pid=" & F.get.int("pid"),"删除失败，本类下还有文章"
			end if
		else
			F.redirect MO_ROOT & "?m=admin&a=catlist&pid=" & F.get.int("pid"),"删除失败，还有子项"
		end if
	end sub
	
	public sub article
		dim keyword,sqlshere
		sqlshere=""
		keyword = F.get.safe("keyword")
		if keyword<>"" then sqlshere="Title like '%" & keyword & "%'"
		Set M = Model__("Diary","id").where(sqlshere).orderby("id desc").limit(F.get.int("page",1),10).query()
		M.assign("articles")
		Mo.display "admin:Admin:articlelist"
	end sub
	
	public sub articleedit
		dim id,list,D,D_,D__,D___ : id =  F.get.int("id")
		Model__("Diary","id").where("id=" & id).query().assign()
		set list = Mo___()
		
		Set D = Model__("Classes","id").orderby("id asc").where("Class_Type=28").query().fetch()
		'仅支持二级目录
		do while not D.Eof()
			Set D_ = D.Read()
			list.addnew()
			list.set "ID",D_.getter__("ID")
			list.set "Class_Name",D_.getter__("Class_Name")
			list.set "Class_PName",""
			Set D__ = Model__("Classes","id").orderby("id asc").where("Class_Type=" & D_.getter__("ID")).query().fetch()
			do while not D__.eof()
				Set D___ = D__.Read()
				list.addnew()
				list.set "ID",D___.getter__("ID")
				list.set "Class_Name",D___.getter__("Class_Name")
				list.set "Class_PName",D_.getter__("Class_Name")
			loop
		loop
		Mo.Assign "classes",list
		Mo.Assign "id",id
		Mo.display "admin:Admin:articleedit"
	end sub
	
	public sub deletearticle
		dim id,M,D : id =  F.get.safe("id")
		if id="" then id=0
		set M = Model__("Diary","id").where("id in(" & id & ")").query()
		set D = M.fetch()
		if D.Eof() then
			F.goto MO_ROOT & "?m=admin&a=article&msg=" & F.encode("记录不存在")
		else
			dim D_
			do while not D.Eof()
				set D_ = D.Read()
				Model__("Guestbook","id").where("forarticle=1 and pid=" & D_.getter__("id")).delete()
				Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除文章【" & D_.getter__("Title") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
				Call Mo("Tags").ReFreashTags(D_.getter__("Tags"))
				Model__("Classes","id").query "UPDATE Mo_Classes SET Class_Count = " & Model__("Diary","id").where("ClassID = " & D_.getter__("ClassID")).count() & " where ID=" & D_.getter__("ClassID")
			loop
			M.delete()
			F.goto MO_ROOT & "?m=admin&a=article&page=" & F.get.int("page") & "&msg=" & F.encode("已删除")
		end if
	end sub
	
	public sub articlesave
		F.post "ClassName",Model__("Classes","id").where("ID=" & F.post.int("ClassID")).query().read("Class_Name")
		dim classpath,D_,D,trackback,trackback_return,trackback_response,article_id
		classpath=""
		set D_ = Model__("Classes","id").where("ID=" & F.post.int("ClassID")).query().fetch()
		do while not D_.eof()
			set D = D_.read()
			classpath = D.getter__("ID") & "," & classpath
			set D_ = Model__("Classes","id").where("ID=" & D.getter__("Class_Type")).query().fetch()
		loop
		if len(classpath)<>"" then classpath = left(classpath,len(classpath)-1)
		F.post "ClassPath",classpath
		if F.post.int("id")=0 then
			F.post "library",formatdate(now(),"YYYY年MM月")
			F.post "trackback",F.post.Safe("trackback",255)
			Model__("Diary","id").insert()
			article_id = Model__("Diary","id").max()
		else
			Model__("Diary","id").update()
			article_id = F.post.int("id")
		end if
		Model__("Classes","ID").where("ID=" & F.post.int("ClassID")).update "Class_Count",Model__("Diary","id").where("ClassID = " & F.post.int("ClassID")).count()
		Call Mo("Tags")(F.post.safe("Tags"))
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","添加/修改文章【" & F.post("Title") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		if (F.post.int("id")=0 or F.post("trackping:i")="yes") and F.post.Safe("trackback")<>"" then
			trackback = "title=" & F.encode(F.post.Safe("Title")) & "&excerpt=" & F.encode(Left(ReplaceEx(F.post("Content"),"(<([\s\S]+?)>|\s)",""),200) & "。") & "&url=" & F.encode(Mo.Value("blog_hostname") & "/?m=home&a=show&id=" & article_id) & "&blog_name=" & F.encode(Mo.Value("blog_title"))
			trackback_response = "已发送通告引用：" & Mo("HttpRequest").New(F.post.Safe("trackback"),"POST",trackback).gettext("utf-8")
		end if
		F.goto MO_ROOT & "?m=admin&a=article&page=" & F.get.int("page") & "&msg=" & F.encode("已保存。" & trackback_response)
	end sub
	
	sub trackback
		Model__("Trackbacks","id").where("artid=" & F.get.Int("id",0)).orderby("id desc").limit(F.get.int("page",1),10).query().assign "trackbacks"
		Mo.display "admin:Admin:trackbacklist"		
	end sub
	
	public sub updatetrackbacks
		Model__("Trackbacks","id").where("id = " & F.get.int("id",0)).toogle "canshow"
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改引用通告状态","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=trackback&id=" & F.get.int("artid",0) & "&page=" & F.get.Int("page",1) & "&msg=" & F.encode("已更改状态")
	end sub
	public sub deletetrackbacks
		Model__("Trackbacks","id").where("id in(" & F.get.int("id",0,true) & ")").delete()
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除引用通告","ip",F.server("REMOTE_ADDR"),"status","成功"
		Model__("Diary","id").where("id=" & F.get.int("artid",0)).update "trackback_count",Model__("Trackbacks","id").where("artid=" & F.get.int("artid",0)).count()
		F.goto MO_ROOT & "?m=admin&a=trackback&id=" & F.get.int("artid",0) & "&page=" & F.get.Int("page",1) & "&msg=" & F.encode("已删除")
	end sub
		
	sub updatetag
		dim D,Tag:set D = Model__("Tags","id").query().fetch()
		dim tagcount
		tagcount = 0
		do while not D.eof()
			Tag = D.read().getter__("name")
			if Tag<>"" then
				Model__("Tags","id").where("name='" & Tag & "'").update "counts",Model__("Diary","id").where("Is_Secret = 0 and ','+Tags+',' like '%," & Tag & ",%'").count("id")
				tagcount = tagcount + 1
			end if
		loop
		Mo.assign "tagcount",tagcount
		Mo.display "admin:Admin:updatetag"
	end sub
	sub updatecats
		dim D,Tag:set D = Model__("Classes","ID").query().fetch()
		dim tagcount
		tagcount = 0
		do while not D.eof()
			Tag = D.read().getter__("ID")
			if Tag<>"" then
				Model__("Classes","ID").where("ID=" & Tag).update "Class_Count",Model__("Diary","id").where("Is_Secret = 0 and ClassID = " & Tag).count("id")
				tagcount = tagcount + 1
			end if
		loop
		Mo.assign "tagcount",tagcount
		Mo.display "admin:Admin:updatecats"
	end sub
	sub clearcache
		Mo.assign "comb",Mo.ClearCompiledCache()
		Mo.assign "app",Mo.ClearLibraryCache()
		'F.goto MO_ROOT & "?m=admin&msg=" & F.encode("缓存清理完成")
		Mo.display "admin:Admin:clearcache"
	end sub
	public sub links
		dim keyword,sqlshere
		sqlshere=""
		keyword = F.get.safe("keyword")
		if keyword<>"" then sqlshere="title like '%" & keyword & "%'"
		Model__("Links","ID").where(sqlshere).orderby("Link_order desc,ID desc").limit(F.get.int("page",1),10).query().assign "Links"
		Mo.display "admin:Admin:linklist"
	end sub
	
	public sub album
		Model__("Album","id").orderby("orderby desc,id desc").limit(F.get.int("page",1),10).query().assign "Albums"
		Mo.display "admin:Admin:albumlist"
	end sub
	
	public sub albumphotos
		Model__("Album","id").where("id=" & F.get.int("id")).query().assign "Album",true
		Model__("Album_Photos","id").where("albumid=" & F.get.int("id")).orderby("orderby desc,id desc").query().assign "Photos" 
		Mo.display "admin:Admin:albumphotolist"
	end sub
	
	public sub deletelinks
		Model__("Links","id").where("id in(" & F.get.int("id",0,true) & ")").delete()
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除友情链接","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=Links&msg=" & F.encode("已删除")
	end sub
	
	public sub pings
		dim id:id = F.get.int("id")
		Mo.Assign "id",id
		if id>0 then Model__("Ping","id").where("id=" & id).query().assign "Ping",true
		Model__("Ping","id").where(sqlshere).orderby("id desc").limit(F.get.int("page",1),10).query().assign "Pings" 
		Mo.display "admin:Admin:pinglist"
	end sub
	
	public sub savepings
		if F.post.int("id")=0 then
			Model__("Ping","id").insert()
		else
			Model__("Ping","id").update()
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","添加/修改ping地址【" & F.post("name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=pings&msg=" & F.encode("已保存")	
	end sub
	public sub deletepings
		dim id : id =  F.get.int("id")
		Model__("Ping","id").where("id=" & id).delete()
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除ping地址","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=pings&msg=" & F.encode("已删除")
	end sub
	
	public sub ping
		on error resume next
		if F.get.int("id")>0 then
			if Mo.Value("blog_ping_opened") ="yes" then
				dim PingUrls,PingUrl,PingMethod,PingContent,returnValue
				set PingUrls = Model__("Ping","id").where("enabled='yes'").query().fetch()
				dim Results:set Results = Mo___()
				do while not PingUrls.Eof()
					PingUrl = PingUrls.Read().getter__("url")
					PingMethod="weblogUpdates.extendedPing"
					if instr(PingUrl,";")>0 then
						PingMethod = mid(PingUrl,instrrev(PingUrl,";")+1)
						PingUrl = mid(PingUrl,1,instrrev(PingUrl,";")-1)
					end if
					Mo.assign "ping_method",PingMethod
					Mo.assign "aid",F.get.int("id")
					PingContent = Mo.fetch("admin:Admin:ping")
					if PingContent<>"" then
						err.clear
						returnValue = returnValue & "Ping请求：" & PingUrl & "<br />"
						Results.Addnew
						Results.set "url",PingUrl
						Dim objHttp
						Set objHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
						objHttp.SetTimeOuts 10000, 10000, 10000, 10000
						objHttp.open "POST",PingUrl, False
						objHttp.setRequestHeader "Content-Type", "text/xml"
						objHttp.send PingContent
						if err then 
							Results.set "result",err.description
						else
							Results.set "result",F.encodeHtml(objHttp.responseText)
						end if
						Set objHttp = Nothing
					end if
				loop
				Results.Assign "Results"
				Mo.assign "PingResult","已处理完毕。"
			else
				Mo.assign "PingResult","Ping功能已关闭，可以进入“站点设置”修改相关配置"
			end if
		else
			Mo.assign "PingResult","参数错误"
		end if
		Mo.display "admin:Admin:pingresult"
		err.clear
	end sub
	
	public sub safe
		Mo.display "admin:Admin:safe"
	end sub
	public sub safesave
		dim username,oldpwd,newpwd,renewpwd,oldusername,rndstr_
		oldusername = F.Session(MO_APP_NAME & "_UserName")
		username = F.post("username")
		username = replaceex(username,"([^\w]+)","")
		oldpwd = F.post("oldpwd")
		newpwd = F.post("newpwd")
		renewpwd = F.post("renewpwd")
		if oldpwd="" then
			F.goto MO_ROOT & "?m=admin&a=safe&msg=" & F.encode("未更改")
			exit sub
		end if
		Set Db = Model__("Admin","id")
		Set Data = Db.select().where("An_Admin='" & oldusername & "'").query().fetch()
		if Data.Eof() then
			F.goto MO_ROOT & "?m=admin&a=safe&msg=" & F.encode("账号不存在")
		else
			Set User = Data.Read()
			if Md5(oldpwd & User.An_Rnd)=User.An_Pwd then
				dim changed
				changed = false
				if oldusername<>username then 
					Db.where("An_Admin='" & oldusername & "'").update "An_Admin",username
					oldusername = username
					Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改用户名【" & oldusername & "】为【" & username & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
					changed = true
				end if
				if newpwd<>"" then
					if newpwd<>renewpwd then
						F.goto MO_ROOT & "?m=admin&a=safe&msg=" & F.encode("两次输入不一样")
					else
						rndstr_ = rndstr1(10)
						Db.where("An_Admin='" & oldusername & "'").update "An_Pwd",Md5(newpwd&rndstr_),"An_Rnd",rndstr_
						Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改密码","ip",F.server("REMOTE_ADDR"),"status","成功"
						changed = true
					end if
				end if
			else
				Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改密码：原密码错误","ip",F.server("REMOTE_ADDR"),"status","失败"
				F.goto MO_ROOT & "?m=admin&a=safe&msg=" & F.encode("原密码错误")
			end if
			if changed then
				F.goto MO_ROOT & "?m=login&a=doLogout&msg=" & F.encode("修改成功，请重新登录")
			else
				F.goto MO_ROOT & "?m=admin&a=safe&msg=" & F.encode("未做任何修改")
			end if
		end if
	end sub
	
	public sub logs
		Model__("Log","id").orderby("id desc").limit(F.get.int("page",1),20).query().assign "Logs" 
		Mo.display "admin:Admin:logs"
	end sub
	
	public sub deletelogs
		if F.get.safe("id")="-1" then
			Model__("Log","id").delete()
			Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","清空操作记录","ip",F.server("REMOTE_ADDR"),"status","成功"
		else
			Model__("Log","id").where("id in(" & F.get.safe("id") & ")").delete()
			Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除操作记录","ip",F.server("REMOTE_ADDR"),"status","成功"
		end if
		F.goto F.get("ref") & "&msg=" & F.encode("成功删除")
	end sub
	
	public sub comments
		dim ty,keyword,sqlshere
		ty = f.get.int("t")
		if ty<>0 then ty=1
		sqlshere=""
		keyword = F.get.safe("keyword")
		if keyword<>"" then sqlshere=" and content like '%" & keyword & "%'"
		
		Mo.Assign "ty",ty
		Model__("Guestbook","id").where("forarticle=" & ty & sqlshere).orderby("id desc").limit(F.get.int("page",1),10).query().assign "Comments"
		Mo.display "admin:Admin:comments"
	end sub
	
	public sub commentview
		Model__("Guestbook","id").where("id=" & f.get.int("id")).query().assign()
		Mo.display "admin:Admin:commentview"
	end sub
	public sub commentread
		Model__("Guestbook","id").where("id=" & f.get.int("id")).update "isreplay",1
		F.goto MO_ROOT & "?m=admin&a=comments&t=" & F.get.int("t",0) & "&msg=" & F.encode("已标记为已读")
	end sub
	
	public sub updatecomments
		Model__("Guestbook","id").where("id = " & F.get.int("id",0)).toogle "checked"
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","审核留言/评论","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=comments&t=" & F.get.int("t",0) & "&page=" & F.get.Int("page",1) & "&msg=" & F.encode("已更改状态")
	end sub
	public sub savereply
		dim msg,action
		action = F.post("submit")
		F.post.remove "submit"
		Model__("Guestbook","id").update()
		msg = "已回复"
		if F.post("email")<>"" and action="回复" then
			if Mo.Value("blog_allow_mail_send") = "yes" then
				if Mo.Value("blog_mail_server")<>"" then
					dim jmail
					set jmail = Mo("Jmail")
					if jmail.enabled() then
						jmail.login Mo.Value("blog_mail_server"),Mo.Value("blog_mail_username"),Mo.Value("blog_mail_password")
						jmail.from Mo.Value("blog_mail_sender"),Mo.Value("blog_mail_display")
						jmail.to F.post("email"),F.post("name")
						jmail.setMessage "您的留言/评论已被回复","<a href=""" & Mo.Value("blog_hostname") & "?m=home&a=guest&id=" & F.post.int("id") & """ target=""_blank"">立即查看</a>，本邮件来自" & Mo.Value("blog_title") & "，可放心打开链接。"
						if jmail.send() then
							msg = msg & "，已发送通知邮件"
						else
							msg = msg & "，邮件发送失败。" & jmail.Exception
						end if
					else
						msg = msg & "，但Jmail组件不可用，无法发送通知邮件"
					end if
				else
					msg = msg & "，未设置SMTP信息，无法发送通知邮件"
				end if
			else
				msg = msg & "，未开启邮件通知功能，无法发送通知邮件"
			end if
		else
			msg = msg & "，访客未留下邮箱或您仅仅是修改的回复内容，未发送通知邮件"
		end if
		F.goto MO_ROOT & "?m=admin&a=comments&t=" & F.get("t") & "&msg=" & F.encode(msg)
	end sub
	public sub deletecomments
		Model__("Guestbook","id").where("id in(" & F.get.int("id",0,true) & ")").delete()
		F.goto MO_ROOT & "?m=admin&a=comments&t=" & F.get.int("t")
	end sub
	
	public sub taglist
		dim pid,id,d_,r_ ,keyword,sqlshere: id =  F.get.int("id")
		keyword = F.get.safe("keyword")
		if keyword<>"" then sqlshere="name like '%" & keyword & "%'"
		Mo.Assign "id",id
		if id>0 then Model__("Tags","id").where("id=" & id).query().assign()
		Model__("Tags","id").where(sqlshere).orderby("id desc").limit(F.get.int("page",1),10).query().assign "Tags"
		Mo.display "admin:Admin:taglist"
	end sub
	
	public sub savetag
		if F.post.int("id")=0 then
			Model__("Tags","id").insert()
		else
			Model__("Tags","id").update()
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改/增加标签【" & F.post("name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=taglist&msg=" & F.encode("已保存") & "&page=" & F.get.int("page",1)
	end sub
	public sub deletetag
		Model__("Tags","id").where("id in(" & F.get.int("id",0,true) & ")").delete()
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除标签","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=taglist&msg=" & F.encode("已删除")
	end sub
	
	public sub attachment_list_json
		Response.Write Model__("Attachment","id").select("id,name,upload_date,update_date").orderby("id desc").query().getjson()
	end sub
	
	public sub attachmentlist
		dim pid,id,d_,r_ ,keyword,sqlshere: id =  F.get.int("id",0)
		keyword = F.get.safe("keyword")
		if keyword<>"" then sqlshere="name like '%" & keyword & "%'"
		Mo.Assign "id",id
		if id>0 then Model__("Attachment","id").where("id=" & id).query().assign()
		Model__("Attachment","id").where(sqlshere).orderby("id desc").limit(F.get.int("page",1),10).query().assign "Attachment"
		Mo.display "admin:Admin:attachmentlist"
	end sub
	
	public sub saveattachment
		dim R_
		set R_ = Record__()
		R_.set "name",F.post("name")
		R_.set "path",F.post("path")
		R_.set "update_date",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss")
		if F.post.int("id",0)=0 then
			Model__("Attachment","id").insert R_
		else
			Model__("Attachment","id").where("id=" & F.post.int("id")).update R_
			if F.post("path")<>F.post("oldpath") then F.deletefile F.mappath(F.post("oldpath"))
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","修改/增加附件【" & F.post("name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=attachmentlist&msg=" & F.encode("已保存") & "&page=" & F.get.int("page",1)
	end sub
	public sub deleteattachment
		dim id ,M,D,D_,R_: id =  F.get.int("id",0,true)
		set M= Model__("Attachment","id").where("id in (" & id & ")").query()
		set D = M.fetch()
		do while not D.eof()
			set D_ = D.read()
			F.deletefile D_.getter__("path")
		loop
		M.delete()
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","删除附件","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.goto MO_ROOT & "?m=admin&a=attachmentlist&msg=" & F.encode("已删除")
	end sub
	
	public sub upload
		Dim Upload,path,File,e
		set Upload=Mo("Upload")
		Upload.AllowMaxFileSize=Mo.C("Blog").UploadMaxSize
		Upload.AllowMaxSize=Mo.C("Blog").UploadMaxSize
		Upload.AllowFileTypes=Mo.C("Blog").UploadAllowFileTypes
		Upload.Charset="utf-8"
		if Not Upload.GetData() then
			response.Write("{""error"":1,""message"":""" & Upload.Description & """}")
		else
			path = MO_ROOT & "__file__/"
			if F.get("image")="true" then path=MO_ROOT & "Images/Upload/"
			if F.get("album")="true" then path=Mo.C("Blog").AlbumPath & F.get.safe("albumname")
			Upload.SavePath = path
			set File = Upload.Save("filedata",0,true)
			if File.Succeed then
				dim R_,Maxid
				Maxid = 0
				if F.get("auto")="true" then
					set R_ = Record__()
					R_.set "name",File.LocalName
					R_.set "path",path & File.FileName
					R_.set "update_date",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss")
					Model__("Attachment","id").insert R_
					Maxid = Model__("Attachment","id").max()
				end if
				if F.get("album")="true" then
					set R_ = Record__()
					R_.set "name",File.LocalName
					R_.set "create_date",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss")
					R_.set "photo_date",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss")
					R_.set "albumid",F.get.int("albumid")
					R_.set "width",0
					R_.set "height",0
					R_.set "path",F.get.safe("albumname") & "/" & File.FileName
					dim jpeg:set jpeg = Mo("Image")
					if jpeg.enabled then
						if jpeg.load(F.mappath(path&"/" & File.FileName)) then
							R_.set "width",jpeg.width
							R_.set "height",jpeg.height	
							if jpeg.GetThumb(Mo.C("Blog").ThumbMaxWidth,Mo.C("Blog").ThumbMaxHeight) then
								R_.set "t_width",jpeg.width
								R_.set "t_height",jpeg.height
								jpeg.Save F.mappath(path & "/thumb_" &  File.FileName)
								R_.set "t_path",F.get.safe("albumname") & "/thumb_" &  File.FileName
							end if			
						end if
					end if
					set jpeg = nothing
					Model__("Album_Photos","id").insert R_				
				end if
				response.Write("{""error"":0,""message"":""upload"",""name"":""" & File.FileName & """,""src"":""" & File.LocalName & """,""max"":""" & Maxid & """}")
			else
				response.Write("{""error"":1,""message"":""" & File.Exception & """}")
			end if
		end if
		set Upload=nothing
	end sub
	
	sub usetemplate 
		Model__("System","id").where("id=1").update "blog_template",F.get.safe("t")
		F.goto MO_ROOT & "?m=admin&a=templates&msg=" & F.encode("模板成功应用")
	end sub
	
	sub templates
		dim templatedir,current,currentt,list
		templatedir = F.mappath(MO_APP & "Templates")
		current = Mo.value("blog_template")
		set currentt = Record__()
		set list = Mo___()
		dim folder,sf
		set folder = F.fso.getFolder(templatedir)
		for each sf in folder.subfolders
			if lcase(sf.name)<>"admin" and lcase(sf.name)<>"common" then
				if F.fso.FileExists(F.mappath(MO_APP & "Templates/" & sf.name & "/index.xml")) then
					dim xml
					set xml = F.activex("MSXML2.DomDocument")
					xml.load F.mappath(MO_APP & "Templates/" & sf.name & "/index.xml")
					if not(xml.documentElement is nothing) then
						dim name,version,forversion,createdatetime,moddatetime,author,email,description
						version =  xml.documentElement.selectSingleNode("/template").getAttribute("version")
						forversion =  xml.documentElement.selectSingleNode("/template").getAttribute("for")
						name = xml.documentElement.selectSingleNode("/template/name").text
						createdatetime = xml.documentElement.selectSingleNode("/template/createdatetime").text
						moddatetime = xml.documentElement.selectSingleNode("/template/moddatetime").text
						author = xml.documentElement.selectSingleNode("/template/author").text
						email = xml.documentElement.selectSingleNode("/template/email").text
						description = xml.documentElement.selectSingleNode("/template/description").text
						if lcase(current) = lcase(sf.name) then
							currentt.set "tname",sf.name
							currentt.set "name",name
							currentt.set "version",version
							currentt.set "for",forversion
							currentt.set "createdatetime",createdatetime
							currentt.set "moddatetime",moddatetime
							currentt.set "author",author
							currentt.set "email",email
							currentt.set "description",description
						else
							list.addnew
							list.set "tname",sf.name
							list.set "name",name
							list.set "version",version
							list.set "for",forversion
							list.set "createdatetime",createdatetime
							list.set "moddatetime",moddatetime
							list.set "author",author
							list.set "email",email
							list.set "description",description
						end if
					end if
				end if
			end if
		next
		currentt.assign "current"
		Mo.Assign "List",list
		Mo.Assign "CoreVersion",Mo.Version
		Mo.display "admin:Admin:templates"
	end sub
end class
%>