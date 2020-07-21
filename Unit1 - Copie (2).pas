unit Unit1;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tpt = record
    // coordonn�es World
    x, y, z : real;
    // coordonn�es observateur
    xo, yo, zo : real;
    // coordonn�es �cran
    x2d, y2d:integer;
    // Eloignement moyen (= zO moyen)
    zmoyen : real;
    // Equation du plan de la face (de type Ax+By+Cz+D=0)
    A,B,C,D : real ;
    ID : integer;
  end;

  TFace = array of Tpt;
  TObj = array of Tface;



  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    btn_Affichage: TButton;
    scb_h: TScrollBar;
    scb_v: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    btn_Charger: TButton;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    edt_Distance: TEdit;
    edt_Zoom: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    chk_Repere: TCheckBox;
    btn_AfficheFace: TButton;
    edt_FaceNum: TEdit;
    btn_Intersect: TButton;
    edt_intersect1: TEdit;
    edt_intersect2: TEdit;
    chk_Ajuster: TCheckBox;
    procedure btn_AffichageClick(Sender: TObject);
    procedure DoChangeAngle(Sender: TObject);
    procedure DoCreate(Sender: TObject);
    procedure btn_ChargerClick(Sender: TObject);
    procedure btn_AfficheFaceClick(Sender: TObject);
    procedure btn_IntersectClick(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }

  end;

var
  Form1: TForm1;

    obj : Tobj;
    face : Tface;
    som : array of TPt;
    nbsom : integer;
    nbface : integer;
    sinus : array[0..359] of real;
    cosinus :array[0..359] of real;
    zoom : integer;
    distance : integer;
    TmpBmp : TBitmap;

implementation

const
     pi = 3.14159;
     tolerance = 0.00000001;
{$R *.DFM}

procedure debug(s: string);
begin
  Form1.Memo1.Lines.Add(s);
end;

procedure CalculPoint(var p : Tpt; angle_h, angle_v, centrex, centrey : integer);
begin
     with p do
     begin
     // syst�me world --> syst�me de l'observateur
     zo := -x*(cosinus[angle_h]*cosinus[angle_v])-y*(sinus[angle_h]*cosinus[angle_v])-z*sinus[angle_v]+distance;
     xo := (-x*sinus[angle_h]+y*cosinus[angle_h]);
     yo := (-x*(cosinus[angle_h]*sinus[angle_v])-y*(sinus[angle_h]*sinus[angle_v])+z*cosinus[angle_v]);

  // projection
      x2d := round(xo*Zoom/zo) + centrex;
      y2d := centrey - (round(yo*Zoom/zo));
     end;
end;

procedure TriFacesSimple;
// tir des faces en fontion de l'�loignement du centre de la face
// par rapport � l'observateur
// on travaille dans le syst�me de l'observateur
var
  curface,cursommet : integer;
  tmpface : TFace;
  zmoyen : real;
  permut : boolean;
begin
  // calcule le zmoyen (= �loignement) pour chaque face
  for curface := 0 to length(obj)-1 do
  begin
    zmoyen := 0;
    for cursommet := 0 to length(obj[curface])-1 do
    begin
      zmoyen := zmoyen + obj[curface][cursommet].zo;
    end;
    // �loignement stock� dans 1er point de la face
    obj[curface][0].zmoyen := zmoyen / length(obj[curface]);
  end;

  // tri � bulle
  repeat
  permut := false;
  for curface := 0 to length(obj)-2 do
  begin
    // si face n+1 est plus �loign�e que face n ==> permutation
    if obj[curface+1][0].zmoyen > obj[curface][0].zmoyen then
    begin
      permut := true;
      tmpface := obj[curface];
      obj[curface] := obj[curface+1];
      obj[curface+1] := tmpface;
    end;
  end;
  until permut = false;
  // fin tri � bulle.
end;

function Signe(r : real) : integer;
begin
     if r >= 0 then signe := 1
     else signe := -1;
end;

function Arrondi(r : real) :real;
begin
  if abs(r) < tolerance then Arrondi := 0 else Arrondi := r;
end;

function LimiteXY(P,Q: TFace) :  boolean;
// test les limites de projections 2D
// ==> si les boites englobantes ne se chevauchent pas --> renvoie true
var
  maxPx, maxPy, minPx, minPy,maxQx, maxQy, minQx, minQy, i : integer;
