<%
'by anlige at www.9fn.net
Class MoLibAes
	Private sKey, sIV, sMode, sPadding, sEncoding
	Private Rcon, S, T1, T2, T3, T4
	Private S5, T5, T6, T7, T8, U1, U2, U3, U4
	Private Rounds
	
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
		Encode = bin2hex(AesEncode(str))
	End Function
	Public Function Decode(ByVal str)
		Decode = AesDecode(hex2bin(str))
	End Function
	
	Private Function AesEncode(ByVal str)

		Dim lens, m, r, i, eKey
		Dim pdcnt, pdstr, iv
		Dim CB, PB, PT(3), sResult

		m = 0 : str = str2bin(str) : lens = LenB(str)

		pdcnt = 16 - (lens Mod 16)
		If sPadding = "pkcs5" Then 
			pdstr = str2bin(String(pdcnt,pdcnt))
			If pdcnt = 16 Then lens = lens + 16
		ElseIf sPadding = "none" Then 
			If pdcnt<>16 Then 
				AesEncode = "None Mode:Length of str must mod by 16"
				Exit Function
			End If
		ElseIf sPadding = "zero" Then 
			If pdcnt<16 Then pdstr = str2bin(String(pdcnt,0))
		End If
		str = str & pdstr
		eKey = keyExpansion(sKey,"en")

		If sMode = "cbc" Then
			iv = str2bin(sIV) : CB = PackBytes(iv, m) : m=0
		End If

		While m<lens

			PB = PackBytes(str, m)

			If sMode = "cbc" Then
				PB(0) = PB(0) Xor CB(0) : PB(1) = PB(1) Xor CB(1) : PB(2) = PB(2) Xor CB(2) : PB(3) = PB(3) Xor CB(3)
			End If

			For r=0 To Rounds-2
				PT(0) = PB(0) Xor eKey(r)(0)
				PT(1) = PB(1) Xor eKey(r)(1)
				PT(2) = PB(2) Xor eKey(r)(2)
				PT(3) = PB(3) Xor eKey(r)(3)

				PB(0) = T1(PT(0) And 255) Xor T2(SAR(PT(1),8) And 255) Xor T3(SAR(PT(2),16) And 255) Xor T4(SHR(PT(3),24))
				PB(1) = T1(PT(1) And 255) Xor T2(SAR(PT(2),8) And 255) Xor T3(SAR(PT(3),16) And 255) Xor T4(SHR(PT(0),24))
				PB(2) = T1(PT(2) And 255) Xor T2(SAR(PT(3),8) And 255) Xor T3(SAR(PT(0),16) And 255) Xor T4(SHR(PT(1),24))
				PB(3) = T1(PT(3) And 255) Xor T2(SAR(PT(0),8) And 255) Xor T3(SAR(PT(1),16) And 255) Xor T4(SHR(PT(2),24))
			Next

			r = Rounds-1

			PT(0) = PB(0) Xor eKey(r)(0)
			PT(1) = PB(1) Xor eKey(r)(1)
			PT(2) = PB(2) Xor eKey(r)(2)
			PT(3) = PB(3) Xor eKey(r)(3)

			PB(0) = F1(PT(0), PT(1), PT(2), PT(3)) Xor eKey(Rounds)(0)
			PB(1) = F1(PT(1), PT(2), PT(3), PT(0)) Xor eKey(Rounds)(1)
			PB(2) = F1(PT(2), PT(3), PT(0), PT(1)) Xor eKey(Rounds)(2)
			PB(3) = F1(PT(3), PT(0), PT(1), PT(2)) Xor eKey(Rounds)(3)

			If sMode = "cbc" Then CB = PB

			For i=0 To 3
				sResult = sResult & ChrB(B0(PB(i))) & ChrB(B1(PB(i))) & ChrB(B2(PB(i))) & ChrB(B3(PB(i)))
			Next

		Wend

		AesEncode = sResult
	End Function

	Private Function AesDecode(ByVal bin)
		Dim lens, m, r, i, eKey, iv
		Dim CB, CB2, PB, PT(3), sResult

		m=0 : lens = LenB(bin)
		eKey = keyExpansion(sKey,"de")

		If sMode = "cbc" Then
			iv = str2bin(sIV) : CB = PackBytes(iv, m) : m=0
		End If

		While m<lens

			PB = PackBytes(bin, m)

			If sMode = "cbc" Then
				CB2 = CB : CB = PB
			End If

			For r=rounds To 2 Step -1
				PT(0) = PB(0) Xor eKey(r)(0)
				PT(1) = PB(1) Xor eKey(r)(1)
				PT(2) = PB(2) Xor eKey(r)(2)
				PT(3) = PB(3) Xor eKey(r)(3)

				PB(0) = T5(B0(PT(0))) Xor T6(B1(PT(3))) Xor T7(B2(PT(2))) Xor T8(B3(PT(1)))
				PB(1) = T5(B0(PT(1))) Xor T6(B1(PT(0))) Xor T7(B2(PT(3))) Xor T8(B3(PT(2)))
				PB(2) = T5(B0(PT(2))) Xor T6(B1(PT(1))) Xor T7(B2(PT(0))) Xor T8(B3(PT(3)))
				PB(3) = T5(B0(PT(3))) Xor T6(B1(PT(2))) Xor T7(B2(PT(1))) Xor T8(B3(PT(0)))
			Next

			PT(0) = PB(0) Xor eKey(1)(0)
			PT(1) = PB(1) Xor eKey(1)(1)
			PT(2) = PB(2) Xor eKey(1)(2)
			PT(3) = PB(3) Xor eKey(1)(3)

			PB(0) = S5(B0(PT(0))) Or SHL(S5(B1(PT(3))),8) Or SHL(S5(B2(PT(2))),16) Or SHL(S5(B3(PT(1))),24)
			PB(1) = S5(B0(PT(1))) Or SHL(S5(B1(PT(0))),8) Or SHL(S5(B2(PT(3))),16) Or SHL(S5(B3(PT(2))),24)
			PB(2) = S5(B0(PT(2))) Or SHL(S5(B1(PT(1))),8) Or SHL(S5(B2(PT(0))),16) Or SHL(S5(B3(PT(3))),24)
			PB(3) = S5(B0(PT(3))) Or SHL(S5(B1(PT(2))),8) Or SHL(S5(B2(PT(1))),16) Or SHL(S5(B3(PT(0))),24)

			PB(0) = PB(0) Xor eKey(0)(0)
			PB(1) = PB(1) Xor eKey(0)(1)
			PB(2) = PB(2) Xor eKey(0)(2)
			PB(3) = PB(3) Xor eKey(0)(3)

			If sMode = "cbc" Then
				PB(0) = PB(0) Xor CB2(0) : PB(1) = PB(1) Xor CB2(1) : PB(2) = PB(2) Xor CB2(2) : PB(3) = PB(3) Xor CB2(3)
			End If

			For i=0 To 3
				sResult = sResult & ChrB(B0(PB(i))) & ChrB(B1(PB(i))) & ChrB(B2(PB(i))) & ChrB(B3(PB(i)))
			Next

		Wend
		
		If sPadding = "pkcs5" Then 
			sResult = LeftB(sResult,LenB(sResult)-AscB(RightB(sResult,1)))
		ElseIf sPadding = "zero" Then 
			sResult = Replace(sResult,Chr(0),"")
		End If
		'/////////////////////////////////////////////

		If sEncoding="gb2312" Then 
			sResult = bin2uni(sResult)
		ElseIf sEncoding="utf-8" Then 
			sResult = bin2utf(sResult)
		End If 
		AesDecode = sResult

	End Function

	Private Function PackBytes(ByVal str, ByRef m)
		Dim temp(3)
		temp(0) = CharCodeAt(str,JJ(m)) Or SHL(CharCodeAt(str,JJ(m)), 8) Or SHL(CharCodeAt(str,JJ(m)), 16) Or SHL(CharCodeAt(str,JJ(m)), 24)
		temp(1) = CharCodeAt(str,JJ(m)) Or SHL(CharCodeAt(str,JJ(m)), 8) Or SHL(CharCodeAt(str,JJ(m)), 16) Or SHL(CharCodeAt(str,JJ(m)), 24)
		temp(2) = CharCodeAt(str,JJ(m)) Or SHL(CharCodeAt(str,JJ(m)), 8) Or SHL(CharCodeAt(str,JJ(m)), 16) Or SHL(CharCodeAt(str,JJ(m)), 24)
		temp(3) = CharCodeAt(str,JJ(m)) Or SHL(CharCodeAt(str,JJ(m)), 8) Or SHL(CharCodeAt(str,JJ(m)), 16) Or SHL(CharCodeAt(str,JJ(m)), 24)
		PackBytes = temp
	End Function

	Private Function B0(ByVal x) 
		B0 = (x And 255)
	End Function

	Private Function B1(ByVal x) 
		B1 = SAR(x, 8) And 255
	End Function

	Private Function B2(ByVal x) 
		B2 = SAR(x, 16) And 255
	End Function

	Private Function B3(ByVal x) 
		B3 = SAR(x, 24) And 255
	End Function

	Private Function F1(ByVal x0, ByVal x1, ByVal x2, ByVal x3)
		F1 = B1(T1(x0 And 255)) Or SHL(B1(T1(SAR(x1, 8) And 255)), 8) Or SHL(B1(T1(SAR(x2, 16) And 255)), 16) Or SHL(B1(T1(SHR(x3, 24))), 24)
	End Function

	Private Function keyExpansion(ByVal key, ByVal encrypt)
		Dim kc, i, j, r, t, keylen
		Dim KeyArr(), tk(), RcPt, tempArr(3)

		RcPt = 0 : key = str2bin(key) : keylen = LenB(key)

		Select Case CLng(keylen)
			Case 16 : Rounds=10 : kc=4
			Case 24 : Rounds=12 : kc=6
			Case 32 : Rounds=14 : kc=8
			Case Else
				Response.Write ("Invalid key length : " & keylen)
				Response.End
		End Select

		ReDim KeyArr(Rounds) : ReDim tk(kc-1)

		For i=0 To Rounds
			KeyArr(i)= tempArr
		Next 

		i=0
		For j=0 To kc-1
			tk(j) = CharCodeAt(key, i) Or SHL(CharCodeAt(key, i+1), 8) Or SHL(CharCodeAt(key, i+2), 16) Or SHL(CharCodeAt(key, i+3), 24)
			i = i + 4
		Next

		r=0 : t=0 : j=0
		While (j<kc And r<Rounds+1)
			While (j<kc And t<4)
				KeyArr(r)(t)=tk(j) : j=j+1 : t=t+1
			Wend
			If t=4 Then r=r+1 : t=0
		Wend

		While (r<rounds+1)
			Dim temp : temp = tk(kc-1)
			tk(0) = tk(0) Xor (S(B1(temp)) Or SHL(S(B2(temp)), 8) Or SHL(S(B3(temp)), 16) Or SHL(S(B0(temp)), 24))
			tk(0) = tk(0) Xor Rcon(JJ(RcPt))
			If kc <> 8 Then
				For j=1 To kc-1 
					tk(j) = tk(j) Xor tk(j-1)
				Next
			Else
				For j=1 To (kc/2) -1
					tk(j) = tk(j) Xor tk(j-1)
				Next 
				temp = tk(kc/2-1)
				tk(kc/2) = tk(kc/2) Xor (S(B0(temp)) Or SHL(S(B1(temp)),8) Or SHL(S(B2(temp)),16) Or SHL(S(B3(temp)),24))
				For j=kc/2+1 To kc-1
					tk(j) = tk(j) Xor tk(j-1)
				Next
			End If
			j = 0
			While (j<kc) And (r<rounds+1)
				While (j<kc) And (t<4)
					KeyArr(r)(t)=tk(j)
					j=j+1 : t=t+1
				Wend
				If t=4 Then : r=r+1 : t=0
			Wend
		Wend
		If LCase(encrypt) = "de" Then
			Dim w
			For r=1 To Rounds-1
				w=KeyArr(r)(0) : KeyArr(r)(0) = U1(B0(w)) Xor U2(B1(w)) Xor U3(B2(w)) Xor U4(B3(w))
				w=KeyArr(r)(1) : KeyArr(r)(1) = U1(B0(w)) Xor U2(B1(w)) Xor U3(B2(w)) Xor U4(B3(w))
				w=KeyArr(r)(2) : KeyArr(r)(2) = U1(B0(w)) Xor U2(B1(w)) Xor U3(B2(w)) Xor U4(B3(w))
				w=KeyArr(r)(3) : KeyArr(r)(3) = U1(B0(w)) Xor U2(B1(w)) Xor U3(B2(w)) Xor U4(B3(w))
			Next
		End If
		keyExpansion = KeyArr
	End Function


	Private Sub Class_Initialize()

		sMode = "cbc"
		sPadding = "pkcs5"
		sIV = ""
		sEncoding = "gb2312"

		'// The round constants used in subkey expansion
		Rcon = Array(1, 2, 4, 8, 16, 32, 64, 128, 27, 54, 108, 216, 171, 77, 154, 47, 94, 188, 99, 198, 151, 53, 106, 212, 179, 125, 250, 239, 197, 145)

		'// Precomputed lookup table for the SBox
		S = Array(99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118, 202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21, 4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117, 9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132, 83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207, 208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168, 81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210, 205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115, 96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219, 224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121, 231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8, 186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138, 112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158, 225,248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223,140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22)

		T1 = Array(&Ha56363c6, &H847c7cf8, &H997777ee, &H8d7b7bf6,&H0df2f2ff, &Hbd6b6bd6, &Hb16f6fde, &H54c5c591,&H50303060, &H03010102, &Ha96767ce, &H7d2b2b56,&H19fefee7, &H62d7d7b5, &He6abab4d, &H9a7676ec,&H45caca8f, &H9d82821f, &H40c9c989, &H877d7dfa,&H15fafaef, &Heb5959b2, &Hc947478e, &H0bf0f0fb,&Hecadad41, &H67d4d4b3, &Hfda2a25f, &Heaafaf45,&Hbf9c9c23, &Hf7a4a453, &H967272e4, &H5bc0c09b,&Hc2b7b775, &H1cfdfde1, &Hae93933d, &H6a26264c,&H5a36366c, &H413f3f7e, &H02f7f7f5, &H4fcccc83,&H5c343468, &Hf4a5a551, &H34e5e5d1, &H08f1f1f9,&H937171e2, &H73d8d8ab, &H53313162, &H3f15152a,&H0c040408, &H52c7c795, &H65232346, &H5ec3c39d,&H28181830, &Ha1969637, &H0f05050a, &Hb59a9a2f,&H0907070e, &H36121224, &H9b80801b, &H3de2e2df,&H26ebebcd, &H6927274e, &Hcdb2b27f, &H9f7575ea,&H1b090912, &H9e83831d, &H742c2c58, &H2e1a1a34,&H2d1b1b36, &Hb26e6edc, &Hee5a5ab4, &Hfba0a05b,&Hf65252a4, &H4d3b3b76, &H61d6d6b7, &Hceb3b37d,&H7b292952, &H3ee3e3dd, &H712f2f5e, &H97848413,&Hf55353a6, &H68d1d1b9, &H00000000, &H2cededc1,&H60202040, &H1ffcfce3, &Hc8b1b179, &Hed5b5bb6,&Hbe6a6ad4, &H46cbcb8d, &Hd9bebe67, &H4b393972,&Hde4a4a94, &Hd44c4c98, &He85858b0, &H4acfcf85,&H6bd0d0bb, &H2aefefc5, &He5aaaa4f, &H16fbfbed,&Hc5434386, &Hd74d4d9a, &H55333366, &H94858511,&Hcf45458a, &H10f9f9e9, &H06020204, &H817f7ffe,&Hf05050a0, &H443c3c78, &Hba9f9f25, &He3a8a84b,&Hf35151a2, &Hfea3a35d, &Hc0404080, &H8a8f8f05,&Had92923f, &Hbc9d9d21, &H48383870, &H04f5f5f1,&Hdfbcbc63, &Hc1b6b677, &H75dadaaf, &H63212142,&H30101020, &H1affffe5, &H0ef3f3fd, &H6dd2d2bf,&H4ccdcd81, &H140c0c18, &H35131326, &H2fececc3,&He15f5fbe, &Ha2979735, &Hcc444488, &H3917172e,&H57c4c493, &Hf2a7a755, &H827e7efc, &H473d3d7a,&Hac6464c8, &He75d5dba, &H2b191932, &H957373e6,&Ha06060c0, &H98818119, &Hd14f4f9e, &H7fdcdca3,&H66222244, &H7e2a2a54, &Hab90903b, &H8388880b,&Hca46468c, &H29eeeec7, &Hd3b8b86b, &H3c141428,&H79dedea7, &He25e5ebc, &H1d0b0b16, &H76dbdbad,&H3be0e0db, &H56323264, &H4e3a3a74, &H1e0a0a14,&Hdb494992, &H0a06060c, &H6c242448, &He45c5cb8,&H5dc2c29f, &H6ed3d3bd, &Hefacac43, &Ha66262c4,&Ha8919139, &Ha4959531, &H37e4e4d3, &H8b7979f2,&H32e7e7d5, &H43c8c88b, &H5937376e, &Hb76d6dda,&H8c8d8d01, &H64d5d5b1, &Hd24e4e9c, &He0a9a949,&Hb46c6cd8, &Hfa5656ac, &H07f4f4f3, &H25eaeacf,&Haf6565ca, &H8e7a7af4, &He9aeae47, &H18080810,&Hd5baba6f, &H887878f0, &H6f25254a, &H722e2e5c,&H241c1c38, &Hf1a6a657, &Hc7b4b473, &H51c6c697,&H23e8e8cb, &H7cdddda1, &H9c7474e8, &H211f1f3e,&Hdd4b4b96, &Hdcbdbd61, &H868b8b0d, &H858a8a0f,&H907070e0, &H423e3e7c, &Hc4b5b571, &Haa6666cc,&Hd8484890, &H05030306, &H01f6f6f7, &H120e0e1c,&Ha36161c2, &H5f35356a, &Hf95757ae, &Hd0b9b969,&H91868617, &H58c1c199, &H271d1d3a, &Hb99e9e27,&H38e1e1d9, &H13f8f8eb, &Hb398982b, &H33111122,&Hbb6969d2, &H70d9d9a9, &H898e8e07, &Ha7949433,&Hb69b9b2d, &H221e1e3c, &H92878715, &H20e9e9c9,&H49cece87, &Hff5555aa, &H78282850, &H7adfdfa5,&H8f8c8c03, &Hf8a1a159, &H80898909, &H170d0d1a,&Hdabfbf65, &H31e6e6d7, &Hc6424284, &Hb86868d0,&Hc3414182, &Hb0999929, &H772d2d5a, &H110f0f1e,&Hcbb0b07b, &Hfc5454a8, &Hd6bbbb6d, &H3a16162c)
		T2 = Array(&H6363c6a5, &H7c7cf884, &H7777ee99, &H7b7bf68d,&Hf2f2ff0d, &H6b6bd6bd, &H6f6fdeb1, &Hc5c59154,&H30306050, &H01010203, &H6767cea9, &H2b2b567d,&Hfefee719, &Hd7d7b562, &Habab4de6, &H7676ec9a,&Hcaca8f45, &H82821f9d, &Hc9c98940, &H7d7dfa87,&Hfafaef15, &H5959b2eb, &H47478ec9, &Hf0f0fb0b,&Hadad41ec, &Hd4d4b367, &Ha2a25ffd, &Hafaf45ea,&H9c9c23bf, &Ha4a453f7, &H7272e496, &Hc0c09b5b,&Hb7b775c2, &Hfdfde11c, &H93933dae, &H26264c6a,&H36366c5a, &H3f3f7e41, &Hf7f7f502, &Hcccc834f,&H3434685c, &Ha5a551f4, &He5e5d134, &Hf1f1f908,&H7171e293, &Hd8d8ab73, &H31316253, &H15152a3f,&H0404080c, &Hc7c79552, &H23234665, &Hc3c39d5e,&H18183028, &H969637a1, &H05050a0f, &H9a9a2fb5,&H07070e09, &H12122436, &H80801b9b, &He2e2df3d,&Hebebcd26, &H27274e69, &Hb2b27fcd, &H7575ea9f,&H0909121b, &H83831d9e, &H2c2c5874, &H1a1a342e,&H1b1b362d, &H6e6edcb2, &H5a5ab4ee, &Ha0a05bfb,&H5252a4f6, &H3b3b764d, &Hd6d6b761, &Hb3b37dce,&H2929527b, &He3e3dd3e, &H2f2f5e71, &H84841397,&H5353a6f5, &Hd1d1b968, &H00000000, &Hededc12c,&H20204060, &Hfcfce31f, &Hb1b179c8, &H5b5bb6ed,&H6a6ad4be, &Hcbcb8d46, &Hbebe67d9, &H3939724b,&H4a4a94de, &H4c4c98d4, &H5858b0e8, &Hcfcf854a,&Hd0d0bb6b, &Hefefc52a, &Haaaa4fe5, &Hfbfbed16,&H434386c5, &H4d4d9ad7, &H33336655, &H85851194,&H45458acf, &Hf9f9e910, &H02020406, &H7f7ffe81,&H5050a0f0, &H3c3c7844, &H9f9f25ba, &Ha8a84be3,&H5151a2f3, &Ha3a35dfe, &H404080c0, &H8f8f058a,&H92923fad, &H9d9d21bc, &H38387048, &Hf5f5f104,&Hbcbc63df, &Hb6b677c1, &Hdadaaf75, &H21214263,&H10102030, &Hffffe51a, &Hf3f3fd0e, &Hd2d2bf6d,&Hcdcd814c, &H0c0c1814, &H13132635, &Hececc32f,&H5f5fbee1, &H979735a2, &H444488cc, &H17172e39,&Hc4c49357, &Ha7a755f2, &H7e7efc82, &H3d3d7a47,&H6464c8ac, &H5d5dbae7, &H1919322b, &H7373e695,&H6060c0a0, &H81811998, &H4f4f9ed1, &Hdcdca37f,&H22224466, &H2a2a547e, &H90903bab, &H88880b83,&H46468cca, &Heeeec729, &Hb8b86bd3, &H1414283c,&Hdedea779, &H5e5ebce2, &H0b0b161d, &Hdbdbad76,&He0e0db3b, &H32326456, &H3a3a744e, &H0a0a141e,&H494992db, &H06060c0a, &H2424486c, &H5c5cb8e4,&Hc2c29f5d, &Hd3d3bd6e, &Hacac43ef, &H6262c4a6,&H919139a8, &H959531a4, &He4e4d337, &H7979f28b,&He7e7d532, &Hc8c88b43, &H37376e59, &H6d6ddab7,&H8d8d018c, &Hd5d5b164, &H4e4e9cd2, &Ha9a949e0,&H6c6cd8b4, &H5656acfa, &Hf4f4f307, &Heaeacf25,&H6565caaf, &H7a7af48e, &Haeae47e9, &H08081018,&Hbaba6fd5, &H7878f088, &H25254a6f, &H2e2e5c72,&H1c1c3824, &Ha6a657f1, &Hb4b473c7, &Hc6c69751,&He8e8cb23, &Hdddda17c, &H7474e89c, &H1f1f3e21,&H4b4b96dd, &Hbdbd61dc, &H8b8b0d86, &H8a8a0f85,&H7070e090, &H3e3e7c42, &Hb5b571c4, &H6666ccaa,&H484890d8, &H03030605, &Hf6f6f701, &H0e0e1c12,&H6161c2a3, &H35356a5f, &H5757aef9, &Hb9b969d0,&H86861791, &Hc1c19958, &H1d1d3a27, &H9e9e27b9,&He1e1d938, &Hf8f8eb13, &H98982bb3, &H11112233,&H6969d2bb, &Hd9d9a970, &H8e8e0789, &H949433a7,&H9b9b2db6, &H1e1e3c22, &H87871592, &He9e9c920,&Hcece8749, &H5555aaff, &H28285078, &Hdfdfa57a,&H8c8c038f, &Ha1a159f8, &H89890980, &H0d0d1a17,&Hbfbf65da, &He6e6d731, &H424284c6, &H6868d0b8,&H414182c3, &H999929b0, &H2d2d5a77, &H0f0f1e11,&Hb0b07bcb, &H5454a8fc, &Hbbbb6dd6, &H16162c3a)
		T3 = Array(&H63c6a563, &H7cf8847c, &H77ee9977, &H7bf68d7b,&Hf2ff0df2, &H6bd6bd6b, &H6fdeb16f, &Hc59154c5,&H30605030, &H01020301, &H67cea967, &H2b567d2b,&Hfee719fe, &Hd7b562d7, &Hab4de6ab, &H76ec9a76,&Hca8f45ca, &H821f9d82, &Hc98940c9, &H7dfa877d,&Hfaef15fa, &H59b2eb59, &H478ec947, &Hf0fb0bf0,&Had41ecad, &Hd4b367d4, &Ha25ffda2, &Haf45eaaf,&H9c23bf9c, &Ha453f7a4, &H72e49672, &Hc09b5bc0,&Hb775c2b7, &Hfde11cfd, &H933dae93, &H264c6a26,&H366c5a36, &H3f7e413f, &Hf7f502f7, &Hcc834fcc,&H34685c34, &Ha551f4a5, &He5d134e5, &Hf1f908f1,&H71e29371, &Hd8ab73d8, &H31625331, &H152a3f15,&H04080c04, &Hc79552c7, &H23466523, &Hc39d5ec3,&H18302818, &H9637a196, &H050a0f05, &H9a2fb59a,&H070e0907, &H12243612, &H801b9b80, &He2df3de2,&Hebcd26eb, &H274e6927, &Hb27fcdb2, &H75ea9f75,&H09121b09, &H831d9e83, &H2c58742c, &H1a342e1a,&H1b362d1b, &H6edcb26e, &H5ab4ee5a, &Ha05bfba0,&H52a4f652, &H3b764d3b, &Hd6b761d6, &Hb37dceb3,&H29527b29, &He3dd3ee3, &H2f5e712f, &H84139784,&H53a6f553, &Hd1b968d1, &H00000000, &Hedc12ced,&H20406020, &Hfce31ffc, &Hb179c8b1, &H5bb6ed5b,&H6ad4be6a, &Hcb8d46cb, &Hbe67d9be, &H39724b39,&H4a94de4a, &H4c98d44c, &H58b0e858, &Hcf854acf,&Hd0bb6bd0, &Hefc52aef, &Haa4fe5aa, &Hfbed16fb,&H4386c543, &H4d9ad74d, &H33665533, &H85119485,&H458acf45, &Hf9e910f9, &H02040602, &H7ffe817f,&H50a0f050, &H3c78443c, &H9f25ba9f, &Ha84be3a8,&H51a2f351, &Ha35dfea3, &H4080c040, &H8f058a8f,&H923fad92, &H9d21bc9d, &H38704838, &Hf5f104f5,&Hbc63dfbc, &Hb677c1b6, &Hdaaf75da, &H21426321,&H10203010, &Hffe51aff, &Hf3fd0ef3, &Hd2bf6dd2,&Hcd814ccd, &H0c18140c, &H13263513, &Hecc32fec,&H5fbee15f, &H9735a297, &H4488cc44, &H172e3917,&Hc49357c4, &Ha755f2a7, &H7efc827e, &H3d7a473d,&H64c8ac64, &H5dbae75d, &H19322b19, &H73e69573,&H60c0a060, &H81199881, &H4f9ed14f, &Hdca37fdc,&H22446622, &H2a547e2a, &H903bab90, &H880b8388,&H468cca46, &Heec729ee, &Hb86bd3b8, &H14283c14,&Hdea779de, &H5ebce25e, &H0b161d0b, &Hdbad76db,&He0db3be0, &H32645632, &H3a744e3a, &H0a141e0a,&H4992db49, &H060c0a06, &H24486c24, &H5cb8e45c,&Hc29f5dc2, &Hd3bd6ed3, &Hac43efac, &H62c4a662,&H9139a891, &H9531a495, &He4d337e4, &H79f28b79,&He7d532e7, &Hc88b43c8, &H376e5937, &H6ddab76d,&H8d018c8d, &Hd5b164d5, &H4e9cd24e, &Ha949e0a9,&H6cd8b46c, &H56acfa56, &Hf4f307f4, &Heacf25ea,&H65caaf65, &H7af48e7a, &Hae47e9ae, &H08101808,&Hba6fd5ba, &H78f08878, &H254a6f25, &H2e5c722e,&H1c38241c, &Ha657f1a6, &Hb473c7b4, &Hc69751c6,&He8cb23e8, &Hdda17cdd, &H74e89c74, &H1f3e211f,&H4b96dd4b, &Hbd61dcbd, &H8b0d868b, &H8a0f858a,&H70e09070, &H3e7c423e, &Hb571c4b5, &H66ccaa66,&H4890d848, &H03060503, &Hf6f701f6, &H0e1c120e,&H61c2a361, &H356a5f35, &H57aef957, &Hb969d0b9,&H86179186, &Hc19958c1, &H1d3a271d, &H9e27b99e,&He1d938e1, &Hf8eb13f8, &H982bb398, &H11223311,&H69d2bb69, &Hd9a970d9, &H8e07898e, &H9433a794,&H9b2db69b, &H1e3c221e, &H87159287, &He9c920e9,&Hce8749ce, &H55aaff55, &H28507828, &Hdfa57adf,&H8c038f8c, &Ha159f8a1, &H89098089, &H0d1a170d,&Hbf65dabf, &He6d731e6, &H4284c642, &H68d0b868,&H4182c341, &H9929b099, &H2d5a772d, &H0f1e110f,&Hb07bcbb0, &H54a8fc54, &Hbb6dd6bb, &H162c3a16)
		T4 = Array(&Hc6a56363, &Hf8847c7c, &Hee997777, &Hf68d7b7b,&Hff0df2f2, &Hd6bd6b6b, &Hdeb16f6f, &H9154c5c5,&H60503030, &H02030101, &Hcea96767, &H567d2b2b,&He719fefe, &Hb562d7d7, &H4de6abab, &Hec9a7676,&H8f45caca, &H1f9d8282, &H8940c9c9, &Hfa877d7d,&Hef15fafa, &Hb2eb5959, &H8ec94747, &Hfb0bf0f0,&H41ecadad, &Hb367d4d4, &H5ffda2a2, &H45eaafaf,&H23bf9c9c, &H53f7a4a4, &He4967272, &H9b5bc0c0,&H75c2b7b7, &He11cfdfd, &H3dae9393, &H4c6a2626,&H6c5a3636, &H7e413f3f, &Hf502f7f7, &H834fcccc,&H685c3434, &H51f4a5a5, &Hd134e5e5, &Hf908f1f1,&He2937171, &Hab73d8d8, &H62533131, &H2a3f1515,&H080c0404, &H9552c7c7, &H46652323, &H9d5ec3c3,&H30281818, &H37a19696, &H0a0f0505, &H2fb59a9a,&H0e090707, &H24361212, &H1b9b8080, &Hdf3de2e2,&Hcd26ebeb, &H4e692727, &H7fcdb2b2, &Hea9f7575,&H121b0909, &H1d9e8383, &H58742c2c, &H342e1a1a,&H362d1b1b, &Hdcb26e6e, &Hb4ee5a5a, &H5bfba0a0,&Ha4f65252, &H764d3b3b, &Hb761d6d6, &H7dceb3b3,&H527b2929, &Hdd3ee3e3, &H5e712f2f, &H13978484,&Ha6f55353, &Hb968d1d1, &H00000000, &Hc12ceded,&H40602020, &He31ffcfc, &H79c8b1b1, &Hb6ed5b5b,&Hd4be6a6a, &H8d46cbcb, &H67d9bebe, &H724b3939,&H94de4a4a, &H98d44c4c, &Hb0e85858, &H854acfcf,&Hbb6bd0d0, &Hc52aefef, &H4fe5aaaa, &Hed16fbfb,&H86c54343, &H9ad74d4d, &H66553333, &H11948585,&H8acf4545, &He910f9f9, &H04060202, &Hfe817f7f,&Ha0f05050, &H78443c3c, &H25ba9f9f, &H4be3a8a8,&Ha2f35151, &H5dfea3a3, &H80c04040, &H058a8f8f,&H3fad9292, &H21bc9d9d, &H70483838, &Hf104f5f5,&H63dfbcbc, &H77c1b6b6, &Haf75dada, &H42632121,&H20301010, &He51affff, &Hfd0ef3f3, &Hbf6dd2d2,&H814ccdcd, &H18140c0c, &H26351313, &Hc32fecec,&Hbee15f5f, &H35a29797, &H88cc4444, &H2e391717,&H9357c4c4, &H55f2a7a7, &Hfc827e7e, &H7a473d3d,&Hc8ac6464, &Hbae75d5d, &H322b1919, &He6957373,&Hc0a06060, &H19988181, &H9ed14f4f, &Ha37fdcdc,&H44662222, &H547e2a2a, &H3bab9090, &H0b838888,&H8cca4646, &Hc729eeee, &H6bd3b8b8, &H283c1414,&Ha779dede, &Hbce25e5e, &H161d0b0b, &Had76dbdb,&Hdb3be0e0, &H64563232, &H744e3a3a, &H141e0a0a,&H92db4949, &H0c0a0606, &H486c2424, &Hb8e45c5c,&H9f5dc2c2, &Hbd6ed3d3, &H43efacac, &Hc4a66262,&H39a89191, &H31a49595, &Hd337e4e4, &Hf28b7979,&Hd532e7e7, &H8b43c8c8, &H6e593737, &Hdab76d6d,&H018c8d8d, &Hb164d5d5, &H9cd24e4e, &H49e0a9a9,&Hd8b46c6c, &Hacfa5656, &Hf307f4f4, &Hcf25eaea,&Hcaaf6565, &Hf48e7a7a, &H47e9aeae, &H10180808,&H6fd5baba, &Hf0887878, &H4a6f2525, &H5c722e2e,&H38241c1c, &H57f1a6a6, &H73c7b4b4, &H9751c6c6,&Hcb23e8e8, &Ha17cdddd, &He89c7474, &H3e211f1f,&H96dd4b4b, &H61dcbdbd, &H0d868b8b, &H0f858a8a,&He0907070, &H7c423e3e, &H71c4b5b5, &Hccaa6666,&H90d84848, &H06050303, &Hf701f6f6, &H1c120e0e,&Hc2a36161, &H6a5f3535, &Haef95757, &H69d0b9b9,&H17918686, &H9958c1c1, &H3a271d1d, &H27b99e9e,&Hd938e1e1, &Heb13f8f8, &H2bb39898, &H22331111,&Hd2bb6969, &Ha970d9d9, &H07898e8e, &H33a79494,&H2db69b9b, &H3c221e1e, &H15928787, &Hc920e9e9,&H8749cece, &Haaff5555, &H50782828, &Ha57adfdf,&H038f8c8c, &H59f8a1a1, &H09808989, &H1a170d0d,&H65dabfbf, &Hd731e6e6, &H84c64242, &Hd0b86868,&H82c34141, &H29b09999, &H5a772d2d, &H1e110f0f,&H7bcbb0b0, &Ha8fc5454, &H6dd6bbbb, &H2c3a1616)

		'// Precomputed lookup table for the inverse SBox
		S5 = Array(82, 9, 106, 213, 48, 54, 165, 56, 191, 64, 163, 158, 129, 243, 215, 251, 124, 227, 57, 130, 155, 47, 255, 135, 52, 142, 67, 68, 196, 222, 233, 203, 84, 123, 148, 50, 166, 194, 35, 61, 238, 76, 149, 11, 66, 250, 195, 78, 8, 46, 161, 102, 40, 217, 36, 178, 118, 91, 162, 73, 109, 139, 209, 37, 114, 248, 246, 100, 134, 104, 152, 22, 212, 164, 92, 204, 93, 101, 182, 146, 108, 112, 72, 80, 253, 237, 185, 218, 94, 21, 70, 87, 167, 141, 157, 132, 144, 216, 171, 0, 140, 188, 211, 10, 247, 228, 88, 5, 184, 179, 69, 6, 208, 44, 30, 143, 202, 63, 15, 2, 193, 175, 189, 3, 1, 19, 138, 107, 58, 145, 17, 65, 79, 103, 220, 234, 151, 242, 207, 206, 240, 180, 230, 115, 150, 172, 116, 34, 231, 173, 53, 133, 226, 249, 55, 232, 28, 117, 223, 110, 71, 241, 26, 113, 29, 41, 197, 137, 111, 183, 98, 14, 170, 24, 190, 27, 252, 86, 62, 75, 198, 210, 121, 32, 154, 219, 192, 254, 120, 205, 90, 244, 31, 221, 168, 51, 136, 7, 199, 49, 177, 18, 16, 89, 39, 128, 236, 95, 96, 81,127, 169, 25, 181, 74, 13, 45, 229, 122, 159, 147, 201, 156, 239, 160,224, 59, 77, 174, 42, 245, 176, 200, 235, 187, 60, 131, 83, 153, 97, 23, 43, 4, 126, 186, 119, 214, 38, 225, 105, 20, 99, 85, 33, 12, 125)

		T5 = Array(&H50a7f451,&H5365417e,&Hc3a4171a,&H965e273a,&Hcb6bab3b,&Hf1459d1f,&Hab58faac,&H9303e34b,&H55fa3020,&Hf66d76ad,&H9176cc88,&H254c02f5,&Hfcd7e54f,&Hd7cb2ac5,&H80443526,&H8fa362b5,&H495ab1de,&H671bba25,&H980eea45,&He1c0fe5d,&H02752fc3,&H12f04c81,&Ha397468d,&Hc6f9d36b,&He75f8f03,&H959c9215,&Heb7a6dbf,&Hda595295,&H2d83bed4,&Hd3217458,&H2969e049,&H44c8c98e,&H6a89c275,&H78798ef4,&H6b3e5899,&Hdd71b927,&Hb64fe1be,&H17ad88f0,&H66ac20c9,&Hb43ace7d,&H184adf63,&H82311ae5,&H60335197,&H457f5362,&He07764b1,&H84ae6bbb,&H1ca081fe,&H942b08f9,&H58684870,&H19fd458f,&H876cde94,&Hb7f87b52,&H23d373ab,&He2024b72,&H578f1fe3,&H2aab5566,&H0728ebb2,&H03c2b52f,&H9a7bc586,&Ha50837d3,&Hf2872830,&Hb2a5bf23,&Hba6a0302,&H5c8216ed,&H2b1ccf8a,&H92b479a7,&Hf0f207f3,&Ha1e2694e,&Hcdf4da65,&Hd5be0506,&H1f6234d1,&H8afea6c4,&H9d532e34,&Ha055f3a2,&H32e18a05,&H75ebf6a4,&H39ec830b,&Haaef6040,&H069f715e,&H51106ebd,&Hf98a213e,&H3d06dd96,&Hae053edd,&H46bde64d,&Hb58d5491,&H055dc471,&H6fd40604,&Hff155060,&H24fb9819,&H97e9bdd6,&Hcc434089,&H779ed967,&Hbd42e8b0,&H888b8907,&H385b19e7,&Hdbeec879,&H470a7ca1,&He90f427c,&Hc91e84f8,&H00000000,&H83868009,&H48ed2b32,&Hac70111e,&H4e725a6c,&Hfbff0efd,&H5638850f,&H1ed5ae3d,&H27392d36,&H64d90f0a,&H21a65c68,&Hd1545b9b,&H3a2e3624,&Hb1670a0c,&H0fe75793,&Hd296eeb4,&H9e919b1b,&H4fc5c080,&Ha220dc61,&H694b775a,&H161a121c,&H0aba93e2,&He52aa0c0,&H43e0223c,&H1d171b12,&H0b0d090e,&Hadc78bf2,&Hb9a8b62d,&Hc8a91e14,&H8519f157,&H4c0775af,&Hbbdd99ee,&Hfd607fa3,&H9f2601f7,&Hbcf5725c,&Hc53b6644,&H347efb5b,&H7629438b,&Hdcc623cb,&H68fcedb6,&H63f1e4b8,&Hcadc31d7,&H10856342,&H40229713,&H2011c684,&H7d244a85,&Hf83dbbd2,&H1132f9ae,&H6da129c7,&H4b2f9e1d,&Hf330b2dc,&Hec52860d,&Hd0e3c177,&H6c16b32b,&H99b970a9,&Hfa489411,&H2264e947,&Hc48cfca8,&H1a3ff0a0,&Hd82c7d56,&Hef903322,&Hc74e4987,&Hc1d138d9,&Hfea2ca8c,&H360bd498,&Hcf81f5a6,&H28de7aa5,&H268eb7da,&Ha4bfad3f,&He49d3a2c,&H0d927850,&H9bcc5f6a,&H62467e54,&Hc2138df6,&He8b8d890,&H5ef7392e,&Hf5afc382,&Hbe805d9f,&H7c93d069,&Ha92dd56f,&Hb31225cf,&H3b99acc8,&Ha77d1810,&H6e639ce8,&H7bbb3bdb,&H097826cd,&Hf418596e,&H01b79aec,&Ha89a4f83,&H656e95e6,&H7ee6ffaa,&H08cfbc21,&He6e815ef,&Hd99be7ba,&Hce366f4a,&Hd4099fea,&Hd67cb029,&Hafb2a431,&H31233f2a,&H3094a5c6,&Hc066a235,&H37bc4e74,&Ha6ca82fc,&Hb0d090e0,&H15d8a733,&H4a9804f1,&Hf7daec41,&H0e50cd7f,&H2ff69117,&H8dd64d76,&H4db0ef43,&H544daacc,&Hdf0496e4,&He3b5d19e,&H1b886a4c,&Hb81f2cc1,&H7f516546,&H04ea5e9d,&H5d358c01,&H737487fa,&H2e410bfb,&H5a1d67b3,&H52d2db92,&H335610e9,&H1347d66d,&H8c61d79a,&H7a0ca137,&H8e14f859,&H893c13eb,&Hee27a9ce,&H35c961b7,&Hede51ce1,&H3cb1477a,&H59dfd29c,&H3f73f255,&H79ce1418,&Hbf37c773,&Heacdf753,&H5baafd5f,&H146f3ddf,&H86db4478,&H81f3afca,&H3ec468b9,&H2c342438,&H5f40a3c2,&H72c31d16,&H0c25e2bc,&H8b493c28,&H41950dff,&H7101a839,&Hdeb30c08,&H9ce4b4d8,&H90c15664,&H6184cb7b,&H70b632d5,&H745c6c48,&H4257b8d0)
		T6 = Array(&Ha7f45150,&H65417e53,&Ha4171ac3,&H5e273a96,&H6bab3bcb,&H459d1ff1,&H58faacab,&H03e34b93,&Hfa302055,&H6d76adf6,&H76cc8891,&H4c02f525,&Hd7e54ffc,&Hcb2ac5d7,&H44352680,&Ha362b58f,&H5ab1de49,&H1bba2567,&H0eea4598,&Hc0fe5de1,&H752fc302,&Hf04c8112,&H97468da3,&Hf9d36bc6,&H5f8f03e7,&H9c921595,&H7a6dbfeb,&H595295da,&H83bed42d,&H217458d3,&H69e04929,&Hc8c98e44,&H89c2756a,&H798ef478,&H3e58996b,&H71b927dd,&H4fe1beb6,&Had88f017,&Hac20c966,&H3ace7db4,&H4adf6318,&H311ae582,&H33519760,&H7f536245,&H7764b1e0,&Hae6bbb84,&Ha081fe1c,&H2b08f994,&H68487058,&Hfd458f19,&H6cde9487,&Hf87b52b7,&Hd373ab23,&H024b72e2,&H8f1fe357,&Hab55662a,&H28ebb207,&Hc2b52f03,&H7bc5869a,&H0837d3a5,&H872830f2,&Ha5bf23b2,&H6a0302ba,&H8216ed5c,&H1ccf8a2b,&Hb479a792,&Hf207f3f0,&He2694ea1,&Hf4da65cd,&Hbe0506d5,&H6234d11f,&Hfea6c48a,&H532e349d,&H55f3a2a0,&He18a0532,&Hebf6a475,&Hec830b39,&Hef6040aa,&H9f715e06,&H106ebd51,&H8a213ef9,&H06dd963d,&H053eddae,&Hbde64d46,&H8d5491b5,&H5dc47105,&Hd406046f,&H155060ff,&Hfb981924,&He9bdd697,&H434089cc,&H9ed96777,&H42e8b0bd,&H8b890788,&H5b19e738,&Heec879db,&H0a7ca147,&H0f427ce9,&H1e84f8c9,&H00000000,&H86800983,&Hed2b3248,&H70111eac,&H725a6c4e,&Hff0efdfb,&H38850f56,&Hd5ae3d1e,&H392d3627,&Hd90f0a64,&Ha65c6821,&H545b9bd1,&H2e36243a,&H670a0cb1,&He757930f,&H96eeb4d2,&H919b1b9e,&Hc5c0804f,&H20dc61a2,&H4b775a69,&H1a121c16,&Hba93e20a,&H2aa0c0e5,&He0223c43,&H171b121d,&H0d090e0b,&Hc78bf2ad,&Ha8b62db9,&Ha91e14c8,&H19f15785,&H0775af4c,&Hdd99eebb,&H607fa3fd,&H2601f79f,&Hf5725cbc,&H3b6644c5,&H7efb5b34,&H29438b76,&Hc623cbdc,&Hfcedb668,&Hf1e4b863,&Hdc31d7ca,&H85634210,&H22971340,&H11c68420,&H244a857d,&H3dbbd2f8,&H32f9ae11,&Ha129c76d,&H2f9e1d4b,&H30b2dcf3,&H52860dec,&He3c177d0,&H16b32b6c,&Hb970a999,&H489411fa,&H64e94722,&H8cfca8c4,&H3ff0a01a,&H2c7d56d8,&H903322ef,&H4e4987c7,&Hd138d9c1,&Ha2ca8cfe,&H0bd49836,&H81f5a6cf,&Hde7aa528,&H8eb7da26,&Hbfad3fa4,&H9d3a2ce4,&H9278500d,&Hcc5f6a9b,&H467e5462,&H138df6c2,&Hb8d890e8,&Hf7392e5e,&Hafc382f5,&H805d9fbe,&H93d0697c,&H2dd56fa9,&H1225cfb3,&H99acc83b,&H7d1810a7,&H639ce86e,&Hbb3bdb7b,&H7826cd09,&H18596ef4,&Hb79aec01,&H9a4f83a8,&H6e95e665,&He6ffaa7e,&Hcfbc2108,&He815efe6,&H9be7bad9,&H366f4ace,&H099fead4,&H7cb029d6,&Hb2a431af,&H233f2a31,&H94a5c630,&H66a235c0,&Hbc4e7437,&Hca82fca6,&Hd090e0b0,&Hd8a73315,&H9804f14a,&Hdaec41f7,&H50cd7f0e,&Hf691172f,&Hd64d768d,&Hb0ef434d,&H4daacc54,&H0496e4df,&Hb5d19ee3,&H886a4c1b,&H1f2cc1b8,&H5165467f,&Hea5e9d04,&H358c015d,&H7487fa73,&H410bfb2e,&H1d67b35a,&Hd2db9252,&H5610e933,&H47d66d13,&H61d79a8c,&H0ca1377a,&H14f8598e,&H3c13eb89,&H27a9ceee,&Hc961b735,&He51ce1ed,&Hb1477a3c,&Hdfd29c59,&H73f2553f,&Hce141879,&H37c773bf,&Hcdf753ea,&Haafd5f5b,&H6f3ddf14,&Hdb447886,&Hf3afca81,&Hc468b93e,&H3424382c,&H40a3c25f,&Hc31d1672,&H25e2bc0c,&H493c288b,&H950dff41,&H01a83971,&Hb30c08de,&He4b4d89c,&Hc1566490,&H84cb7b61,&Hb632d570,&H5c6c4874,&H57b8d042)
		T7 = Array(&Hf45150a7,&H417e5365,&H171ac3a4,&H273a965e,&Hab3bcb6b,&H9d1ff145,&Hfaacab58,&He34b9303,&H302055fa,&H76adf66d,&Hcc889176,&H02f5254c,&He54ffcd7,&H2ac5d7cb,&H35268044,&H62b58fa3,&Hb1de495a,&Hba25671b,&Hea45980e,&Hfe5de1c0,&H2fc30275,&H4c8112f0,&H468da397,&Hd36bc6f9,&H8f03e75f,&H9215959c,&H6dbfeb7a,&H5295da59,&Hbed42d83,&H7458d321,&He0492969,&Hc98e44c8,&Hc2756a89,&H8ef47879,&H58996b3e,&Hb927dd71,&He1beb64f,&H88f017ad,&H20c966ac,&Hce7db43a,&Hdf63184a,&H1ae58231,&H51976033,&H5362457f,&H64b1e077,&H6bbb84ae,&H81fe1ca0,&H08f9942b,&H48705868,&H458f19fd,&Hde94876c,&H7b52b7f8,&H73ab23d3,&H4b72e202,&H1fe3578f,&H55662aab,&Hebb20728,&Hb52f03c2,&Hc5869a7b,&H37d3a508,&H2830f287,&Hbf23b2a5,&H0302ba6a,&H16ed5c82,&Hcf8a2b1c,&H79a792b4,&H07f3f0f2,&H694ea1e2,&Hda65cdf4,&H0506d5be,&H34d11f62,&Ha6c48afe,&H2e349d53,&Hf3a2a055,&H8a0532e1,&Hf6a475eb,&H830b39ec,&H6040aaef,&H715e069f,&H6ebd5110,&H213ef98a,&Hdd963d06,&H3eddae05,&He64d46bd,&H5491b58d,&Hc471055d,&H06046fd4,&H5060ff15,&H981924fb,&Hbdd697e9,&H4089cc43,&Hd967779e,&He8b0bd42,&H8907888b,&H19e7385b,&Hc879dbee,&H7ca1470a,&H427ce90f,&H84f8c91e,&H00000000,&H80098386,&H2b3248ed,&H111eac70,&H5a6c4e72,&H0efdfbff,&H850f5638,&Hae3d1ed5,&H2d362739,&H0f0a64d9,&H5c6821a6,&H5b9bd154,&H36243a2e,&H0a0cb167,&H57930fe7,&Heeb4d296,&H9b1b9e91,&Hc0804fc5,&Hdc61a220,&H775a694b,&H121c161a,&H93e20aba,&Ha0c0e52a,&H223c43e0,&H1b121d17,&H090e0b0d,&H8bf2adc7,&Hb62db9a8,&H1e14c8a9,&Hf1578519,&H75af4c07,&H99eebbdd,&H7fa3fd60,&H01f79f26,&H725cbcf5,&H6644c53b,&Hfb5b347e,&H438b7629,&H23cbdcc6,&Hedb668fc,&He4b863f1,&H31d7cadc,&H63421085,&H97134022,&Hc6842011,&H4a857d24,&Hbbd2f83d,&Hf9ae1132,&H29c76da1,&H9e1d4b2f,&Hb2dcf330,&H860dec52,&Hc177d0e3,&Hb32b6c16,&H70a999b9,&H9411fa48,&He9472264,&Hfca8c48c,&Hf0a01a3f,&H7d56d82c,&H3322ef90,&H4987c74e,&H38d9c1d1,&Hca8cfea2,&Hd498360b,&Hf5a6cf81,&H7aa528de,&Hb7da268e,&Had3fa4bf,&H3a2ce49d,&H78500d92,&H5f6a9bcc,&H7e546246,&H8df6c213,&Hd890e8b8,&H392e5ef7,&Hc382f5af,&H5d9fbe80,&Hd0697c93,&Hd56fa92d,&H25cfb312,&Hacc83b99,&H1810a77d,&H9ce86e63,&H3bdb7bbb,&H26cd0978,&H596ef418,&H9aec01b7,&H4f83a89a,&H95e6656e,&Hffaa7ee6,&Hbc2108cf,&H15efe6e8,&He7bad99b,&H6f4ace36,&H9fead409,&Hb029d67c,&Ha431afb2,&H3f2a3123,&Ha5c63094,&Ha235c066,&H4e7437bc,&H82fca6ca,&H90e0b0d0,&Ha73315d8,&H04f14a98,&Hec41f7da,&Hcd7f0e50,&H91172ff6,&H4d768dd6,&Hef434db0,&Haacc544d,&H96e4df04,&Hd19ee3b5,&H6a4c1b88,&H2cc1b81f,&H65467f51,&H5e9d04ea,&H8c015d35,&H87fa7374,&H0bfb2e41,&H67b35a1d,&Hdb9252d2,&H10e93356,&Hd66d1347,&Hd79a8c61,&Ha1377a0c,&Hf8598e14,&H13eb893c,&Ha9ceee27,&H61b735c9,&H1ce1ede5,&H477a3cb1,&Hd29c59df,&Hf2553f73,&H141879ce,&Hc773bf37,&Hf753eacd,&Hfd5f5baa,&H3ddf146f,&H447886db,&Hafca81f3,&H68b93ec4,&H24382c34,&Ha3c25f40,&H1d1672c3,&He2bc0c25,&H3c288b49,&H0dff4195,&Ha8397101,&H0c08deb3,&Hb4d89ce4,&H566490c1,&Hcb7b6184,&H32d570b6,&H6c48745c,&Hb8d04257)
		T8 = Array(&H5150a7f4,&H7e536541,&H1ac3a417,&H3a965e27,&H3bcb6bab,&H1ff1459d,&Hacab58fa,&H4b9303e3,&H2055fa30,&Hadf66d76,&H889176cc,&Hf5254c02,&H4ffcd7e5,&Hc5d7cb2a,&H26804435,&Hb58fa362,&Hde495ab1,&H25671bba,&H45980eea,&H5de1c0fe,&Hc302752f,&H8112f04c,&H8da39746,&H6bc6f9d3,&H03e75f8f,&H15959c92,&Hbfeb7a6d,&H95da5952,&Hd42d83be,&H58d32174,&H492969e0,&H8e44c8c9,&H756a89c2,&Hf478798e,&H996b3e58,&H27dd71b9,&Hbeb64fe1,&Hf017ad88,&Hc966ac20,&H7db43ace,&H63184adf,&He582311a,&H97603351,&H62457f53,&Hb1e07764,&Hbb84ae6b,&Hfe1ca081,&Hf9942b08,&H70586848,&H8f19fd45,&H94876cde,&H52b7f87b,&Hab23d373,&H72e2024b,&He3578f1f,&H662aab55,&Hb20728eb,&H2f03c2b5,&H869a7bc5,&Hd3a50837,&H30f28728,&H23b2a5bf,&H02ba6a03,&Hed5c8216,&H8a2b1ccf,&Ha792b479,&Hf3f0f207,&H4ea1e269,&H65cdf4da,&H06d5be05,&Hd11f6234,&Hc48afea6,&H349d532e,&Ha2a055f3,&H0532e18a,&Ha475ebf6,&H0b39ec83,&H40aaef60,&H5e069f71,&Hbd51106e,&H3ef98a21,&H963d06dd,&Hddae053e,&H4d46bde6,&H91b58d54,&H71055dc4,&H046fd406,&H60ff1550,&H1924fb98,&Hd697e9bd,&H89cc4340,&H67779ed9,&Hb0bd42e8,&H07888b89,&He7385b19,&H79dbeec8,&Ha1470a7c,&H7ce90f42,&Hf8c91e84,&H00000000,&H09838680,&H3248ed2b,&H1eac7011,&H6c4e725a,&Hfdfbff0e,&H0f563885,&H3d1ed5ae,&H3627392d,&H0a64d90f,&H6821a65c,&H9bd1545b,&H243a2e36,&H0cb1670a,&H930fe757,&Hb4d296ee,&H1b9e919b,&H804fc5c0,&H61a220dc,&H5a694b77,&H1c161a12,&He20aba93,&Hc0e52aa0,&H3c43e022,&H121d171b,&H0e0b0d09,&Hf2adc78b,&H2db9a8b6,&H14c8a91e,&H578519f1,&Haf4c0775,&Heebbdd99,&Ha3fd607f,&Hf79f2601,&H5cbcf572,&H44c53b66,&H5b347efb,&H8b762943,&Hcbdcc623,&Hb668fced,&Hb863f1e4,&Hd7cadc31,&H42108563,&H13402297,&H842011c6,&H857d244a,&Hd2f83dbb,&Hae1132f9,&Hc76da129,&H1d4b2f9e,&Hdcf330b2,&H0dec5286,&H77d0e3c1,&H2b6c16b3,&Ha999b970,&H11fa4894,&H472264e9,&Ha8c48cfc,&Ha01a3ff0,&H56d82c7d,&H22ef9033,&H87c74e49,&Hd9c1d138,&H8cfea2ca,&H98360bd4,&Ha6cf81f5,&Ha528de7a,&Hda268eb7,&H3fa4bfad,&H2ce49d3a,&H500d9278,&H6a9bcc5f,&H5462467e,&Hf6c2138d,&H90e8b8d8,&H2e5ef739,&H82f5afc3,&H9fbe805d,&H697c93d0,&H6fa92dd5,&Hcfb31225,&Hc83b99ac,&H10a77d18,&He86e639c,&Hdb7bbb3b,&Hcd097826,&H6ef41859,&Hec01b79a,&H83a89a4f,&He6656e95,&Haa7ee6ff,&H2108cfbc,&Hefe6e815,&Hbad99be7,&H4ace366f,&Head4099f,&H29d67cb0,&H31afb2a4,&H2a31233f,&Hc63094a5,&H35c066a2,&H7437bc4e,&Hfca6ca82,&He0b0d090,&H3315d8a7,&Hf14a9804,&H41f7daec,&H7f0e50cd,&H172ff691,&H768dd64d,&H434db0ef,&Hcc544daa,&He4df0496,&H9ee3b5d1,&H4c1b886a,&Hc1b81f2c,&H467f5165,&H9d04ea5e,&H015d358c,&Hfa737487,&Hfb2e410b,&Hb35a1d67,&H9252d2db,&He9335610,&H6d1347d6,&H9a8c61d7,&H377a0ca1,&H598e14f8,&Heb893c13,&Hceee27a9,&Hb735c961,&He1ede51c,&H7a3cb147,&H9c59dfd2,&H553f73f2,&H1879ce14,&H73bf37c7,&H53eacdf7,&H5f5baafd,&Hdf146f3d,&H7886db44,&Hca81f3af,&Hb93ec468,&H382c3424,&Hc25f40a3,&H1672c31d,&Hbc0c25e2,&H288b493c,&Hff41950d,&H397101a8,&H08deb30c,&Hd89ce4b4,&H6490c156,&H7b6184cb,&Hd570b632,&H48745c6c,&Hd04257b8)

		U1 = Array(&H00000000,&H0b0d090e,&H161a121c,&H1d171b12,&H2c342438,&H27392d36,&H3a2e3624,&H31233f2a,&H58684870,&H5365417e,&H4e725a6c,&H457f5362,&H745c6c48,&H7f516546,&H62467e54,&H694b775a,&Hb0d090e0,&Hbbdd99ee,&Ha6ca82fc,&Hadc78bf2,&H9ce4b4d8,&H97e9bdd6,&H8afea6c4,&H81f3afca,&He8b8d890,&He3b5d19e,&Hfea2ca8c,&Hf5afc382,&Hc48cfca8,&Hcf81f5a6,&Hd296eeb4,&Hd99be7ba,&H7bbb3bdb,&H70b632d5,&H6da129c7,&H66ac20c9,&H578f1fe3,&H5c8216ed,&H41950dff,&H4a9804f1,&H23d373ab,&H28de7aa5,&H35c961b7,&H3ec468b9,&H0fe75793,&H04ea5e9d,&H19fd458f,&H12f04c81,&Hcb6bab3b,&Hc066a235,&Hdd71b927,&Hd67cb029,&He75f8f03,&Hec52860d,&Hf1459d1f,&Hfa489411,&H9303e34b,&H980eea45,&H8519f157,&H8e14f859,&Hbf37c773,&Hb43ace7d,&Ha92dd56f,&Ha220dc61,&Hf66d76ad,&Hfd607fa3,&He07764b1,&Heb7a6dbf,&Hda595295,&Hd1545b9b,&Hcc434089,&Hc74e4987,&Hae053edd,&Ha50837d3,&Hb81f2cc1,&Hb31225cf,&H82311ae5,&H893c13eb,&H942b08f9,&H9f2601f7,&H46bde64d,&H4db0ef43,&H50a7f451,&H5baafd5f,&H6a89c275,&H6184cb7b,&H7c93d069,&H779ed967,&H1ed5ae3d,&H15d8a733,&H08cfbc21,&H03c2b52f,&H32e18a05,&H39ec830b,&H24fb9819,&H2ff69117,&H8dd64d76,&H86db4478,&H9bcc5f6a,&H90c15664,&Ha1e2694e,&Haaef6040,&Hb7f87b52,&Hbcf5725c,&Hd5be0506,&Hdeb30c08,&Hc3a4171a,&Hc8a91e14,&Hf98a213e,&Hf2872830,&Hef903322,&He49d3a2c,&H3d06dd96,&H360bd498,&H2b1ccf8a,&H2011c684,&H1132f9ae,&H1a3ff0a0,&H0728ebb2,&H0c25e2bc,&H656e95e6,&H6e639ce8,&H737487fa,&H78798ef4,&H495ab1de,&H4257b8d0,&H5f40a3c2,&H544daacc,&Hf7daec41,&Hfcd7e54f,&He1c0fe5d,&Heacdf753,&Hdbeec879,&Hd0e3c177,&Hcdf4da65,&Hc6f9d36b,&Hafb2a431,&Ha4bfad3f,&Hb9a8b62d,&Hb2a5bf23,&H83868009,&H888b8907,&H959c9215,&H9e919b1b,&H470a7ca1,&H4c0775af,&H51106ebd,&H5a1d67b3,&H6b3e5899,&H60335197,&H7d244a85,&H7629438b,&H1f6234d1,&H146f3ddf,&H097826cd,&H02752fc3,&H335610e9,&H385b19e7,&H254c02f5,&H2e410bfb,&H8c61d79a,&H876cde94,&H9a7bc586,&H9176cc88,&Ha055f3a2,&Hab58faac,&Hb64fe1be,&Hbd42e8b0,&Hd4099fea,&Hdf0496e4,&Hc2138df6,&Hc91e84f8,&Hf83dbbd2,&Hf330b2dc,&Hee27a9ce,&He52aa0c0,&H3cb1477a,&H37bc4e74,&H2aab5566,&H21a65c68,&H10856342,&H1b886a4c,&H069f715e,&H0d927850,&H64d90f0a,&H6fd40604,&H72c31d16,&H79ce1418,&H48ed2b32,&H43e0223c,&H5ef7392e,&H55fa3020,&H01b79aec,&H0aba93e2,&H17ad88f0,&H1ca081fe,&H2d83bed4,&H268eb7da,&H3b99acc8,&H3094a5c6,&H59dfd29c,&H52d2db92,&H4fc5c080,&H44c8c98e,&H75ebf6a4,&H7ee6ffaa,&H63f1e4b8,&H68fcedb6,&Hb1670a0c,&Hba6a0302,&Ha77d1810,&Hac70111e,&H9d532e34,&H965e273a,&H8b493c28,&H80443526,&He90f427c,&He2024b72,&Hff155060,&Hf418596e,&Hc53b6644,&Hce366f4a,&Hd3217458,&Hd82c7d56,&H7a0ca137,&H7101a839,&H6c16b32b,&H671bba25,&H5638850f,&H5d358c01,&H40229713,&H4b2f9e1d,&H2264e947,&H2969e049,&H347efb5b,&H3f73f255,&H0e50cd7f,&H055dc471,&H184adf63,&H1347d66d,&Hcadc31d7,&Hc1d138d9,&Hdcc623cb,&Hd7cb2ac5,&He6e815ef,&Hede51ce1,&Hf0f207f3,&Hfbff0efd,&H92b479a7,&H99b970a9,&H84ae6bbb,&H8fa362b5,&Hbe805d9f,&Hb58d5491,&Ha89a4f83,&Ha397468d)
		U2 = Array(&H00000000,&H0d090e0b,&H1a121c16,&H171b121d,&H3424382c,&H392d3627,&H2e36243a,&H233f2a31,&H68487058,&H65417e53,&H725a6c4e,&H7f536245,&H5c6c4874,&H5165467f,&H467e5462,&H4b775a69,&Hd090e0b0,&Hdd99eebb,&Hca82fca6,&Hc78bf2ad,&He4b4d89c,&He9bdd697,&Hfea6c48a,&Hf3afca81,&Hb8d890e8,&Hb5d19ee3,&Ha2ca8cfe,&Hafc382f5,&H8cfca8c4,&H81f5a6cf,&H96eeb4d2,&H9be7bad9,&Hbb3bdb7b,&Hb632d570,&Ha129c76d,&Hac20c966,&H8f1fe357,&H8216ed5c,&H950dff41,&H9804f14a,&Hd373ab23,&Hde7aa528,&Hc961b735,&Hc468b93e,&He757930f,&Hea5e9d04,&Hfd458f19,&Hf04c8112,&H6bab3bcb,&H66a235c0,&H71b927dd,&H7cb029d6,&H5f8f03e7,&H52860dec,&H459d1ff1,&H489411fa,&H03e34b93,&H0eea4598,&H19f15785,&H14f8598e,&H37c773bf,&H3ace7db4,&H2dd56fa9,&H20dc61a2,&H6d76adf6,&H607fa3fd,&H7764b1e0,&H7a6dbfeb,&H595295da,&H545b9bd1,&H434089cc,&H4e4987c7,&H053eddae,&H0837d3a5,&H1f2cc1b8,&H1225cfb3,&H311ae582,&H3c13eb89,&H2b08f994,&H2601f79f,&Hbde64d46,&Hb0ef434d,&Ha7f45150,&Haafd5f5b,&H89c2756a,&H84cb7b61,&H93d0697c,&H9ed96777,&Hd5ae3d1e,&Hd8a73315,&Hcfbc2108,&Hc2b52f03,&He18a0532,&Hec830b39,&Hfb981924,&Hf691172f,&Hd64d768d,&Hdb447886,&Hcc5f6a9b,&Hc1566490,&He2694ea1,&Hef6040aa,&Hf87b52b7,&Hf5725cbc,&Hbe0506d5,&Hb30c08de,&Ha4171ac3,&Ha91e14c8,&H8a213ef9,&H872830f2,&H903322ef,&H9d3a2ce4,&H06dd963d,&H0bd49836,&H1ccf8a2b,&H11c68420,&H32f9ae11,&H3ff0a01a,&H28ebb207,&H25e2bc0c,&H6e95e665,&H639ce86e,&H7487fa73,&H798ef478,&H5ab1de49,&H57b8d042,&H40a3c25f,&H4daacc54,&Hdaec41f7,&Hd7e54ffc,&Hc0fe5de1,&Hcdf753ea,&Heec879db,&He3c177d0,&Hf4da65cd,&Hf9d36bc6,&Hb2a431af,&Hbfad3fa4,&Ha8b62db9,&Ha5bf23b2,&H86800983,&H8b890788,&H9c921595,&H919b1b9e,&H0a7ca147,&H0775af4c,&H106ebd51,&H1d67b35a,&H3e58996b,&H33519760,&H244a857d,&H29438b76,&H6234d11f,&H6f3ddf14,&H7826cd09,&H752fc302,&H5610e933,&H5b19e738,&H4c02f525,&H410bfb2e,&H61d79a8c,&H6cde9487,&H7bc5869a,&H76cc8891,&H55f3a2a0,&H58faacab,&H4fe1beb6,&H42e8b0bd,&H099fead4,&H0496e4df,&H138df6c2,&H1e84f8c9,&H3dbbd2f8,&H30b2dcf3,&H27a9ceee,&H2aa0c0e5,&Hb1477a3c,&Hbc4e7437,&Hab55662a,&Ha65c6821,&H85634210,&H886a4c1b,&H9f715e06,&H9278500d,&Hd90f0a64,&Hd406046f,&Hc31d1672,&Hce141879,&Hed2b3248,&He0223c43,&Hf7392e5e,&Hfa302055,&Hb79aec01,&Hba93e20a,&Had88f017,&Ha081fe1c,&H83bed42d,&H8eb7da26,&H99acc83b,&H94a5c630,&Hdfd29c59,&Hd2db9252,&Hc5c0804f,&Hc8c98e44,&Hebf6a475,&He6ffaa7e,&Hf1e4b863,&Hfcedb668,&H670a0cb1,&H6a0302ba,&H7d1810a7,&H70111eac,&H532e349d,&H5e273a96,&H493c288b,&H44352680,&H0f427ce9,&H024b72e2,&H155060ff,&H18596ef4,&H3b6644c5,&H366f4ace,&H217458d3,&H2c7d56d8,&H0ca1377a,&H01a83971,&H16b32b6c,&H1bba2567,&H38850f56,&H358c015d,&H22971340,&H2f9e1d4b,&H64e94722,&H69e04929,&H7efb5b34,&H73f2553f,&H50cd7f0e,&H5dc47105,&H4adf6318,&H47d66d13,&Hdc31d7ca,&Hd138d9c1,&Hc623cbdc,&Hcb2ac5d7,&He815efe6,&He51ce1ed,&Hf207f3f0,&Hff0efdfb,&Hb479a792,&Hb970a999,&Hae6bbb84,&Ha362b58f,&H805d9fbe,&H8d5491b5,&H9a4f83a8,&H97468da3)
		U3 = Array(&H00000000,&H090e0b0d,&H121c161a,&H1b121d17,&H24382c34,&H2d362739,&H36243a2e,&H3f2a3123,&H48705868,&H417e5365,&H5a6c4e72,&H5362457f,&H6c48745c,&H65467f51,&H7e546246,&H775a694b,&H90e0b0d0,&H99eebbdd,&H82fca6ca,&H8bf2adc7,&Hb4d89ce4,&Hbdd697e9,&Ha6c48afe,&Hafca81f3,&Hd890e8b8,&Hd19ee3b5,&Hca8cfea2,&Hc382f5af,&Hfca8c48c,&Hf5a6cf81,&Heeb4d296,&He7bad99b,&H3bdb7bbb,&H32d570b6,&H29c76da1,&H20c966ac,&H1fe3578f,&H16ed5c82,&H0dff4195,&H04f14a98,&H73ab23d3,&H7aa528de,&H61b735c9,&H68b93ec4,&H57930fe7,&H5e9d04ea,&H458f19fd,&H4c8112f0,&Hab3bcb6b,&Ha235c066,&Hb927dd71,&Hb029d67c,&H8f03e75f,&H860dec52,&H9d1ff145,&H9411fa48,&He34b9303,&Hea45980e,&Hf1578519,&Hf8598e14,&Hc773bf37,&Hce7db43a,&Hd56fa92d,&Hdc61a220,&H76adf66d,&H7fa3fd60,&H64b1e077,&H6dbfeb7a,&H5295da59,&H5b9bd154,&H4089cc43,&H4987c74e,&H3eddae05,&H37d3a508,&H2cc1b81f,&H25cfb312,&H1ae58231,&H13eb893c,&H08f9942b,&H01f79f26,&He64d46bd,&Hef434db0,&Hf45150a7,&Hfd5f5baa,&Hc2756a89,&Hcb7b6184,&Hd0697c93,&Hd967779e,&Hae3d1ed5,&Ha73315d8,&Hbc2108cf,&Hb52f03c2,&H8a0532e1,&H830b39ec,&H981924fb,&H91172ff6,&H4d768dd6,&H447886db,&H5f6a9bcc,&H566490c1,&H694ea1e2,&H6040aaef,&H7b52b7f8,&H725cbcf5,&H0506d5be,&H0c08deb3,&H171ac3a4,&H1e14c8a9,&H213ef98a,&H2830f287,&H3322ef90,&H3a2ce49d,&Hdd963d06,&Hd498360b,&Hcf8a2b1c,&Hc6842011,&Hf9ae1132,&Hf0a01a3f,&Hebb20728,&He2bc0c25,&H95e6656e,&H9ce86e63,&H87fa7374,&H8ef47879,&Hb1de495a,&Hb8d04257,&Ha3c25f40,&Haacc544d,&Hec41f7da,&He54ffcd7,&Hfe5de1c0,&Hf753eacd,&Hc879dbee,&Hc177d0e3,&Hda65cdf4,&Hd36bc6f9,&Ha431afb2,&Had3fa4bf,&Hb62db9a8,&Hbf23b2a5,&H80098386,&H8907888b,&H9215959c,&H9b1b9e91,&H7ca1470a,&H75af4c07,&H6ebd5110,&H67b35a1d,&H58996b3e,&H51976033,&H4a857d24,&H438b7629,&H34d11f62,&H3ddf146f,&H26cd0978,&H2fc30275,&H10e93356,&H19e7385b,&H02f5254c,&H0bfb2e41,&Hd79a8c61,&Hde94876c,&Hc5869a7b,&Hcc889176,&Hf3a2a055,&Hfaacab58,&He1beb64f,&He8b0bd42,&H9fead409,&H96e4df04,&H8df6c213,&H84f8c91e,&Hbbd2f83d,&Hb2dcf330,&Ha9ceee27,&Ha0c0e52a,&H477a3cb1,&H4e7437bc,&H55662aab,&H5c6821a6,&H63421085,&H6a4c1b88,&H715e069f,&H78500d92,&H0f0a64d9,&H06046fd4,&H1d1672c3,&H141879ce,&H2b3248ed,&H223c43e0,&H392e5ef7,&H302055fa,&H9aec01b7,&H93e20aba,&H88f017ad,&H81fe1ca0,&Hbed42d83,&Hb7da268e,&Hacc83b99,&Ha5c63094,&Hd29c59df,&Hdb9252d2,&Hc0804fc5,&Hc98e44c8,&Hf6a475eb,&Hffaa7ee6,&He4b863f1,&Hedb668fc,&H0a0cb167,&H0302ba6a,&H1810a77d,&H111eac70,&H2e349d53,&H273a965e,&H3c288b49,&H35268044,&H427ce90f,&H4b72e202,&H5060ff15,&H596ef418,&H6644c53b,&H6f4ace36,&H7458d321,&H7d56d82c,&Ha1377a0c,&Ha8397101,&Hb32b6c16,&Hba25671b,&H850f5638,&H8c015d35,&H97134022,&H9e1d4b2f,&He9472264,&He0492969,&Hfb5b347e,&Hf2553f73,&Hcd7f0e50,&Hc471055d,&Hdf63184a,&Hd66d1347,&H31d7cadc,&H38d9c1d1,&H23cbdcc6,&H2ac5d7cb,&H15efe6e8,&H1ce1ede5,&H07f3f0f2,&H0efdfbff,&H79a792b4,&H70a999b9,&H6bbb84ae,&H62b58fa3,&H5d9fbe80,&H5491b58d,&H4f83a89a,&H468da397)
		U4 = Array(&H00000000,&H0e0b0d09,&H1c161a12,&H121d171b,&H382c3424,&H3627392d,&H243a2e36,&H2a31233f,&H70586848,&H7e536541,&H6c4e725a,&H62457f53,&H48745c6c,&H467f5165,&H5462467e,&H5a694b77,&He0b0d090,&Heebbdd99,&Hfca6ca82,&Hf2adc78b,&Hd89ce4b4,&Hd697e9bd,&Hc48afea6,&Hca81f3af,&H90e8b8d8,&H9ee3b5d1,&H8cfea2ca,&H82f5afc3,&Ha8c48cfc,&Ha6cf81f5,&Hb4d296ee,&Hbad99be7,&Hdb7bbb3b,&Hd570b632,&Hc76da129,&Hc966ac20,&He3578f1f,&Hed5c8216,&Hff41950d,&Hf14a9804,&Hab23d373,&Ha528de7a,&Hb735c961,&Hb93ec468,&H930fe757,&H9d04ea5e,&H8f19fd45,&H8112f04c,&H3bcb6bab,&H35c066a2,&H27dd71b9,&H29d67cb0,&H03e75f8f,&H0dec5286,&H1ff1459d,&H11fa4894,&H4b9303e3,&H45980eea,&H578519f1,&H598e14f8,&H73bf37c7,&H7db43ace,&H6fa92dd5,&H61a220dc,&Hadf66d76,&Ha3fd607f,&Hb1e07764,&Hbfeb7a6d,&H95da5952,&H9bd1545b,&H89cc4340,&H87c74e49,&Hddae053e,&Hd3a50837,&Hc1b81f2c,&Hcfb31225,&He582311a,&Heb893c13,&Hf9942b08,&Hf79f2601,&H4d46bde6,&H434db0ef,&H5150a7f4,&H5f5baafd,&H756a89c2,&H7b6184cb,&H697c93d0,&H67779ed9,&H3d1ed5ae,&H3315d8a7,&H2108cfbc,&H2f03c2b5,&H0532e18a,&H0b39ec83,&H1924fb98,&H172ff691,&H768dd64d,&H7886db44,&H6a9bcc5f,&H6490c156,&H4ea1e269,&H40aaef60,&H52b7f87b,&H5cbcf572,&H06d5be05,&H08deb30c,&H1ac3a417,&H14c8a91e,&H3ef98a21,&H30f28728,&H22ef9033,&H2ce49d3a,&H963d06dd,&H98360bd4,&H8a2b1ccf,&H842011c6,&Hae1132f9,&Ha01a3ff0,&Hb20728eb,&Hbc0c25e2,&He6656e95,&He86e639c,&Hfa737487,&Hf478798e,&Hde495ab1,&Hd04257b8,&Hc25f40a3,&Hcc544daa,&H41f7daec,&H4ffcd7e5,&H5de1c0fe,&H53eacdf7,&H79dbeec8,&H77d0e3c1,&H65cdf4da,&H6bc6f9d3,&H31afb2a4,&H3fa4bfad,&H2db9a8b6,&H23b2a5bf,&H09838680,&H07888b89,&H15959c92,&H1b9e919b,&Ha1470a7c,&Haf4c0775,&Hbd51106e,&Hb35a1d67,&H996b3e58,&H97603351,&H857d244a,&H8b762943,&Hd11f6234,&Hdf146f3d,&Hcd097826,&Hc302752f,&He9335610,&He7385b19,&Hf5254c02,&Hfb2e410b,&H9a8c61d7,&H94876cde,&H869a7bc5,&H889176cc,&Ha2a055f3,&Hacab58fa,&Hbeb64fe1,&Hb0bd42e8,&Head4099f,&He4df0496,&Hf6c2138d,&Hf8c91e84,&Hd2f83dbb,&Hdcf330b2,&Hceee27a9,&Hc0e52aa0,&H7a3cb147,&H7437bc4e,&H662aab55,&H6821a65c,&H42108563,&H4c1b886a,&H5e069f71,&H500d9278,&H0a64d90f,&H046fd406,&H1672c31d,&H1879ce14,&H3248ed2b,&H3c43e022,&H2e5ef739,&H2055fa30,&Hec01b79a,&He20aba93,&Hf017ad88,&Hfe1ca081,&Hd42d83be,&Hda268eb7,&Hc83b99ac,&Hc63094a5,&H9c59dfd2,&H9252d2db,&H804fc5c0,&H8e44c8c9,&Ha475ebf6,&Haa7ee6ff,&Hb863f1e4,&Hb668fced,&H0cb1670a,&H02ba6a03,&H10a77d18,&H1eac7011,&H349d532e,&H3a965e27,&H288b493c,&H26804435,&H7ce90f42,&H72e2024b,&H60ff1550,&H6ef41859,&H44c53b66,&H4ace366f,&H58d32174,&H56d82c7d,&H377a0ca1,&H397101a8,&H2b6c16b3,&H25671bba,&H0f563885,&H015d358c,&H13402297,&H1d4b2f9e,&H472264e9,&H492969e0,&H5b347efb,&H553f73f2,&H7f0e50cd,&H71055dc4,&H63184adf,&H6d1347d6,&Hd7cadc31,&Hd9c1d138,&Hcbdcc623,&Hc5d7cb2a,&Hefe6e815,&He1ede51c,&Hf3f0f207,&Hfdfbff0e,&Ha792b479,&Ha999b970,&Hbb84ae6b,&Hb58fa362,&H9fbe805d,&H91b58d54,&H83a89a4f,&H8da39746)

	End Sub

	Private Function CharCodeAt(ByVal str, ByVal index)
		On Error Resume Next
		CharCodeAt = AscB(MidB(str, index+1, 1))
	End Function

	Private Function JJ(ByRef n)
		JJ = n
		n = n + 1
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