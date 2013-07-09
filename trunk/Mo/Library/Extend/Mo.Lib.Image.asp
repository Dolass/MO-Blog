<%
'by anlige at www.9fn.net
Class MoLibImage
	Private vMode, vFileCount,mvarJpeg,mvarEnabled,mvarQuality,mvarJpegTemp,mvarX,mvarY,mvarCharset
	private mvarPen,mvarBrush
	
	Public Property Let Charset(ByVal value)
		mvarCharset = value
	End Property
	
	Public Property Let X(ByVal value)
		mvarX = value
	End Property
	
	Public Property Let Y(ByVal value)
		mvarY = value
	End Property
	
	Public Property Get Src_()
		set Src_ = mvarJpeg
	End Property
	
	Public Property Get Position(byval X,Byval Y)
		Position = Array(X,Y)
	End Property

	Public Property Get Angle(byval X,Byval Y)
		Angle = Array(X,Y)
	End Property
		
	Public Property Let Quality(ByVal value)
		mvarQuality = value
		mvarJpeg.Quality=mvarQuality
	End Property
	
	Public Property Get Width()
		Width = mvarJpeg.width
	End Property
	
	Public Property Get Height()
		Height = mvarJpeg.height
	End Property
	
	
	Public Property Get Binary()
		Binary = mvarJpeg.Binary
	End Property
	
	Public Property Get Enabled()
		Enabled = mvarEnabled
	End Property

	
	Public Property Let FontFamily(ByVal value)
		mvarJpeg.Canvas.font.Family = value
	End Property
	
	Public Property Let FontWidth(ByVal value)
		mvarJpeg.Canvas.font.Width = value
	End Property
	Public Property Let FontBold(ByVal value)
		mvarJpeg.Canvas.font.Bold = value
	End Property
	
	Public Property Let ShadowColor(ByVal value)
		mvarJpeg.Canvas.font.ShadowColor = value
	End Property
	Public Property Let ShadowXoffset(ByVal value)
		mvarJpeg.Canvas.font.ShadowXoffset = value
	End Property
	
	Public Property Let ShadowYoffset(ByVal value)
		mvarJpeg.Canvas.font.ShadowYoffset = value
	End Property
	
	Private Sub Class_Initialize()
		mvarEnabled = false
		if F.activex_("Persits.Jpeg") then
			mvarQuality = 100
			mvarX = 0
			mvarY = 0
			mvarCharset=1
			mvarEnabled = true
			mvarPen = Array(&H000000,1)
			mvarBrush = Array(&H000000,false)
			Set mvarJpeg = F.activex("Persits.Jpeg")
			mvarJpeg.RegKey="48958-77556-02411"
			mvarJpeg.Quality = mvarQuality
		end if
	End Sub
	
	Private Sub Class_Terminate()
		if isobject(mvarJpeg) then Set mvarJpeg = nothing
	End Sub
	
	Public Sub [New](byval width,byval height,byval color)
		mvarJpeg.new width,height,color
	End Sub
	Public Sub Pen(byval color,Byval width)
		mvarPen = Array(color,width)
	End Sub
	
	Public Sub Brush(byval color,Byval solid)
		mvarBrush = Array(color,solid)
	End Sub
	
	public function LoadBinary(binary)
		mvarJpeg.OpenBinary binary
	end function
	
	public function Copy()
		dim copy_ 
		set copy_ = new MoLibImage
		if copy_.Enabled then copy_.LoadBinary mvarJpeg.binary
		set Copy = copy_
	end function
	
	public function Load(byval path)
		dim filepath
		filepath = F.mappath(path)
		if not F.fso.FileExists(filepath) then
			Load = false
			exit function
		end if
		mvarJpeg.Open filepath
		Load = true
	end function
	
	public function GetThumb(byval MaxWidth,byval MaxHeight)
		dim mvarWidth,mvarHeight,mvarB
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 then
			GetThumb = false
			exit function
		end if
		mvarB = mvarHeight/mvarWidth
		if mvarWidth>MaxWidth then
			mvarWidth = MaxWidth
			mvarHeight = cint(mvarWidth*mvarB)
		end if
		if mvarHeight>MaxHeight then
			mvarHeight = MaxHeight
			mvarWidth = cint(mvarHeight/mvarB)
		end if
		mvarJpeg.width = mvarWidth
		mvarJpeg.height = mvarHeight
		GetThumb = true
	end function
	
	public function Cut(byval X,byval Y,byval nWidth,byval nHeight)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 or X>=mvarWidth or Y>=mvarHeight then
			Cut = false
			exit function
		end if
		if X<=0 then X=0
		if Y<=0 then Y=0
		if nWidth>mvarWidth-X then nWidth = mvarWidth-X
		if nHeight>mvarHeight-Y then nHeight = mvarHeight-Y
		mvarJpeg.Crop X,Y,nWidth+X,nHeight+Y
		Cut = true
	end function

	public function DrawPng(byval X,byval Y,byval path)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 or X>=mvarWidth or Y>=mvarHeight then
			DrawPng = false
			exit function
		end if
		if X<=0 then X=0
		if Y<=0 then Y=0
		mvarJpeg.Canvas.DrawPNG X,Y,F.mappath(path)
		DrawPng = true
	end function
	
	public function DrawPngBinary(byval X,byval Y, Byval binary)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 or X>=mvarWidth or Y>=mvarHeight then
			DrawPngBinary = false
			exit function
		end if
		if X<=0 then X=0
		if Y<=0 then Y=0
		mvarJpeg.Canvas.DrawPNGBinary X,Y,binary
		DrawPngBinary = true
	end function
			
	public function DrawImage(byval X,byval Y,byval path,byval opacity)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 or X>=mvarWidth or Y>=mvarHeight then
			DrawImage = false
			exit function
		end if
		if X<=0 then X=0
		if Y<=0 then Y=0
		dim mvarJpegTemp:set mvarJpegTemp = new MoLibImage
		if mvarJpegTemp.Load(F.mappath(path)) then
			mvarJpeg.DrawImage X,Y,mvarJpegTemp.Src__,opacity
			DrawImage = true
		else
			DrawImage = false
		end if
	end function

	public function DrawObjectImage(byval X,byval Y,byref obj,byval opacity)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 or X>=mvarWidth or Y>=mvarHeight then
			DrawObjectImage = false
			exit function
		end if
		if X<=0 then X=0
		if Y<=0 then Y=0
		mvarJpeg.DrawImage X,Y,obj.Src_,opacity
		DrawObjectImage = true
	end function
	
	public function SetTextStyle(byval fontfamily,byval bold)
		mvarJpeg.Canvas.font.Family =fontfamily
		mvarJpeg.Canvas.font.Bold =bold
	end function
	public function SetShadow(byval shadowcolor,byval shadowxoffset,byval shadowyoffset)
		mvarJpeg.Canvas.font.ShadowColor =shadow
		mvarJpeg.Canvas.font.ShadowXoffset =shadowxoffset
		mvarJpeg.Canvas.font.ShadowYoffset =shadowyoffset
	end function
	
	public function DrawText(byval text,byval X,byval Y,byval color,byval size)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 or X>=mvarWidth or Y>=mvarHeight then
			DrawText = false
			exit function
		end if
		if Y<=0 then Y=0
		if X<=0 then X=0
		mvarJpeg.Canvas.font.color =color
		mvarJpeg.Canvas.font.size =size
		mvarJpeg.Canvas.Printtext X,Y,text
		DrawText = true
	end function
	
	
	public function MeasureText(byval text,byval size)
		mvarJpeg.Canvas.font.size =size
		MeasureText = mvarJpeg.Canvas.GetTextExtent(text,mvarCharset)
	end function
	
	public function DrawLine(byval X,byval Y,byval X1,byval Y1)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 then
			DrawLine = false
			exit function
		end if
		mvarJpeg.Canvas.pen.color =mvarPen(0)
		mvarJpeg.Canvas.pen.width =mvarPen(1)
		mvarJpeg.Canvas.Brush.color =mvarBrush(0)
		mvarJpeg.Canvas.Brush.solid =mvarBrush(1)
		mvarJpeg.Canvas.DrawLine X,Y,X1,Y1
		DrawLine = true
	end function

	public function DrawEllipse(byval X,byval Y,byval width,byval height)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 then
			DrawEllipse = false
			exit function
		end if
		mvarJpeg.Canvas.pen.color =mvarPen(0)
		mvarJpeg.Canvas.pen.width =mvarPen(1)
		mvarJpeg.Canvas.Brush.color =mvarBrush(0)
		mvarJpeg.Canvas.Brush.solid =mvarBrush(1)
		mvarJpeg.Canvas.DrawEllipse X,Y,X+width,Y+height
		DrawEllipse = true
	end function
	
	public function DrawCircle(byval X,byval Y,byval radius)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 then
			DrawCircle = false
			exit function
		end if
		mvarJpeg.Canvas.pen.color =mvarPen(0)
		mvarJpeg.Canvas.pen.width =mvarPen(1)
		mvarJpeg.Canvas.Brush.color =mvarBrush(0)
		mvarJpeg.Canvas.Brush.solid =mvarBrush(1)
		mvarJpeg.Canvas.DrawCircle X,Y,radius
		DrawCircle = true
	end function
	
	
	public function DrawBar(byval X,byval Y,byval width,byval height)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 then
			DrawBar = false
			exit function
		end if
		mvarJpeg.Canvas.pen.color =mvarPen(0)
		mvarJpeg.Canvas.pen.width =mvarPen(1)
		mvarJpeg.Canvas.Brush.color =mvarBrush(0)
		mvarJpeg.Canvas.Brush.solid =mvarBrush(1)
		mvarJpeg.Canvas.DrawBar X,Y,X+width,Y+height
		DrawBar = true
	end function
	
	public function DrawArc(byval X,byval Y,byval radius ,byval startangle,byval endangle)
		dim mvarWidth,mvarHeight
		mvarWidth = Width
		mvarHeight = Height
		if mvarWidth=0 or mvarHeight=0 then
			DrawArc = false
			exit function
		end if
		mvarJpeg.Canvas.pen.color =mvarPen(0)
		mvarJpeg.Canvas.pen.width =mvarPen(1)
		mvarJpeg.Canvas.Brush.color =mvarBrush(0)
		mvarJpeg.Canvas.Brush.solid =mvarBrush(1)
		mvarJpeg.Canvas.DrawArc X,Y,radius,startangle,endangle
		DrawArc = true
	end function
		
	public function Save(byval path)
		dim filepath : filepath = F.mappath(path)
		mvarJpeg.save filepath
	end function
	public function Close()
		mvarJpeg.close
	end function
End Class
%>