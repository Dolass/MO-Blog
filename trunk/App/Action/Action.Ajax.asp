<%
class ActionAjax
	private M,D
	private sub Class_Initialize()
		if F.session(MO_APP_NAME & "_Status")<>"yes" then
			set Mo = nothing
			F.exit "未登录，请先登录！"
		end if
	end sub
	
	private sub Class_Terminate()
	end sub
	
	
	public sub [empty](a)
		Mo.display "admin:admin:ajax"
	end sub
	
	public sub photo
		dim id:id = F.get.int("id")
		Mo.Assign "id",id
		if id>0 then Model__("Album_Photos","id").where("id=" & id).query().assign "Photo",true
		F.get "for","photo"
		Mo.display "admin:admin:ajax"	
	end sub
	public sub link
		dim id:id = F.get.int("id")
		Mo.Assign "id",id
		if id>0 then Model__("Links","ID").where("ID=" & id).query().assign "Link",true
		F.get "for","link"
		Mo.display "admin:admin:ajax"
	end sub
	
	public sub album
		dim id:id = F.get.int("id")
		Mo.Assign "id",id
		if id>0 then Model__("Album","id").where("id=" & id).query().assign "Album",true
		F.get "for","album"
		Mo.display "admin:admin:ajax"
	end sub
	
	public sub savelinks
		if F.post.int("id")=0 then
			Model__("Links","id").insert()
		else
			Model__("Links","id").update()
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","添加/修改友情链接【" & F.post("title") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.echo ("已保存")	
	end sub
	
	
	public sub savephoto
		if F.post.safe("isfirst")="1" then
			Model__("Album_Photos","id").where("albumid=" & F.get.int("albumid")).update "isfirst",0
		end if
		if F.post.int("id")=0 then
			Model__("Album_Photos","id").insert()
		else
			Model__("Album_Photos","id").update()
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","添加/修改图片【" & F.post("name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.echo ("已保存")	
	end sub
	
	public sub deletealbum
		dim id:id = f.get.Int("id")
		dim D:set D = Model__("Album_Photos","id").where("albumid=" & id).query().fetch()
		do while not D.eof()
			dim R:set R = D.read()
			f.get "id",R.getter__("id")
			Call deletephoto()
		loop
		Model__("Album","id").where("id=" & id).delete()
		F.deletefile Mo.C("Blog").AlbumPath & F.get.safe("tag"),true
		F.echo "相册已删除"
	end sub
	public sub deletephotos
		dim id:id = F.get.safe("id")
		dim idlist:idlist = split(id,",")
		if ubound(idlist)<0 then
			F.echo "没有选择任何照片"
		else
			dim i
			for i=0 to ubound(idlist)
				F.get "id",idlist(i)
				Call deletephoto()
			next
		end if
	end sub
	public sub deletephoto
		dim id:id = f.get.Int("id")
		dim D:set D = Model__("Album_Photos","id").where("id=" & id).query().fetch()
		if not D.eof() then
			dim R,path,t_path:set R = D.read()
			path = R.getter__("path")
			t_path = R.getter__("t_path")
			F.deletefile Mo.C("Blog").AlbumPath & path
			F.deletefile Mo.C("Blog").AlbumPath & t_path
			Model__("Album_Photos","id").where("id=" & id).delete()
			F.echo "已删除照片"
		else
			F.echo "照片不存在"
		end if
	end sub
	public sub savealbum
		if F.post.int("id")=0 then
			Model__("Album","id").insert()
		else
			Model__("Album","id").update()
		end if
		Model__("Log","id").Insert "username",F.Session(MO_APP_NAME & "_UserName"),"model",Mo.method,"action",Mo.action,"description","添加/修改相册【" & F.post("name") & "】","ip",F.server("REMOTE_ADDR"),"status","成功"
		F.echo ("已保存")	
	end sub
end class
%>