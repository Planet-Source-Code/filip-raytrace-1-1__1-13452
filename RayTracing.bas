Attribute VB_Name = "RayTrace"
Option Explicit

Public LightSources As New Collection

' Ambient lighting values
Public AmbIr As Single
Public AmbIg As Single
Public AmbIb As Single

' Background color
Public BackR As Integer
Public BackG As Integer
Public BackB As Integer

' Eye position
' Cartesian
Public Eye_X As Single
Public Eye_Y As Single
Public Eye_Z As Single
' Spherical
Public EyePhi As Single
Public EyeTheta As Single
Public EyeR As Single

' Focus point
Public FocusX As Single
Public FocusY As Single
Public FocusZ As Single

' Running booleans
Public Running As Boolean
Public PRunning As Boolean

' Objects collection
Public Objects As New Collection

' Sub for calculating the hit color for the eye at
' (eyeX, eyeY, eyeZ), the hitpoint at (px, py, pz), and
' normal vector <Nx, Ny, Nz>, and ambient, diffuse and
' specular reflection.
Public Sub CalculateHitColor(Objects As Collection, _
    ByVal TargetObj As RayTraceable, _
    ByVal eyeX As Single, ByVal eyeY As Single, ByVal eyeZ As Single, _
    ByVal px As Single, ByVal py As Single, ByVal pz As Single, _
    ByVal Nx As Single, ByVal Ny As Single, ByVal Nz As Single, _
    ByVal DiffKr As Single, ByVal DiffKg As Single, ByVal DiffKb As Single, _
    ByVal AmbKr As Single, ByVal AmbKg As Single, ByVal AmbKb As Single, _
    ByVal SpecK As Single, ByVal SpecN As Single, _
    ByRef R As Integer, ByRef G As Integer, ByRef B As Integer)
    
    ' Vectors:
    Dim Vx As Single        'V: p to viewpoint
    Dim Vy As Single
    Dim Vz As Single
    Dim Vlen As Single
    Dim Lx As Single        'L: p to lightsource
    Dim Ly As Single
    Dim Lz As Single
    Dim Llen As Single
    Dim LMx As Single       'LM: Light source mirror vector
    Dim LMy As Single
    Dim LMz As Single
    
    Dim DistFactor As Single
    
    ' Dot products:
    Dim LdotN As Single
    Dim VdotN As Single
    Dim LMdotV As Single
    
    ' Colors:
    Dim TotalR As Single
    Dim TotalG As Single
    Dim TotalB As Single
    
    Dim Light_Source As LightSource
    Dim Shadowed As Boolean
    Dim ShadowObject As RayTraceable
    Dim ShadowT As Single
    Dim spec As Single
    
    'Get vector V
    Vx = eyeX - px
    Vy = eyeY - py
    Vz = eyeZ - pz
    Vlen = Sqr(Vx * Vx + Vy * Vy + Vz * Vz)
    Vx = Vx / Vlen
    Vy = Vy / Vlen
    Vz = Vz / Vlen
    
    ' Consider each lightsource
    For Each Light_Source In LightSources
        ' Find vector L not normalized
        Lx = Light_Source.TransX - px
        Ly = Light_Source.TransY - py
        Lz = Light_Source.TransZ - pz
        
        ' See if we are shadowed
        Shadowed = False
        For Each ShadowObject In Objects
            If Not (ShadowObject Is TargetObj) Then
                ' See where vector L intersects the
                ' Shadow object
                ShadowT = ShadowObject.FindT( _
                    False, _
                    Light_Source.TransX, _
                    Light_Source.TransY, _
                    Light_Source.TransZ, _
                    -Lx, -Ly, -Lz)
                
                ' If ShadowT < 1, we're shadowed
                If (ShadowT > 0) And (ShadowT < 1) Then
                    Shadowed = True
                    Exit For
                End If
            End If
        Next ShadowObject
        
        ' Normalize vector L
        Llen = Sqr(Lx * Lx + Ly * Ly + Lz * Lz)
        DistFactor = (Light_Source.Rmin + Light_Source.Kdist) / (Llen + Light_Source.Kdist)
        Lx = Lx / Llen
        Ly = Ly / Llen
        Lz = Lz / Llen
        
        ' See if the viewpoint is on the same side
        ' of the surface as the Surface Normal
        VdotN = Vx * Nx + Vy * Ny + Vz * Nz
        
        ' See if the LightSrc is on the same side
        ' of the surface as the Surface Normal
        LdotN = Lx * Nx + Ly * Ny + Lz * Nz
        
        ' We only have specular and diffuse lighting
        ' components if the viewpoint and light are
        ' on the same side of the surface, and if we
        ' are not shadowed
        If (VdotN >= 0) And (LdotN >= 0) And (Not Shadowed) Then
            ' The light is shining on the surface
            
            ' ####################
            ' # Diffuse lighting #
            ' ####################
            ' There is a diffuse component
            TotalR = TotalR + Light_Source.Ir * DiffKr * LdotN * DistFactor
            TotalG = TotalG + Light_Source.Ig * DiffKg * LdotN * DistFactor
            TotalB = TotalB + Light_Source.Ib * DiffKb * LdotN * DistFactor
            
            ' #####################
            ' # Specular lighting #
            ' #####################
            ' Find the light mirror vector LM
            LMx = 2 * Nx * LdotN - Lx
            LMy = 2 * Ny * LdotN - Ly
            LMz = 2 * Nz * LdotN - Lz
            
            ' Get LM dot V
            LMdotV = LMx * Vx + LMy * Vy + LMz * Vz
            If LMdotV > 0 Then
                spec = SpecK * (LMdotV ^ SpecN)
                TotalR = TotalR + Light_Source.Ir * spec
                TotalG = TotalG + Light_Source.Ig * spec
                TotalB = TotalB + Light_Source.Ib * spec
            End If
        End If
    Next Light_Source
    
    ' ####################
    ' # Ambient lighting #
    ' ####################
    TotalR = TotalR + AmbIr * AmbKr
    TotalG = TotalG + AmbIg * AmbKg
    TotalB = TotalB + AmbIb * AmbKb
    
    ' Keep the color components <= 255
    If TotalR > 255 Then TotalR = 255
    If TotalG > 255 Then TotalG = 255
    If TotalB > 255 Then TotalB = 255
    
    ' Also keep them >= 0
    If TotalR < 0 Then TotalR = 0
    If TotalG < 0 Then TotalG = 0
    If TotalB < 0 Then TotalB = 0
    
    ' Set the ByRef-passed color components
    R = TotalR
    G = TotalG
    B = TotalB