begin
  // calule min et max x et y de P
  maxPx := P[0].x2d;
  minPx := P[0].x2d;
  maxPy := P[0].y2d;
  minPy := P[0].y2d;
  for i := 1 to length(P)-1 do
    begin
      if P[i].x2d > maxPx then maxPx := P[i].x2d;
      if P[i].x2d < minPx then minPx := P[i].x2d;
      if P[i].y2d > maxPy then maxPy := P[i].y2d;
      if P[i].y2d < minPy then minPy := P[i].y2d;
    end;
  // calule min et max x et y de Q
  maxQx := Q[0].x2d;
  minQx := maxQx;
  maxQy := Q[0].y2d;
  minQy := maxQy;
  for i := 1 to length(Q)-1 do
    begin
      if Q[i].x2d > maxQx then maxQx := Q[i].x2d;
      if Q[i].x2d < minQx then minQx := Q[i].x2d;
      if Q[i].y2d > maxQy then maxQy := Q[i].y2d;
      if Q[i].y2d < minQy then minQy := Q[i].y2d;
    end;
  // teste le chevauchement
    if (maxPx < minQx) or
    (maxQx < minPx) or
    (maxPy < minQy) or
    (maxQy < minPy) then LimiteXY := true  // disjoints
    else LimiteXY := false;    // chevauchement
end;

function ZBufferIntersect(P,Q: TFace; cx,cy : integer) : boolean;
var
  r, rP, rQ : Trect;
  maxPx, maxPy, minPx, minPy,maxQx, maxQy, minQx, minQy, i : integer;
  zP, zQ : real;
  centre : TPoint;
  x1,y1,z1,x2,y2,z2,x3,y3,z3 : real;
  Pa,Pb,Pc,Pd,Qa,Qb,Qc,Qd : real;
begin
  if LimiteXY(P,Q)  then
  begin
    ZBufferIntersect := true;
    Exit;
  end;
  // calule min et max x et y de P
  maxPx := P[0].x2d;
  minPx := maxPx;
  maxPy := P[0].y2d;
  minPy := maxPy;
  for i := 1 to length(P)-1 do
    begin
      if P[i].x2d > maxPx then maxPx := P[i].x2d;
      if P[i].x2d < minPx then minPx := P[i].x2d;
      if P[i].y2d > maxPy then maxPy := P[i].y2d;
      if P[i].y2d < minPy then minPy := P[i].y2d;
    end;
  // calule min et max x et y de Q
  maxQx := Q[0].x2d;
  minQx := maxQx;
  maxQy := Q[0].y2d;
  minQy := maxQy;
  for i := 1 to length(Q)-1 do
    begin
      if Q[i].x2d > maxQx then maxQx := Q[i].x2d;
      if Q[i].x2d < minQx then minQx := Q[i].x2d;
      if Q[i].y2d > maxQy then maxQy := Q[i].y2d;
      if Q[i].y2d < minQy then minQy := Q[i].y2d;
    end;

  // interesection des boites limites de P et Q
  rP.Left := minPx; rP.Right := maxPx; rP.Top := minPy; rP.Bottom := maxPy;
  rQ.Left := minQx; rQ.Right := maxQx; rQ.Top := minQy; rQ.Bottom := maxQy;
  IntersectRect(r,rP,rQ);
  // centre de l'intersection
  centre.X := r.Left + (r.Right - r.Left) div 2;
  centre.Y := r.Top + (r.Bottom - r.Top) div 2;

  x1 := P[0].xo; y1 := P[0].yo; z1 := P[0].zo;
  x2 := P[1].xo; y2 := P[1].yo; z2 := P[1].zo;
  x3 := P[2].xo; y3 := P[2].yo; z3 := P[2].zo;
  Pa := Arrondi(y1 * (z2 -z3) + y2 * (z3 - z1) + y3 * (z1 - z2));
  Pb := Arrondi(- x1 * (z2-z3) + x2 * (z1-z3) - x3 * (z1-z2));
  Pc := Arrondi(x1 * (y2-y3) - x2 * (y1-y3) + x3 * (y1-y2));
  Pd := Arrondi(- x1 * (y2*z3 - y3*z2) + x2 * (y1*z3 -y3*z1) - x3 * (y1*z2 - y2*z1));

  x1 := Q[0].xo; y1 := Q[0].yo; z1 := Q[0].zo;
  x2 := Q[1].xo; y2 := Q[1].yo; z2 := Q[1].zo;
  x3 := Q[2].xo; y3 := Q[2].yo; z3 := Q[2].zo;
  Qa := Arrondi(y1 * (z2 -z3) + y2 * (z3 - z1) + y3 * (z1 - z2));
  Qb := Arrondi(- x1 * (z2-z3) + x2 * (z1-z3) - x3 * (z1-z2));
  Qc := Arrondi(x1 * (y2-y3) - x2 * (y1-y3) + x3 * (y1-y2));
  Qd := Arrondi(- x1 * (y2*z3 - y3*z2) + x2 * (y1*z3 -y3*z1) - x3 * (y1*z2 - y2*z1));

  zP := Arrondi(- Pd / (Pa*(centre.X-cx)/zoom + Pb * (cy-centre.Y)+ Pc)/zoom);
  zQ := Arrondi(- Qd / (Qa*(centre.X-cx)/zoom + Qb * (cy-centre.Y)+ Qc)/zoom);
  if zP >= zQ then ZBufferIntersect := true else ZBufferIntersect := false;
