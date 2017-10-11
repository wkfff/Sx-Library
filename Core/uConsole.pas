unit uConsole;

interface

uses
  Windows, Classes;

type
  TConsoleColor = (ccBlack, ccBlue, ccGreen, ccAquq, ccRed, ccPurple, ccYellow, ccLightGray, ccGray, ccLightBlue,
    ccLightGreen, ccLightAqua, ccLightRed, ccLightPurple, ccLightYellow, ccWhite);

  TConsole = class
  public
    class procedure Write(const AText: string); overload;
    class procedure Write(const AText: string; const AForegroundColor: TConsoleColor; const ABackgroundColor:
      TConsoleColor = ccBlack); overload;

    class procedure WriteLine(const AText: string); overload;
    class procedure WriteLine(const AText: string; const AForegroundColor: TConsoleColor; const ABackgroundColor:
      TConsoleColor = ccBlack); overload;

    class procedure WriteAligned(const AText: string; const AFixedWidth: Integer; const AHorizontalAlign: TAlignment;
      AForegroundColor: TConsoleColor; ABackgroundColor: TConsoleColor);

    class function GetSize: TCoord;
    class procedure SetSize(const AValue: TCoord);

    class function GetCursorPosition: TCoord;
  end;

implementation

uses
  uTypes, uCharset, uChar, uStrings;

class procedure TConsole.WriteLine(const AText: string);
begin
  if Length(AText) = GetSize.X - GetCursorPosition.X then
  begin
    TConsole.Write(AText);
  end
  else
  begin
    {$ifdef UNICODE}
    System.Writeln(AText);
    {$else}
    System.Writeln(ConvertAnsiToOem(AText));
    {$endif}
  end;
end;

class procedure TConsole.Write(const AText: string);
begin
  {$ifdef UNICODE}
  System.Write(AText);
  {$else}
  System.Write(ConvertAnsiToOem(AText));
  {$endif}
end;

class function TConsole.GetSize: TCoord;
var
  csbi: CONSOLE_SCREEN_BUFFER_INFO;
  handle: THandle;
begin
  Result.X := 0;
  Result.Y := 0;
  handle := GetStdHandle(STD_OUTPUT_HANDLE);
  if handle <> INVALID_HANDLE_VALUE  then
    if GetConsoleScreenBufferInfo(handle, csbi) then
      Result := csbi.dwSize;
end;

class function TConsole.GetCursorPosition: TCoord;
var
  csbi: CONSOLE_SCREEN_BUFFER_INFO;
  handle: THandle;
begin
  Result.X := 0;
  Result.Y := 0;
  handle := GetStdHandle(STD_OUTPUT_HANDLE);
  if handle <> INVALID_HANDLE_VALUE  then
    if GetConsoleScreenBufferInfo(handle, csbi) then
      Result := csbi.dwCursorPosition;
end;

class procedure TConsole.SetSize(const AValue: TCoord);
var
  csbi: CONSOLE_SCREEN_BUFFER_INFO;
  handle: THandle;
begin
  handle := GetStdHandle(STD_OUTPUT_HANDLE);
  if handle <> INVALID_HANDLE_VALUE then
    if GetConsoleScreenBufferInfo(handle, csbi) then
    begin
      csbi.dwSize := AValue;
      SetConsoleScreenBufferSize(handle, csbi.dwSize);
    end;
end;

class procedure TConsole.WriteLine(const AText: string; const AForegroundColor, ABackgroundColor: TConsoleColor);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), U2(AForegroundColor) or U2(ABackgroundColor) shl 4);
  try
    WriteLine(AText);
  finally
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), U2(ccLightGray)); // Default
  end;
end;

class procedure TConsole.Write(const AText: string; const AForegroundColor, ABackgroundColor: TConsoleColor);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), U2(AForegroundColor) or U2(ABackgroundColor) shl 4);
  try
    Write(AText);
  finally
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), U2(ccLightGray)); // Default
  end;
end;

class procedure TConsole.WriteAligned(const AText: string;
  const AFixedWidth: Integer; const AHorizontalAlign: TAlignment;
  AForegroundColor, ABackgroundColor: TConsoleColor);
const
  HorizontalEllipsis = CharRightPointingDoubleAngleQuotationMark;
begin
  if Length(AText) > AFixedWidth then
  begin
    Write(Copy(AText, 1, AFixedWidth - Length(HorizontalEllipsis)));
    Write(HorizontalEllipsis, ccLightYellow);
  end
  else
  begin
    case AHorizontalAlign of
    taLeftJustify:
      Write(PadRight(AText, AFixedWidth), AForegroundColor, ABackgroundColor);
    taRightJustify:
      Write(PadLeft(AText, AFixedWidth), AForegroundColor, ABackgroundColor);
    taCenter:
      Write(PadCenter(AText, AFixedWidth), AForegroundColor, ABackgroundColor);
    end;
  end;
end;

end.

