SuperStrict

Module vertex.raycaster

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Oliver Skawronek"
ModuleInfo "License: GNU Lesser General Public License, Version 3"

Import brl.max2d

Const FACE_FRONT : Byte = 1
Const FACE_BACK  : Byte = 2
Const FACE_LEFT  : Byte = 3
Const FACE_RIGHT : Byte = 4

Type TRaycaster
	Field TileSize  : Int
	Field TileCount : Int
	Field Tiles     : TTexture[]
	Field MapSize   : Int[2]
	Field Map       : Int[,]
	Field Camera    : TCamera

	Method New()
		Self.TileSize  = 64
		Self.TileCount = 0
		Self.MapSize   = [0, 0]
		Self.Camera    = Null
	End Method

	Method LoadTile:Int(URL:Object)
		Local Texture:TTexture

		Texture = TTexture.Load(URL, Self.TileSize)
		If Not Texture Then Return -1

		Self.TileCount :+ 1
		Tiles = Tiles[..Self.TileCount]
		Tiles[Self.TileCount-1] = Texture

		Return Self.TileCount
	End Method

	Method SetMapSize(Columns:Int, Rows:Int)
		Self.MapSize[0] = Columns
		Self.MapSize[1] = Rows
		Self.Map        = New Int[Columns, Rows]
	End Method

	Method SetTile(Column:Int, Row:Int, TileNr:Int)
		If (Column < 0 Or Column => Self.MapSize[0]) Or ..
		   (Row < 0 Or Row => Self.MapSize[1]) Or ..
		   (TileNr < 0 Or TileNr > Self.TileCount) Then Return

		Self.Map[Column, Row] = TileNr
	End Method

	Method SetCamera(Camera:TCamera)
		Self.Camera = Camera
	End Method

	Method Render()
		If Self.Camera Then Self.Camera.Render(Self)
	End Method
End Type

Type TCamera
	Field FOV        : Float
	Field Viewport   : Int[4]
	Field ClearColor : Byte[4] 
	Field Position   : Float[2]
	Field Yaw        : Float
	Field Screen     : TPixmap

	Method New()
		Self.SetFOV(60.0)
		Self.SetViewport(0, 0, GraphicsWidth(), GraphicsHeight())
		Self.SetClearColor(0, 0, 0)
		Self.SetPosition(0.0, 0.0)
		Self.SetRotation(0.0)
	End Method

	Method SetFOV(FOV:Float)
		Self.FOV = FOV
	End Method

	Method SetViewport(X:Int, Y:Int, Width:Int, Height:Int)
		Self.Viewport[0] = X
		Self.Viewport[1] = Y
		Self.Viewport[2] = Width
		Self.Viewport[3] = Height
		Self.Screen      = CreatePixmap(Width, Height, PF_RGBA8888)
	End Method

	Method SetClearColor(Red:Byte, Green:Byte, Blue:Byte, Alpha:Byte=255)
		Self.ClearColor[0] = Red
		Self.ClearColor[1] = Green
		Self.ClearColor[2] = Blue
		Self.CLearColor[3] = Alpha
	End Method

	Method SetRotation(Yaw:Float)
		Self.Yaw = Yaw
	End Method

	Method Turn(DeltaYaw:Float)
		Self.Yaw :+ DeltaYaw
	End Method

	Method SetPosition(X:Float, Z:Float)
		Self.Position[0] = X
		Self.Position[1] = Z
	End Method

	Method Translate(X:Float, Z:Float)
		Self.Position[0] :+ X
		Self.Position[1] :+ Z
	End Method

	Method Move(Speed:Float)
		Self.Position[0] :+ (Cos(Self.Yaw)*Speed)
		Self.Position[1] :+ (Sin(Self.Yaw)*Speed)
	End Method

	Method Clear()
		Local X:Int, Y:Int, Offset:Byte Ptr

		Offset = Self.Screen.Pixels
		For Y = 0 Until Self.Viewport[3]
			For X = 0 Until Self.Viewport[2]
				Offset[0] = Self.ClearColor[0]
				Offset[1] = Self.ClearColor[1]
				Offset[2] = Self.ClearColor[2]
				Offset[3] = Self.ClearColor[3]

				Offset :+ 4
			Next
		Next
	End Method

	Method Render(Raycaster:TRaycaster)
		Local DeltaAngle:Float, Ray:TRay, Column:Int
		Local Dividend:Float, Height:Int
		Local Texture:TTexture, TextureColumn:Float

		' Clear Background
		Self.Clear()

		' Calculate Angle for one Screen-Column
		DeltaAngle = Self.FOV/Float(Self.Viewport[2])

		' Emit Rays
		Ray = New TRay
		Ray.Angle = Self.Yaw - Self.FOV/2.0

		' Dividend to calculate the projected Height
		Dividend = Float(Raycaster.TileSize) * ..
		           Sin(90.0-Self.FOV/2.0)*Float(Self.Viewport[2]/2)

		For Column = 0 Until Self.Viewport[2]
			Ray.Z = Self.Position[1]
			Ray.Emit(Raycaster)

			If Ray.Tile > 0 Then
				Texture = Raycaster.Tiles[Ray.Tile-1]
				Select Ray.Face
					Case FACE_FRONT
						TextureColumn = Ray.X Mod Float(Raycaster.TileSize)

					Case FACE_BACK
						TextureColumn = Float(Raycaster.TileSize) - (Ray.X ..
						                Mod Float(Raycaster.TileSize)) - 1.0

					Case FACE_LEFT
						TextureColumn = Float(Raycaster.TileSize) - (Ray.Z ..
						                Mod Float(Raycaster.TileSize)) - 1

					Case FACE_RIGHT
						TextureColumn = Ray.Z Mod Float(Raycaster.TileSize)
				End Select

				' Correct the Fisheye-Effect
				Height = Dividend/(Ray.Distance*Cos(Self.Yaw - Ray.Angle))

				' Draw scaled Comlumn
				Texture.DrawColumn(Column, TextureColumn, Height, Self)
			EndIf

			Ray.Angle :+ DeltaAngle
		Next

		' Display the Result
		DrawPixmap(Self.Screen, Self.Viewport[0], Self.Viewport[1])
	End Method
