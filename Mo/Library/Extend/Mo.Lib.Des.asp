<%
'by anlige at www.9fn.net
Class MoLibDes
	Private sKey, sIV, sMode, sPadding, sEncoding
	Private spFunc1, spFunc2, spFunc3, spFunc4, spFunc5, spFunc6, spFunc7, spFunc8
	Private pc2bt0, pc2bt1, pc2bt2, pc2bt3, pc2bt4, pc2bt5, pc2bt6
	Private pc2bt7, pc2bt8, pc2bt9, pc2bt10, pc2bt11, pc2bt12, pc2bt13

	Public Property Let Key(ByVal strKey)
		sKey = strKey
	End Property

	Public Property Let IV(ByVal strIV)
		sIV = strIV
	End Property

	Public Property Let Mode(ByVal strMode)
		sMode = LCase(strMode)
	End Property

	Public Property Let Padding(ByVal strPadding)
		sPadding = LCase(strPadding)
	End Property

	Public Property Let Encoding(ByVal strEncoding)
		sEncoding = LCase(strEncoding)
	End Property


	Public Default Function Encode(ByVal str)
		Encode = bin2hex(Des(sKey, str, True, sMode, sIV))
	End Function
	Public Function Decode(ByVal str)
		Decode = Des(sKey, hex2bin(str), False, sMode, sIV)
	End Function

	Private Function Des(ByVal key, ByVal message, ByVal encrypt, ByVal mode, ByVal iv)
		
		Dim keys, m
		Dim i, j, temp, temp2, right1, right2, lefts, rights, looping
		Dim cbcleft, cbcleft2, cbcright, cbcright2
		Dim endloop, loopinc
		Dim lens, pdcnt, pdstr, chunk, iterations
		Dim result, tempresult

		m = 0 : chunk = 0
		result = "" : tempresult = ""
		keys = CreateKeys(str2bin(key))
		iv = str2bin(iv)
		If encrypt Then 
			message = str2bin(message)
		End If 
		lens = LenB(message)
		If encrypt Then
			pdcnt = 8 - (lens Mod 8)
			If sPadding = "pkcs5" Then 
				pdstr = str2bin(String(pdcnt,pdcnt))
				If pdcnt = 8 Then lens = lens + 8
			ElseIf sPadding = "none" Then 
				If pdcnt<>8 Then 
					Des = "None Mode:Length of str must mod by 16"
					Exit Function
				End If
			ElseIf sPadding = "zero" Then 
				If pdcnt<8 Then pdstr = str2bin(String(pdcnt,0))
			End If
			message = message & pdstr
		End If 

		iterations = IIF(UBound(keys)+1 = 32, 3, 9)
		If iterations = 3 Then 
			looping = IIF(encrypt, Array(0, 32, 2), Array(30, -2, -2))
		Else
			looping = IIF(encrypt, Array(0, 32, 2, 62, 30, -2, 64, 96, 2), Array(94, 62, -2, 32, 64, 2, 30, -2, -2))
		End If 

		If mode = "cbc" Then
			cbcleft = SHL(CharCodeAt(iv,JJ(m)), 24) Or SHL(CharCodeAt(iv,JJ(m)), 16) Or SHL(CharCodeAt(iv,JJ(m)), 8) Or CharCodeAt(iv,JJ(m))
			cbcright = SHL(CharCodeAt(iv,JJ(m)), 24) Or SHL(CharCodeAt(iv,JJ(m)), 16) Or SHL(CharCodeAt(iv,JJ(m)), 8) Or CharCodeAt(iv,JJ(m))
			m = 0
		End If

		while m < lens
			lefts = SHL(CharCodeAt(message,JJ(m)), 24) Or SHL(CharCodeAt(message,JJ(m)), 16) Or SHL(CharCodeAt(message,JJ(m)), 8) Or CharCodeAt(message,JJ(m))
			rights = SHL(CharCodeAt(message,JJ(m)), 24) Or SHL(CharCodeAt(message,JJ(m)), 16) Or SHL(CharCodeAt(message,JJ(m)), 8) Or CharCodeAt(message,JJ(m))
			If mode = "cbc" Then
				If encrypt Then
					lefts = lefts Xor cbcleft
					rights = rights Xor cbcright
				Else
					cbcleft2 = cbcleft
					cbcright2 = cbcright
					cbcleft = lefts
					cbcright = rights
				End If 
			End If 

			temp = (SHR(lefts, 4) Xor rights) And 252645135
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 4)
			temp = (SHR(lefts, 16) Xor rights) And 65535
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 16)
			temp = (SHR(rights, 2) Xor lefts) And 858993459
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, 2)
			temp = (SHR(rights, 8) Xor lefts) And 16711935
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, 8)
			temp = (SHR(lefts, 1) Xor rights) And 1431655765
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 1)

			lefts = (SHL(lefts, 1) Or SHR(lefts, 31))
			rights = (SHL(rights, 1) Or SHR(rights, 31))

			For j = 0 To iterations - 1 Step 3
				endloop = looping(j + 1)
				loopinc = looping(j + 2)
				i = looping(j)
				While i <> endloop
					right1 = rights Xor keys(i)
					right2 = (SHR(rights, 4) Or SHL(rights, 28)) Xor keys(i + 1)
					temp = lefts
					lefts = rights
					rights = temp Xor (spFunc2(SHR(right1, 24) And 63) Or spFunc4(SHR(right1, 16) And 63) Or spFunc6(SHR(right1, 8) And 63) Or spFunc8(right1 And 63) Or spFunc1(SHR(right2, 24) And 63) Or spFunc3(SHR(right2, 16) And 63) Or spFunc5(SHR(right2, 8) And 63) Or spFunc7(right2 And 63))
					i = i + loopinc
				Wend
				temp = lefts
				lefts = rights
				rights = temp
			Next

			lefts = (SHR(lefts, 1) Or SHL(lefts, 31))
			rights = (SHR(rights, 1) Or SHL(rights, 31))

			temp = (SHR(lefts, 1) Xor rights) And 1431655765
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 1)
			temp = (SHR(rights, 8) Xor lefts) And 16711935
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, 8)
			temp = (SHR(rights, 2) Xor lefts) And 858993459
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, 2)
			temp = (SHR(lefts, 16) Xor rights) And 65535
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 16)
			temp = (SHR(lefts, 4) Xor rights) And 252645135
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 4)

			If mode = "cbc" Then 
				If encrypt Then
					cbcleft = lefts
					cbcright = rights
				Else
					lefts = lefts Xor cbcleft2
					rights = rights Xor cbcright2
				End If 
			End If 

			tempresult = tempresult & ChrB(SHR(lefts, 24)) & ChrB(SHR(lefts, 16) And 255) & ChrB(SHR(lefts, 8) And 255) & ChrB(lefts And 255) & ChrB(SHR(rights, 24)) & ChrB(SHR(rights, 16) And 255) & ChrB(SHR(rights, 8) And 255) & ChrB(rights And 255)

			chunk = chunk + 8
			if chunk = 512 Then 
				result = result & tempresult
				tempresult = ""
				chunk = 0
			End If 	

		Wend
		result = result & tempresult

		If Not encrypt Then
			If sPadding = "pkcs5" Then 
				result = LeftB(result,LenB(result)-AscB(RightB(result,1)))
			ElseIf sPadding = "zero" Then 
				result = Replace(result,Chr(0),"")
			End If
			If sEncoding = "gb2312" Then
				result = bin2uni(result)
			ElseIf sEncoding = "utf-8" Then
				result = bin2utf(result)
			End If 
		End If 
		Des = result
	End Function

	Private Function CreateKeys(ByVal key)
		Dim iterations, keys(), shifts
		Dim lefttemp, righttemp, m, n, temp
		Dim lefts, rights, i, j
		iterations = IIF(LenB(key) >= 24, 3, 1)
		ReDim keys(32 * iterations - 1)
		shifts = Array(0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0)

		m = 0 : n = 0

		For j = 0 To iterations - 1
			lefts = SHL(CharCodeAt(key,JJ(m)), 24) Or SHL(CharCodeAt(key,JJ(m)), 16) Or SHL(CharCodeAt(key,JJ(m)), 8) Or CharCodeAt(key,JJ(m))
			rights = SHL(CharCodeAt(key,JJ(m)), 24) Or SHL(CharCodeAt(key,JJ(m)), 16) Or SHL(CharCodeAt(key,JJ(m)), 8) Or CharCodeAt(key,JJ(m))

			temp = (SHR(lefts, 4) Xor rights) And 252645135
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 4)
			temp = (SHR(rights, -16) Xor lefts) And 65535
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, -16)
			temp = (SHR(lefts, 2) Xor rights) And 858993459
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 2)
			temp = (SHR(rights, -16) Xor lefts) And 65535
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, -16)
			temp = (SHR(lefts, 1) Xor rights) And 1431655765
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 1)
			temp = (SHR(rights, 8) Xor lefts) And 16711935
			lefts = lefts Xor temp
			rights = rights Xor SHL(temp, 8)
			temp = (SHR(lefts, 1) Xor rights) And 1431655765
			rights = rights Xor temp
			lefts = lefts Xor SHL(temp, 1)

			temp = SHL(lefts, 8) Or (SHR(rights, 20) And 240)
			lefts = SHL(rights, 24) Or (SHL(rights, 8) And 16711680) Or (SHR(rights, 8) And 65280) Or (SHR(rights, 24) And 240)
			rights = temp

			For i = 0 To UBound(shifts)
				If shifts(i) Then
					lefts = SHL(lefts, 2) Or SHR(lefts, 26)
					rights = SHL(rights, 2) Or SHR(rights, 26)
				Else
					lefts = SHL(lefts, 1) Or SHR(lefts, 27)
					rights = SHL(rights, 1) Or SHR(rights, 27)
				End If 

				lefts = lefts And -15
				rights = rights And -15

				lefttemp = pc2bt0(SHR(lefts, 28)) Or pc2bt1(SHR(lefts, 24) And 15) Or pc2bt2(SHR(lefts, 20) And 15) Or pc2bt3(SHR(lefts, 16) And 15) Or pc2bt4(SHR(lefts, 12) And 15) Or pc2bt5(SHR(lefts, 8) And 15) Or pc2bt6(SHR(lefts, 4) And 15)
				righttemp = pc2bt7(SHR(rights, 28)) Or pc2bt8(SHR(rights, 24) And 15) Or pc2bt9(SHR(rights, 20) And 15) Or pc2bt10(SHR(rights, 16) And 15) Or pc2bt11(SHR(rights, 12) And 15) Or pc2bt12(SHR(rights, 8) And 15) Or pc2bt13(SHR(rights, 4) And 15)
				temp = (SHR(righttemp, 16) Xor lefttemp) And 65535
				keys(JJ(n)) = lefttemp Xor temp
				keys(JJ(n)) = righttemp Xor SHL(temp, 16)
			Next
		Next
		CreateKeys = keys
	End Function

	Private Sub Class_Initialize()
		sMode = "ecb"
		sPadding = "pkcs5"
		sIV = ""
		sEncoding = "gb2312"

		spFunc1 = Array(16843776, 0, 65536, 16843780, 16842756, 66564, 4, 65536, 1024, 16843776, 16843780, 1024, 16778244, 16842756, 16777216, 4, 1028, 16778240, 16778240, 66560, 66560, 16842752, 16842752, 16778244, 65540, 16777220, 16777220, 65540, 0, 1028, 66564, 16777216, 65536, 16843780, 4, 16842752, 16843776, 16777216, 16777216, 1024, 16842756, 65536, 66560, 16777220, 1024, 4, 16778244, 66564, 16843780, 65540, 16842752, 16778244, 16777220, 1028, 66564, 16843776, 1028, 16778240, 16778240, 0, 65540, 66560, 0, 16842756)
		spFunc2 = Array( -2146402272, -2147450880, 32768, 1081376, 1048576, 32, -2146435040, -2147450848, -2147483616, -2146402272, -2146402304, -2147483648, -2147450880, 1048576, 32, -2146435040, 1081344, 1048608, -2147450848, 0, -2147483648, 32768, 1081376, -2146435072, 1048608, -2147483616, 0, 1081344, 32800, -2146402304, -2146435072, 32800, 0, 1081376, -2146435040, 1048576, -2147450848, -2146435072, -2146402304, 32768, -2146435072, -2147450880, 32, -2146402272, 1081376, 32, 32768, -2147483648, 32800, -2146402304, 1048576, -2147483616, 1048608, -2147450848, -2147483616, 1048608, 1081344, 0, -2147450880, 32800, -2147483648, -2146435040, -2146402272, 1081344)
		spFunc3 = Array(520, 134349312, 0, 134348808, 134218240, 0, 131592, 134218240, 131080, 134217736, 134217736, 131072, 134349320, 131080, 134348800, 520, 134217728, 8, 134349312, 512, 131584, 134348800, 134348808, 131592, 134218248, 131584, 131072, 134218248, 8, 134349320, 512, 134217728, 134349312, 134217728, 131080, 520, 131072, 134349312, 134218240, 0, 512, 131080, 134349320, 134218240, 134217736, 512, 0, 134348808, 134218248, 131072, 134217728, 134349320, 8, 131592, 131584, 134217736, 134348800, 134218248, 520, 134348800, 131592, 8, 134348808, 131584)
		spFunc4 = Array(8396801, 8321, 8321, 128, 8396928, 8388737, 8388609, 8193, 0, 8396800, 8396800, 8396929, 129, 0, 8388736, 8388609, 1, 8192, 8388608, 8396801, 128, 8388608, 8193, 8320, 8388737, 1, 8320, 8388736, 8192, 8396928, 8396929, 129, 8388736, 8388609, 8396800, 8396929, 129, 0, 0, 8396800, 8320, 8388736, 8388737, 1, 8396801, 8321, 8321, 128, 8396929, 129, 1, 8192, 8388609, 8193, 8396928, 8388737, 8193, 8320, 8388608, 8396801, 128, 8388608, 8192, 8396928)
		spFunc5 = Array(256, 34078976, 34078720, 1107296512, 524288, 256, 1073741824, 34078720, 1074266368, 524288, 33554688, 1074266368, 1107296512, 1107820544, 524544, 1073741824, 33554432, 1074266112, 1074266112, 0, 1073742080, 1107820800, 1107820800, 33554688, 1107820544, 1073742080, 0, 1107296256, 34078976, 33554432, 1107296256, 524544, 524288, 1107296512, 256, 33554432, 1073741824, 34078720, 1107296512, 1074266368, 33554688, 1073741824, 1107820544, 34078976, 1074266368, 256, 33554432, 1107820544, 1107820800, 524544, 1107296256, 1107820800, 34078720, 0, 1074266112, 1107296256, 524544, 33554688, 1073742080, 524288, 0, 1074266112, 34078976, 1073742080)
		spFunc6 = Array(536870928, 541065216, 16384, 541081616, 541065216, 16, 541081616, 4194304, 536887296, 4210704, 4194304, 536870928, 4194320, 536887296, 536870912, 16400, 0, 4194320, 536887312, 16384, 4210688, 536887312, 16, 541065232, 541065232, 0, 4210704, 541081600, 16400, 4210688, 541081600, 536870912, 536887296, 16, 541065232, 4210688, 541081616, 4194304, 16400, 536870928, 4194304, 536887296, 536870912, 16400, 536870928, 541081616, 4210688, 541065216, 4210704, 541081600, 0, 541065232, 16, 16384, 541065216, 4210704, 16384, 4194320, 536887312, 0, 541081600, 536870912, 4194320, 536887312)
		spFunc7 = Array(2097152, 69206018, 67110914, 0, 2048, 67110914, 2099202, 69208064, 69208066, 2097152, 0, 67108866, 2, 67108864, 69206018, 2050, 67110912, 2099202, 2097154, 67110912, 67108866, 69206016, 69208064, 2097154, 69206016, 2048, 2050, 69208066, 2099200, 2, 67108864, 2099200, 67108864, 2099200, 2097152, 67110914, 67110914, 69206018, 69206018, 2, 2097154, 67108864, 67110912, 2097152, 69208064, 2050, 2099202, 69208064, 2050, 67108866, 69208066, 69206016, 2099200, 0, 2, 69208066, 0, 2099202, 69206016, 2048, 67108866, 67110912, 2048, 2097154)
		spFunc8 = Array(268439616, 4096, 262144, 268701760, 268435456, 268439616, 64, 268435456, 262208, 268697600, 268701760, 266240, 268701696, 266304, 4096, 64, 268697600, 268435520, 268439552, 4160, 266240, 262208, 268697664, 268701696, 4160, 0, 0, 268697664, 268435520, 268439552, 266304, 262144, 266304, 262144, 268701696, 4096, 64, 268697664, 4096, 266304, 268439552, 64, 268435520, 268697600, 268697664, 268435456, 262144, 268439616, 0, 268701760, 262208, 268435520, 268697600, 268439552, 268439616, 0, 268701760, 266240, 266240, 4160, 4160, 262208, 268435456, 268701696)
		pc2bt0 = Array(0, 4, 536870912, 536870916, 65536, 65540, 536936448, 536936452, 512, 516, 536871424, 536871428, 66048, 66052, 536936960, 536936964)
		pc2bt1 = Array(0, 1, 1048576, 1048577, 67108864, 67108865, 68157440, 68157441, 256, 257, 1048832, 1048833, 67109120, 67109121, 68157696, 68157697)
		pc2bt2 = Array(0, 8, 2048, 2056, 16777216, 16777224, 16779264, 16779272, 0, 8, 2048, 2056, 16777216, 16777224, 16779264, 16779272)
		pc2bt3 = Array(0, 2097152, 134217728, 136314880, 8192, 2105344, 134225920, 136323072, 131072, 2228224, 134348800, 136445952, 139264, 2236416, 134356992, 136454144)
		pc2bt4 = Array(0, 262144, 16, 262160, 0, 262144, 16, 262160, 4096, 266240, 4112, 266256, 4096, 266240, 4112, 266256)
		pc2bt5 = Array(0, 1024, 32, 1056, 0, 1024, 32, 1056, 33554432, 33555456, 33554464, 33555488, 33554432, 33555456, 33554464, 33555488)
		pc2bt6 = Array(0, 268435456, 524288, 268959744, 2, 268435458, 524290, 268959746, 0, 268435456, 524288, 268959744, 2, 268435458, 524290, 268959746)
		pc2bt7 = Array(0, 65536, 2048, 67584, 536870912, 536936448, 536872960, 536938496, 131072, 196608, 133120, 198656, 537001984, 537067520, 537004032, 537069568)
		pc2bt8 = Array(0, 262144, 0, 262144, 2, 262146, 2, 262146, 33554432, 33816576, 33554432, 33816576, 33554434, 33816578, 33554434, 33816578)
		pc2bt9 = Array(0, 268435456, 8, 268435464, 0, 268435456, 8, 268435464, 1024, 268436480, 1032, 268436488, 1024, 268436480, 1032, 268436488)
		pc2bt10 = Array(0, 32, 0, 32, 1048576, 1048608, 1048576, 1048608, 8192, 8224, 8192, 8224, 1056768, 1056800, 1056768, 1056800)
		pc2bt11 = Array(0, 16777216, 512, 16777728, 2097152, 18874368, 2097664, 18874880, 67108864, 83886080, 67109376, 83886592, 69206016, 85983232, 69206528, 85983744)
		pc2bt12 = Array(0, 4096, 134217728, 134221824, 524288, 528384, 134742016, 134746112, 16, 4112, 134217744, 134221840, 524304, 528400, 134742032, 134746128)
		pc2bt13 = Array(0, 4, 256, 260, 0, 4, 256, 260, 1, 5, 257, 261, 1, 5, 257, 261)
	End Sub

	Private Sub Class_Terminate()
	End Sub

	Private Function JJ(ByRef n)
		JJ = n
		n = n + 1
	End Function

	Private Function CharCodeAt(ByVal str, ByVal index)
		On Error Resume Next
		CharCodeAt = AscB(MidB(str, index+1, 1))
	End Function

	Private Function IIF(ByVal con, ByVal tv, ByVal fv)
		If con Then
			IIF = tv
		Else
			IIF = fv
		End If
	End Function

	Private Function SHL(ByVal Num, ByVal iCL)
		If Num>=2^31 Or Num<-(2^31) Then 
			Err.Raise 6 : Exit Function
		End If
		If Abs(iCL) >= 32 Then iCL = iCL - Fix(iCL/32)*32
		If iCL<0 Then iCL = iCL + 32
		Dim i, Mask
		For i=1 To iCL
			Mask=0
			If (Num And &H40000000)<>0 Then Mask=&H80000000
			Num=(Num And &H3FFFFFFF)*2 Or Mask
		Next
		SHL = Num
	End Function 

	Private Function SHR(ByVal Num, ByVal iCL)
		If Num>=2^31 Or Num<-(2^31) Then 
			Err.Raise 6 : Exit Function
		End If
		Dim i, Mask, iCN
		If Abs(iCL) >= 32 Then iCL = iCL - Fix(iCL/32)*32
		If iCL<0 Then iCL = iCL + 32
		If Num<0 Then Num = Num + 2^31 : iCN = 2^(31-iCL)
		For i=1 To iCL
			Mask=0
			If (Num And &H80000000)<>0 Then Mask=&H40000000
			Num=(Num And &H7FFFFFFF)\2 Or Mask
		Next
		SHR = Num + iCN
	End Function 

	Private Function SAR(ByVal Num, ByVal iCL)
		If Num>=2^31 Or Num<-(2^31) Then 
			Err.Raise 6 : Exit Function
		End If
		If Abs(iCL) >= 32 Then iCL = iCL - Fix(iCL/32)*32
		If iCL<0 Then iCL = iCL + 32
		Dim i, Mask
		For i=1 To iCL
			Mask=0
			If (Num And &H80000000)<>0 Then Mask=&HC0000000
			Num=(Num And &H7FFFFFFF)\2 Or Mask
		Next
		SAR = Num
	End Function 

	Private Function bin2utf(ByVal bin)
		Dim i, sLen, iAsc, iAsc2, iAsc3
		sLen = LenB(bin)
		For i=1 To sLen
			iAsc = AscB(MidB(bin,i,1))
			If iAsc>=0 And iAsc<=127 Then
				bin2utf = bin2utf & Chr(iAsc)
			ElseIf iAsc >= 224 And iAsc <= 239 Then
				iAsc2 = AscB(MidB(bin,i+1,1))
				iAsc3 = AscB(MidB(bin,i+2,1))
				bin2utf = bin2utf & ChrW(CDbl(iAsc-224) * 4096 + CDbl((iAsc2-128) * 64) + CDbl(iAsc3-128))
				i=i+2
			ElseIf iAsc >= 192 And iAsc <= 223 Then
				iAsc2 = AscB(MidB(bin,i+1,1))
				bin2utf = bin2utf & ChrW(CDbl(iAsc-192) * (2^6) + CDbl(iAsc2-128))
				i=i+1
			End If
		Next
	End Function

	Private Function bin2uni(ByVal bin)
		Dim i, sLen, iAsc
		sLen = LenB(bin)
		For i=1 To sLen
			iAsc = AscB(MidB(bin,i,1))
			If iAsc>=0 And iAsc<=127 Then
				bin2uni = bin2uni & Chr(iAsc)
			Else 
				i=i+1
				If i <= sLen Then
					bin2uni = bin2uni & Chr(AscW(MidB(bin,i,1) & MidB(bin,i-1,1)))
				ElseIf i=sLen+1 Then
					bin2uni = bin2uni & Chr(AscB(MidB(bin,i-1,1)))
				End If
			End If
		Next
	End Function
	Private Function str2bin(ByVal str) 
		Dim i, j, istr, iarr
		For i=1 To Len(str)
			istr = mid(str,i,1)
			istr = Replace(Server.UrlEncode(istr),"+"," ")
			If len(istr) = 1 Then
				str2bin = str2bin & chrB(AscB(istr))
			Else
				iarr = split(istr,"%")
				For j=1 To ubound(iarr)
					str2bin = str2bin & chrB("&H" & iarr(j)) 
				Next
			End If
		Next
	End Function

	Private Function hex2bin(ByVal str)
		Dim i
		For i = 1 To Len(str) Step 2
			hex2bin = hex2bin & ChrB("&H" & Mid(str, i, 2))
		Next
	End Function

	Private Function bin2hex(ByVal str)
		Dim t, i
		For i = 1 To LenB(str)
			t = Hex(AscB(MidB(str, i, 1)))
			If (Len(t) < 2) Then
				while (Len(t) < 2)
					t = "0" & t
				Wend
			End If
			bin2hex = LCase(bin2hex & t)
		Next
	End Function

End Class
%>