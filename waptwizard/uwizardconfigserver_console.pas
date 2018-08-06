unit uwizardconfigserver_console;

{$mode objfpc}{$H+}

interface

uses
  uwizard,
  uwizardstepframe,

  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls;

type

  { TWizardConfigServer_Console }

  TWizardConfigServer_Console = class(TWizardStepFrame)
    cb_configure_console: TCheckBox;
  public

    // TWizardStepFrame
    procedure wizard_show(); override; final;
    procedure wizard_previous(var bCanPrevious: boolean); override; final;
    procedure wizard_next(var bCanNext: boolean); override; final;
    procedure clear();  override; final;

  end;

implementation

uses
  WizardControls,
  uwizardconfigserver_data,
  uwapt_ini,
  uwizardutil,
  Dialogs,
  waptcommon
  ;

{$R *.lfm}

{ TWizardConfigServer_Console }

procedure TWizardConfigServer_Console.clear();
begin
  self.cb_configure_console.Checked := true;
end;

procedure TWizardConfigServer_Console.wizard_show();
begin
  inherited;

  self.m_wizard.WizardButtonPanel.NextButton.SetFocus;
end;

procedure TWizardConfigServer_Console.wizard_previous(var bCanPrevious: boolean );
begin
  self.m_wizard.WizardManager.PageByName( PAGE_CONSOLE ).PreviousOffset := 3;
end;

procedure TWizardConfigServer_Console.wizard_next(var bCanNext: boolean);
var
  data : PWizardConfigServerData;
  p_console : TWizardPage;
  p_finished : TWizardPage;
begin
  bCanNext := true;
  data := self.m_wizard.data();

  p_console  := self.m_wizard.WizardManager.PageByName( PAGE_CONSOLE );
  p_finished := self.m_wizard.WizardManager.PageByName( PAGE_FINISHED );

  if self.cb_configure_console.Checked then
  begin
    p_console.NextOffset      := 1;
    p_finished.PreviousOffset := 1;
  end
  else
  begin
    p_console.NextOffset      := p_finished.Index - p_console.Index;
    p_finished.PreviousOffset := p_console.NextOffset;
  end;


end;



initialization

RegisterClass(TWizardConfigServer_Console);

end.

