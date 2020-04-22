{
  FreePascal Demo for QuickJS Engine \
  Tested On Mac - Win - Linux >> with FreePascal v3.0.4 .

  Copyright(c) 2019 Coldzer0 <Coldzer0 [at] protonmail.ch> .

  License: MIT .
}

program Demo;
{$IFDEF FPC}
  {$Mode Delphi}{$H+}
  {$extendedsyntax on}
{$ENDIF}
uses
  {$IFDEF unix}cthreads,{$ENDIF}
  cmem,
  quickjs,
  QuickJSDemo,RawExecution;


function eval_buf(ctx: JSContext; Buf: PChar; buf_len: integer;
  filename: PChar; is_main : boolean; eval_flags: integer = -1): JSValue;
var
  ret: JSValue;
begin
  if eval_flags = -1 then
  begin
    if JS_DetectModule(Buf,buf_len) then
      eval_flags := JS_EVAL_TYPE_MODULE
    else
      eval_flags := JS_EVAL_TYPE_GLOBAL;
  end;

  if (eval_flags and JS_EVAL_TYPE_MASK) = JS_EVAL_TYPE_MODULE then
  begin
    ret := JS_Eval(ctx, buf, buf_len, filename, eval_flags or JS_EVAL_FLAG_COMPILE_ONLY);
    if not JS_IsException(ret) then
    begin
      js_module_set_import_meta(ctx, ret, True, is_main);
      ret := JS_EvalFunction(ctx, ret);
    end;
  end
  else
    ret := JS_Eval(ctx, buf, buf_len, filename, eval_flags);

  if JS_IsException(ret) then
  begin
    js_std_dump_error(ctx);
    Result := JS_NULL;
  end
  else
    Result := ret;
end;

function eval_file(ctx : JSContext; filename : PChar; eval_flags : Integer = -1): JSValue;
var
  buf_len : size_t;
  Buf : Pointer;
begin
  buf := js_load_file(ctx, @buf_len, filename);
  if not Assigned(buf) then
  begin
    Writeln('Error While Loading : ',filename);
    exit(JS_EXCEPTION);
  end;
  Result := eval_buf(ctx, buf, buf_len, filename, true, eval_flags);
  js_free(ctx, buf);
end;


function logme(ctx : JSContext; {%H-}this_val : JSValueConst; argc : Integer; argv : PJSValueConstArr): JSValue; cdecl;
var
  i : Integer;
  str : PChar;
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
  Writeln();
  Result := JS_UNDEFINED;
end;

procedure RunCode();
var
  rt  : JSRuntime;
  ctx : JSContext;
  m   : JSModuleDef;
  global : JSValue;
  filename : PChar;
const
  std_hepler : PChar =
    'import * as std from ''std'';'#10+
    'import * as os from ''os'';'#10+
    'import * as Cmu from ''Cmu'';'#10+ // Our Custom Module.
    'globalThis.std = std;'#10+
    'globalThis.os = os;'#10+
    'globalThis.Cmu = Cmu;'#10;
begin
  rt := JS_NewRuntime;
  if Assigned(rt) then
  begin
    ctx := JS_NewContext(rt);
    if Assigned(rt) then
    begin
      // ES6 Module loader.
      JS_SetModuleLoaderFunc(rt, nil, @js_module_loader, nil);

      js_std_add_helpers(ctx,argc-1,@argv[1]);
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
      m := JS_NewCModule(ctx, 'Cmu', @Emu_init);
      JS_AddModuleExport(ctx,m,'ApiHook');

      eval_buf(ctx, std_hepler, strlen(std_hepler), '<global_helper>', False, JS_EVAL_TYPE_MODULE);


      global := JS_GetGlobalObject(ctx);

      // Define a function in the global context.
      JS_SetPropertyStr(ctx,global,'log',JS_NewCFunction(ctx, @logme, 'log', 1));

      JS_FreeValue(ctx, global);

      if ParamCount >= 1 then
      begin
        filename := PChar(ParamStr(1));
        eval_file(ctx,filename);
      end;

      js_std_loop(ctx);

      js_std_free_handlers(rt);
      JS_FreeContext(ctx);
    end;
    JS_FreeRuntime(rt);
  end;
  Writeln();
end;



begin
  { TODO -oColdzer0 : RawTest Bytes need to be updated }
  //RawTest; // If you unComment this comment the next line.
  RunCode;
end.

