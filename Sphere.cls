VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Sphere"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' Sphere

Implements RayTraceable

' Position
Private Center As Point3D
' Radius
Private Radius As Single

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

Public Function RayTraceable_FindT(DirectC As Boolean, px As Single, py As Single, pz As Single, Vx As Single, Vy As Single, Vz As Single) As Single
    Dim A As Single
    Dim B As Single
    Dim C As Single
    Dim B24AC As Single
    Dim t1 As Single
    Dim t2 As Single
    Dim Cx As Single
    Dim Cy As Single
    Dim Cz As Single
    ' Create values for the center of the sphere
    Cx = Center.Trans(1)
    Cy = Center.Trans(2)
    Cz = Center.Trans(3)
    ' Get coefficients for the quadratic
    A = Vx * Vx + Vy * Vy + Vz * Vz
    B = 2 * Vx * (px - Cx) + _
        2 * Vy * (py - Cy) + _
        2 * Vz * (pz - Cz)
    C = Cx * Cx + Cy * Cy + Cz * Cz + _
        px * px + py * py + pz * pz - _
        2 * (Cx * px + Cy * py + Cz * pz) - _
        Radius * Radius
    ' Solve the quadratic A * t ^ 2 + B * t + C = 0
    B24AC = B * B - 4 * A * C
    ' Check intersections
    If B24AC < 0 Then
        ' No real intersection
        RayTraceable_FindT = -1
        Exit Function
    ElseIf B24AC = 0 Then
        ' One intersection
        t1 = -B / 2 / A
    Else
        ' Two intersections
        B24AC = Sqr(B24AC)
        t1 = (-B + B24AC) / 2 / A
        t2 = (-B - B24AC) / 2 / A
        ' Use only positive values for t
        If t1 < 0.01 Then t1 = t2
        If t2 < 0.01 Then t2 = t1
        ' Use the smallest one
        If t1 > t2 Then t1 = t2
    End If
    ' If there's no positive value, there's no intersection
    If t1 < 0.01 Then
        RayTraceable_FindT = -1
        Exit Function
    End If
    ' If the function reaches this line, we had a hit
    RayTraceable_FindT = t1
End Function

Public Sub RayTraceable_FindHitColor(Objects As Collection, _
    ByVal eyeX As Single, ByVal eyeY As Single, ByVal eyeZ As Single, _
    ByVal px As Single, ByVal py As Single, ByVal pz As Single, _
    ByRef R As Integer, ByRef G As Integer, ByRef B As Integer)
    
    Dim Nx As Single
    Dim Ny As Single
    Dim Nz As Single
    Dim Nlen As Single
    
    ' Find the unit normal
    Nx = px - Center.Trans(1)
    Ny = py - Center.Trans(2)
    Nz = pz - Center.Trans(3)
    Nlen = Sqr(Nx * Nx + Ny * Ny + Nz * Nz)
    Nx = Nx / Nlen
    Ny = Ny / Nlen
    Nz = Nz / Nlen
    ' Uncomment the following lines for normal
    ' vector perturbation (bumpiness)
    ' Nx = Nx + Rnd * 0.2
    ' Ny = Ny + Rnd * 0.2
    ' Nz = Nz + Rnd * 0.2
    ' Nlen = Sqr(Nx * Nx + Ny * Ny + Nz * Nz)
    ' Nx = Nx / Nlen
    ' Ny = Ny / Nlen
    ' Nz = Nz / Nlen
    
    ' Calculate hit color
    CalculateHitColor Objects, Me, eyeX, eyeY, eyeZ, _
        px, py, pz, _
        Nx, Ny, Nz, _
        DiffKr, DiffKg, DiffKb, _
        AmbKr, AmbKg, AmbKb, _
        Spec_K, Spec_N, _
        R, G, B
End Sub

Public Sub RayTraceable_Apply(M() As Single)
    m3Apply Center.Coord, M, Center.Trans
End Sub

Public Sub RayTraceable_ApplyFull(M() As Single)
    m3ApplyFull Center.Coord, M, Center.Trans
End Sub

Public Sub SetValues(ByVal X As Single, ByVal Y As Single, ByVal Z As Single, _
    ByVal Rad As Single, _
    ByVal AmbientKr As Single, ByVal AmbientKg As Single, ByVal AmbientKb, _
    ByVal DiffuseKr As Single, ByVal DiffuseKg As Single, ByVal DiffuseKb, _
    ByVal SpecularK As Single, ByVal SpecularN As Single)
    
    ' Assign values to local variables
    ' Position and radius
    Center.Coord(1) = X
    Center.Coord(2) = Y
    Center.Coord(3) = Z
    Center.Coord(4) = 1#
    Radius = Rad
    
    ' Lighting
    ' Ambient
    AmbKr = AmbientKr
    AmbKg = AmbientKg
    AmbKb = AmbientKb
    ' Diffuse
    DiffKr = DiffuseKr
    DiffKg = DiffuseKg
    DiffKb = DiffuseKb
    ' Specular
    Spec_K = SpecularK
    Spec_N = SpecularN
End Sub

Private Sub RayTraceable_GetRminRmax(new_min As Single, new_max As Single, ByVal X As Single, ByVal Y As Single, ByVal Z As Single)
    Dim dx As Single
    Dim dy As Single
    Dim dz As Single
    Dim dist As Single

    dx = X - Center.Trans(1)
    dy = Y - Center.Trans(2)
    dz = Z - Center.Trans(3)
    dist = Sqr(dx * dx + dy * dy + dz * dz)
    new_max = dist + Radius
    new_min = dist - Radius
    If new_min < 0 Then new_min = 0
End Sub

