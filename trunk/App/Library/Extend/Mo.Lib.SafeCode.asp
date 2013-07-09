<%
class MoLibSafeCode
	Private vVersion
	 
	Public Property Get Version()
	   Version = vVersion
	 End Property
	 
	 Private Sub Class_Initialize()
		vVersion = "Safe Code 8.12.14"
	 End Sub
	
	Public Sub Code(ByVal sessionKey)
	Response.Buffer = True
	Response.Expires = -1
	Response.AddHeader "Pragma", "no-cache"
	Response.AddHeader "cache-ctrol", "no-cache"
	Response.ContentType = "Image/bmp"
	Randomize
	Dim I, ii, iii
	Const cOdds = 3
	Const cAmount = 10
	Const cCode = "0123456789abcd"
	Dim vColorData(6)
	vColorData(0) = ChrB(&H0) & ChrB(&H0) & ChrB(&HFF) 
	vColorData(1) =  ChrB(&HFF) & ChrB(&HFF) & ChrB(&HFF)
	vColorData(2) = ChrB(&HFF) & ChrB(&HFF) & ChrB(&HFF)
	vColorData(3) = ChrB(0) & ChrB(0) & ChrB(255)
	vColorData(4) = ChrB(0) & ChrB(102) & ChrB(0)
	vColorData(5) = ChrB(255) & ChrB(0) & ChrB(0)
	vColorData(6) = ChrB(0) & ChrB(0) & ChrB(0)
	Dim vCode(4), vCodes
	For I = 0 To 3
	vCode(I) = Int(Rnd * cAmount)
	vCodes = vCodes & Mid(cCode, vCode(I) + 1, 1)
	Next
	Session(sessionKey) = vCodes
	Dim vNumberData(9)
	vNumberData(0) = "1110000111110111101111011110111101001011110100101111010010111101001011110111101111011110111110000111"
	vNumberData(1) = "1111011111110001111111110111111111011111111101111111110111111111011111111101111111110111111100000111"
	vNumberData(2) = "1110000111110111101111011110111111111011111111011111111011111111011111111011111111011110111100000011"
	vNumberData(3) = "1110000111110111101111011110111111110111111100111111111101111111111011110111101111011110111110000111"
	vNumberData(4) = "1111101111111110111111110011111110101111110110111111011011111100000011111110111111111011111111000011"
	vNumberData(5) = "1100000011110111111111011111111101000111110011101111111110111111111011110111101111011110111110000111"
	vNumberData(6) = "1111000111111011101111011111111101111111110100011111001110111101111011110111101111011110111110000111"
	vNumberData(7) = "1100000011110111011111011101111111101111111110111111110111111111011111111101111111110111111111011111"
	vNumberData(8) = "1110000111110111101111011110111101111011111000011111101101111101111011110111101111011110111110000111"
	vNumberData(9) = "1110001111110111011111011110111101111011110111001111100010111111111011111111101111011101111110001111"

	Response.BinaryWrite ChrB(66) & ChrB(77) & ChrB(230) & ChrB(4) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(54) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(40) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(40) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(10) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(1) & ChrB(0)

	Response.BinaryWrite ChrB(24) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(176) & ChrB(4) & ChrB(0) & ChrB(0) & ChrB(18) & ChrB(11) & ChrB(0) & ChrB(0) & ChrB(18) & ChrB(11) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0) & ChrB(0)
	For I = 9 To 0 Step -1
	For ii = 0 To 3
	For iii = 1 To 10
	If Rnd * 99 + 1 < cOdds Then
		Response.BinaryWrite vColorData(2)
	Else
		if Mid(vNumberData(vCode(ii)), I * 10 + iii, 1) = 0 Then 
			Response.BinaryWrite getrndcolor()
		Else
			Response.BinaryWrite vColorData(1)
		End If
	End If
	Next
	Next
	Next
	End Sub
	private function getrndcolor()
		getrndcolor = chrb(int(rnd()*255)) & chrb(int(rnd()*255)) & chrb(int(rnd()*255))
	End function
End Class
%>