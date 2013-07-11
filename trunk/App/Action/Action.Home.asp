<%
class ActionHome
	private mvarTag,mvarPageUrl
	private sub Class_Initialize()
		dim mvarWhiteList,mvarBlackList,mvarListArray,i,mvarRemoteAddr,canViewBlog,mvarBlockMode
		MO_TEMPLATE_NAME = Model__("System","id").where("id=1").query().assign("System",true).read("blog_template")
		if F.get.safe("view")="yes" then MO_TEMPLATE_NAME = F.get.safe("name")
		if MO_TEMPLATE_NAME="" then MO_TEMPLATE_NAME="default"
		
		if Mo.Values("System","blog_state_closed") = "yes" then
			Response.Status = "404 Not Found"
			Set Mo = nothing
			F.exit Mo.Values("System","blog_state_closed_reason")
		end if
		mvarBlockMode = Mo.Values("System","blog_block_mode")
		if mvarBlockMode="white" or mvarBlockMode="black" then
			mvarRemoteAddr = F.server("REMOTE_ADDR")
			mvarRemoteAddr = Replace(mvarRemoteAddr,"::1","127.0.0.1")
			mvarWhiteList = Mo.Values("System","blog_block_" & mvarBlockMode)
			canViewBlog = (mvarBlockMode="black")
			if mvarWhiteList<>"" then
				mvarListArray = Split(mvarWhiteList,",")
				if ubound(mvarListArray)>=0 then
					for i=0 to ubound(mvarListArray)
						if Mo.Static("Net").InSameNetWork(mvarListArray(i),mvarRemoteAddr) then
							canViewBlog = (mvarBlockMode<>"black")
							exit for
						end if
					next
				end if
			end if
			if not canViewBlog then
				Response.Status = "404 Not Found"
				Set Mo = nothing
				F.exit "您的IP地址[" & mvarRemoteAddr & "]在我们的阻止列表里面。"
			end if
		end if
	end sub
	
	private sub common__
		Model__("Tags","id").select("top 50 *").orderby("counts desc").query().assign "TagsCloud" 
		Model__("Diary","id").select("library,count(library) as num").where("Is_Secret=0").groupby("library").orderby("library desc").query().assign "Librarys"
		dim list
		set list = Mo___()
		set D = Model__("Classes","id").where("Class_Type=28").orderby("Class_Order desc").query().fetch()
		'仅支持二级目录
		dim index,counts,idlist
		do while not D.Eof()
			set D_ = D.Read()
			index = list.addnew()
			list.set "ID",D_.getter__("ID")
			list.set "Class_Name",D_.getter__("Class_Name")
			list.set "Class_PName",""
			list.set "Class_Tag",D_.getter__("Class_Tag")
			counts = D_.getter__("Class_Count")
			idlist = D_.getter__("ID")
			set D__ = Model__("Classes","id").where("Class_Type=" & D_.getter__("ID")).orderby("Class_Order desc").query().fetch()
			do while not D__.eof()
				set D___ = D__.Read()
				list.addnew()
				list.set "ID",D___.getter__("ID")
				list.set "Class_Name",D___.getter__("Class_Name")
				list.set "Class_PName",D_.getter__("Class_Name")
				list.set "Class_Tag",D___.getter__("Class_Tag")
				list.set "counts",D___.getter__("Class_Count")
				list.set "idlist",D___.getter__("ID")
				idlist = idlist & "," & D___.getter__("ID")
				counts = counts + D___.getter__("Class_Count")
			loop
			list.set "counts",counts,index
			list.set "idlist",idlist,index
		loop
		Mo.assign "cats",list
		Model__("Links","id").where("ischecked=1").select("top 20 title,url,author,id").orderby("link_order desc").query().assign "Links"
		Model__("Guestbook","id").select("top 10 id,pid as article_id,content,name").where("forarticle=1 and secret='no' and checked=1").orderby("id desc").query().assign "Comments"
		Model__("Guestbook","id").select("top 10 id,pid,Content,name").where("forarticle=0 and secret='no' and checked=1").orderby("id desc").query().assign "Guests"
		Model__("Album","id").select("top 6 id,name,(select top 1 t_path from Mo_Album_Photos where albumid=Mo_Album.id order by isfirst desc,id desc) as t_path").where("issecret='n'").orderby("orderby desc,id desc").query().assign "Albums"
	end sub
	private sub Class_Terminate()
	end sub
	
	public sub Index
		Model__("Diary","id").limit(F.get.int("page",1),10).where("Is_Secret=0").orderby("Is_Top desc,id desc").query().assign "diary"
		if F.get("ajax")="true" then
			Mo.display "IndexArticle"
		else
			Call common__()
			Mo.display "Index"
		end if
	end sub
	
	public sub cats
		dim pid,sqlwhere
		pid = F.get.int("cat",0,true)
		Mo.Assign "self_title","文章 - "
		sqlwhere = "Is_Secret=0"
		if pid<>"" then
			sqlwhere=sqlwhere & " and ClassID in (" & pid & ")"
			Mo.Assign "self_title",Model__("Classes","ID").where("ID=" & split(pid,",")(0)).query().read("Class_Name") & " - "
		end if
		Model__("Diary","id").where(sqlwhere).limit(F.get.int("page",1),10).orderby("Is_Top desc,id desc").query().assign "diary"
		if F.get("ajax")="true" then
			Mo.display "IndexArticle"
		else
			Call common__()
			Mo.display "Index"
		end if
	end sub
	public sub Search
		Call common__()
		dim keyword,sqlwhere:keyword = F.get.safe("keyword")
		Mo.Assign "self_title","搜索结果：" & keyword & " - "
		sqlwhere = "Is_Secret=0"
		if keyword<>"" then sqlwhere= sqlwhere & " and title like '%" & left(keyword,20) & "%'"
		Mo.Assign "keyword",keyword
		Model__("Diary","id").select("id,Title,AddDate,Tags,views,ClassID,ClassName").limit(F.get.int("page",1),10).where(sqlwhere).orderby("id desc").query().assign "diary"
		Mo.display "Search"
	end sub
	public sub library
		Call common__()
		dim keyword,sqlwhere:keyword = replaceex(F.get.safe("keyword"),"^([^\d]*)(\d+)年(\d+)月(.*)$","$2年$3月")
		if regtest(keyword,"\d{6}") then keyword = replaceex(keyword,"^(\d{4})(\d{2})$","$1年$2月")
		Mo.Assign "self_title","文章归档：" & keyword & " - "
		sqlwhere = "Is_Secret=0"
		if keyword<>"" then sqlwhere= sqlwhere & " and library = '" & keyword & "'"
		Mo.Assign "keyword",keyword
		Model__("Diary","id").select("id,Title,AddDate,Tags,views,ClassID,ClassName").limit(F.get.int("page",1),10).where(sqlwhere).orderby("id desc").query().assign "diary" 
		Mo.display "Search"
	end sub
	public sub show
		Call common__()
		dim id:id= F.get.int("id")
		dim Db
		set Db = Model__("Diary","id").where("Is_Secret = 0 and id =" & id).query().assign().fetch()
		if not Db.Eof() then
			dim R
			set R = Db.read()
			dim can_comment
			can_comment = Mo.values("System","blog_allow_comments")
			if can_comment="yes" then
				if R.getter__("can_comment")<>1 then can_comment = "no"
			else
				can_comment = "no"
			end if
			Mo.Assign "self_title",R.Title & " - "
			Mo.Assign "can_comment",can_comment
			Mo.Assign "self_keywords",R.Tags & ","
			Mo.Assign "self_description",Left(ReplaceEx(R.Content,"(<([\s\S]+?)>|\s)",""),200) & "。"
			Model__("Guestbook","id").where("pid=" & id & " and forarticle=1 and secret='no' and checked=1").limit(F.get.int("page",1),6).orderby("id desc").query().assign "aComments" 
			Model__("Diary","id").select("top 1 *").where("Is_Secret = 0 and id >" & id).orderby("id asc").query().assign "Next",true
			Model__("Diary","id").select("top 1 *").where("Is_Secret = 0 and id <" & id).orderby("id desc").query().assign "Last",true
			Mo.display "Show"
			if F.cookie("visited_" & id)="" then
				Model__("Diary","id").where("id=" & id).increase "views"
				F.cookie "visited_" & id,datediff("s",#2013-1-1#,now()),cint(Mo.values("System","blog_visit_timeout")) * 60
			end if
		else
			Response.Status="301 Permanently Moved"
			Response.AddHeader "Location","/"
		end if
	end sub
	public sub links
		Call common__()
		Mo.Assign "self_title","友情链接 - "
		Model__("Links","id").where("ischecked=1 and isimage=1").orderby("link_order desc").query().assign "LinksImage"
		Model__("Links","id").where("ischecked=1 and isimage=0").orderby("link_order desc").query().assign "LinksText"
		Mo.display "Links"
	end sub
	public sub clicklink
		Model__("Links","id").where("id=" & F.get.int("id")).increase "clickcount"
	end sub
	public sub photos
		Call common__()
		Mo.Assign "self_title","相册 - " & Model__("Album","id").where("id=" & F.get.int("id")).query().assign("Album",true).read("name") & " - "
		Mo.display "Photos"
	end sub
	public sub gallerydata
		F.echo Model__("Album_Photos","id").where("albumid=" & F.get.int("id")).orderby("orderby desc,id desc").query().getjson()
	end sub
	
	public sub guest
		Call common__()
		Mo.Assign "self_title","访客留言 - "
		dim id,sqlwhere:id= F.get.int("id")
		if id>0 then sqlwhere=" and id=" & id
		Model__("GuestBook","id").pageurl(mvarPageUrl).where("forarticle=0 and checked=1 and secret='no'" & sqlwhere).limit(F.get.int("page",1),6).orderby("id desc").query().assign "List"
		Mo.display "GuestBook"
	end sub
	public sub apply
		if Mo.Values("System","blog_allow_apply_links") <> "yes" then
			F.echo "管理员关闭了友情链接的申请！"
			exit sub
		end if
		if F.session(MO_APP_NAME & "_mocode")="" or F.post("code")="" or F.session(MO_APP_NAME & "_mocode")<>F.post("code") then
			F.echo "验证码错误哟！"
		else
			dim rs :set rs = Record__()
			rs.set "author",F.post.safe("name",50)
			rs.set "title",F.post.safe("title",50)
			rs.set "url",F.post.url("url")
			rs.set "isimage",0
			rs.set "ischecked",0
			rs.set "link_order",999
			if f.post.url("logo")<>"" then
				rs.set "isimage",1
				rs.set "image_",f.post.url("logo")
			end if
			Model__("Links","id").insert rs
			F.echo "已提交申请，请等待管理员审核"
		end if
		F.session MO_APP_NAME & "_mocode",""
	end sub
	public sub saveguest
		if Mo.Values("System","blog_allow_guestbook") <> "yes" then
			F.echo "管理员关闭了留言板哦！"
			exit sub
		end if
		if F.session(MO_APP_NAME & "_mocode")="" or F.post("code")="" or F.session(MO_APP_NAME & "_mocode")<>F.post("code") then
			F.echo "验证码错误哟！"
		else
			dim rs :set rs = Record__()
			rs.set "content",F.post.safe("content",512)
			rs.set "name",F.post.safe("name",50)
			rs.set "email",F.post.email("email")
			rs.set "ly_date",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss")
			rs.set "secret",F.post.safe("secret")
			if F.post.safe("secret")<>"yes" then rs.set "secret","no"
			rs.set "ly_ip",F.server("REMOTE_ADDR")
			rs.set "homepage",F.post.url("homepage")
			if Mo.Values("System","blog_comments_check")="yes" then rs.set "checked",0
			Model__("Guestbook","id").insert rs
			F.echo "成功提交啦！"
		end if
		F.session MO_APP_NAME & "_mocode",""
	end sub	
	public sub savecomment
		dim can_comment
		can_comment = Mo.values("System","blog_allow_comments")
		if can_comment="yes" then
			if Model__("Diary","id").where("Is_Secret = 0 and id =" & F.post.int("pid")).query().fetch().read("can_comment")<>1 then can_comment = "no"
		else
			can_comment = "no"
		end if
		if can_comment <> "yes" then
			F.echo "管理员关闭了评论功能！"
			exit sub
		end if
		if F.session(MO_APP_NAME & "_mocode")="" or F.post("code")="" or F.session(MO_APP_NAME & "_mocode")<>F.post("code") then
			F.echo "验证码错误哟！"
		else
			dim rs :set rs = Record__()
			rs.set "content",F.post.safe("content",512)
			rs.set "pid",F.post.int("pid")
			rs.set "forarticle",1
			rs.set "name",F.post.safe("name",50)
			rs.set "email",F.post.email("email")
			rs.set "ly_date",F.formatdate(now(),"yyyy-MM-dd HH:mm:ss")
			rs.set "secret",F.post.safe("secret")
			if F.post.safe("secret")<>"yes" then rs.set "secret","no"
			rs.set "ly_ip",F.server("REMOTE_ADDR")
			rs.set "homepage",F.post.url("homepage")
			if Mo.Values("System","blog_comments_check")="yes" then rs.set "checked",0
			Model__("Guestbook","id").insert rs
			F.echo "成功提交啦！"
		end if
		F.session MO_APP_NAME & "_mocode",""
	end sub	
	public sub safecode
		Mo("safecode").code MO_APP_NAME & "_mocode"
	end sub
	public sub tag
		Call common__()
		dim key,base64,D_,T_
		key = replaceEx(F.get("keyword"),"[^0-9a-zA-Z]+","")
		set D_ = Model__("Tags","id").where("tag='" & key & "'").query().fetch()
		if D_.Eof() then
			Mo.Assign "self_title","不存在的标签 - "
			Mo.Assign "diary",Mo___()
			Mo.display "Search"
		else
			set T_ = D_.Read()
			key = T_.getter__("name")
			Mo.Assign "self_title","标签：" & key & " - "
			if key<>"" then sqlwhere= "',' + Tags +',' like '%," & key & ",%'"
			Model__("Diary","id").select("id,Title,AddDate,Tags,views").limit(F.get.int("page",1),10).where(sqlwhere).orderby("id desc").query().assign "diary"
			Mo.display "Search"
		end if
	end sub
	public sub [empty](action)
		Call common__()
		Response.Status = "404 Not Found"
		Mo.Assign "action",action
		Mo.display "Error"
	end sub	
	public sub attachment()
		dim D_,R_,actpath,filename
		set D_= Model__("Attachment","id").where("id=" & F.get.int("id")).query().fetch()
		if not D_.eof() then
			set R_ = D_.read()
			actpath = server.MapPath(R_.getter__("path"))
			filename = R_.getter__("name")
			if not F.fso.FileExists(actpath) then
				response.Status="404 Not Found"
				response.Write "文件不存在"
			else
				dim stream,readed,block
				set stream = server.CreateObject("adodb.stream")
				stream.mode=3
				stream.type=1
				stream.open
				stream.loadfromfile actpath
				response.ContentType="application/octet-stream"
				response.AddHeader "Content-Disposition", "attachment; filename=""" & F.encode(filename) & """"
				readed =0
				block = 102400
				if 102400>=stream.size then
					Response.BinaryWrite Stream.Read(Stream.size)
				else
					do while readed<stream.size
						if readed+block>stream.size then block = stream.size-readed
						Response.BinaryWrite stream.read(block)
						readed=readed+block
					loop
				end if
				stream.close
				set stream = nothing	
				Model__("Attachment","id").where("id=" & F.get.int("id")).increase "counts"
			end if
		else
			response.Status="404 Not Found"
			response.Write "文件不存在"
		end if
	end sub
	public sub rss
		dim catid:catid = F.get.int("catid")
		dim xmltype:xmltype = lcase(F.get("type"))
		if xmltype<>"feed" and xmltype<>"atom" and xmltype<>"sitemap" then xmltype = "Rss"
		if catid>0 then
			Model__("Diary","id").where("Is_Secret=0 and ClassID=" & catid).orderby("id desc").query().assign "list"
		else
			catid = F.get.int("catid","",true)
			if catid<>"" then
				Model__("Diary","id").where("Is_Secret=0 and ClassID in(" & catid & ")").orderby("id desc").query().assign "list"
			else
				Model__("Diary","id").where("Is_Secret=0").orderby("id desc").query().assign "list"
			end if
		end if
		Mo.display "common:Home:" & xmltype
	end sub
	public sub trackbacks
		dim id:id = F.get.int("id",0)
		dim Db
		set Db = Model__("Diary","id").where("Is_Secret = 0 and id =" & id).query().assign("Art",true).fetch()
		if not Db.Eof() then
			Model__("Trackbacks","id").where("canshow=1 and artid=" & id).query().assign "items" 
			Mo.display "common:Home:TrackBack"
		else
			Response.Status="301 Permanently Moved"
			Response.AddHeader "Location","/"
		end if
	end sub
	public sub trackback_ping
		dim id,title,url,excerpt,blog_name,xmlstr,error_code,error_msg
		error_code = 0
		error_msg=""
		id = F.get.Int("id",0)
		title = F.post.Safe("title",255)
		url = F.post.url("url")
		excerpt = F.post.Safe("excerpt",255)
		blog_name = F.post.Safe("blog_name",255)
		if url="" then
			error_code = 1
			error_msg = "trackback参数不完整"
		else
			if title="" then title=url
			if Model__("Trackbacks","id").where("artid=" & id,"url='" & url & "'").query().fetch().Eof() then
				F.post "artid",id
				Model__("Trackbacks","id").insert()
				Model__("Diary","id").where("id=" & id).update "trackback_count",Model__("Trackbacks","id").where("artid=" & id).count()
			else
				error_code = 1
				error_msg = "本trackback已被请求过"
			end if
		end if
		xmlstr="<?xml version=""1.0"" encoding=""UTF-8""?>"
		xmlstr=xmlstr & "<response>"
		xmlstr=xmlstr & "<error>" & error_code & "</error>"
		if error_code=1 then xmlstr=xmlstr & "<message>" & error_msg & "</message>"
		xmlstr=xmlstr & "</response>"
		F.echo xmlstr
	end sub
end class
%>