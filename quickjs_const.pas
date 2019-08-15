{
  FreePascal binding for QuickJS Engine.

  Copyright(c) 2019 Coldzer0 <Coldzer0 [at] protonmail.ch>

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
}

unit quickjs_const;

{$IfDef FPC}
  {$mode delphi}
{$EndIf}
interface

uses
  math;

const
  { all tags with a reference count are negative }
  JS_TAG_FIRST                = -10; { first negative tag }
  JS_TAG_BIG_INT              = -10;
  JS_TAG_BIG_FLOAT            = -9;
  JS_TAG_SYMBOL               = -8;
  JS_TAG_STRING               = -7;
  JS_TAG_SHAPE                = -6; { used internally during GC }
  JS_TAG_ASYNC_FUNCTION       = -5; { used internally during GC }
  JS_TAG_VAR_REF              = -4; { used internally during GC }
  JS_TAG_MODULE               = -3; { used internally }
  JS_TAG_FUNCTION_BYTECODE    = -2; { used internally }
  JS_TAG_OBJECT               = -1;

  JS_TAG_INT                  = 0;
  JS_TAG_BOOL                 = 1;
  JS_TAG_NULL                 = 2;
  JS_TAG_UNDEFINED            = 3;
  JS_TAG_UNINITIALIZED        = 4;
  JS_TAG_CATCH_OFFSET         = 5;
  JS_TAG_EXCEPTION            = 6;
  JS_TAG_FLOAT64              = 7;
  { any larger tag is FLOAT64 if JS_NAN_BOXING }

  JS_FLOAT64_NAN = NaN;


const
  { flags for object properties }
  JS_PROP_CONFIGURABLE  = (1 shl 0);
  JS_PROP_WRITABLE      = (1 shl 1);
  JS_PROP_ENUMERABLE    = (1 shl 2);
  JS_PROP_C_W_E         = (JS_PROP_CONFIGURABLE or JS_PROP_WRITABLE or JS_PROP_ENUMERABLE);
  JS_PROP_LENGTH        = (1 shl 3); { used internally in Arrays }
  JS_PROP_TMASK         = (3 shl 4); { mask for NORMAL, GETSET, VARREF, AUTOINIT }
  JS_PROP_NORMAL        = (0 shl 4);
  JS_PROP_GETSET        = (1 shl 4);
  JS_PROP_VARREF        = (2 shl 4); { used internally }
  JS_PROP_AUTOINIT      = (3 shl 4); { used internally }

  { flags for JS_DefineProperty }
  JS_PROP_HAS_SHIFT        = 8;
  JS_PROP_HAS_CONFIGURABLE = (1 shl 8);
  JS_PROP_HAS_WRITABLE     = (1 shl 9);
  JS_PROP_HAS_ENUMERABLE   = (1 shl 10);
  JS_PROP_HAS_GET          = (1 shl 11);
  JS_PROP_HAS_SET          = (1 shl 12);
  JS_PROP_HAS_VALUE        = (1 shl 13);

  { throw an exception if false would be returned /
   (JS_DefineProperty/JS_SetProperty) }
  JS_PROP_THROW            = (1 shl 14);
  { throw an exception if false would be returned in strict mode /
     (JS_SetProperty) }
  JS_PROP_THROW_STRICT     = (1 shl 15);
  JS_PROP_NO_ADD           = (1 shl 16); { internal use }
  JS_PROP_NO_EXOTIC        = (1 shl 17); { internal use }

  JS_DEFAULT_STACK_SIZE    = (256 * 1024);

  { JS_Eval() flags }
  JS_EVAL_TYPE_GLOBAL      = (0 shl 0); { global code (default) }
  JS_EVAL_TYPE_MODULE      = (1 shl 0); { module code }
  JS_EVAL_TYPE_DIRECT      = (2 shl 0); { direct call (internal use) }
  JS_EVAL_TYPE_INDIRECT    = (3 shl 0); { indirect call (internal use) }
  JS_EVAL_TYPE_MASK        = (3 shl 0);

  JS_EVAL_FLAG_STRICT       = (1 shl 3); { force 'strict' mode }
  JS_EVAL_FLAG_STRIP        = (1 shl 4); { force 'strip' mode }
  JS_EVAL_FLAG_COMPILE_ONLY = (1 shl 5); { internal use }


  JS_EVAL_BINARY_LOAD_ONLY  = (1 shl 0); { only load the module }

  { Object Writer/Reader (currently only used to handle precompiled code)  }
  JS_WRITE_OBJ_BYTECODE     = (1 shl 0); { allow function/module }
  JS_WRITE_OBJ_BSWAP        = (1 shl 1); { byte swapped output }

  JS_READ_OBJ_BYTECODE      = (1 shl 0); { allow function/module  }
  JS_READ_OBJ_ROM_DATA      = (1 shl 1); { avoid duplicating 'buf' data  }

  { C property definition }
  JS_DEF_CFUNC = 0;
  JS_DEF_CGETSET = 1;
  JS_DEF_CGETSET_MAGIC = 2;
  JS_DEF_PROP_STRING = 3;
  JS_DEF_PROP_INT32 = 4;
  JS_DEF_PROP_INT64 = 5;
  JS_DEF_PROP_DOUBLE = 6;
  JS_DEF_PROP_UNDEFINED = 7;
  JS_DEF_OBJECT = 8;
  JS_DEF_ALIAS = 9;


  { C function definition }
  { JSCFunctionEnum }
  JS_CFUNC_generic = 0;
  JS_CFUNC_generic_magic = 1;
  JS_CFUNC_constructor = 2;
  JS_CFUNC_constructor_magic = 3;
  JS_CFUNC_constructor_or_func = 4;
  JS_CFUNC_constructor_or_func_magic = 5;
  JS_CFUNC_f_f = 6;
  JS_CFUNC_f_f_f = 7;
  JS_CFUNC_getter = 8;
  JS_CFUNC_setter = 9;
  JS_CFUNC_getter_magic = 10;
  JS_CFUNC_setter_magic = 11;
  JS_CFUNC_iterator_next = 12;

  JS_GPN_STRING_MASK  = (1 shl 0);
  JS_GPN_SYMBOL_MASK  = (1 shl 1);
  JS_GPN_PRIVATE_MASK = (1 shl 2);

  { only include the enumerable properties }
  JS_GPN_ENUM_ONLY = (1 shl 4);
  { set theJSPropertyEnum.is_enumerable field }
  JS_GPN_SET_ENUM = (1 shl 5);

  // TODO: write parser for atom header.
  { ATOM }
  JS_ATOM_prototype   = 58;
  JS_ATOM_constructor = 59;

implementation

end.

