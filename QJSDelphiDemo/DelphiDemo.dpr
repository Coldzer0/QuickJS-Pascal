{
  Delphi Demo for QuickJS Engine \
  Tested On Win x32 - x64 >> with "Delphi 10.3".

  Copyright(c) 2019 Coldzer0 <Coldzer0 [at] protonmail.ch> .

  License: MIT .
}

program DelphiDemo;

uses
  {$IFDEF mswindows}
  windows,
  {$ENDIF }
  quickjs,
  QuickJSDemo;

function eval_buf(ctx : JSContext; Buf : PAnsiChar; buf_len : Integer; filename : PAnsiChar; eval_flags : Integer): Integer;
var
  val : JSValue;
begin
  val := JS_Eval(ctx, buf, buf_len, filename, eval_flags);
  if JS_IsException(val) then
  begin
    js_std_dump_error(ctx);
    Result := -1;
  end
  else
    Result := 0;
    JS_FreeValue(ctx, val);
end;

function eval_file(ctx : JSContext; filename : PAnsiChar; eval_flags : Integer): Integer;
var
  buf_len : size_t;
  Buf : Pointer;
begin
  buf := js_load_file(ctx, @buf_len, filename);
  if not Assigned(buf) then
  begin
    Writeln('Error While Loading : ',filename);
    exit(1);
  end;
  Result := eval_buf(ctx, buf, buf_len, filename, eval_flags);
  js_free(ctx, buf);
end;


function logme(ctx : JSContext; {%H-}this_val : JSValueConst; argc : Integer; argv : PJSValueConstArr): JSValue; cdecl;
var
  i : Integer;
  str : PAnsiChar;
begin
  for i := 0 to Pred(argc) do
  begin
     if i <> 0 then
       write(' ');
     str := JS_ToCString(ctx, argv[i]);
     if not Assigned(str) then
        exit(JS_EXCEPTION);
     Write(str);
     JS_FreeCString(ctx, str);
  end;
  Writeln;
  Result := JS_UNDEFINED;
end;

procedure RunCode();
var
  rt  : JSRuntime;
  ctx : JSContext;
  m   : JSModuleDef;
  global : JSValue;
  filename : PAnsiChar;
const
  std_hepler : PAnsiChar =
    'import * as std from ''std'';'#10+
    'import * as os from ''os'';'#10+
    'import * as Cmu from ''Cmu'';'#10+ // Our Custom Module.
    'std.global.std = std;'#10+
    'std.global.os = os;'#10+
    'std.global.Cmu = Cmu;'#10;
begin
  rt := JS_NewRuntime;
  if Assigned(rt) then
  begin
    ctx := JS_NewContext(rt);
    if Assigned(rt) then
    begin
      // ES6 Module loader.
      JS_SetModuleLoaderFunc(rt, nil, @js_module_loader, nil);

      js_std_add_helpers(ctx,0,nil);
      js_init_module_std(ctx, 'std');
      js_init_module_os(ctx, 'os');

      {
        Functions init order is important \
        cuz i init the class and it's obj's and constructor in \
        RegisterNativeClass then i just point the Module constructor to the same one.
      }

      // Register with global object directly .
      RegisterNativeClass(ctx);

      // Register with module
      m := JS_NewCModule(ctx, PAnsiChar('Cmu'), @Emu_init);
      JS_AddModuleExport(ctx,m, PAnsiChar('ApiHook'));

      eval_buf(ctx, std_hepler, {$IFDEF FPC}strlen{$ELSE}lstrlenA{$ENDIF}(std_hepler), '<global_helper>', JS_EVAL_TYPE_MODULE);


      global := JS_GetGlobalObject(ctx);

      // Define a function in the global context.
      JS_SetPropertyStr(ctx,global,'log',JS_NewCFunction(ctx, @logme, 'log', 1));

      JS_FreeValue(ctx, global);

      if ParamCount >= 1 then
      begin
        filename :=PAnsiChar(AnsiString(ParamStr(1)));
        eval_file(ctx,filename,JS_EVAL_TYPE_GLOBAL or JS_EVAL_TYPE_MODULE);
      end;

      js_std_loop(ctx);

      js_std_free_handlers(rt);
      JS_FreeContext(ctx);
    end;
    JS_FreeRuntime(rt);
  end;
  Writeln;
end;



begin
  RunCode;
end.