end;


function Devant(P,Q : TFace; angle_h, angle_v: integer) : integer;
// tous les point de Q sont-ils devant le plan P ?
var
   Ap,Bp,Cp,Dp : real;
   i,positif, negatif,cotepoint : integer;
   position, tempo, xobs, yobs, zobs : real;
begin
     Ap := P[0].A; Bp := P[0].B; Cp := P[0].C; Dp := P[0].D;

     // positon observateur dansle syst�me world;
     xobs := Arrondi(distance*cosinus[angle_h]*cosinus[angle_v]);
     yobs := Arrondi(distance*sinus[angle_h]*cosinus[angle_v]);
     zobs := Arrondi(distance*sinus[angle_v]);

     // De quel cot� du plan P sont les points de la face Q ?
     positif := 0; negatif := 0; cotepoint := 0;
     for i := 0 to length(Q)-1 do
     begin
          tempo := Arrondi(Ap*Q[i].x + Bp*Q[i].y + Cp*Q[i].z + Dp);
          if tempo > 0 then  inc(positif);
          if tempo < 0 then  inc(negatif);
          // on ignore le cas ou tempo = 0
          // ==> ce point de Q est dans plan P
          // ==> neutralit�
     end;

     // points de Q de chaque cot� de P
     if (positif > 0) and (negatif > 0) then
     begin
        // on ne peut rien d�terminer. Q "� cheval" sur le plan Pbegin
        Devant := 0;
        //debug('fonction Devant : P � cheval sur le plan Q');
        Exit;
     end
     // tous les point de Q sont du m�me cot� du plan P
     else
     begin
       if positif > 0 then cotepoint := 1;
       if negatif > 0 then cotepoint := -1;
       // dans quel demi espace est l'observateur ?
       position := signe(Arrondi(Ap*xobs + Bp*yobs + Cp*zobs + Dp));
       if position = cotepoint then  // Q du m�me cot� que l'observateur ?
         begin
              Devant := 1;   // oui
              Exit;
         end
         else  // Q est derri�re P ==> permutation
         begin
              Devant := -1;
              Exit;
         end;
     end;
end;

function Derriere(P,Q : TFace; angle_h, angle_v: integer) : integer;
// tous les point de P sont-ils derri�re le plan Q ?
var
   Aq,Bq,Cq,Dq : real;
   i,positif, negatif,cotepoint : integer;
   position, tempo, xobs, yobs, zobs : real;
begin
     Aq := Q[0].A; Bq := Q[0].B; Cq := Q[0].C; Dq := Q[0].D;

     // positon observateur dansle syst�me world;
     xobs := Arrondi(distance*cosinus[angle_h]*cosinus[angle_v]);
     yobs := Arrondi(distance*sinus[angle_h]*cosinus[angle_v]);
     zobs := Arrondi(distance*sinus[angle_v]);


     // De quel cot� du plan Q sont les points de la face P ?
     positif := 0; negatif := 0; cotepoint := 0;
     for i := 0 to length(P)-1 do
     begin
          tempo := Arrondi(Aq*P[i].x + Bq*P[i].y + Cq*P[i].z + Dq);
          if tempo > 0 then  inc(positif);
          if tempo < 0 then  inc(negatif);
          // on ignore le cas ou tempo = 0
          // ==> ce point de Q est dans plan P
          // ==> neutralit�
     end;

     // points de Q de chaque cot� de P
     if (positif > 0) and (negatif > 0) then
     begin
        // on ne peut rien d�terminer. Q "� cheval" sur le plan P
        Derriere := 0;
        //debug('fonction Derriere : Q � cheval sur le plan P');
        Exit;
     end
     else
     // tous les point de P sont du m�me cot� du plan Q
     begin
       if positif > 0 then cotepoint := 1;
       if negatif > 0 then cotepoint := -1;
       // dans quel demi espace est l'observateur ?
       position := signe(Arrondi(Aq*xobs + Bq*yobs + Cq*zobs + Dq));
       // les points de P sont du m�me cot� que l'observateur ?
       if position <> cotepoint then
       // oui
       Derriere := 1
       else
       // non permutation
       Derriere := -1;
     end;
