<%
class ActionLogin
	private sub Class_Initialize()

	end sub
	
	private sub Class_Terminate()
	end sub
	public sub [Index]
		Call Login()
	end sub
	public sub [Empty](a)
		Call Login()
	end sub
	public sub Login
		Mo.display "admin:Admin:login"
	end sub
	public sub doLogout
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","用户退出","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.session MO_APP_NAME & "_Status","no"
		F.session MO_APP_NAME & "_UserName",""
		F.session MO_APP_NAME & "_LastDate",""
		F.session MO_APP_NAME & "_LastIP",""
		F.session MO_APP_NAME & "_LogCount",""
		F.redirect MO_ROOT & "?m=login&a=login","已退出"
	end sub
	public sub doLogin
		if F.session(MO_APP_NAME & "_mocode")="" or F.post("code")="" or F.session(MO_APP_NAME & "_mocode")<>F.post("code") then
			F.session MO_APP_NAME & "_mocode",""
			F.echo "验证码错误！"
			exit sub
		end if
		dim username,password,Db,Data
		username = F.post.safe("username")
		username = replaceex(username,"([^\w]+)","")
		password = F.post.safe("password")
		Set Db = Model__("Admin","id")
		Set Data = Db.select().where("An_Admin='" & username & "'").query().fetch()
		if Data.Eof() then
			Model__("Log","id").Insert "username",username,"model",Mo.method,"action",Mo.action,"description","账号不存在","ip",F.server("REMOTE_ADDR"),"status","失败"
			F.echo "认证信息错误啊！记错用户名了？记错密码了？"
		else
			Set User = Data.Read()
			if Md5(password & User.An_Rnd)=User.An_Pwd then
				F.session MO_APP_NAME & "_Status", "yes"
				F.session MO_APP_NAME & "_UserName", User.An_Admin
				F.session MO_APP_NAME & "_LastDate", User.An_LastDate
				F.session MO_APP_NAME & "_LastIP", User.An_LastIP
				F.session MO_APP_NAME & "_LogCount", User.An_LogCount
				Db.Where("id=" & User.id).Update "An_LastDate",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss"),"An_LastIP",F.server("REMOTE_ADDR"),"An_LogCount",User.An_LogCount+1
				Model__("Log","id").Insert "username",username,"model",Mo.method,"action",Mo.action,"description","登录成功","ip",F.server("REMOTE_ADDR"),"status","成功"
				F.echo "登录成功！"
			else
				Model__("Log","id").Insert "username",username,"model",Mo.method,"action",Mo.action,"description","密码错误","ip",F.server("REMOTE_ADDR"),"status","失败"
				F.echo "认证信息错误啊！记错用户名了？记错密码了？"
			end if
		end if
	end sub
end class
%>