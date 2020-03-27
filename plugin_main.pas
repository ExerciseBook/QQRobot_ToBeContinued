{
	酷Q功能开发参考
}

{$IFDEF FPC}
	{$MODE OBJFPC}
	{$CODEPAGE UTF-8}
{$ENDIF}

unit plugin_main;

interface
uses CoolQSDK;
procedure Initialize();
function SelectAMusic():ansistring;

implementation
{$R audio\audio.res}

uses sysutils, classes;

procedure LoadResourceFile(aFile:ansistring; ms:TMemoryStream);
var
	HResInfo: HRSRC;
	HGlobal: THandle;
	Buffer, GoodType : pchar;
	Ext:ansistring;
begin
	ext:=uppercase(extractfileext(aFile));
	ext:=copy(ext,2,length(ext));
	Goodtype:=@ext[1];
	aFile:=changefileext(aFile,'');
	HResInfo := FindResource(HInstance, @aFile[1], GoodType);
	HGlobal := LoadResource(HInstance, HResInfo);
	if HGlobal = 0 then
		raise EResNotFound.Create('Can''t load resource: '+aFile);
	Buffer := LockResource(HGlobal);
	ms.clear;
	ms.WriteBuffer(Buffer[0], SizeOfResource(HInstance, HResInfo));
	ms.Seek(0,0);
	UnlockResource(HGlobal);
	FreeResource(HGlobal);
end;

function GetResourcePath():ansistring;inline;
begin
	exit(ExtractFilePath(ParamStr(0))+'data\record\'+'com.superexercisebook.tobecontinued\');
end;

procedure LoadAudio(resourceName, fileName: ansistring);
var
	ResourceFile : TMemoryStream;
	FileStream : TFileStream;
begin
	try
		if FileExists(GetResourcePath()+fileName) then exit();
		ResourceFile := TMemoryStream.Create();
		LoadResourceFile(resourceName, ResourceFile);
		ForceDirectories(GetResourcePath());
		FileStream := TFileStream.Create(GetResourcePath()+fileName, fmCreate);
		FileStream.CopyFrom(ResourceFile, ResourceFile.Size);
		ResourceFile.Free;
		FileStream.Free;
	except
		on e: Exception do begin
			CQ_i_addLog(CQLog_Error,'To be continued',e.message);
		end;
	end;
end;

function SelectAMusic():ansistring;
Var
	Info : TSearchRec;
	Count : Longint;
Begin
	ForceDirectories(GetResourcePath());

	Count:=0;
    result:='';
	If FindFirst (GetResourcePath()+'*',faAnyFile,Info)=0 then begin
		Repeat
		if ((Info.Attr and faDirectory) <> faDirectory) then begin
			inc(Count);
			if (random(Count)>Count-1-1) then result:='com.superexercisebook.tobecontinued\'+Info.Name;
		end;
		Until FindNext(info)<>0;
	end;
	FindClose(Info);
End;

procedure Initialize();
begin
	LoadAudio('audio1.mp3', 'Jack Stauber - buttercup.mp3');
	LoadAudio('audio2.mp3', 'Yes - Roundabout.mp3');
end;

end.