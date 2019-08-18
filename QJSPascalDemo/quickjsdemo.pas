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
function Emu_init(ctx : JSContext; m : JSModuleDef): Integer;cdecl;

procedure RegisterNativeClass(ctx : JSContext); cdecl;

implementation

function install(ctx : JSContext; {%H-}this_val : JSValueConst; argc : Integer; argv : PJSValueConstArr): JSValue; cdecl;
var
  Module,API : PChar;
  OnCallBack,res : JSValue;
  x : int64;
begin
  Result := JS_UNDEFINED;
  if argc >= 2 then
  begin
    try
      Writeln('');
      JS_ToInt64(ctx,@x,argv[2]);
      Writeln('X : ',x);
      Module := JS_ToCString(ctx, argv[0]);
      API := JS_ToCString(ctx, argv[1]);

      Writeln('API : ',Module, '.', API);

      OnCallBack := JS_GetPropertyStr(ctx,this_val,'OnCallBack');
      if JS_IsFunction(ctx,OnCallBack) then
      begin
        res := JS_Call(ctx,OnCallBack,this_val,argc,argv);
        if JS_IsException(res) then
           exit(res);
        Writeln('OnCallBack return = ', JS_ToBool(ctx,res));
      end;
    finally
      JS_FreeValue(ctx,OnCallBack);
      JS_FreeCString(ctx, Module);
      JS_FreeCString(ctx, API);
    end;
  end;
end;

function CConstructor(ctx : JSContext; new_target : JSValueConst; argc : Integer; argv : PJSValueConstArr): JSValue; cdecl;
begin
  Result := JS_NewObjectProtoClass(ctx,API_Class_Proto,API_Class_id);
end;

procedure Emu_mod_init(ctx : JSContext; m : JSModuleDef); cdecl;
var
  obj : JSValue;
begin
  obj := JS_NewCFunction2(ctx, @CConstructor, 'ApiHook', 1, JS_CFUNC_constructor, 0);
  JS_SetModuleExport(ctx, m, 'ApiHook', obj);
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

  // Create New Class id.
  JS_NewClassID(@API_Class_id);
  // Create the Class Name and other stuff.
  JS_NewClass(JS_GetRuntime(ctx),API_Class_id,@JClass);

  // Properties list.
  tab[0] := JS_CFUNC_DEF('install', 1, JSCFunctionType(@install));
  tab[1] := JS_PROP_INT32_DEF('version', 1337, JS_PROP_CONFIGURABLE);

  // New Object act as Prototype for the Class.
  API_Class_Proto := JS_NewObject(ctx);

  // Set list of Properties to the prototype Object.
  JS_SetPropertyFunctionList(ctx,API_Class_Proto,@tab,Length(tab));
  // Set single prototype - it's easier to define array this way :P.
  JS_SetPropertyStr(ctx,API_Class_Proto,'args',JS_NewArray(ctx));

  // Set the Prototype to the Class.
  JS_SetClassProto(ctx, API_Class_id, API_Class_Proto);

  // Set the Class native constructor.
  obj := JS_NewCFunction2(ctx, @CConstructor, 'ApiHook', 1, JS_CFUNC_constructor, 0);

  // Add the Class to Global Object so we can use it.
  global := JS_GetGlobalObject(ctx);
  JS_SetPropertyStr(ctx,global,'ApiHook',obj);
  JS_FreeValue(ctx,global);
end;

end.

