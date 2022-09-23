unit UPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ComCtrls, StdCtrls, inifiles, DateUtils,
  IBServices, CheckLst, ShellAPI, Menus, ShlObj, ActiveX, ComObj, Registry,
  AppEvnts, Gauges, DB, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP,  FileCtrl,
  System.ImageList, Vcl.ImgList;

const WM_TRAYICON=WM_USER+1;

const
  SELDIRHELP = 1000;

type
  THorario = packed record
    Hora: TTime;
    Feito: Boolean;
    Agendado: Boolean;
  end;

  TFPrincipalBackup = class(TForm)
    reStatus: TRichEdit;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Timer: TTimer;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    eBase1: TEdit;
    eBase2: TEdit;
    eBase3: TEdit;
    eBase4: TEdit;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    eDirBackup1: TEdit;
    eDirBackup2: TEdit;
    eDirBackup3: TEdit;
    eDirBackup4: TEdit;
    GroupBox1: TGroupBox;
    clbSemana: TCheckListBox;
    clbHorarios: TCheckListBox;
    BitBtn2: TBitBtn;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    MostrarAplicao1: TMenuItem;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    Memo2: TMemo;
    BitBtn3: TBitBtn;
    Timerclose: TTimer;
    BitBtn4: TBitBtn;
    ApplicationEvents1: TApplicationEvents;
    GroupBox4: TGroupBox;
    Gauge1: TGauge;
    labelletra1: TLabel;
    Labelletra2: TLabel;
    Gauge2: TGauge;
    LabelLetra3: TLabel;
    Gauge3: TGauge;
    LabelLetra4: TLabel;
    Gauge4: TGauge;
    ZConnection1: TZConnection;
    ZQuery2: TZQuery;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    TrayIcon1: TTrayIcon;
    ImageList1: TImageList;
    IBBackupService1: TIBBackupService;
    procedure TimerTimer(Sender: TObject);
    procedure sbSairClick(Sender: TObject);
    PROCEDURE FAZ(CONST Abase, adir: STRING);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure carregacfg;
    procedure MostrarAplicao1Click(Sender: TObject);
    function PegaCampo(inTexto: string;inPos :integer;inSep :string;inTamanho :integer) : string ;
    function CriarAtalho(ANomeArquivo, AParametros, ADiretorioInicial,ANomedoAtalho, APastaDoAtalho: string): boolean;
    procedure BitBtn1Click(Sender: TObject);
    procedure compactaarquivozip(const origem: string; Destino: string);
    procedure restauraarquivozip(const origem: string; Destino: string);
    procedure atualizadrivers;
    function TEMNALISTA(const ALISTA: TStringList; ATEXTO: STRING): boolean;
    function DriveOk(Drive: Char): boolean;
    PROCEDURE loga_help(const amsg: string);
    PROCEDURE loga_ult_backup;
    function SysComputerName: string;
    procedure BitBtn3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimercloseTimer(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
  private
    Horarios: array[0..23] of THorario;
    function DoBackup: Boolean;
    procedure AddStatusLine(S: string; Cor: TColor = clWindowText; Tamanho: byte = 8);



  public

  end;

var
  FPrincipalBackup: TFPrincipalBackup;
  nomearquivocfg: string;
  listadedriversok: tstringlist;
  listadedriverserror: tstringlist;
  textochamado: tstringlist;
  dir: string;

const
  Dia: array[1..7] of string = ('Domingo', 'Segunda', 'Ter�a', 'Quarta', 'Quinta', 'Sexta', 'S�bado');

implementation

uses ConfigurarBackup, uzipMain, restore;

{$R *.dfm}

procedure TFPrincipalBackup.TimercloseTimer(Sender: TObject);
begin
  if fileexists('c:\conectivasoft\close_backup.con') then
  begin
    timerclose.enabled:=false;
    deletefile('c:\conectivasoft\close_backup.con');
    Self.Visible:= True;
    application.terminate;
  end;
end;

procedure TFPrincipalBackup.TimerTimer(Sender: TObject);
var
  i: integer;
  FileName: string;
  sr: TSearchRec;
begin
  { ---------------------------------------------------
    IMPLEMENTADO PARA VERIFICAR SE HOUVE O BKP NAQUELE DIA
    ATUALMENTE BUSCANDO POR DATA, PRECISA AJUSTAR PARA BUSCAR
    PELAS HORAS PROGRAMADAS
    POR: MARCELO MENDES
    BLOCO DE C�DIGO ORIGINAL DO ONTIMER:
    for i := low(Horarios) to High(Horarios) do
    begin
      if (Horarios[i].Agendado) and (not Horarios[i].Feito) and (Horarios[i].Hora = HourOf(now)) then
        begin
          Timer.Enabled := false;
          Horarios[i].Feito := DoBackup;
          Timer.Enabled := true;
          Break;
        end;
    end;

 }
 IF FindFirst('C:\CONECTIVASOFT\BACKUP_T\'+Filename+'*.gbk.zip', faAnyFile, sr) = 0 THEN
  BEGIN
//    ShowMessage('BACKUP DE HOJE J� REALIZADO');
//    FindClose(sr);
//    Abort;
  END
 ELSE
  BEGIN
  for i := low(Horarios) to High(Horarios) do
    begin
      if (Horarios[i].Agendado) and (not Horarios[i].Feito) and (Horarios[i].Hora = HourOf(now)) then
        begin
          Timer.Enabled := false;
          Horarios[i].Feito := DoBackup;
          Timer.Enabled := true;
          Break;
        end;
    end;
  END;
end;
procedure TFPrincipalBackup.TrayIcon1Click(Sender: TObject);
begin
  TrayIcon1.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();

end;

procedure TFPrincipalBackup.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
    restatus.Lines.INSERT(0,E.Message);

end;

procedure TFPrincipalBackup.ApplicationEvents1Minimize(Sender: TObject);
begin
  self.Hide();
  self.WindowState := wsMinimized;
  trayIcon1.Visible := true;
  TrayIcon1.Animate := True;
  TrayIcon1.ShowBalloonHint;
end;

procedure TFPrincipalBackup.BitBtn1Click(Sender: TObject);
begin
  if  dobackup then loga_ult_backup;
end;

procedure TFPrincipalBackup.BitBtn2Click(Sender: TObject);
begin
  if not assigned(FrmConfigurarBackup) then FrmConfigurarBackup:=tFrmConfigurarBackup.create(self);
  FrmConfigurarBackup.showmodal;

  atualizadrivers;
end;

procedure TFPrincipalBackup.BitBtn3Click(Sender: TObject);
begin
  application.terminate;
end;

procedure TFPrincipalBackup.BitBtn4Click(Sender: TObject);
begin
  if not assigned(frmrestore) then frmrestore:=tfrmrestore.Create(application);
  frmrestore.ShowModal;
  FreeAndNil(frmrestore);
end;

procedure TFPrincipalBackup.BitBtn5Click(Sender: TObject);
begin
  dir :='C:\';
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt],SELDIRHELP) then
  FAZ(eBase1.text,DIR);

