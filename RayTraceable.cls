VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "RayTraceable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' RayTraceable Class; all objects implement this class

Public Function FindT(DirectC As Boolean, px As Single, py As Single, pz As Single, Vx As Single, Vy As Single, Vz As Single) As Single
    ' Empty
End Function

Public Sub Apply(M() As Single)
    ' Empty
End Sub

Public Sub ApplyFull(M() As Single)
    ' Empty
End Sub

Public Sub FindHitColor(Objects As Collection, _
    ByVal eyeX As Single, ByVal eyeY As Single, ByVal eyeZ As Single, _
    ByVal px As Single, ByVal py As Single, ByVal pz As Single, _
    ByRef R As Integer, ByRef G As Integer, ByRef B As Integer)
    ' Empty
End Sub

Public Sub GetRminRmax(new_min As Single, new_max As Single, ByVal X As Single, ByVal Y As Single, ByVal Z As Single)
    ' Empty
End Sub

