<%
class MoLibPinyin
	public default function GetPy(byref path,byval query)
		if len(query)<=0  then
			GetPy = ""
			exit function
		end if
		dim i,c,ret,q,src
		path = F.mappath(path)
		src = LoadFile(path,"gbk")
		ret = ""
		for i=1 to len(query)
			c = mid(query,i,1)
			q =  GetPySingle(src,c)
			if instr(q,"&")>0 then q = split(q,"&")(0)
			ret = ret & q
		next
		GetPy = ret
	end function
	function GetPySingle(byref src,byval char)
		dim w,p1,c,ret
		w = ascw(char)
		if w>256 or w<=0 then
			p1 = instr(src,hex(w)&",")
			if p1>0 then
				p1 = p1+5
				c =  mid(src,p1,1)
				do while not (asc(c)>=asc("a") and asc(c)<=asc("z")) or c="&"
					p1=p1+1
					c = mid(src,p1,1)
				loop
				do while (asc(c)>=asc("a") and asc(c)<=asc("z")) or c="&"
					ret = ret & c
					p1=p1+1
					c = mid(src,p1,1)
				loop
			else
				ret = ret & char
			end if
		else
			ret = ret & char
		end if
		GetPySingle = ret
	end function
	
	public function LoadFile(path,charset)
		if not F.fso.fileexists(path) then
			LoadFile = ""
			exit function
		end if
		dim stream
		set stream = Server.CreateObject("Adodb.Stream")
		stream.mode = 3
		stream.type=2
		stream.charset=charset
		stream.open
		stream.loadfromfile path
		LoadFile = stream.readtext()
		stream.close
		set stream = nothing
	end function
end class
%>