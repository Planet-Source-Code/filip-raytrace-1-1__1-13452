VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Plane"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' Infinite plane

Implements RayTraceable

' Position
Private Point1 As Point3D ' A point on the plane
Private Point2 As Point3D ' point2-point1 = surface normal
' This way to calculate the normal makes sure the normal
' is not distorted after applying a transformation matrix
' to the plane

' Lighting values:
' Ambient:
Private AmbKr As Single
Private AmbKg As Single
Private AmbKb As Single
' Diffuse
Private DiffKr As Single
Private DiffKg As Single
Private DiffKb As Single
' Specular
Private Spec_K As Single
Private Spec_N As Single

' Find the unit surface normal
Public Sub GetUNormal(ByRef Nx As Single, ByRef Ny As Single, ByRef Nz As Single)
    Dim Nlen As Single
    Nx = Point2.Trans(1) - Point1.Trans(1)
    Ny = Point2.Trans(2) - Point1.Trans(2)
    Nz = Point2.Trans(3) - Point1.Trans(3)
    Nlen = Sqr(Nx * Nx + Ny * Ny + Nz * Nz)
    Nx = Nx / Nlen
    Ny = Ny / Nlen
    Nz = Nz / Nlen
End Sub

Public Sub RayTraceable_Apply(M() As Single)
    m3Apply Point1.Coord, M, Point1.Trans
    m3Apply Point2.Coord, M, Point2.Trans
End Sub

Public Sub RayTraceable_ApplyFull(M() As Single)
    m3ApplyFull Point1.Coord, M, Point1.Trans
    m3ApplyFull Point2.Coord, M, Point2.Trans
End Sub

Public Sub RayTraceable_FindHitColor(Objects As Collection, ByVal eyeX As Single, ByVal eyeY As Single, ByVal eyeZ As Single, ByVal px As Single, ByVal py As Single, ByVal pz As Single, R As Integer, G As Integer, B As Integer)
    Dim Nx As Single
    Dim Ny As Single
    Dim Nz As Single
    Dim Vx As Single
    Dim Vy As Single
    Dim Vz As Single
    Dim NdotV As Single
    
    ' Get the unit normal
    GetUNormal Nx, Ny, Nz
    
    ' Make sure the normal points towards the eye
    Vx = Eye_X - px
    Vy = Eye_Y - py
    Vz = Eye_Z - pz
    NdotV = Nx * Vx + Ny * Vy + Nz * Vz
    If NdotV < 0 Then
        Nx = -Nx
        Ny = -Ny
        Nz = -Nz
    End If
    
    ' Calculate the hit color
    CalculateHitColor Objects, Me, _
        eyeX, eyeY, eyeZ, _
        px, py, pz, _
        Nx, Ny, Nz, _
        DiffKr, DiffKg, DiffKb, _
        AmbKr, AmbKg, AmbKb, _
        Spec_K, Spec_N, _
        R, G, B
End Sub

Public Function RayTraceable_FindT(DirectC As Boolean, px As Single, py As Single, pz As Single, Vx As Single, Vy As Single, Vz As Single) As Single
    Dim A As Single
    Dim B As Single
    Dim C As Single
    Dim D As Single
    Dim Nx As Single
    Dim Ny As Single
    Dim Nz As Single
    Dim Denom As Single
    Dim t As Single
    
    ' Find the unit normal
    GetUNormal Nx, Ny, Nz
    
    ' Calculate the plane's parameters
    A = Nx
    B = Ny
    C = Nz
    D = -(Nx * Point1.Trans(1) + _
        Ny * Point1.Trans(2) + _
        Nz * Point1.Trans(3))
            
    ' If the denominator in the equation for t equals 0,
    ' the ray is parralel to the plane so there's no
    ' intersection
    Denom = A * Vx + B * Vy + C * Vz
    If Denom = 0 Then
        RayTraceable_FindT = -1
        Exit Function
    End If
    
    ' Solve for t
    t = -(A * px + B * py + C * pz + D) / Denom
    
    ' If there's no positive t value, there's no intersection
    ' in this direction
    If t < 0.01 Then
        RayTraceable_FindT = -1
        Exit Function
    End If
    
    ' We had a hit
    RayTraceable_FindT = t
End Function

Public Sub SetValues(ByVal p1x As Single, ByVal p1y As Single, ByVal p1z As Single, _
    ByVal p2x As Single, ByVal p2y As Single, ByVal p2z As Single, _
    ByVal AmbientKr As Single, ByVal AmbientKg As Single, ByVal AmbientKb As Single, _
    ByVal DiffuseKr As Single, ByVal DiffuseKg As Single, ByVal DiffuseKb As Single, _
    ByVal SpecularK As Single, ByVal SpecularN As Single)
    
    ' Set point1
    Point1.Coord(1) = p1x
    Point1.Coord(2) = p1y
    Point1.Coord(3) = p1z
    
    ' Set point2
    Point2.Coord(1) = p2x
    Point2.Coord(2) = p2y
    Point2.Coord(3) = p2z
    
    ' Set ambient lighting
    AmbKr = AmbientKr
    AmbKg = AmbientKg
    AmbKb = AmbientKb
    
    ' Set diffuse lighting
    DiffKr = DiffuseKr
    DiffKg = DiffuseKg
    DiffKb = DiffuseKb
    
    ' Set specular lighting
    Spec_K = SpecularK
    Spec_N = SpecularN
End Sub

Private Sub RayTraceable_GetRminRmax(new_min As Single, new_max As Single, ByVal X As Single, ByVal Y As Single, ByVal Z As Single)
Dim dx As Single
Dim dy As Single
Dim dz As Single
Dim dist As Single

    dx = X - Point1.Trans(1)
    dy = Y - Point1.Trans(2)
    dz = Z - Point1.Trans(3)
    dist = Sqr(dx * dx + dy * dy + dz * dz)
    new_max = dist
    new_min = dist
End Sub

