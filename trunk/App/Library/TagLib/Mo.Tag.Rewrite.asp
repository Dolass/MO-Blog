<%
class MoTagRewrite
	private mvarDicts
	public default sub A__(mvarContent)
		if MO_REWRITE_MODE<>"404" and MO_REWRITE_MODE<>"URL" then
			mvarContent = replaceex(mvarContent,"<rewrite>(.+?)</rewrite>","$1")
			exit sub
		end if
		dim matches,match
		set matches = GetMatch(mvarContent,"<rewrite>(.+?)</rewrite>")
		for each match in matches
			mvarContent = replace(mvarContent,match.value,parseURI(match.submatches(0)))
		next
		set matches = nothing
	end sub
	private function getRndid()
		dim rid
		rid = RndStr1(10)
		do while mvarDicts.exists(rid)
			rid = RndStr1(10)
		loop
		getRndid = rid
	end function
	public function parseURI(byval value)
		if MO_REWRITE_MODE<>"404" and MO_REWRITE_MODE<>"URL" then
			parseURI = value
			exit function
		end if
		dim templist,match
		templist = array()
		for each match in GetMatch(value,"\{\$(.+?)\}")
			redim preserve templist(ubound(templist)+1)
			templist(ubound(templist)) = match.value
			value = replace(value,match.value,"{#" & ubound(templist) & "}")
		next
		value = replaceex(value,"^\?","")
		value = replaceex(value,"^m\=home&(amp;)?a\=rss&(amp;)?type\=(atom|feed|sitemap|rss)$","$3/")
		value = replaceex(value,"^m\=home&a\=rss$","rss/")
		value = replaceex(value,"^m\=home&a\=guest&page\=(.+?)$","guest-$1.html")
		value = replaceex(value,"^m\=home&(amp;)?a\=index$","index.html")
		value = replaceex(value,"^m\=home&(amp;)?a\=guest$","guest.html")
		value = replaceex(value,"^m\=home&(amp;)?a\=links$","links.html")
		value = replaceex(value,"^m\=home&a\=rss&catid\=(.+?)$","rss/$1/")
		value = replaceex(value,"^m\=home&a\=show&id\=(.+?)&page\=(.+?)$","post/$1/$2.html")
		value = replaceex(value,"^m\=home&(amp;)?a\=show&(amp;)?id\=(.+?)$","post/$3.html")
		value = replaceex(value,"^m\=home&a\=cats&cat\=(.+?)&page\=(.+?)$","cats/$1/$2/")
		value = replaceex(value,"^m\=home&(amp;)?a\=cats&(amp;)?cat\=(.+?)$","cats/$3/")
		value = replaceex(value,"^m\=home&a\=search&keywords\=(.+?)&page\=(.+?)$","search/$1/$2/")
		value = replaceex(value,"^m\=home&a\=search&keywords\=(.+?)$","search/$1/")
		value = replaceex(value,"^m\=home&a\=tag&keyword\=(.+?)&page\=(.+?)$","tag/$1/$2.html")
		value = replaceex(value,"^m\=home&a\=tag&keyword\=(.+?)$","tag/$1.html")
		value = replaceex(value,"^m\=home&a\=library&keyword\=(.+?)&page\=(.+?)$","library/$1/$2.html")
		value = replaceex(value,"^m\=home&a\=library&keyword\=(.+?)$","library/$1.html")
		value = replaceex(value,"^m\=home&a\=photos&id\=(.+?)$","photos/$1/")
		if MO_REWRITE_MODE="URL" then value = "?/" & value
		for each match in GetMatch(value,"\{\#(\d+)\}")
			value = replace(value,match.value,templist(cint(match.submatches(0))))
		next
		parseURI = value
	end function
end class
%>