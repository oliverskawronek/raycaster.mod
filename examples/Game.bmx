SuperStrict

Framework brl.blitz
Import vertex.raycaster
Import brl.glmax2d
Import brl.pngloader

Global Raycaster : TRaycaster
Global Camera    : TCamera

Global MapWidth : Int
Global MapDepth : Int
Global Column   : Int
Global Row      : Int
Global Tile     : Int

Global FrameCount : Int
Global Start      : Int
Global FPS        : Int

Graphics(320, 240, 0, 0)

' Init Raycaster
Raycaster:TRaycaster = New TRaycaster

' Load Tileset
Raycaster.LoadTile("assets/Tile1.png")
Raycaster.LoadTile("assets/Tile2.png")
Raycaster.LoadTile("assets/Tile3.png")
Raycaster.LoadTile("assets/Tile4.png")
Raycaster.LoadTile("assets/Tile5.png")
Raycaster.LoadTile("assets/Tile6.png")
Raycaster.LoadTile("assets/Tile7.png")
Raycaster.LoadTile("assets/Tile8.png")

' Read Map
RestoreData Map
ReadData MapWidth, MapDepth
Raycaster.SetMapSize(MapWidth, MapDepth)
For Row = 0 Until MapDepth
	For Column = 0 Until MapWidth
		ReadData Tile
		Raycaster.SetTile(Column, Row, Tile)
	Next
Next

' Add Camera
Camera = New TCamera
Camera.SetClearColor(30, 10, 0)
Camera.SetPosition(672.0, 672.0)
Raycaster.SetCamera(Camera)

While Not KeyDown(KEY_ESCAPE)
	If KeyDown(KEY_LEFT)  Then Camera.Turn(-1.0)
	If KeyDown(KEY_RIGHT) Then Camera.Turn( 1.0)

	If KeyDown(KEY_UP)   Then Camera.Move( 1.0)
	If KeyDown(KEY_DOWN) Then Camera.Move(-1.0)

	Raycaster.Render()

	SetColor(255, 255, 255)
	DrawText(FPS + " FPS", 10, 10)

	Flip()
	FrameCount :+ 1

	If MilliSecs() - Start >= 1000 Then
		FPS        = FrameCount
		FrameCount = 0
		Start      = MilliSecs()
	EndIf
Wend

EndGraphics()
End

#Map
DefData 20, 20
DefData 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
DefData 1, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 0, 0, 0, 3, 3, 3, 3, 3, 3, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 0, 0, 0, 3, 3, 6, 6, 6, 3, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 0, 0, 0, 3, 3, 6, 6, 6, 3, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 6, 6, 6, 3, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 2, 2, 0, 3, 3, 6, 6, 6, 6, 3, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 1
DefData 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 1
DefData 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
DefData 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 8, 1, 1