End Sub
    
' Trace a ray from point p, along the vector V
Public Sub TraceRay(DirectC As Boolean, SkipObject As Sphere, _
    ByVal px As Single, ByVal py As Single, ByVal pz As Single, _
    ByVal Vx As Single, ByVal Vy As Single, ByVal Vz As Single, _
    ByRef cR As Integer, ByRef cG As Integer, ByRef cB As Integer)
    
    ' Variables
    Dim Obj As RayTraceable
    Dim BestObj As RayTraceable
    Dim BestT As Single
    Dim t As Single
    
    BestT = INFINITY
    ' Find the object that's closest to p
    For Each Obj In Objects
        ' Skip the object SkipObject. We use this
        ' to avoid erroneously hitting the object
        ' casting out a ray.
        If Not (Obj Is SkipObject) Then
            t = Obj.FindT(DirectC, px, py, pz, Vx, Vy, Vz)
            If (t > 0) And (BestT > t) Then
                BestT = t
                Set BestObj = Obj
            End If
        End If
    Next Obj
    ' See if we hit anything
    If BestObj Is Nothing Then
        ' We hit nothing. Return background color
        cR = BackR
        cG = BackG
        cB = BackB
    Else
        ' Compute the color at that point
        BestObj.FindHitColor Objects, _
            px, py, pz, _
            px + BestT * Vx, _
            py + BestT * Vy, _
            pz + BestT * Vz, _
            cR, cG, cB
    End If
End Sub

' Trace all the rays on picturebox pic
Public Sub TraceAllRays(ByVal pic As PictureBox, _
    ByVal Skip As Integer)
    
    Dim Pix_x As Long
    Dim Pix_y As Long
    Dim RealX As Long
    Dim RealY As Long
    Dim Xmin As Integer
    Dim Ymin As Integer
    Dim Xmax As Integer
    Dim Ymax As Integer
    Dim Xoff As Integer
    Dim Yoff As Integer
    Dim R As Integer
    Dim G As Integer
    Dim B As Integer
    Dim Sph As Sphere
    
    ' Get the transformed coordinates of the eye
    Xoff = pic.ScaleWidth / 2
    Yoff = pic.ScaleHeight / 2
    Xmin = pic.ScaleLeft
    Xmax = Xmin + pic.ScaleWidth - 1
    Ymin = pic.ScaleTop
    Ymax = Ymin + pic.ScaleHeight - 1
    ' Trace the rays
    For Pix_y = Ymin To Ymax Step Skip
        RealY = Pix_y - Yoff
        For Pix_x = Xmin To Xmax Step Skip
            RealX = Pix_x - Xoff
            ' Calculate the value of the pixel (x,y). After
            ' transformation the eye is at (0,0,eyeR) and
            ' the plane of projection lies in the X-Y plane
            TraceRay True, Nothing, 0, 0, EyeR, _
                CSng(RealX), CSng(RealY), -EyeR, _
                R, G, B
            pic.Line (Pix_x, Pix_y)-Step(Skip - 1, Skip - 1), _
                RGB(R, G, B), BF
        Next Pix_x
        pic.Refresh
        DoEvents
        If Not Running Then Exit Sub
    Next Pix_y