end;

function LimiteZ(P,Q: TFace) : integer;
var
  i : integer;
  minZP, maxZP, maxZQ, minZQ : real;
begin
  minZP := P[0].zo;
  maxZP := P[0].zo;
  for i := 1 to length(P)-1 do
  begin
    if P[i].zo < minZP then minZP := P[i].zo;
    if P[i].zo > maxZP then maxZP := P[i].zo;
  end;
  minZQ := Q[0].zo;
  maxZQ := Q[0].zo;
  for i := 1 to length(Q)-1 do
  begin
    if Q[i].zo < minZQ then minZQ := Q[i].zo;
    if Q[i].zo > maxZQ then maxZQ := Q[i].zo;
  end;
  // teste les maxi-mini
  if minZP > maxZQ then LimiteZ := 1  // P plus loin que Q
  else
  if minZQ > maxZP then LimiteZ := -1 // Q plus loin que P
  else
  LimiteZ := 0; // ind�termin� : chevauchement en Z
end;

function LimiteRegion(P,Q: TFace) : boolean;
var
  RP, RQ, R : HRGN;
  ptabP, ptabQ : array of TPoint;
  i : integer;
begin
  // pr�paration des tableaux de points
  SetLength(ptabP,length(P));
  for i  := 0 to Length(P)-1 do
  ptabP[i] := point(P[i].x2d,P[i].y2d);
  SetLength(ptabQ,length(Q));
  for i  := 0 to Length(Q)-1 do
  ptabQ[i] := point(Q[i].x2d,Q[i].y2d);
  // creation des r�gions
  RP := CreatePolygonRgn(ptabP[0],length(P),WINDING);
  RQ := CreatePolygonRgn(ptabQ[0],length(Q),WINDING);
  R := CreatePolygonRgn(ptabQ[0],length(Q),WINDING); // pour init. R
  // intersection
  i := CombineRgn(R, RP, RQ, RGN_AND);
     {case i of
      NULLREGION : debug('combinaison = null region') ;
      ERROR : debug('combinaison = error') ;
      SIMPLEREGION : debug('combinaison = simple') ;
      COMPLEXREGION : debug('combinaison = complexe') ;
     end; }
  if i = NULLREGION then LimiteRegion := true
  else LimiteRegion := false;
  DeleteObject(RP);
  DeleteObject(RQ);
  DeleteObject(R);
end;

function Eloignement(P,Q: TFace) : boolean;
// mesure l'�loignemetLimiteRegion du centre des 2 faces (= moyenne des zo)
// renvoie true si moyenne de P > moyenne de Q
var
    zmoyenP, zmoyenQ : real;
    i : integer;
begin
  zmoyenP := 0;
  for i := 0 to length(P)-1 do zmoyenP := zmoyenP + P[i].zo;
  zmoyenP := zmoyenP / length(P);

  zmoyenQ := 0;
  for i := 0 to length(Q)-1 do zmoyenQ := zmoyenQ + Q[i].zo;
  zmoyenQ := zmoyenQ / length(Q);

  if zmoyenP > zmoyenQ then Eloignement := true
  else Eloignement := false;
end;

procedure Ajuster;
var
  i,j : integer;
  xmin,xmax,ymin,ymax,zmin, zmax,xdelta,ydelta,zdelta : real;
  ratio, K : real;
