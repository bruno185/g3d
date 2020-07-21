object Form1: TForm1
  Left = 389
  Top = 363
  Caption = 'Form1'
  ClientHeight = 535
  ClientWidth = 693
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = DoCreate
  OnMouseWheelDown = DoWheelDown
  OnMouseWheelUp = DoWheelUp
  OnResize = btn_AffichageClick
  OnShow = DoCreate
  DesignSize = (
    693
    535)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 25
    Top = 167
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 25
    Top = 186
    Width = 3
    Height = 13
  end
  object PaintBox1: TPaintBox
    Left = 240
    Top = 8
    Width = 446
    Height = 520
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    ParentColor = False
    OnMouseDown = DoMouseDown
    OnMouseMove = DoMouseMove
    OnMouseUp = DoMouseUp
    OnPaint = btn_AffichageClick
    ExplicitHeight = 452
  end
  object Label3: TLabel
    Left = 7
    Top = 359
    Width = 42
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Distance'
  end
  object Label4: TLabel
    Left = 7
    Top = 385
    Width = 27
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Zoom'
  end
  object Label5: TLabel
    Left = 7
    Top = 170
    Width = 15
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'h : '
  end
  object Label6: TLabel
    Left = 7
    Top = 188
    Width = 12
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'v :'
  end
  object Label7: TLabel
    Left = 8
    Top = 206
    Width = 8
    Height = 13
    Caption = 'w'
  end
  object Label8: TLabel
    Left = 25
    Top = 206
    Width = 3
    Height = 13
  end
  object btn_Affichage: TButton
    Left = 7
    Top = 7
    Width = 227
    Height = 26
    Caption = 'Affichage'
    TabOrder = 0
    OnClick = btn_AffichageClick
  end
  object scb_h: TScrollBar
    Left = 7
    Top = 40
    Width = 227
    Height = 24
    LargeChange = 5
    Max = 180
    Min = -180
    PageSize = 0
    Position = 45
    TabOrder = 1
    OnChange = DoChangeAngle
  end
  object scb_v: TScrollBar
    Left = 7
    Top = 70
    Width = 227
    Height = 24
    LargeChange = 5
    Max = 180
    Min = -180
    PageSize = 0
    Position = 83
    TabOrder = 2
    OnChange = DoChangeAngle
  end
  object btn_Charger: TButton
    Left = 7
    Top = 141
    Width = 66
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Charger'
    TabOrder = 3
    OnClick = btn_ChargerClick
  end
  object Memo1: TMemo
    Left = 85
    Top = 141
    Width = 150
    Height = 211
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    ScrollBars = ssVertical
    TabOrder = 4
    OnChange = DoMemoChange
  end
  object edt_Distance: TEdit
    Left = 72
    Top = 358
    Width = 46
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 5
    Text = '256'
    OnChange = DoChangeParam
  end
  object edt_Zoom: TEdit
    Left = 72
    Top = 382
    Width = 46
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 6
    Text = '512'
  end
  object chk_Repere: TCheckBox
    Left = 7
    Top = 406
    Width = 60
    Height = 14
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Rep'#232'res'
    TabOrder = 7
    OnClick = btn_AffichageClick
  end
  object btn_AfficheFace: TButton
    Left = 146
    Top = 357
    Width = 81
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Afficher Face'
    TabOrder = 8
    OnClick = btn_AfficheFaceClick
  end
  object edt_FaceNum: TEdit
    Left = 146
    Top = 382
    Width = 81
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 9
    Text = '0'
  end
  object btn_Intersect: TButton
    Left = 146
    Top = 406
    Width = 81
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'intersec'
    TabOrder = 10
    OnClick = btn_IntersectClick
  end
  object edt_intersect1: TEdit
    Left = 146
    Top = 432
    Width = 38
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 11
    Text = '0'
  end
  object edt_intersect2: TEdit
    Left = 189
    Top = 432
    Width = 33
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 12
    Text = '1'
  end
  object chk_Ajuster: TCheckBox
    Left = 7
    Top = 425
    Width = 60
    Height = 14
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Ajuster'
    Checked = True
    State = cbChecked
    TabOrder = 13
  end
  object btn_FacesShow: TButton
    Left = 146
    Top = 469
    Width = 81
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Faces Show'
    TabOrder = 14
    OnClick = btn_FacesShowClick
  end
  object btn_MemoClear: TButton
    Left = 7
    Top = 245
    Width = 66
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Memo clear'
    TabOrder = 15
    OnClick = btn_MemoClearClick
  end
  object btn_Verifier: TButton
    Left = 7
    Top = 456
    Width = 66
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'V'#233'rifier'
    TabOrder = 16
    OnClick = btn_VerifierClick
  end
  object btn_TC: TButton
    Left = 78
    Top = 456
    Width = 61
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'TC'
    TabOrder = 17
    OnClick = btn_TCClick
  end
  object chk_Ortho: TCheckBox
    Left = 7
    Top = 277
    Width = 43
    Height = 14
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Ortho'
    TabOrder = 18
    OnClick = DoOrthoChange
  end
  object btn_JPEG: TButton
    Left = 72
    Top = 406
    Width = 60
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'JPEG'
    TabOrder = 19
    OnClick = btn_JPEGClick
  end
  object scb_w: TScrollBar
    Left = 8
    Top = 104
    Width = 226
    Height = 24
    LargeChange = 5
    Max = 180
    Min = -180
    PageSize = 0
    TabOrder = 20
    OnChange = DoChangeAngle
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Texte|*.txt'
    Left = 376
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'jpg'
    Filter = 'JPEG|*.jpg'
    Left = 312
    Top = 16
  end
end
