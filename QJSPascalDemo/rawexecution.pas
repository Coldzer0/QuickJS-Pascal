unit RawExecution;

{$mode delphi}

interface

uses
  Classes, SysUtils, quickjs, quickjs_const;

const
  fib : array [0..130] of byte =(
  $01,$03,$2c,$65,$78,$61,$6d,$70,
  $6c,$65,$73,$2f,$66,$69,$62,$5f,
  $6d,$6f,$64,$75,$6c,$65,$2e,$6a,
  $73,$06,$66,$69,$62,$02,$6e,$0e,
  $90,$03,$00,$01,$00,$00,$92,$03,
  $00,$00,$0d,$00,$02,$01,$9e,$01,
  $00,$00,$00,$01,$01,$01,$04,$00,
  $92,$03,$00,$01,$c3,$00,$e4,$29,
  $90,$03,$01,$04,$01,$00,$03,$14,
  $0d,$43,$02,$01,$92,$03,$01,$00,
  $01,$04,$01,$00,$1a,$01,$94,$03,
  $00,$01,$00,$92,$03,$00,$00,$d4,
  $b8,$ab,$ed,$03,$b8,$28,$d4,$b9,
  $b0,$ed,$03,$b9,$28,$e0,$d4,$b9,
  $a5,$f2,$e0,$d4,$ba,$a5,$f2,$a4,
  $28,$90,$03,$02,$06,$04,$1c,$08,
  $21,$08,$08
  );
  hello : array [0..160] of byte = (
  $01,$07,$30,$65,$78,$61,$6d,$70,
  $6c,$65,$73,$2f,$68,$65,$6c,$6c,
  $6f,$5f,$6d,$6f,$64,$75,$6c,$65,
  $2e,$6a,$73,$1e,$2e,$2f,$66,$69,
  $62,$5f,$6d,$6f,$64,$75,$6c,$65,
  $2e,$6a,$73,$06,$66,$69,$62,$0e,
  $63,$6f,$6e,$73,$6f,$6c,$65,$06,
  $6c,$6f,$67,$16,$48,$65,$6c,$6c,
  $6f,$20,$57,$6f,$72,$6c,$64,$10,
  $66,$69,$62,$28,$31,$30,$29,$3d,
  $0e,$90,$03,$01,$92,$03,$00,$00,
  $01,$00,$94,$03,$00,$0d,$00,$02,
  $01,$9e,$01,$00,$00,$00,$05,$01,
  $00,$2c,$00,$94,$03,$00,$0c,$36,
  $cb,$00,$00,$00,$40,$cc,$00,$00,
  $00,$04,$cd,$00,$00,$00,$24,$01,
  $00,$0e,$36,$cb,$00,$00,$00,$40,
  $cc,$00,$00,$00,$04,$ce,$00,$00,
  $00,$5f,$00,$00,$c0,$0a,$f2,$24,
  $02,$00,$29,$90,$03,$01,$02,$04,
  $62
  );


procedure RawTest();

implementation

procedure RawTest();
var
  rt  : JSRuntime;
  ctx : JSContext;
begin
  rt := JS_NewRuntime;
  if Assigned(rt) then
  begin
    ctx := JS_NewContextRaw(rt);
    JS_AddIntrinsicBaseObjects(ctx);
    js_std_add_helpers(ctx,argc,argv);
    js_std_eval_binary(ctx,@fib,Length(fib),JS_EVAL_BINARY_LOAD_ONLY);
    js_std_eval_binary(ctx,@hello,Length(hello),0);
    js_std_loop(ctx);
    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);
  end;
  Writeln();
end;

end.