begin
  K := 120;
  xmin := obj[0][0].x;
  xmax := obj[0][0].x;
  ymin := obj[0][0].y;
  ymax := obj[0][0].y;
  zmin := obj[0][0].z;
  zmax := obj[0][0].z;

  for i := 0 to length(obj)-1 do
  for j := 0 to length(obj[i])-1 do
    begin
      if xmin < obj[i][j].x then xmin := obj[i][j].x;
      if xmax > obj[i][j].x then xmax := obj[i][j].x;
      if ymin < obj[i][j].y then ymin := obj[i][j].y;
      if ymax > obj[i][j].y then ymax := obj[i][j].y;
      if zmin < obj[i][j].z then zmin := obj[i][j].z;
      if zmax > obj[i][j].z then zmax := obj[i][j].z;
    end;
  xdelta := (xmax+xmin)/2;
  ydelta := (ymax+ymin)/2;
  zdelta := (zmax+zmin)/2;

  if xmax-xmin > ymax-ymin then ratio := xmax-xmin else ratio := ymax-ymin;
  if zmax-zmin > ratio then ratio := zmax-zmin;
  ratio := abs(K / ratio);



  for i := 0 to length(obj)-1 do
  for j := 0 to length(obj[i])-1 do
    begin
      obj[i][j].x := ratio * (obj[i][j].x - xdelta);
      obj[i][j].y := ratio * (obj[i][j].y - ydelta);
      obj[i][j].z := ratio * (obj[i][j].z - zdelta);
    end;
end;


procedure AfficheFace(face : integer);
var
  i : integer;
  f : array of TPoint;
begin
      setlength(f,length(obj[face]));
      for i := 0 to length(obj[face])-1 do
        begin
          f[i].X := obj[face][i].x2d;
          f[i].Y := obj[face][i].y2d;
        end;
      with Form1.PaintBox1.Canvas do
      begin
        Brush.Color := clGreen;
        Pen.Color := clLtGray;
        Polygon(f);
      end;
end;

procedure TestComplet(angle_h,angle_v,centrex,centrey : integer);
// tri des face suivant leurposition dans l'espace
// par raport � l'observateur
// on travaille dans le syst�me World.
type
  binome = array[1..2] of integer;
var
  curface, i, j,nbcycle,nbpermut : integer;
  tmpface : TFace;
  x1,y1,z1,x2,y2,z2,x3,y3,z3 : real;
  permut : boolean;
  P,Q : TFace;
  bug : array of binome;

  procedure DoPermut;
  var
    a,b,l : integer;
    trouve : boolean;
  begin
    if P[0].ID < Q[0].ID then
    begin
      a := P[0].ID;
      b := Q[0].ID;
    end;
    for l := 0 to nbpermut-1 do
    if (bug[l][1] = a) and (bug[l][2] = b)  then trouve := true;
    if trouve then Exit
    else
    begin
    inc(nbpermut);
    setlength(bug,nbpermut);
    if P[0].ID < Q[0].ID then
    begin
      bug[nbpermut-1][1]:= P[0].ID;
      bug[nbpermut-1][2]:= Q[0].ID;
    end
    else
    begin
      bug[nbpermut-1][1]:= Q[0].ID;
      bug[nbpermut-1][2]:= P[0].ID;
    end;
    // debug(IntToStr(P[0].ID)+ ' '+IntToStr(Q[0].ID));
    permut := true;
    tmpface := obj[i];
    obj[i] := obj[j];
    obj[j] := tmpface;
    debug('permut');
    end;
  end;

