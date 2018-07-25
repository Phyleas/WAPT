unit uwizardconfigserver_data;

{$mode objfpc}{$H+}

interface

uses

  uwizard,
  Classes, SysUtils;


const
    WizardConfigServerPage_page_welcome                 : String = 'welcome';
    WizardConfigServerPage_page_firewall                : String = 'firewall';
    WizardConfigServerPage_page_postsetup               : String = 'post_setup';
    WizardConfigServerPage_page_keyoption               : String = 'key_option';
    WizardConfigServerPage_page_console                 : String = 'console';
    WizardConfigServerPage_page_package_create_new_key  : String = 'package_create_new_key';
    WizardConfigServerPage_page_package_use_existing_key: String = 'package_use_existing_key';
    WizardConfigServerPage_page_server_url              : String = 'server_url';
    WizardConfigServerPage_page_build_agent             : String = 'build_agent';
    WizardConfigServerPage_page_finished                : String = 'finished';


type

  TWizardConfigServerData = record
    wapt_server                     : String;
    wapt_user                       : String;
    wapt_password                   : String;
    wapt_password_crypted           : String;
    default_package_prefix          : String;
    package_certificate             : String;
    package_private_key             : String;
    package_private_key_password    : String;
    verify_cert                     : String;
    is_enterprise_edition           : boolean;
    server_certificate              : String;
    launch_console                  : boolean;
    check_certificates_validity     : String;
    repo_url                        : String;
    configure_console               : Boolean;
  end;
  PWizardConfigServerData = ^TWizardConfigServerData;



  function TWizardConfigServerData_write_ini_waptserver(  data : PWizardConfigServerData; w : TWizard ): integer;
  function TWizardConfigServerData_write_ini_waptconsole( data : PWizardConfigServerData; w : TWizard ): integer;
  function TWizardConfigServerData_write_ini_waptget(     data : PWizardConfigServerData; w : TWizard ): integer;

implementation


uses
  uwapt_ini,
  uwizardutil,
  IniFiles;


function TWizardConfigServerData_write_ini_waptserver( data : PWizardConfigServerData; w : TWizard ): integer;
var
  ini : TIniFile;
  r   : integer;
  s   : String;
begin
  ini := nil;

  w.SetValidationDescription( 'Writing wapt server configuration file' );

  r := wapt_server_installation(s);
  if r <> 0 then
    exit(-1);
  wapt_ini_waptserver( s, s );
  try


    // waptserver.ini
    ini := TIniFile.Create(s);
    ini.WriteString( INI_OPTIONS, INI_DB_NAME,       'wapt');
    ini.WriteString( INI_OPTIONS, INI_DB_USER,       'wapt' );
    ini.WriteString( INI_OPTIONS, INI_WAPT_USER,     'admin' );
    ini.WriteString( INI_OPTIONS, INI_WAPT_PASSWORD, data^.wapt_password_crypted );
    ini.WriteString( INI_OPTIONS, INI_ALLOW_UNAUTHENTICATED_REGISTRATION, 'True' );
    r := Length( Trim(ini.ReadString( INI_OPTIONS, INI_SERVER_UUID, '')) );
    if r = 0 then
      ini.WriteString( INI_OPTIONS, INI_SERVER_UUID, random_server_uuid() );
    FreeAndNil( ini );


    result := 0;
  except on Ex : Exception do
    begin
      result := -1;
      w.SetValidationDescription( ex.Message );
    end;
  end;

  if Assigned(ini) then
    FreeAndNil(ini);

end;



function TWizardConfigServerData_write_ini_waptconsole( data : PWizardConfigServerData; w : TWizard ): integer;
var
  ini : TIniFile;
  s   : String;
begin
  ini := nil;

  w.SetValidationDescription( 'Writing waptconsole configuration file' );
  try

    // waptconsole.ini
    wapt_ini_waptconsole(s);
    ini := TIniFile.Create( s );
    ini.WriteString( INI_GLOBAL, INI_CHECK_CERTIFICATES_VALIDITY, data^.check_certificates_validity );
    ini.WriteString( INI_GLOBAL, INI_VERIFIY_CERT,                data^.verify_cert );
    ini.WriteString( INI_GLOBAL, INI_WAPT_SERVER,                 data^.wapt_server );
    ini.WriteString( INI_GLOBAL, INI_REPO_URL,                    data^.wapt_server + '/wapt');
    ini.WriteString( INI_GLOBAL, INI_DEFAULT_PACKAGE_PREFIX,      data^.default_package_prefix );
    ini.WriteString( INI_GLOBAL, INI_PERSONAL_CERTIFICATE_PATH,   data^.package_certificate );
    FreeAndNil( ini );

    result := 0;
  except on Ex : Exception do
    begin
      result := -1;
      w.SetValidationDescription( ex.Message );
    end;
  end;

  if Assigned(ini) then
    FreeAndNil(ini);

end;

function TWizardConfigServerData_write_ini_waptget( data : PWizardConfigServerData; w : TWizard ): integer;
var
  ini : TIniFile;
begin
  ini := nil;

  w.SetValidationDescription( 'Writing wapt-get configuration file' );
  try

    // wapt-get.ini
    ini := TIniFile.Create('wapt-get.ini' );
    ini.WriteString( INI_GLOBAL, INI_CHECK_CERTIFICATES_VALIDITY, data^.check_certificates_validity );
    ini.WriteString( INI_GLOBAL, INI_VERIFIY_CERT,                data^.verify_cert );
    ini.WriteString( INI_GLOBAL, INI_WAPT_SERVER,                 data^.wapt_server );
    ini.WriteString( INI_GLOBAL, INI_REPO_URL,                    data^.wapt_server + '/wapt' );
    FreeAndNil( ini );

    result := 0;
  except on Ex : Exception do
    begin
      result := -1;
      w.SetValidationDescription( ex.Message );
    end;
  end;

  if Assigned(ini) then
    FreeAndNil(ini);

end;

end.