End Type

Type TRay
	Field Angle    : Float
	Field X        : Float
	Field Z        : Float
	Field Tile     : Int
	Field Distance : Float
	Field Face     : Byte

	Method Emit(Raycaster:TRaycaster)
		Local DeltaX:Float, DeltaZ:Float, DX:Float, DZ:Float, TanAngle:Float
		Local Quit:Int, Face:Byte, MapColumn:Int, MapRow:Int, Tile:Int, Distance:Float
		Local OldX:Float, OldZ:Float, OldTile:Int, OldDistance:Float, OldFace:Byte

		' 0° => Angle <= 360°
		Self.Angle = Self.Angle Mod 360.0
		If Self.Angle < 0.0 Then Self.Angle = 360.0+Self.Angle
		TanAngle = Tan(Self.Angle)

		' Find horizontal intersection
		Quit = False
		If Self.Angle > 0.0 And Self.Angle < 180.0 Then
			DeltaZ = Float(Raycaster.TileSize)
			DeltaX = DeltaZ/TanAngle
			Self.Z = Float((Int(Raycaster.Camera.Position[1]) / ..
			         Raycaster.TileSize)*Raycaster.TileSize + Raycaster.TileSize)
			DZ     = Self.Z - Raycaster.Camera.Position[1]
			DX     = DZ/TanAngle
			Self.X = Raycaster.Camera.Position[0] + DX
			Face   = FACE_BACK

		ElseIf Self.Angle > 180.0 And Self.Angle < 360.0 Then
			DeltaZ = -Float(Raycaster.TileSize)
			DeltaX = DeltaZ/TanAngle
			Self.Z = Float((Int(Raycaster.Camera.Position[1]) / ..
			         Raycaster.TileSize)*Raycaster.TileSize)
			DZ     = Self.Z - Raycaster.Camera.Position[1]
			DX     = DZ/TanAngle
			Self.X = Raycaster.Camera.Position[0] + DX
			FACE   = FACE_FRONT

		ElseIf Self.Angle = 0.0 Or Self.Angle = 180.0
			Quit  = True

		ElseIf Self.Angle = 90.0 Then
			DeltaZ = Float(Raycaster.TileSize)
			DeltaX = 0.0
			Self.Z = Float((Int(Raycaster.Camera.Position[1]) / ..
			         Raycaster.TileSize)*Raycaster.TileSize + Raycaster.TileSize)
			Self.X = Raycaster.Camera.Position[0]
			FACE   = FACE_BACK

		ElseIf Self.Angle = 270.0 Then
			DeltaZ = -Float(Raycaster.TileSize)
			DeltaX = 0.0
			Self.Z = Float((Int(Raycaster.Camera.Position[1]) / ..
			         Raycaster.TileSize)*Raycaster.TileSize)
			Self.X = Raycaster.Camera.Position[0]
			FACE   = FACE_FRONT
		EndIf

		Tile = 0
		While Not Quit
			MapColumn = Int(Self.X)/Raycaster.TileSize
			If Self.Angle => 0.0 And Self.Angle <= 180.0 Then
				MapRow = Int(Self.Z)/Raycaster.TileSize
			ElseIf Self.Angle > 180.0 And Self.Angle < 360.0 Then
				MapRow = Int(Self.Z)/Raycaster.TileSize - 1
			EndIf

			If MapColumn < 0 Or MapColumn > Raycaster.MapSize[0] - 1 Or ..
			   MapRow < 0 Or MapRow > Raycaster.MapSize[1] - 1 Then Exit

			Tile = Raycaster.Map[MapColumn, MapRow]
			If Tile > 0 Then Exit

			Self.X :+ DeltaX
			Self.Z :+ DeltaZ
		Wend

		If Tile > 0 Then
			DX = Raycaster.Camera.Position[0] - Self.X
			DZ = Raycaster.Camera.Position[1] - Self.Z
			Distance = Sqr(DX*DX + DZ*DZ)
		EndIf

		OldX        = Self.X
		OldZ        = Self.Z
		OldDistance = Distance
		OldTile     = Tile
		OldFace     = Face

		' Find vertical intersection
		Quit = False
		If (Self.Angle > 270.0 And Self.Angle < 360.0) Or ..
		   (Self.Angle > 0.0 And Self.Angle < 90.0) Then
			DeltaX = Float(Raycaster.TileSize)
			DeltaZ = TanAngle*DeltaX
			Self.X = Float(Int(Raycaster.Camera.Position[0])/Raycaster.TileSize * ..
			         Raycaster.TileSize + Raycaster.TileSize)
			DX     = Self.X - Raycaster.Camera.Position[0]
			DZ     = TanAngle*DX
			Self.Z = Raycaster.Camera.Position[1]+DZ
			Face   = FACE_RIGHT

		ElseIf Self.Angle > 90.0 And Self.Angle < 270.0 Then
			DeltaX = -Float(Raycaster.TileSize)
			DeltaZ = TanAngle*DeltaX
			Self.X = Float(Int(Raycaster.Camera.Position[0])/Raycaster.TileSize * ..
			         Raycaster.TileSize)
			DX     = Self.X - Raycaster.Camera.Position[0]
			DZ     = TanAngle*DX
			Self.Z = Raycaster.Camera.Position[1]+DZ
			Face   = FACE_LEFT

		ElseIf Self.Angle = 90.0 Or Self.Angle = 270.0 Then
			Quit = True

		ElseIf Self.Angle = 0.0 Then
			DeltaX = Float(Raycaster.TileSize)
			DeltaZ = 0.0
			Self.X = Float(Int(Raycaster.Camera.Position[0])/Raycaster.TileSize * ..
			         Raycaster.TileSize + Raycaster.TileSize)
			Self.Z = Raycaster.Camera.Position[1]
			Face   = FACE_RIGHT

		ElseIf Self.Angle = 180.0
			DeltaX = -Float(Raycaster.TileSize)
			DeltaZ = 0.0
			Self.X = Float(Int(Raycaster.Camera.Position[0])/Raycaster.TileSize * ..
			         Raycaster.TileSize)
			Self.Z = Raycaster.Camera.Position[1]
			Face   = FACE_LEFT
		EndIf

		Tile = 0
		While Not Quit	
			MapRow = Int(Self.Z)/Raycaster.TileSize
			If (Self.Angle > 270.0 And Self.Angle < 360.0) Or ..
		       (Self.Angle => 0.0 And Self.Angle < 90.0) Then
				MapColumn = Int(Self.X)/Raycaster.TileSize
			ElseIf Self.Angle => 90.0 And Self.Angle <= 270.0 Then
				MapColumn = Int(Self.X)/Raycaster.TileSize - 1
			EndIf

			If MapColumn < 0 Or MapColumn > Raycaster.MapSize[0] - 1 Or ..
			   MapRow < 0 Or MapRow > Raycaster.MapSize[1] - 1 Then Exit

			Tile = Raycaster.Map[MapColumn, MapRow]
			If Tile > 0 Then Exit

			Self.X :+ DeltaX
			Self.Z :+ DeltaZ
		Wend

		' Find the shortest Distance
		If Tile > 0 Then
			DX = Raycaster.Camera.Position[0] - Self.X
			DZ = Raycaster.Camera.Position[1] - Self.Z
			Distance = Sqr(DX*DX + DZ*DZ)

			If OldTile > 0 Then
				If Distance <= OldDistance Then
					Self.Distance = Distance
					Self.Tile     = Tile
					Self.Face     = Face
				Else
					Self.Distance = OldDistance
					Self.X        = OldX
					Self.Z        = OldZ
					Self.Tile     = OldTile
					Self.Face     = OldFace
				EndIf
			Else
				Self.Distance = Distance
				Self.Tile     = Tile
				Self.Face     = Face
			EndIf
		Else
			Self.Distance = OldDistance
			Self.X        = OldX
			Self.Z        = OldZ
			Self.Tile     = OldTile
			Self.Face     = OldFace
		EndIf
	End Method
