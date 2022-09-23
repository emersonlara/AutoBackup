program AutoBackup;

uses
  Forms,
  windows,
  messages,
  dialogs,
  ConfigurarBackup in 'ConfigurarBackup.pas' {FrmConfigurarBackup},
  uzipMain in 'uzipMain.pas' {frmZipMain},
  Restore in 'Restore.pas' {FrmRestore},
  UPrincipal in 'UPrincipal.pas' {FPrincipalBackup};

{$R *.res}
//{SR UAC.res}   <== TROCAR O S POR $

var
 Instancia: THandle;

begin
//  Hwnd := FindWindow (nil, 'Conectiva - Sistema de Backup Autom�tico');

  Instancia:= CreateMutex(nil, false, 'InstanciaIniciada');
  if WaitForSingleObject(Instancia, 0) = wait_Timeout then
  begin
    Application.MessageBox('Aten��o. Sistema de Backup Autom�tico j� est� aberto, verifique no canto inferior direito da tela (do lado do rel�gio.)','Programa j� est� aberto',MB_ICONINFORMATION);
    Exit;
  end;

  Application.Initialize;
  Application.Title := 'Conectiva - Sistema de Backup Autom�tico';
  Application.CreateForm(TFPrincipalBackup, FPrincipalBackup);
  Application.CreateForm(TfrmZipMain, frmZipMain);
  Application.Run;
end.