begin
  // calcul de l'�quation de plan pour chaque face
  // les donn�es sont stock�es dans le 1er point de chaque face (obj[curface][0])
  for curface := 0 to length(obj)-1 do
  begin
     x1 := obj[curface][0].x; y1 := obj[curface][0].y; z1 := obj[curface][0].z;
     x2 := obj[curface][1].x; y2 := obj[curface][1].y; z2 := obj[curface][1].z;
     x3 := obj[curface][2].x; y3 := obj[curface][2].y; z3 := obj[curface][2].z;

     obj[curface][0].A := Arrondi(y1 * (z2 -z3) + y2 * (z3 - z1) + y3 * (z1 - z2));
     obj[curface][0].B := Arrondi(- x1 * (z2-z3) + x2 * (z1-z3) - x3 * (z1-z2));
     obj[curface][0].C := Arrondi(x1 * (y2-y3) - x2 * (y1-y3) + x3 * (y1-y2));
     obj[curface][0].D := Arrondi(- x1 * (y2*z3 - y3*z2) + x2 * (y1*z3 -y3*z1) - x3 * (y1*z2 - y2*z1));
  end;

  // tri
  nbcycle := 0;
  setlength(bug,0);
  nbpermut := 0;

  TriFacesSimple;
        permut := false;
        for i := 0 to length(obj)-2 do
        for j := i+1 to length(obj)-1 do
        begin
             inc(nbcycle);
             P := obj[i];
             Q := obj[j];

             // test les limites de projections 2D
             if LimiteXY(P,Q) then Continue; // projections disjointes

             //teste les limites de  profondeurs (syst�me observateur)
             if LimiteZ(P,Q) = 1 then Continue // P "derri�re" Q
             else
             if LimiteZ(P,Q) = -1 then // Q "derri�re" P
             begin
                  DoPermut;
                  Continue;

                  debug('limiteZ');
             end;

             // Teest des r�gions
             if LimiteRegion(P,Q) then Continue;


             // tous les points de Q devant P ?
             if Devant(P,Q,angle_h,angle_v) = 1 then Continue;

             // tous les points de P derri�re le plan Q ?
             if Derriere(P,Q,angle_h,angle_v) = 1 then Continue;

             // tous les points de Q derri�re P ?
             // ou tous les points de P devant Q ?

             if Derriere(Q,P,angle_h,angle_v) = 1 then
             begin
                  DoPermut;
                  Continue;
             end;

             if Devant(Q,P,angle_h,angle_v) = 1 then
             begin
                  DoPermut;
                  Continue;
             end;


             // moyenne z de P < moyenne z de Q ?
             {if Eloignement(P,Q)= false then
             begin
                  // permutation
                  permut := true;
                  tmpface := obj[curface];
                  obj[curface] := obj[curface+1];
                  obj[curface+1] := tmpface;
                  Continue;
             end;  }

              // ne fonctionne pas !
             {if ZBufferIntersect(P,Q,centrex,centrey) = false then
             begin
                  // permutation
                  permut := true;
                  tmpface := obj[curface];
                  obj[curface] := obj[curface+1];
                  obj[curface+1] := tmpface;
                  debug('ZBuffer : permutation');
                  Continue;
             end; }
             debug('indertermin�');
        end;
  //until (permut = false);
end;

// Affichage systeme de R�f�rence
procedure Reference(angle_h,angle_v,centrex,centrey : integer);
var
  p : array of Tpt;
  i : integer;
begin
  setlength(p,4);
  with p[0] do
  begin
       x := 0; y := 0; z := 0;
  end;
  with p[1] do
  begin
       x := 100; y := 0; z := 0;
  end;
  with p[2] do
  begin
       x := 0; y := 100; z := 0;
  end;
  with p[3] do
  begin
       x := 0; y := 0; z := 100;
  end;
  // calcul du syst�me de r�f�rence
  for i := 0 to 3 do //pour chaque points
  CalculPoint(p[i],angle_h,angle_v,centrex,centrey);

  //affichage syst�me de r�f�rence
  with TmpBmp.Canvas do
     begin
          Pen.Width := 2;
          // x
          Pen.Color := clRed;
          Moveto(p[0].X2d,p[0].Y2d);
          LineTo(p[1].X2d,p[1].Y2d);
          // y
          Pen.Color := clGreen;
          Moveto(p[0].X2d,p[0].Y2d);
          LineTo(p[2].X2d,p[2].Y2d);
          // z
          Pen.Color := clBlue;
          Moveto(p[0].X2d,p[0].Y2d);
          LineTo(p[3].X2d,p[3].Y2d);
   end;
end;

procedure TForm1.btn_AffichageClick(Sender: TObject);
var
i,j : integer;
angle_h, angle_v: integer;
f : array of TPoint;
centrex, centrey : integer;
r : TRect;