end;

procedure TFPrincipalBackup.BitBtn6Click(Sender: TObject);
begin
  dir :='C:\';
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt],SELDIRHELP) then
  FAZ(eBase2.text,DIR);

end;

procedure TFPrincipalBackup.BitBtn7Click(Sender: TObject);
begin
  dir :='C:\';
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt],SELDIRHELP) then
  FAZ(eBase3.text,DIR);

end;

procedure TFPrincipalBackup.BitBtn8Click(Sender: TObject);
begin
  dir :='C:\';
  if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt],SELDIRHELP) then
  FAZ(eBase4.text,DIR);

end;

function TFPrincipalBackup.DoBackup: Boolean;
var
  reg: Tinifile;

begin
  Result := true;

  reg := tinifile.Create(nomearquivocfg);
  restatus.Lines.INSERT(0,'ARQUIVO DE REGISTRO CRIADO.');


  try
      begin
        try
          if directoryexists(reg.ReadString('Agendamento','BackupDir1','C:\CONECTIVASOFT\BACKUP_T')) = false then
          ForceDirectories(reg.ReadString('Agendamento','BackupDir1','C:\CONECTIVASOFT\BACKUP_T'));

          if (directoryexists(reg.ReadString('Agendamento','BackupDir2','C:\CONECTIVASOFT\BACKUP_T')) = false) and (reg.ReadString('Agendamento','BackupDir2','C:\CONECTIVASOFT\BACKUP_T') <> '') then
          ForceDirectories(reg.ReadString('Agendamento','BackupDir2','C:\CONECTIVASOFT\BACKUP_T'));

          if (directoryexists(reg.ReadString('Agendamento','BackupDir3','C:\CONECTIVASOFT\BACKUP_T')) = false) and (reg.ReadString('Agendamento','BackupDir3','C:\CONECTIVASOFT\BACKUP_T') <> '') then
          ForceDirectories(reg.ReadString('Agendamento','BackupDir3','C:\CONECTIVASOFT\BACKUP_T'));

          if (directoryexists(reg.ReadString('Agendamento','BackupDir4','C:\CONECTIVASOFT\BACKUP_T')) = false) and (reg.ReadString('Agendamento','BackupDir4','C:\CONECTIVASOFT\BACKUP_T') <> '') then
          ForceDirectories(reg.ReadString('Agendamento','BackupDir4','C:\CONECTIVASOFT\BACKUP_T'));

          restatus.Lines.INSERT(0,'ENVIANDO COMANDO PARA BACKUP DA BASE 1: '+reg.ReadString('Agendamento','Base1','C:\CONECTIVASOFT\DADOS\X.FDB')+' GRAVANDO EM: '+reg.ReadString('Agendamento','BackupDir1','C:\CONECTIVASOFT\BACKUP_T'));
          APPLICATION.ProcessMessages;

          FAZ(reg.ReadString('Agendamento','Base1','C:\CONECTIVASOFT\DADOS\X.FDB'),reg.ReadString('Agendamento','BackupDir1','C:\CONECTIVASOFT\BACKUP_T'));

          if eBase2.Text <> '' then
          FAZ(reg.ReadString('Agendamento','Base2',''),reg.ReadString('Agendamento','BackupDir2',''));

          if eBase3.Text <> '' then
          FAZ(reg.ReadString('Agendamento','Base3',''),reg.ReadString('Agendamento','BackupDir3',''));

          if eBase4.Text <> '' then
          FAZ(reg.ReadString('Agendamento','Base4',''),reg.ReadString('Agendamento','BackupDir4',''));


          REG.writestring('GENERAL','DATA',DATETOSTR(DATE));

        except

          Result := false;
        end;
      end;
  finally
    timer.enabled:=true;
  end;