End Sub

' Perform ray tracing on picturebox pic
Public Sub Render(pic As Object, Skip As Integer)
    Dim M(1 To 4, 1 To 4) As Single
    Dim Obj As RayTraceable
    Dim LSource As LightSource
    
    ' Create the projection Matrix
    m3PProject M, m3Perspective, EyeR, EyePhi, EyeTheta, _
        FocusX, FocusY, FocusZ, _
        0, 1, 0
        
    ' Transform the eye location
    Eye_X = 0
    Eye_Y = 0
    Eye_Z = EyeR
    
    ' Transform the objects
    For Each Obj In Objects
        Obj.Apply M
    Next Obj
    
    ' Transform the LightSources
    For Each LSource In LightSources
        LSource.Apply M
    Next LSource
    
    ScaleLightSourcesForDepth
    ' Trace all the rays
    TraceAllRays pic, Skip
    Running = False
End Sub

' Perform ray tracing for a preview image
Public Sub PreviewRender(pic As Object, Skip As Integer)
    Dim M(1 To 4, 1 To 4) As Single
    Dim Obj As RayTraceable
    Dim LSource As LightSource
    
    ' Create the projection Matrix
    m3PProject M, m3Perspective, EyeR, EyePhi, EyeTheta, _
        FocusX, FocusY, FocusZ, _
        0, 1, 0
        
    ' Transform the eye location
    Eye_X = 0
    Eye_Y = 0
    Eye_Z = EyeR
    
    ' Transform the objects
    For Each Obj In Objects
        Obj.Apply M
    Next Obj
    
    ' Transform the LightSources
    For Each LSource In LightSources
        LSource.Apply M
    Next LSource
    
    ScaleLightSourcesForDepth
    
    ' Trace all the rays
    PTraceAllRays pic, Skip
    PRunning = False
End Sub

' Trace all rays for a preview image
Public Sub PTraceAllRays(ByVal pic As PictureBox, _
    ByVal Skip As Integer)
    
    Dim Pix_x As Long
    Dim Pix_y As Long
    Dim RealX As Long
    Dim RealY As Long
    Dim Xmin As Integer
    Dim Ymin As Integer
    Dim Xmax As Integer
    Dim Ymax As Integer
    Dim Xoff As Integer
    Dim Yoff As Integer
    Dim R As Integer
    Dim G As Integer
    Dim B As Integer
    Dim Sph As Sphere
    
    ' Get the transformed coordinates of the eye
    Xoff = pic.ScaleWidth / 2
    Yoff = pic.ScaleHeight / 2
    Xmin = pic.ScaleLeft
    Xmax = Xmin + pic.ScaleWidth - 1
    Ymin = pic.ScaleTop
    Ymax = Ymin + pic.ScaleHeight - 1
    ' Trace the rays
    For Pix_y = Ymin - 100 To Ymax * Skip Step Skip
        RealY = Pix_y - Yoff
        For Pix_x = Xmin - 100 To Xmax * Skip Step Skip
            RealX = Pix_x - Xoff
            ' Calculate the value of the pixel (x,y). After
            ' transformation the eye is at (0,0,eyeR) and
            ' the plane of projection lies in the X-Y plane
            TraceRay True, Nothing, 0, 0, EyeR, _
                CSng(RealX), CSng(RealY), -EyeR, _
                R, G, B
            pic.Line (Pix_x / 3 + 30, Pix_y / 3 + 30)-Step(0, 0), _
                RGB(R, G, B), BF
        Next Pix_x
        pic.Refresh
        DoEvents
        If Not PRunning Then Exit Sub
    Next Pix_y
End Sub

Private Sub ScaleIntensityForDepth(ByVal light As LightSource)
Dim solid As RayTraceable
Dim Rmin As Single
Dim Rmax As Single
Dim new_rmin As Single
Dim new_rmax As Single

    Rmin = 1E+30
    Rmax = -1E+30

    For Each solid In Objects
        solid.GetRminRmax new_rmin, new_rmax, _
            light.TransX, light.TransY, light.TransZ
        If Rmin > new_rmin Then Rmin = new_rmin
        If Rmax < new_rmax Then Rmax = new_rmax
    Next solid

    light.Rmin = Rmin
'    light.Kdist = (Rmax - 5 * Rmin) / 4 ' Fade to 1/5.
    light.Kdist = Rmax - 2 * Rmin ' Fade to 1/2.
End Sub

Private Sub ScaleLightSourcesForDepth()
Dim light As LightSource

    For Each light In LightSources
        ScaleIntensityForDepth light
    Next light
End Sub