begin
  // init.
  TmpBmp := TBitmap.Create;
  TmpBmp.Width := PaintBox1.Width;
  TmpBmp.Height := PaintBox1.Height;
  TmpBmp.Canvas.Lock;

  distance := StrToInt (edt_Distance.Text);
  zoom := StrToInt (edt_Zoom.Text);
  centrex := PaintBox1.Width div 2;
  centrey := PaintBox1.Height div 2;
  angle_h := scb_h.Position  ;
  if angle_h<0 then angle_h := 360 + angle_h;
  angle_v := scb_v.Position  ;
  if angle_v <0 then angle_v := 360 + angle_v;

  // fond noir
  r.Left := 0; r.Top := 0;
  r.Right := PaintBox1.Width;
  r.Bottom := PaintBox1.Height;
  with TmpBmp.Canvas do
     begin
          Brush.Color := clBlack ;
          FillRect(r);
          Pen.Width := 2;
     end;

   // Tri des faces !
   for i := 0 to length(obj)-1 do
   for j := 0 to length(obj[i])-1 do CalculPoint(obj[i][j],angle_h,angle_v,centrex,centrey);


   //TriFacesSimple;
   TestComplet(angle_h,angle_v,centrex,centrey);

   //  Affiche les FACES !!!
   for i := 0 to length(obj)-1 do
    begin
      setlength(f,length(obj[i]));
      for j := 0 to length(obj[i])-1 do
        begin
          f[j].X := obj[i][j].x2d;
          f[j].Y := obj[i][j].y2d;
        end;
      with TmpBmp.Canvas do
      begin
        Brush.Color := clWhite ;
        Pen.Color := clLtGray;
        Polygon(f);
      end;
    end;
    // Affichage du syst�me de R�f�rence
    if chk_Repere.Checked then Reference(angle_h,angle_v,centrex,centrey);
    // affichage de la bitmap dans laquelleon a dessin�
    Form1.PaintBox1.Canvas.Draw(0,0,TmpBmp);
    TmpBmp.Canvas.Unlock;
    TmpBmp.Destroy;
end;

procedure TForm1.btn_ChargerClick(Sender: TObject);
var
  filin : textfile;
  s : string;
  sl : TStringList;
  i, nbpermut : integer;