end;

procedure TFPrincipalBackup.AddStatusLine(S: string; Cor: TColor; Tamanho: byte);
begin
  reStatus.SelAttributes.Color := Cor;
  reStatus.SelAttributes.Size := Tamanho;
  restatus.Lines.INSERT(0,S);
end;

procedure TFPrincipalBackup.sbSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFPrincipalBackup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if BitBtn3.Enabled then //ESSE BOTAO S� ESTA ATIVADO SE O SISTEMA DE BACKUP ESTIVER EXECUTANDO FORA DO CONECTIVASOFT.EXE
  BEGIN
//    self.Visible:=false;
      self.Hide();
  self.WindowState := wsMinimized;
  trayIcon1.Visible := true;
  TrayIcon1.Animate := True;
  TrayIcon1.ShowBalloonHint;

    action:=canone;
  END;
end;

procedure TFPrincipalBackup.FormCreate(Sender: TObject);
var
  i: integer;
  ashow: boolean;
  FileName: string;
  sr: TSearchRec;
begin
  //if fileexists('C:\CONECTIVASOFT\CFG_BACKUP.INI') then
  listadedriversok:=TStringList.Create;
  listadedriverserror:=TStringList.Create;
  textochamado:=TStringList.Create;
  nomearquivocfg:='C:\CONECTIVASOFT\CFG_BACKUP.INI';
