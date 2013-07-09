<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-cn" lang="zh-cn">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>AjaxTest</title>
	<script type="text/javascript" src="f.ajax.source.js"></script>
    <script type="text/javascript">
		window.onload=function(){
			Ajax.postJSON("ajax_test.asp?test=json","c=d",function(data,b){	
				document.getElementById("test").innerHTML=data.QueryString + "---" + data.Form + "---" + data.Now;
			});	
		}
	</script>
</head>
<body>
<div id="test"></div>
</body>
</html>