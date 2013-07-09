<%function Temp___()
dim T:T=""
T = T & "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbcrlf & "<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""zh-cn"" lang=""zh-cn"">" & vbcrlf & "<head>" & vbcrlf & "    <meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />" & vbcrlf & "    <meta name=""keywords"" content=""" & Mo.value("self_keywords") & Mo.Values("System","blog_keyword")  & """ />" & vbcrlf & "    <meta name=""description"" content=""" & Mo.value("self_description") & Mo.Values("System","blog_description")  & """ />" & vbcrlf & "    <meta name=""google-site-verification"" content=""fvR3nari9hBgMrQZrv2S7Q24UfQnJU_pPtxs31TFMVE"" />" & vbcrlf & "    <meta name=""baidu-site-verification"" content=""9bpC0gvchh5GKWkv"" />" & vbcrlf & "    <title>" & Mo.value("self_title") & Mo.Values("System","title")  & "</title>" & vbcrlf & "    <link rel=""alternate"" type=""application/rss+xml"" title=""订阅 " & Mo.Values("System","blog_title") & " 所有文章"" href=""/?m=home&a=rss"" />" & vbcrlf & "	<link rel=""alternate"" type=""application/atom+xml"" href=""/?m=home&a=rss&type=atom"" title=""订阅 " & Mo.Values("System","blog_title") & " 所有文章(ATOM)"" />" & vbcrlf & "	<script type=""text/javascript"" src=""/Scripts/s.js""></script>" & vbcrlf & "	<script type=""text/javascript"" src=""/Scripts/f.js""></script>" & vbcrlf & "	<script type=""text/javascript"" src=""/Scripts/f.e.js""></script>" & vbcrlf & "	<script type=""text/javascript"" src=""/Scripts/f.ajax.js""></script>" & vbcrlf & "    <script type=""text/javascript"">" & vbcrlf & "	var MessageType={Error:1,Notice:2,Information:3};" & vbcrlf & "	var MessageBox={timeout:1500,show:function(message,mt){var classname=""information"";if(mt==MessageType.Error)classname=""error"";if(mt==MessageType.Notice)classname=""notice"";F(""#mo-tips"").css({""display"":""block""});F(""#mo-tips-content"").html(message).Class(classname);if(MessageBox.timeout>0)window.setTimeout(function(){F(""#mo-tips"").css({""display"":""none""});},MessageBox.timeout);},showError:function(message){MessageBox.show(message,MessageType.Error);},showNotice:function(message){MessageBox.show(message,MessageType.Notice);},showInformation:function(message){MessageBox.show(message,MessageType.Information);}};" & vbcrlf & "	</script>" & vbcrlf & "    <link href=""/App/Templates/" & MO_TEMPLATE_NAME & "/Home/layout.css"" rel=""stylesheet"" />" & vbcrlf & "</head>" & vbcrlf & "<body>" & vbcrlf & "	<div id=""mo-top"">" & vbcrlf & "    		<div id=""mo-top-main"">" & vbcrlf & "        	<h2><a href=""/"">" & Mo.Values("System","blog_title") & "</a></h2>" & vbcrlf & "            <h3>" & Mo.Values("System","blog_sub_title") & "</h3>" & vbcrlf & "            </div>" & vbcrlf & "    </div>" & vbcrlf & "	<div id=""mo-body"" class=""clearfix"">" & vbcrlf & "<div id=""mo-body-left"">" & vbcrlf & "<div id=""mo-art-list"">" & vbcrlf
if Mo.Exists("diary") then
set D__diary = Mo.value("diary")
if D__diary.eof() then T = T & "<div class=""mo-box-eof"">还没有任何文章可看哈！</div>"
do while not D__diary.eof()
set C__diary =  D__diary.read()
T = T & "    <div class=""mo-box-left"
if (C__diary.getter__("Is_Top") = "1") then T = T & " mo-istop-1"
T = T & """>" & vbcrlf & "        <div class=""mo-box-left-content hslice"">" & vbcrlf & "            <h2><a href=""/?m=home&a=show&id=" & C__diary.getter__("id") & """>"
if (C__diary.getter__("Is_Top") = "1") then T = T & "【置顶】"
T = T & C__diary.getter__("Title")
T = T & "</a></h2>" & vbcrlf & "            <h3>" & FormatDate(C__diary.getter__("AddDate"),"01") & " 分类：<a href=""/?m=home&a=cats&cat=" & C__diary.getter__("ClassID") & """>" & C__diary.getter__("ClassName") & "</a> 标签："
T = T & Mo.Static("Common").ActTags(C__diary.getter__("Tags"),true)
if (C__diary.getter__("views") > "0") then T = T & " 浏览：" & C__diary.getter__("views") & "次"
T = T & "</h3>" & vbcrlf & "            "
if (C__diary.getter__("Is_Top") = "0") then T = T & "<div class=""mo-box-left-diary"">" & Mo.Static("Common").GetIndexHtml(C__diary.getter__("Content")) & "</div>"
T = T & "        </div>" & vbcrlf & "    </div>" & vbcrlf
Loop 
End If
T = T & "</div>" & vbcrlf & "<div class=""pagestr_index"">" & CreatePageList("/?m=home&a=cats&cat=" & F.get("cat") & "&page={#page}",D__diary.recordcount,D__diary.pagesize,D__diary.currentpage) & "</div>" & vbcrlf & "<div id=""mo-more"" class=""mo-box-left mo-more"" rel=""m=" & F.get("m") & "&a=" & F.get("a") & "m&cat=" & F.get("cat") & "&page=" & F.get("page") & """>" & vbcrlf & "<div class=""mo-box-left-content""><h2 id=""mo-more-content"">更多文章。。。</h2></div>" & vbcrlf & "</div>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "F("".mo-box-left-diary img"").lazyLoad({replaceHolder:""/Images/blank.gif"",offset:0});" & vbcrlf & "var parms={""a"":""" & F.get("a") & """,""m"":""" & F.get("m") & """,""cat"":""" & F.get("cat") & """,""page"":""" & F.get("page") & """,""ajax"":""true""};" & vbcrlf & "if(parms.page=="""")parms.page=1;" & vbcrlf & "var loaded=true;" & vbcrlf & "var atend=false;" & vbcrlf & "if(parms.a==""cats""){" & vbcrlf & "	F(window).scroll(LoadMore);" & vbcrlf & "	LoadMore();" & vbcrlf & "}else{" & vbcrlf & "	F(""#mo-more"").css(""display"",""none"");" & vbcrlf & "}" & vbcrlf & "F(""pre.prettyprint"").each(function(i){" & vbcrlf & "	var pre = this;  " & vbcrlf & "	pre.id=""code_"" + i;" & vbcrlf & "	var cls = pre.className||"""";" & vbcrlf & "	if(cls.indexOf(""lang-"")>=0){" & vbcrlf & "		var lng = cls.replace(/^(.+?)lang\-(.+?)( (.+?))?$/,""$2"");" & vbcrlf & "		var h3 = document.createElement(""h3"");" & vbcrlf & "		h3.className=""lang_type"";" & vbcrlf & "		h3.innerHTML=lng+"" 代码[<a href=\""javascript:void(0)\"" onclick=\""F('#"" + pre.id + ""').copy();\"">复制</a>]："";" & vbcrlf & "		pre.parentNode.insertBefore(h3,pre);" & vbcrlf & "	}" & vbcrlf & "});" & vbcrlf & "function LoadMore(){" & vbcrlf & "	if(!loaded || atend)return;" & vbcrlf & "	if(F(""#mo-more"").isInView()){" & vbcrlf & "		parms.page++;" & vbcrlf & "		loaded=false;" & vbcrlf & "		F(""#mo-more-content"").html(""正在努力的为您加载文章。。。"");" & vbcrlf & "		F.ajax({" & vbcrlf & "			url:""/""," & vbcrlf & "			data:parms," & vbcrlf & "			succeed:function(msg){" & vbcrlf & "				/*alert(msg);*/" & vbcrlf & "				if(msg.indexOf(""没有任何文章"")>0){" & vbcrlf & "					F(""#mo-more-content"").html(""哎呀，没有文章可看了。"");" & vbcrlf & "					atend=true;" & vbcrlf & "				}else{" & vbcrlf & "					F(""#mo-art-list"").append(msg);" & vbcrlf & "				}" & vbcrlf & "				loaded = true;" & vbcrlf & "			}," & vbcrlf & "			error:function(){" & vbcrlf & "				loaded = true;parms.page--;" & vbcrlf & "			}," & vbcrlf & "			ontimeout:function(){loaded = true;parms.page--;}" & vbcrlf & "		});" & vbcrlf & "	}				  " & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "</div>" & vbcrlf & "<div id=""mo-body-right"">" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2 id=""weather_title"">天气预报</h2>" & vbcrlf & "            <div id=""weather_content"">加载中...</div>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>我的博客</h2>" & vbcrlf & "            <ul class=""cats"">" & vbcrlf & "                <li><a href=""/?m=home&a=index"">&raquo; 博客首页</a></li>" & vbcrlf & "                "
if Mo.Exists("cats") then
set D__cats = Mo.value("cats")
do while not D__cats.eof()
set C__cats =  D__cats.read()
T = T & "                "
if is_empty(C__cats.getter__("Class_PName")) then
T = T & "                <li><a href=""/?m=home&a=cats&cat=" & C__cats.getter__("idlist") & """>&raquo; " & C__cats.getter__("Class_Name") & "(" & C__cats.getter__("counts") & ")</a> [<a href=""/?m=home&a=rss&catid=" & C__cats.getter__("idlist") & """ target=""_blank"">RSS</a>]</li>" & vbcrlf & "                "
else
T = T & "                <li class=""sub""><a href=""/?m=home&a=cats&cat=" & C__cats.getter__("idlist") & """>&nbsp; &nbsp;" & C__cats.getter__("Class_Name") & "(" & C__cats.getter__("counts") & ")</a> [<a href=""/?m=home&a=rss&catid=" & C__cats.getter__("idlist") & """ target=""_blank"">RSS</a>]</li>" & vbcrlf & "                "
end if
T = T & "                "
Loop 
End If
T = T & "                <li><a href=""/?m=home&a=links"">&raquo; 友情链接</a> | <a href=""/?m=home&a=guest"">访客留言簿</a> | <a href=""/?m=admin"">管理博客</a></li>" & vbcrlf & "            </ul>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>博客搜索</h2>" & vbcrlf & "            <form action=""/"" method=""get"">" & vbcrlf & "            <input type=""hidden"" name=""m"" value=""home"" /><input type=""hidden"" name=""a"" value=""search"" />" & vbcrlf & "            关键字：<input type=""text"" class=""inputText width_100"" name=""keyword"" /> <input class=""inputButton"" type=""submit"" value=""搜索"" />" & vbcrlf & "            </form>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>相册</h2>" & vbcrlf & "            <ul class=""cats index-album clearfix"">" & vbcrlf & "            "
if Mo.Exists("Albums") then
set D__Albums = Mo.value("Albums")
do while not D__Albums.eof()
set C__Albums =  D__Albums.read()
T = T & "                <li><a href=""/?m=home&a=photos&id=" & C__Albums.getter__("id") & """><img src=""" & Mo.C("Blog").AlbumPath & C__Albums.getter__("t_path")  & """ width=""96"" title=""" & C__Albums.getter__("name") & """ alt=""" & C__Albums.getter__("name") & """ /></a></li>" & vbcrlf & "            "
Loop 
End If
T = T & "            </ul>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>最新评论</h2>" & vbcrlf & "            <ul class=""cats"">" & vbcrlf & "            "
if Mo.Exists("Comments") then
set D__Comments = Mo.value("Comments")
do while not D__Comments.eof()
set C__Comments =  D__Comments.read()
T = T & "                <li><a href=""/?m=home&a=show&id=" & C__Comments.getter__("article_id") & "#c" & C__Comments.getter__("id") & """>&raquo; " & left(C__Comments.getter__("content"),30) & "</a></li>" & vbcrlf & "            "
Loop 
End If
T = T & "            </ul>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>最新留言</h2>" & vbcrlf & "            <ul class=""cats"">" & vbcrlf & "            "
if Mo.Exists("Guests") then
set D__Guests = Mo.value("Guests")
do while not D__Guests.eof()
set C__Guests =  D__Guests.read()
T = T & "                <li><a href=""/?m=home&a=guest#g" & C__Guests.getter__("id") & """>&raquo; " & Mo.Static("Common").IndexRight(C__Guests.getter__("Content")) & "</a></li>" & vbcrlf & "            "
Loop 
End If
T = T & "            </ul>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>标签云集</h2>" & vbcrlf & "            <div class=""cats_tags clearfix"">" & vbcrlf & "            "
if Mo.Exists("TagsCloud") then
set D__TagsCloud = Mo.value("TagsCloud")
do while not D__TagsCloud.eof()
set C__TagsCloud =  D__TagsCloud.read()
T = T & "                <a href=""/?m=home&a=tag&keyword=" & C__TagsCloud.getter__("tag") & """ title=""引用" & C__TagsCloud.getter__("counts") & "次"">" & C__TagsCloud.getter__("name") & "</a>&nbsp; " & vbcrlf & "            "
Loop 
End If
T = T & "            </div>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>文章归档</h2>" & vbcrlf & "            <ul class=""cats"">" & vbcrlf & "            "
if Mo.Exists("Librarys") then
set D__Librarys = Mo.value("Librarys")
do while not D__Librarys.eof()
set C__Librarys =  D__Librarys.read()
T = T & "                <li><a href=""/?m=home&a=library&keyword=" & F.encode(C__Librarys.getter__("library")) & """ title=""" & C__Librarys.getter__("library") & """>&raquo; " & C__Librarys.getter__("library") & "(" & C__Librarys.getter__("num") & ")</a></li>" & vbcrlf & "            "
Loop 
End If
T = T & "            </ul>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "    <div class=""mo-box-right"">" & vbcrlf & "        <div class=""mo-box-right-content"">" & vbcrlf & "            <h2>友情链接</h2>" & vbcrlf & "            <ul class=""cats"">" & vbcrlf & "            "
if Mo.Exists("Links") then
set D__Links = Mo.value("Links")
do while not D__Links.eof()
set C__Links =  D__Links.read()
T = T & "                <li><a href=""" & C__Links.getter__("url") & """ onclick=""return clicklink(" & C__Links.getter__("id") & ");"" target=""_blank"" title=""" & C__Links.getter__("author") & "=>" & C__Links.getter__("title") & """>&raquo; " & C__Links.getter__("title") & "</a></li>" & vbcrlf & "            "
Loop 
End If
T = T & "                <li><a href=""/?m=home&a=links"">---申请友情链接---</a></li>" & vbcrlf & "            </ul>" & vbcrlf & "        </div>" & vbcrlf & "    </div>" & vbcrlf & "</div>" & vbcrlf & "<script type=""text/javascript"">" & vbcrlf & "F(""div.cats_tags a"").each(function(){" & vbcrlf & "	var color=""rgb("" + parseInt(64+Math.random()*128) + "","" + parseInt(64+Math.random()*128) + "","" + parseInt(64+Math.random()*128) + "")"";" & vbcrlf & "	var count = parseInt(this.title.replace(/^引用(\d+)次$/ig,""$1""));" & vbcrlf & "	if(count<1)count=1;" & vbcrlf & "	var size = Math.log(count+1)/Math.log(3);" & vbcrlf & "	this.style.color=color;" & vbcrlf & "	this.style.fontSize=Math.ceil(12+size*2-1)+""px"";" & vbcrlf & "});" & vbcrlf & "function clicklink(id){Ajax({url:""/?m=home&a=clicklink&id="" + id});return true;}" & vbcrlf & "function getWeather(Weather){" & vbcrlf & "	if(Weather){" & vbcrlf & "		if(Weather[""weather""]!=null){" & vbcrlf & "			var W = Weather[""weather""];	" & vbcrlf & "			var wstr = ""<span class=\""title\"">"" + W.city + ""("" + W.date_y + W.fchh + ""时)</span>"";" & vbcrlf & "			F(""#weather_title"").html(wstr.replace(/(\d+)/igm,""<span style=\""color:green\"">$1</span>""));" & vbcrlf & "			wstr =W.date + "" "" + W.week;" & vbcrlf & "			wstr +=W.temp1 + "","" + W.weather1;" & vbcrlf & "			if(W.img1!=""99"")wstr +=""<img src='http://dev.mo.cn/kits/weather/icons/c"" + W.img1 + "".gif' alt='"" + W.img_title1 + ""' />"";" & vbcrlf & "			if(W.img2!=""99"")wstr +=""<img src='http://dev.mo.cn/kits/weather/icons/c"" + W.img2 + "".gif' alt='"" + W.img_title2 + ""' />"";" & vbcrlf & "			wstr +="","" + W.wind1 + ""。<br />"";" & vbcrlf & "			wstr +=W.index_d+""<br />"";" & vbcrlf & "			wstr +=""<strong>明天</strong>：""+W.temp2 + "","" + W.weather2 + "","" + W.wind2+""<br />"";" & vbcrlf & "			F(""#weather_content"").html(wstr.replace(/(\d+)([^\w\.]{1})/igm,""<span style=\""color:green\"">$1</span>$2""));" & vbcrlf & "		}else{" & vbcrlf & "			F(""#weather_title"").html(Weather['city']-Weather['prov']);" & vbcrlf & "			F(""#weather_content"").html(""天气加载失败"");" & vbcrlf & "		}" & vbcrlf & "	}else{" & vbcrlf & "		F(""#weather_content"").html(""天气加载失败"");" & vbcrlf & "	}" & vbcrlf & "}" & vbcrlf & "</script>" & vbcrlf & "<script type=""text/javascript"" src=""http://dev.mo.cn/kits/weather/?callback=getWeather"" defer=""defer""></script>" & vbcrlf & "    </div>" & vbcrlf & "	<div id=""mo-bottom"" class=""mo-box-right"">" & Mo.Values("System","blog_copy_right") & "</div>" & vbcrlf & "    <div id=""mo-tips""><div id=""mo-tips-content""></div></div>" & vbcrlf & "	<script type=""text/javascript"">" & vbcrlf & "	if(F.browser.ie && F.browser.version==""6.0""){" & vbcrlf & "		MessageBox.timeout=0;" & vbcrlf & "		MessageBox.showNotice(""同学，咱还用IE6？忒OUT了吧！抓紧换换吧，哪怕是IE7也中！再者由于本人比较懒，不想再写代码去兼容IE6了！<a href=\""javascript:void(0)\"" onclick=\""F('#mo-tips').css({'display':'none'});\"">关闭</a>"");" & vbcrlf & "	}" & vbcrlf & "    </script>" & vbcrlf & "  </body>" & vbcrlf & "</html>"
Temp___ = T
end function%>