begin
  nbsom := 0;
  nbface := 0;
  if OpenDialog1.Execute then
  begin
    assignFile(filin, OpenDialog1.FileName);
    reset(filin);
  end
  else Exit;
  // entete = sommets
  // lit jusqu'� ligne "sommets" (normalement c'est la 1ere ligne
  // mais pourqoi pas avoir un commentaire avant
    repeat
      readln(filin,s);
      s := LowerCase(trim(s));
    until (pos('sommets',s)=1) or (eof(filin));
    // si on atteint la fin du fichier sas lire "sommets" ==> erreur
    if eof(filin) then
    begin
      CloseFile(filin);
      Application.MessageBox('Fichier incorrect (pas de section "sommets")', 'ATTENTION', MB_ICONEXCLAMATION + MB_OK);
      Exit;
    end;
    // lecture des sommets
    repeat
      readln(filin,s);
      s := LowerCase(trim(s));
      if length(s) > 0 then
      begin
        if (pos('faces',s)<>1) then
        begin
          sl := TStringList.Create();
          sl.Text := StringReplace(s, ',', '.', [rfReplaceAll]);

          sl.Text := StringReplace(s, ' ', #13#10, [rfReplaceAll]);
          inc(nbsom);
          setlength(som,nbsom);
          som[nbsom-1].x := StrTOFloat(sl[0]);
          som[nbsom-1].y := StrTOFloat(sl[1]);
          som[nbsom-1].z := StrTOFloat(sl[2]);
          if sl.Count <> 3 then
          begin
            Application.MessageBox('Fichier incorrect (nb. de coordonn�es <> 3)', 'ATTENTION', MB_ICONEXCLAMATION + MB_OK);
            sl.Free();
            CloseFile(filin);
            Exit;
          end;
          sl.Free();
        end;
    end;
    until (pos('faces',s)=1) or (eof(filin));

    // test fin de fichier ==> erreur
    if eof(filin) then
    begin
      CloseFile(filin);
      Application.MessageBox('Fichier incorrect (pas de section "faces")', 'ATTENTION', MB_ICONEXCLAMATION + MB_OK);
      Exit;
    end;
    // lecture des faces
    repeat
      readln(filin,s);
      if length(s) > 0 then
      begin
        inc(nbface);
        setlength(obj,nbface);
        sl := TStringList.Create();
        sl.Text := StringReplace(s, ' ', #13#10, [rfReplaceAll]);
        setlength(obj[nbface-1],sl.Count);
        if sl.Count > 2 then
        begin
          for i := 0 to (sl.Count-1) do
          begin
            obj[nbface-1][i].x := som[StrToInt(sl[i])].x;
            obj[nbface-1][i].y := som[StrToInt(sl[i])].y;
            obj[nbface-1][i].z := som[StrToInt(sl[i])].z;
          end; // for
          obj[nbface-1][0].ID := nbface-1;
        end  // if sl.count ...
        else
        begin
          CloseFile(filin);
          sl.Free;
          Application.MessageBox('Fichier incorrect (nb de sommet incorrect)', 'ATTENTION', MB_ICONEXCLAMATION + MB_OK);
          Exit;
        end;
        sl.Free;
      end;  // length > 0
    until eof(filin);
    CloseFile(filin);
    if chk_Ajuster.Checked then Ajuster;
    PaintBox1.Invalidate;
end;

procedure TForm1.btn_AfficheFaceClick(Sender: TObject);
begin
  if (edt_FaceNum.Text<>'') and (StrToInt(edt_FaceNum.Text)< length(obj)) then
  begin
    AfficheFace(StrToInt(edt_FaceNum.Text));
  end;
end;

procedure TForm1.btn_IntersectClick(Sender: TObject);
var
  r, rP, rQ : Trect;
  maxPx, maxPy, minPx, minPy,maxQx, maxQy, minQx, minQy, i : integer;
  //zP, zQ : real;
  centre : TPoint;
  //x1,y1,z1,x2,y2,z2,x3,y3,z3 : real;
  //Pa,Pb,Pc,Pd,Qa,Qb,Qc,Qd : real;
  P,Q : TFace;
  tmpbr :Tbrush;
begin
  if length(obj)<2 then Exit;
  if (StrToInt(edt_intersect1.Text)> length(obj)-1)
  or (StrToInt(edt_intersect2.Text)> length(obj)-1) then Exit;

  P := obj[StrToInt(edt_intersect1.Text)]; Q := obj[StrToInt(edt_intersect2.Text)];
  // calule min et max x et y de P
  maxPx := P[0].x2d;
  minPx := maxPx;
  maxPy := P[0].y2d;
  minPy := maxPy;
  for i := 1 to length(P)-1 do
    begin
      if P[i].x2d > maxPx then maxPx := P[i].x2d;
      if P[i].x2d < minPx then minPx := P[i].x2d;
      if P[i].y2d > maxPy then maxPy := P[i].y2d;
      if P[i].y2d < minPy then minPy := P[i].y2d;
    end;
  // calule min et max x et y de Q
  maxQx := Q[0].x2d;
  minQx := maxQx;
  maxQy := Q[0].y2d;
  minQy := maxQy;
  for i := 1 to length(Q)-1 do
    begin
      if Q[i].x2d > maxQx then maxQx := Q[i].x2d;
      if Q[i].x2d < minQx then minQx := Q[i].x2d;
      if Q[i].y2d > maxQy then maxQy := Q[i].y2d;
      if Q[i].y2d < minQy then minQy := Q[i].y2d;
    end;

  // interesection des boites limites de P et Q
  rP.Left := minPx; rP.Right := maxPx; rP.Top := minPy; rP.Bottom := maxPy;
  rQ.Left := minQx; rQ.Right := maxQx; rQ.Top := minQy; rQ.Bottom := maxQy;
  IntersectRect(r,rP,rQ);
  tmpbr := PaintBox1.Canvas.Brush;
  //
  AfficheFace(StrToInt(edt_intersect1.Text));
  AfficheFace(StrToInt(edt_intersect2.Text));
  debug('Devant(p,q) = ' + IntToStr(Devant(P,Q,scb_h.Position,scb_v.Position)));
  debug('Devant(q,p) = ' + IntToStr(Devant(Q,P,scb_h.Position,scb_v.Position)));
  debug('Derriere(p,q) = ' + IntToStr(Derriere(P,Q,scb_h.Position,scb_v.Position)));
  debug('Derriere(q,p) = ' + IntToStr(Derriere(Q,P,scb_h.Position,scb_v.Position)));

  PaintBox1.Canvas.Brush.Color := clRed;
  PaintBox1.Canvas.FrameRect(r);

  LimiteRegion(P,Q);


  PaintBox1.Canvas.Brush := tmpbr;

end;

procedure TForm1.DoChangeAngle(Sender: TObject);
begin
    Label1.Caption := IntToStr(scb_h.Position);
    Label2.Caption := IntToStr(scb_v.Position);
    PaintBox1.Invalidate;
end;

procedure TForm1.DoCreate(Sender: TObject);
var
  i : integer;
begin
     DoubleBuffered := True; // pour �viter le flicker

     Label1.Caption := IntToStr(scb_h.Position);
     Label2.Caption := IntToStr(scb_v.Position);
     Zoom := StrToInt(edt_Zoom.Text);
     distance := StrToInt(edt_Distance.Text);

    // pr�calcul des sin et cos.
     for i := 0 To 359 do begin
        sinus[i] := Sin(i * (PI / 180));
        cosinus[i] := Cos(i * (PI / 180));
     end;
end;

end.