//  else
//  BEGIN
//    nomearquivocfg:=ExtractFileDir(APPLICATION.ExeName)+'\AutoBackup.INI';
//  END;

  restatus.Lines.INSERT(0,'NOME DO ARQUIVO DE CONFIGURA��O: '+nomearquivocfg);

  carregacfg;

  atualizadrivers;

  for i := 0 to ParamCount do
  begin
    if ParamStr(i) = '/Show' then
    ashow:=true;
  end;

  if ashow = false then
  begin
    self.Visible:=false;
  self.Hide();
  self.WindowState := wsMinimized;
  trayIcon1.Visible := true;
  TrayIcon1.Animate := True;
  TrayIcon1.ShowBalloonHint;

    end;

  //implementado apenas para efeitos de teste de busca do arquivo do bkp
 { Filename:= FormatDateTime('yyyymmdd', now);

  if FindFirst('C:\CONECTIVASOFT\BACKUP_T\'+Filename+'*.gbk.zip', faAnyFile, sr) = 0 then
    begin
    ShowMessage('BACKUP DE HOJE J� REALIZADO');
    FindClose(sr);
    Abort;
    end
  else ShowMessage('NENHUM BACKUP LOCALIZADO.');  }

end;

procedure TFPrincipalBackup.MostrarAplicao1Click(Sender: TObject);
begin
  Self.Visible:= True;
end;

PROCEDURE TFPrincipalBackup.FAZ(CONST Abase, adir: STRING);
var
adir1, adir2, adir3, adir4: string;
realdir1, REALDIR2, REALDIR3, REALDIR4: STRING;

BEGIN
  adir1:=PegaCampo(adir,1,';',200);
  adir2:=PegaCampo(adir,2,';',200);
  adir3:=PegaCampo(adir,3,';',200);
  adir4:=PegaCampo(adir,4,';',200);

  restatus.Lines.INSERT(0,'dir1 '+adir1);
  restatus.Lines.INSERT(0,'dir2 '+adir2);
  restatus.Lines.INSERT(0,'dir3 '+adir3);
  restatus.Lines.INSERT(0,'dir4 '+adir4);

  if fileexists(abase) then
  BEGIN
    //IBBackupService1.Params
    IBBackupService1.DatabaseName := ABASE;
    IBBackupService1.BackupFile.Clear;
    IBBackupService1.BackupFile.Add(ChangeFileExt(adir1 + '\' + FormatDateTime('yyyymmddnnhh', now), '.gbk'));

    if ADIR1 <> '' then
    begin
      forcedirectories(adir1);
      REALDIR1:=(ChangeFileExt(adir1 + '\' + FormatDateTime('yyyymmddnnhh', now), '.gbk'));
    end;

    if ADIR2 <> '' then
    begin
      forcedirectories(adir2);
      REALDIR2:=(ChangeFileExt(adir2 + '\' + FormatDateTime('yyyymmddnnhh', now), '.gbk'));
    end;

    if ADIR3 <> '' then
    begin
      forcedirectories(adir3);
      REALDIR3:=(ChangeFileExt(adir3 + '\' + FormatDateTime('yyyymmddnnhh', now), '.gbk'));
    end;

    if ADIR4 <> '' then
    begin
      forcedirectories(adir4);
      REALDIR4:=(ChangeFileExt(adir4 + '\' + FormatDateTime('yyyymmddnnhh', now), '.gbk'));
    end;

    IBBackupService1.Active := true;
    AddStatusLine(DATETOSTR(DATE)+' - '+Format(ABASE+' - '+ADIR1+' - Backup Iniciado �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clGreen);
    IBBackupService1.ServiceStart;

    Memo1.Lines.Clear;
    While not IBBackupService1.Eof do
    BEGIN
      Memo1.Lines.Add(IBBackupService1.GetNextLine);
      APPLICATION.PROCESSMESSAGES;
    END;

    IBBackupService1.Active := false;
    AddStatusLine(DATETOSTR(DATE)+' - '+ADIR1+' - '+Format('Backup Finalizado �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clGreen);
    AddStatusLine(DATETOSTR(DATE)+' - '+ADIR1+' - '+Format('Criado c�pia para: '+realdir1+'.ZIP'+' �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clGreen);

    compactaarquivozip(realdir1,realdir1+'.zip');
    deletefile(realdir1);

    if REALDIR2 <> '' then
    BEGIN
      CopyFile(pchar(realdir1+'.zip'),pchar(realdir2+'.zip'),false);
      AddStatusLine(DATETOSTR(DATE)+' - '+ADIR2+' - '+Format('Criado c�pia para: '+realdir2+'.ZIP'+' �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clGreen);
      //compactaarquivozip(realdir2,realdir2+'.zip');
      //deletefile(realdir2);
    END;
    if REALDIR3 <> '' then
    BEGIN
      CopyFile(pchar(realdir1+'.zip'),pchar(realdir3+'.zip'),false);
      AddStatusLine(DATETOSTR(DATE)+' - '+ADIR3+' - '+Format('Criado c�pia para: '+realdir3+'.ZIP'+' �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clGreen);
      //compactaarquivozip(realdir3,realdir3+'.zip');
      //deletefile(realdir3);
    END;
    if REALDIR4 <> '' then
    BEGIN
      CopyFile(pchar(realdir1+'.zip'),pchar(realdir4+'.zip'),false);
      AddStatusLine(DATETOSTR(DATE)+' - '+ADIR4+' - '+Format('Criado c�pia para: '+realdir4+'.ZIP'+' �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clGreen);
      //compactaarquivozip(realdir4,realdir4+'.zip');
      //deletefile(realdir4);
    END;
  END
  else
  AddStatusLine('Arquivo n�o encontrado: '+abase);

END;




procedure tFPrincipalBackup.carregacfg;
var
  reg: TINIFILE;
  DiaBackup: Boolean;
  i: integer;
begin
  reg := tinifile.Create(nomearquivocfg);
  try
      eBase1.Text := reg.ReadString('Agendamento','Base1','C:\CONECTIVASOFT\DADOS\X.FDB');
      eBase2.Text := reg.ReadString('Agendamento','Base2','');
      eBase3.Text := reg.ReadString('Agendamento','Base3','');
      eBase4.Text := reg.ReadString('Agendamento','Base4','');

      eDirBackup1.Text := reg.ReadString('Agendamento','BackupDir1','C:\CONECTIVASOFT\BACKUP_T');
      eDirBackup2.Text := reg.ReadString('Agendamento','BackupDir2','');
      eDirBackup3.Text := reg.ReadString('Agendamento','BackupDir3','');
      eDirBackup4.Text := reg.ReadString('Agendamento','BackupDir4','');
      for i := Low(Dia) to High(Dia) do
      clbSemana.Checked[i-1] := reg.ReadBool('Agendamento',Dia[i],FALSE);

      for i := 0 to (clbHorarios.Items.Count - 1) do
      clbHorarios.Checked[i] := reg.ReadBool('Agendamento',FormatFloat('00', i) + ':00',FALSE);

      begin
        try
          DiaBackup := reg.ReadBool('Agendamento',Dia[DayOfWeek(date)],true);
        except
          DiaBackup := false;
        end;
//        if not DiaBackup or not reg.OpenKey('\Software\FireBackup\Horarios', false) then AddStatusLine('N�o existe Backup agendado para hoje...', clMaroon, 12)
//        else
          begin
            AddStatusLine(DATETOSTR(DATE)+' - '+Format('Sistema de Backup inicializado �s %s horas', [FormatDateTime('hh:nn:ss', now)]), clNavy, 12);
            for i := low(Horarios) to high(Horarios) do
              begin
                Horarios[i].Hora := I;
                Horarios[i].Agendado := reg.ReadBool('Agendamento',formatfloat('00', i) + ':00',false);
              end;
            Timer.Enabled := true;
          end;
      end;
  finally
    reg.FREE;
  end;

end;


//------------------------------------------------------------------------------
// Procura um texto dentro de uma string com separadores
// EX.
//      PegaCampo('Brasil#Argentina#Canada',2,'#',30)
//                                                    retorna Argentina
//     2 - Segundo campo
//     # - Separador de campos
//    30 - Tamanho m�ximo do campo procurado - se ele for maior s� pega 30 - utilize 0 para n�o se preocupar com o tamanho
//------------------------------------------------------------------------------

function tFPrincipalBackup.PegaCampo(inTexto: string;inPos :integer;inSep :string;inTamanho :integer) : string ;
var vPosTexto,vPosFinalTexto,vTamanhoPalavra : integer ;
var vContSep : integer ;
var vCar : string[1] ;
var vSaida : string ;
begin
    vPosTexto := 1 ;
    vPosFinalTexto := length(inTexto) ;
    vSaida := '';
    vTamanhoPalavra := 0 ;
    vContSep := 1 ;
    While vPosTexto <= vPosFinalTexto do
    Begin
       vCar := copy(inTexto,vPosTexto,1);
       if vCar <> inSep then
       begin
          vSaida := vSaida+vCar;
          Inc(vTamanhoPalavra);
          if (vTamanhoPalavra = inTamanho) and (vContSep=inPos) then
          begin
             result := vSaida ;
             exit;
          end;
       end else
       begin
          if vContSep = inPos then
          begin
             result := vSaida ;
             exit;
          end;
          vTamanhoPalavra := 0 ;
          vSaida:='';
          Inc(vContSep);
       end;
       Inc(vPosTexto);
    end;

    if vContSep < inPos then
       result:= ''
    else
       result := vSaida ;
    exit;

end;

function tFPrincipalBackup.CriarAtalho(ANomeArquivo, AParametros, ADiretorioInicial,
  ANomedoAtalho, APastaDoAtalho: string): boolean;
var
  MeuObjeto: IUnknown;
  MeuSLink: IShellLink;
  MeuPFile: IPersistFile;
  Diretorio: string;
  wNomeArquivo: WideString;
  MeuRegistro: TRegIniFile;
begin
  //Cria e instancia os objetos usados para criar o atalho
  MeuObjeto := CreateComObject(CLSID_ShellLink);
  MeuSLink := MeuObjeto as IShellLink;
  MeuPFile := MeuObjeto as IPersistFile;
  with MeuSLink do
  begin
    SetArguments(PChar(AParametros));
    SetPath(PChar(ANomeArquivo));
    SetWorkingDirectory(PChar(ADiretorioInicial));
  end;

  //Pega endere�o da pasta Desktop do Windows
  MeuRegistro :=TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
  Diretorio := MeuRegistro.ReadString('Shell Folders', 'Startup', '');
  wNomeArquivo := Diretorio + '\' + ANomedoAtalho + '.lnk';
  //Cria de fato o atalho na tela
  MeuPFile.Save(PWChar(wNomeArquivo), False);
  MeuRegistro.Free;

  if fileexists(Diretorio + '\' + ANomedoAtalho + '.lnk') then result:=true
  else
  result:=false;

end;


//Leia mais em: Criando e excluindo atalhos do desktop http://www.devmedia.com.br/criando-e-excluindo-atalhos-do-desktop/980#ixzz3f1f6Frxj


procedure tFPrincipalBackup.compactaarquivozip(const origem: string; Destino: string);
// var
// Zip: TCompressionStream;
// FileIni, FileOut: TFileStream;
begin
  { FileIni:=TFileStream.Create(origem, fmOpenRead and fmShareExclusive);
    FileOut:=TFileStream.Create(destino, fmCreate or fmShareExclusive);
    Zip:=TCompressionStream.Create(clMax, FileOut);
    Zip.CopyFrom(FileIni, FileIni.Size);
    Zip.Free;
    FileOut.Free;
    FileIni.Free; }
  if not assigned(frmZipMain) then
    frmZipMain := tfrmZipMain.create(Application);
  frmZipMain.Show;
  frmZipMain.eSrcDir.text := origem;
  frmZipMain.eDstDir.text := Destino;
  frmZipMain.btnSpanning.Click;
end;

procedure tFPrincipalBackup.restauraarquivozip(const origem: string; Destino: string);
begin
  if not assigned(frmZipMain) then
    frmZipMain := tfrmZipMain.create(Application);
  frmZipMain.Show;
  frmZipMain.eArcName.text := origem;
  frmZipMain.eUnpackDir.text := Destino;
  frmZipMain.btnUnpack.Click;
end;

procedure tFPrincipalBackup.atualizadrivers;
var
adir1, adir2, adir3, adir4: string;
adir21, adir22, adir23, adir24: string;
adir31, adir32, adir33, adir34: string;
adir41, adir42, adir43, adir44: string;
letra: string;
FreeAvailable,TotalSpace,TotalFree : Int64;
i: integer;
BEGIN
  reStatus.Clear;
  TEXTOCHAMADO.clear;

  listadedriversok.Clear;
  listadedriverserror.Clear;

  adir1:=PegaCampo(eDirBackup1.text,1,';',200);
  adir2:=PegaCampo(eDirBackup1.text,2,';',200);
  adir3:=PegaCampo(eDirBackup1.text,3,';',200);
  adir4:=PegaCampo(eDirBackup1.text,4,';',200);

  adir21:=PegaCampo(eDirBackup2.text,1,';',200);
  adir22:=PegaCampo(eDirBackup2.text,2,';',200);
  adir23:=PegaCampo(eDirBackup2.text,3,';',200);
  adir24:=PegaCampo(eDirBackup2.text,4,';',200);

  adir31:=PegaCampo(eDirBackup3.text,1,';',200);
  adir32:=PegaCampo(eDirBackup3.text,2,';',200);
  adir33:=PegaCampo(eDirBackup3.text,3,';',200);
  adir34:=PegaCampo(eDirBackup3.text,4,';',200);

  adir41:=PegaCampo(eDirBackup4.text,1,';',200);
  adir42:=PegaCampo(eDirBackup4.text,2,';',200);
  adir43:=PegaCampo(eDirBackup4.text,3,';',200);
  adir44:=PegaCampo(eDirBackup4.text,4,';',200);

  if (Copy(adir1,0,1) <> '\') and (adir1 <> '') then
  begin
    letra:=Copy(adir1,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);

      END
      else
      begin
        //ShowMessage('DRIVE NAO PREPARADO: '+LETRA1);
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir2,0,1) <> '\')  and (adir2 <> '') then
  begin
    letra:=Copy(adir2,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir3,0,1) <> '\') and (adir4 <> '') then
  begin
    letra:=Copy(adir3,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir4,0,1) <> '\') and (adir4 <> '') then
  begin
    letra:=Copy(adir4,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir21,0,1) <> '\') and (adir21 <> '') then
  begin
    letra:=Copy(adir21,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir22,0,1) <> '\') and (adir22 <> '') then
  begin
    letra:=Copy(adir22,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir23,0,1) <> '\') and (adir23 <> '') then
  begin
    letra:=Copy(adir23,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir24,0,1) <> '\') and (adir24 <> '') then
  begin
    letra:=Copy(adir24,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir31,0,1) <> '\') and (adir31 <> '') then
  begin
    letra:=Copy(adir31,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir32,0,1) <> '\') and (adir32 <> '') then
  begin
    letra:=Copy(adir32,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir33,0,1) <> '\') and (adir33 <> '') then
  begin
    letra:=Copy(adir33,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir34,0,1) <> '\') and (adir34 <> '') then
  begin
    letra:=Copy(adir34,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir41,0,1) <> '\') and (adir41 <> '') then
  begin
    letra:=Copy(adir41,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir42,0,1) <> '\') and (adir42 <> '') then
  begin
    letra:=Copy(adir42,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir43,0,1) <> '\') and (adir43 <> '') then
  begin
    letra:=Copy(adir43,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;

  if (Copy(adir44,0,1) <> '\') and (adir44 <> '') then
  begin
    letra:=Copy(adir44,0,2);
    begin
      if DRIVEOK(LETRA[1]) then
      BEGIN
        if TEMNALISTA(listadedriversok,letra) = false then
        listadedriversok.Add(letra);
      END
      else
      begin
        if TEMNALISTA(listadedriverserror,letra) = false then
        listadedriverserror.Add(letra);
      end;
    end;
  end;


  restatus.Lines.INSERT(0,'Drivers OK: '+#13+listadedriversok.Text);
  restatus.Lines.INSERT(0,'Drivers com erro: '+#13+listadedriverserror.Text);

  for I := 0 to listadedriversERROR.Count - 1 do
  begin
    textochamado.Add(('ATEN��O! DRIVE INFORMADO PARA ARMAZENAMENTO N�O FOI ENCONTRADO: ['+listadedriversERROR.strings[i]+']'));
  end;

  for I := 0 to listadedriversok.Count - 1 do
  begin

        GetDiskFreeSpaceEx(PChar(listadedriversok.strings[i]),FreeAvailable,TotalSpace,@TotalFree);
    //    ShowMessage('Espa�o livre: '+listadedriversok.strings[i]+' - '+FormatFloat('#,0',TotalFree)+#13+
    //    'Espa�o dispon�vel: '+FormatFloat('#,0',FreeAvailable)+#13+
    //    'Espa�o total do disco: '+FormatFloat('#,0',TotalSpace));
    //    ShowMessage('percentual livre: '+floattostr((totalfree/totalspace)*100)+'%');

//    Gauge1.Visible:=false;
    Gauge2.Visible:=false;
    Gauge3.Visible:=false;
    Gauge4.Visible:=false;
//    labelletra1.Visible:=false;
    labelletra2.Visible:=false;
    labelletra3.Visible:=false;
    labelletra4.Visible:=false;

    if i = 0 then
    begin
      Gauge1.Visible:=True;
      LabelLetra1.Visible:=true;

      Gauge1.MaxValue:=100;
      Gauge1.Progress:=100 -round((totalfree/totalspace)*100);
      labelletra1.Caption:=listadedriversok.strings[i];

      if Gauge1.Progress > 90 then
      textochamado.Add(('ATEN��O! DRIVE INFORMADO PARA ARMAZENAMENTO ESTA LOTADO: ['+listadedriversok.strings[i]+']'));
    end;

    if i = 1 then
    begin
      Gauge2.Visible:=True;
      LabelLetra2.Visible:=true;

      Gauge2.MaxValue:=100;
      Gauge2.Progress:=100 -round((totalfree/totalspace)*100);
      labelletra2.Caption:=listadedriversok.strings[i];
      if Gauge2.Progress > 90 then
      textochamado.Add(('ATEN��O! DRIVE INFORMADO PARA ARMAZENAMENTO ESTA LOTADO: ['+listadedriversok.strings[i]+']'));
    end;

    if i = 2 then
    begin
      Gauge3.Visible:=True;
      LabelLetra3.Visible:=true;

      Gauge3.MaxValue:=100;
      Gauge3.Progress:=100 -round((totalfree/totalspace)*100);
      labelletra3.Caption:=listadedriversok.strings[i];
      if Gauge3.Progress > 90 then
      textochamado.Add(('ATEN��O! DRIVE INFORMADO PARA ARMAZENAMENTO ESTA LOTADO: ['+listadedriversok.strings[i]+']'));
    end;

    if i = 3 then
    begin
      Gauge4.Visible:=True;
      LabelLetra4.Visible:=true;

      Gauge4.MaxValue:=100;
      Gauge4.Progress:=100 -round((totalfree/totalspace)*100);
      labelletra4.Caption:=listadedriversok.strings[i];
      if Gauge4.Progress > 90 then
      textochamado.Add(('ATEN��O! DRIVE INFORMADO PARA ARMAZENAMENTO ESTA LOTADO: ['+listadedriversok.strings[i]+']'));
    end;
  end;
  if listadedriversok.Count < 2 then
  textochamado.Add('� NECESS�RIO AO MENOS [2] DRIVERS DE DESTINO PARA O BACKUP SER CONFI�VEL.');

  if textochamado.Count > 0 then
  begin
    restatus.Lines.INSERT(0,TEXTOCHAMADO.TEXT);
    loga_help('MENSAGEM AUTOM�TICA [SISTEMA DE BACKUP]'+#13+'Nome do Computador: ['+SYSCOMPUTERNAME+']'+#13+textochamado.Text);
  end;

end;

function tFPrincipalBackup.TEMNALISTA(const ALISTA: TStringList; ATEXTO: STRING): boolean;
begin
  TRY
    if ATEXTO = '' then
    begin
      result := true
    end // se estiver em branco, diz que tem pra n�o cadastrar...
    else
    begin
      if ALISTA.IndexOf(ATEXTO) > -1 then
      begin
        result := true;
      end
      else
      begin
        result := false;
      end;
    end;
  except
  end;
end;

function tFPrincipalBackup.DriveOk(Drive: Char): boolean;
var
I: byte;
begin
Drive := UpCase(Drive);
if not (Drive in ['A'..'Z']) then
raise Exception.Create('Unidade incorreta');
I := Ord(Drive) - 64;
Result := DiskSize(I) >= 0;
end;


PROCEDURE tFPrincipalBackup.loga_help(const amsg: string);
VAR
am: integer;
begin
  Exit;
  restatus.Lines.INSERT(0,'Trabalhando online - Avisando Suporte sobre problemas no backup...');

  try
    ZConnection1.LibraryLocation:=''; //tiro por causa do bug do windows 10 que acabou exigindo o library pra acessar o banco de modo de desenvolvimento
    restatus.Lines.INSERT(0,eBASE1.text+' - Acesso ao Sistema [Aguarde, tentando link com o banco de dados...]');

    zconnection1.Connected:=false;
    zconnection1.Database:=eBASE1.text;

    TRY
      zconnection1.Connected:=true;
      zquery2.close;
      zquery2.sql.clear;
      zquery2.sql.add('select * from empresa');
      zquery2.open;
      restatus.Lines.INSERT(0,eBASE1.text+' - Acesso ao banco de dados principal conclu�do.');
    EXCEPT
    END;
    //==========================

    IF ZConnection1.Connected = FALSE THEN
    BEGIN
      restatus.Lines.INSERT(0,'ERRO AO ACESSAR OS DADOS. SE VOC� EST� USANDO O SISTEMA EM REDE, VERIFIQUE OS CABOS E DESLIGUE E LIGUE O HUB. SE ACABOU DE LIGAR O MICRO, AGUARDE MAIS ALGUNS INSTANTES PARA QUE O FIREBIRD SEJA CARREGADO E TENTE NOVAMENTE.');
    END;
  finally

  end;
//**********************************************************************

END;

PROCEDURE tFPrincipalBackup.loga_ult_backup;
VAR QUERY: TZQUERY;
am: integer;
BASESFEITAS: TStringList;
begin
  Exit;
  BASESFEITAS:=TStringList.Create;
  BASESFEITAS.Clear;

  restatus.Lines.INSERT(0,'Trabalhando online - informando sucesso do backup...');

  try
    ZConnection1.LibraryLocation:=''; //tiro por causa do bug do windows 10 que acabou exigindo o library pra acessar o banco de modo de desenvolvimento
    restatus.Lines.INSERT(0,eBASE1.text+' - Acesso ao Sistema [Aguarde, tentando link com o banco de dados...]');

    zconnection1.Connected:=false;
    zconnection1.Database:=eBASE1.text;

    TRY
      zconnection1.Connected:=true;
      zquery2.close;
      zquery2.sql.clear;
      zquery2.sql.add('select * from empresa');
      zquery2.open;
      restatus.Lines.INSERT(0,eBASE1.text+' - Acesso ao banco de dados principal conclu�do.');
    EXCEPT
    END;
    //==========================

    IF ZConnection1.Connected = FALSE THEN
    BEGIN
      restatus.Lines.INSERT(0,'ERRO AO ACESSAR OS DADOS. SE VOC� EST� USANDO O SISTEMA EM REDE, VERIFIQUE OS CABOS E DESLIGUE E LIGUE O HUB. SE ACABOU DE LIGAR O MICRO, AGUARDE MAIS ALGUNS INSTANTES PARA QUE O FIREBIRD SEJA CARREGADO E TENTE NOVAMENTE.');
    END;
    //**********************************************************************

    BASESFEITAS.Add(EBASE1.Text);

    if (eBase2.TEXT <> '') AND (TEMNALISTA(BASESFEITAS,eBase2.Text) = FALSE) then
    begin
      restatus.Lines.INSERT(0,'Trabalhando online - informando sucesso do backup...');

      try
        restatus.Lines.INSERT(0,eBASE2.text+' - Acesso ao Sistema [Aguarde, tentando link com o banco de dados...]');

        zconnection1.Connected:=false;
        zconnection1.Database:=eBASE2.text;

        TRY
          zconnection1.Connected:=true;
          zquery2.close;
          zquery2.sql.clear;
          zquery2.sql.add('select * from empresa');
          zquery2.open;
          restatus.Lines.INSERT(0,eBASE2.text+' - Acesso ao banco de dados principal conclu�do.');
        EXCEPT
        END;
        //==========================

        IF ZConnection1.Connected = FALSE THEN
        BEGIN
          restatus.Lines.INSERT(0,'ERRO AO ACESSAR OS DADOS. SE VOC� EST� USANDO O SISTEMA EM REDE, VERIFIQUE OS CABOS E DESLIGUE E LIGUE O HUB. SE ACABOU DE LIGAR O MICRO, AGUARDE MAIS ALGUNS INSTANTES PARA QUE O FIREBIRD SEJA CARREGADO E TENTE NOVAMENTE.');
        END;
        //**********************************************************************

        BASESFEITAS.Add(EBASE2.Text);

      EXCEPT
      end;
    end;
    //********************************************************************************************************

    if (eBase3.TEXT <> '') AND (TEMNALISTA(BASESFEITAS,eBase3.Text) = FALSE) then
    begin
      restatus.Lines.INSERT(0,'Trabalhando online - informando sucesso do backup...');

      try
        restatus.Lines.INSERT(0,eBASE3.text+' - Acesso ao Sistema [Aguarde, tentando link com o banco de dados...]');

        zconnection1.Connected:=false;
        zconnection1.Database:=eBASE3.text;

        TRY
          zconnection1.Connected:=true;
          zquery2.close;
          zquery2.sql.clear;
          zquery2.sql.add('select * from empresa');
          zquery2.open;
          restatus.Lines.INSERT(0,eBASE3.text+' - Acesso ao banco de dados principal conclu�do.');
        EXCEPT
        END;
        //==========================

        IF ZConnection1.Connected = FALSE THEN
        BEGIN
          restatus.Lines.INSERT(0,'ERRO AO ACESSAR OS DADOS. SE VOC� EST� USANDO O SISTEMA EM REDE, VERIFIQUE OS CABOS E DESLIGUE E LIGUE O HUB. SE ACABOU DE LIGAR O MICRO, AGUARDE MAIS ALGUNS INSTANTES PARA QUE O FIREBIRD SEJA CARREGADO E TENTE NOVAMENTE.');
        END;
        //**********************************************************************

        BASESFEITAS.Add(EBASE3.Text);

      EXCEPT
      end;
    end;
    //********************************************************************************************************

    if (eBase4.TEXT <> '') AND (TEMNALISTA(BASESFEITAS,eBase4.Text) = FALSE) then
    begin
      restatus.Lines.INSERT(0,'Trabalhando online - informando sucesso do backup...');

      try
        restatus.Lines.INSERT(0,eBASE4.text+' - Acesso ao Sistema [Aguarde, tentando link com o banco de dados...]');

        zconnection1.Connected:=false;
        zconnection1.Database:=eBASE4.text;

        TRY
          zconnection1.Connected:=true;
          zquery2.close;
          zquery2.sql.clear;
          zquery2.sql.add('select * from empresa');
          zquery2.open;
          restatus.Lines.INSERT(0,eBASE4.text+' - Acesso ao banco de dados principal conclu�do.');
        EXCEPT
        END;
        //==========================

        IF ZConnection1.Connected = FALSE THEN
        BEGIN
          restatus.Lines.INSERT(0,'ERRO AO ACESSAR OS DADOS. SE VOC� EST� USANDO O SISTEMA EM REDE, VERIFIQUE OS CABOS E DESLIGUE E LIGUE O HUB. SE ACABOU DE LIGAR O MICRO, AGUARDE MAIS ALGUNS INSTANTES PARA QUE O FIREBIRD SEJA CARREGADO E TENTE NOVAMENTE.');
        END;
        //**********************************************************************

        BASESFEITAS.Add(EBASE4.Text);

      EXCEPT
      end;
    end;
    //********************************************************************************************************




    freeandnil(query);
  finally
  end;
END;

function TFPrincipalBackup.SysComputerName: string;
var
  i: DWORD;
begin
  i := MAX_COMPUTERNAME_LENGTH + 1;
  SetLength(result, i);
  windows.GetComputerName(pchar(result), i);
  result := UPPERCASE(string(pchar(result)));
end;

end.

