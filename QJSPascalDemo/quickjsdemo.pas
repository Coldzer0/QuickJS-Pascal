{
  Native Class Demo - With module or Global context.
}

unit QuickJSDemo;

{$mode delphi}{$H+}{$M+}
{$PackRecords C}

interface

uses
  quickjs, quickjs_const;

// if you want to make a native class you must follow the following \
// tab, JClass, Class_id and Class_proto Must be a global variables.
var
  API_Class_id : JSClassID = 0;
  API_Class_Proto : JSValue;
  JClass : JSClassDef = (class_name:'ApiHook';finalizer:nil;gc_mark:nil;call:nil;exotic:nil);
  tab : array [0..1] of JSCFunctionListEntry;

procedure Emu_mod_init(ctx : JSContext; m : JSModuleDef); cdecl;
procedure Emu_mod_export(ctx : JSContext; m : JSModuleDef);cdecl;
function Emu_init(ctx : JSContext; m : JSModuleDef): Integer;cdecl;

procedure RegisterNativeClass(ctx : JSContext); cdecl;

implementation

function install(ctx : JSContext; {%H-}this_val : JSValueConst; argc : Integer; argv : PJSValueConstArr): JSValue; cdecl;
var
  Module,API : PChar;
  OnCallBack,res : JSValue;
begin
  if argc = 2 then
  begin
    Module := JS_ToCString(ctx, argv[0]);
    API := JS_ToCString(ctx, argv[1]);

    Writeln('Module : ',Module, ', API : ',API);

    OnCallBack := JS_GetPropertyStr(ctx,this_val,'OnCallBack');
    if Boolean(JS_IsFunction(ctx,OnCallBack)) then
    begin
      res := JS_Call(ctx,OnCallBack,this_val,argc,argv);
      Writeln('OnCallBack return = ',Boolean(JS_ToBool(ctx,res)));
    end;

    JS_FreeValue(ctx,OnCallBack);
    JS_FreeCString(ctx, Module);
    JS_FreeCString(ctx, API);
  end;
  Result := JS_UNDEFINED;
end;


function js_create_from_ctor(ctx : JSContext; ctor : JSValueConst; class_id : Integer; API_Class_Proto : JSValue): JSValue;cdecl;
var
  proto : JSValue;
begin
  if Boolean(JS_IsUndefined(ctor)) then
  begin
    proto := JS_DupValue(ctx, API_Class_Proto);
  end
  else
  begin
    proto := JS_GetProperty(ctx, ctor, JS_ATOM_prototype);
    if Boolean(JS_IsException(proto)) then
    begin
      Writeln('f*ck');
      exit(proto);
    end;
    if not Boolean(JS_IsObject(proto)) then
    begin
      JS_FreeValue(ctx, proto);
      proto := JS_DupValue(ctx, API_Class_Proto);
    end;
  end;
  Result := JS_NewObjectProtoClass(ctx, proto, class_id);
  JS_FreeValue(ctx, proto);
end;

function CConstructor(ctx : JSContext; new_target : JSValueConst; argc : Integer; argv : PJSValueConstArr): JSValue; cdecl;
begin
  //Result := js_create_from_ctor(ctx,new_target,API_Class_id,API_Class_Proto);
  Result := JS_NewObjectProtoClass(ctx,API_Class_Proto,API_Class_id);
end;

procedure Emu_mod_init(ctx : JSContext; m : JSModuleDef); cdecl;
var
  obj : JSValue;
begin

  JS_NewClassID(@API_Class_id);
  JS_NewClass(JS_GetRuntime(ctx),API_Class_id,@JClass);

  tab[0] := JS_CFUNC_DEF('install', 1, JSCFunctionType(@install));
  tab[1] := JS_PROP_INT32_DEF('version', 1337,JS_PROP_CONFIGURABLE);

  API_Class_Proto := JS_NewObject(ctx);
  JS_SetPropertyFunctionList(ctx,API_Class_Proto,@tab,Length(tab));

  JS_SetClassProto(ctx, API_Class_id, API_Class_Proto);

  obj := JS_NewCFunction2(ctx, @CConstructor, 'ApiHook', 1, JS_CFUNC_constructor, 0);
  JS_SetModuleExport(ctx, m, 'ApiHook', obj);
end;

procedure Emu_mod_export(ctx : JSContext; m : JSModuleDef); cdecl;
begin
  JS_AddModuleExport(ctx,m,'ApiHook');
end;

function Emu_init(ctx : JSContext; m : JSModuleDef): Integer;cdecl;
begin
  Emu_mod_init(ctx,m);
  Result := 0;
end;

procedure RegisterNativeClass(ctx : JSContext); cdecl;
var
  obj,global : JSValue;
begin

  JS_NewClassID(@API_Class_id);
  JS_NewClass(JS_GetRuntime(ctx),API_Class_id,@JClass);

  tab[0] := JS_CFUNC_DEF('install', 1, JSCFunctionType(@install));
  tab[1] := JS_PROP_INT32_DEF('version', 1337, JS_PROP_CONFIGURABLE);

  API_Class_Proto := JS_NewObject(ctx);
  JS_SetPropertyFunctionList(ctx,API_Class_Proto,@tab,Length(tab));

  JS_SetClassProto(ctx, API_Class_id, API_Class_Proto);

  obj := JS_NewCFunction2(ctx, @CConstructor, 'ApiHook', 1, JS_CFUNC_constructor, 0);

  global := JS_GetGlobalObject(ctx);
  JS_SetPropertyStr(ctx,global,'ApiHook',obj);
  JS_FreeValue(ctx,global);
end;

end.