End Type

Type TTexture
	Field Height : Int
	Field Texels : Int[,]

	Method New()
		Self.Height = 0
		Self.Texels = Null
	End Method

	Method Delete()
		If Self.Texels Then MemFree(Self.Texels)
	End Method

	Method DrawColumn(X:Int, Column:Float, Height:Int, Camera:TCamera)
		Local DeltaY:Float, StartY:Int, Y:Int
		Local Texel:Int, TempY:Int, Offset:Byte Ptr

		DeltaY = Float(Self.Height)/Float(Height)
		If Height > Camera.Viewport[3] Then
			StartY = (Height - Camera.Viewport[3])/2
			Height = Camera.Viewport[3]
		Else
			StartY = 0
		EndIf

		TempY = Camera.Viewport[3]/2 - Height/2 - StartY

		For Y = StartY Until Height+StartY
			Row = Int(Float(Y)*DeltaY)

			Offset = Camera.Screen.Pixels + ..
			         (TempY+Y)*Camera.Viewport[2]*4 + X*4

			Texel = Self.Texels[Row, Column]
			Offset[2] = (Texel Shr 16) & $FF
			Offset[1] = (Texel Shr 8) & $FF
			Offset[0] = Texel & $FF
		Next
	End Method

	Function Load:TTexture(URL:Object, TileSize:Int)
		Local Pixmap:TPixmap, Texture:TTexture

		Pixmap = LoadPixmap(URL)
		If Not Pixmap Then Return Null

		Pixmap = ResizePixmap(Pixmap, TileSize, Pixmap.Height)

		?Win32
			Pixmap = Pixmap.Convert(PF_RGBA8888)
		?MacOS
			Pixmap = Pixmap.Convert(PF_BGRA8888)
		?Linux
			Pixmap = Pixmap.Convert(PF_RGBA8888)
		?

		Texture = New TTexture
		Texture.Height = Pixmap.Height
		Texture.Texels = New Int[Texture.Height, TileSize]
		MemCopy(Texture.Texels, Pixmap.PixelPtr(0, 0), TileSize*Texture.Height*4)

		Return Texture
	End Function
End Type