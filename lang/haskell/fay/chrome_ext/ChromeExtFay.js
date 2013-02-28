/** @constructor
*/
var ChromeExtFay = function(){
/*******************************************************************************
 * Thunks.
 */

// Force a thunk (if it is a thunk) until WHNF.
function Fay$$_(thunkish,nocache){
  while (thunkish instanceof Fay$$$) {
    thunkish = thunkish.force(nocache);
  }
  return thunkish;
}

// Apply a function to arguments (see method2 in Fay.hs).
function Fay$$__(){
  var f = arguments[0];
  for (var i = 1, len = arguments.length; i < len; i++) {
    f = (f instanceof Fay$$$? Fay$$_(f) : f)(arguments[i]);
  }
  return f;
}

// Thunk object.
function Fay$$$(value){
  this.forced = false;
  this.value = value;
}

// Force the thunk.
Fay$$$.prototype.force = function(nocache) {
  return nocache ?
    this.value() :
    (this.forced ?
     this.value :
     (this.value = this.value(), this.forced = true, this.value));
};


function Fay$$seq(x) {
  return function(y) {
    Fay$$_(x,false);
    return y;
  }
}

function Fay$$seq$36$uncurried(x,y) {
  Fay$$_(x,false);
  return y;
}

/*******************************************************************************
 * Monad.
 */

function Fay$$Monad(value){
  this.value = value;
}

// This is used directly from Fay, but can be rebound or shadowed. See primOps in Types.hs.
// >>
function Fay$$then(a){
  return function(b){
    return Fay$$bind(a)(function(_){
      return b;
    });
  };
}

// This is used directly from Fay, but can be rebound or shadowed. See primOps in Types.hs.
// >>
function Fay$$then$36$uncurried(a,b){
  return Fay$$bind$36$uncurried(a,function(_){ return b; });
}

// >>=
// This is used directly from Fay, but can be rebound or shadowed. See primOps in Types.hs.
function Fay$$bind(m){
  return function(f){
    return new Fay$$$(function(){
      var monad = Fay$$_(m,true);
      return Fay$$_(f)(monad.value);
    });
  };
}

// >>=
// This is used directly from Fay, but can be rebound or shadowed. See primOps in Types.hs.
function Fay$$bind$36$uncurried(m,f){
  return new Fay$$$(function(){
    var monad = Fay$$_(m,true);
    return Fay$$_(f)(monad.value);
  });
}

// This is used directly from Fay, but can be rebound or shadowed.
function Fay$$$_return(a){
  return new Fay$$Monad(a);
}

// Allow the programmer to access thunk forcing directly.
function Fay$$force(thunk){
  return function(type){
    return new Fay$$$(function(){
      Fay$$_(thunk,type);
      return new Fay$$Monad(Fay$$unit);
    })
  }
}

// This is used directly from Fay, but can be rebound or shadowed.
function Fay$$return$36$uncurried(a){
  return new Fay$$Monad(a);
}

// Unit: ().
var Fay$$unit = null;

/*******************************************************************************
 * Serialization.
 * Fay <-> JS. Should be bijective.
 */

// Serialize a Fay object to JS.
function Fay$$fayToJs(type,fayObj){
  var base = type[0];
  var args = type[1];
  var jsObj;
  if(base == "action") {
    // A nullary monadic action. Should become a nullary JS function.
    // Fay () -> function(){ return ... }
    jsObj = function(){
      return Fay$$fayToJs(args[0],Fay$$_(fayObj,true).value);
    };

  }
  else if(base == "function") {
    // A proper function.
    jsObj = function(){
      var fayFunc = fayObj;
      var return_type = args[args.length-1];
      var len = args.length;
      // If some arguments.
      if (len > 1) {
        // Apply to all the arguments.
        fayFunc = Fay$$_(fayFunc,true);
        // TODO: Perhaps we should throw an error when JS
        // passes more arguments than Haskell accepts.
        for (var i = 0, len = len; i < len - 1 && fayFunc instanceof Function; i++) {
          // Unserialize the JS values to Fay for the Fay callback.
          fayFunc = Fay$$_(fayFunc(Fay$$jsToFay(args[i],arguments[i])),true);
        }
        // Finally, serialize the Fay return value back to JS.
        var return_base = return_type[0];
        var return_args = return_type[1];
        // If it's a monadic return value, get the value instead.
        if(return_base == "action") {
          return Fay$$fayToJs(return_args[0],fayFunc.value);
        }
        // Otherwise just serialize the value direct.
        else {
          return Fay$$fayToJs(return_type,fayFunc);
        }
      } else {
        throw new Error("Nullary function?");
      }
    };

  }
  else if(base == "string") {
    jsObj = Fay$$fayToJs_string(fayObj);
  }
  else if(base == "list") {
    // Serialize Fay list to JavaScript array.
    var arr = [];
    fayObj = Fay$$_(fayObj);
    while(fayObj instanceof Fay$$Cons) {
      arr.push(Fay$$fayToJs(args[0],fayObj.car));
      fayObj = Fay$$_(fayObj.cdr);
    }
    jsObj = arr;

  }
  else if(base == "tuple") {
    // Serialize Fay tuple to JavaScript array.
    var arr = [];
    fayObj = Fay$$_(fayObj);
    var i = 0;
    while(fayObj instanceof Fay$$Cons) {
      arr.push(Fay$$fayToJs(args[i++],fayObj.car));
      fayObj = Fay$$_(fayObj.cdr);
    }
    jsObj = arr;

  }
  else if(base == "defined") {
    fayObj = Fay$$_(fayObj);
    if (fayObj instanceof $_Language$Fay$FFI$Undefined) {
      jsObj = undefined;
    } else {
      jsObj = Fay$$fayToJsUserDefined(args[0],fayObj["slot1"]);
    }

  }
  else if(base == "nullable") {
    fayObj = Fay$$_(fayObj);
    if (fayObj instanceof $_Language$Fay$FFI$Null) {
      jsObj = null;
    } else {
      jsObj = Fay$$fayToJsUserDefined(args[0],fayObj["slot1"]);
    }

  }
  else if(base == "double" || base == "int" || base == "bool") {
    // Bools are unboxed.
    jsObj = Fay$$_(fayObj);

  }
  else if(base == "ptr" || base == "unknown")
    return fayObj;
  else if(base == "automatic" || base == "user") {
    if(fayObj instanceof Fay$$$)
      fayObj = Fay$$_(fayObj);
    jsObj = Fay$$fayToJsUserDefined(type,fayObj);

  }
  else
    throw new Error("Unhandled Fay->JS translation type: " + base);
  return jsObj;
}

// Specialized serializer for string.
function Fay$$fayToJs_string(fayObj){
  // Serialize Fay string to JavaScript string.
  var str = "";
  fayObj = Fay$$_(fayObj);
  while(fayObj instanceof Fay$$Cons) {
    str += fayObj.car;
    fayObj = Fay$$_(fayObj.cdr);
  }
  return str;
};
function Fay$$jsToFay_string(x){
  return Fay$$list(x)
};

// Special num/bool serializers.
function Fay$$jsToFay_int(x){return x;}
function Fay$$jsToFay_double(x){return x;}
function Fay$$jsToFay_bool(x){return x;}

function Fay$$fayToJs_int(x){return Fay$$_(x);}
function Fay$$fayToJs_double(x){return Fay$$_(x);}
function Fay$$fayToJs_bool(x){return Fay$$_(x);}

// Unserialize an object from JS to Fay.
function Fay$$jsToFay(type,jsObj){
  var base = type[0];
  var args = type[1];
  var fayObj;
  if(base == "action") {
    // Unserialize a "monadic" JavaScript return value into a monadic value.
    fayObj = new Fay$$Monad(Fay$$jsToFay(args[0],jsObj));

  }
  else if(base == "string") {
    // Unserialize a JS string into Fay list (String).
    fayObj = Fay$$list(jsObj);
  }
  else if(base == "list") {
    // Unserialize a JS array into a Fay list ([a]).
    var serializedList = [];
    for (var i = 0, len = jsObj.length; i < len; i++) {
      // Unserialize each JS value into a Fay value, too.
      serializedList.push(Fay$$jsToFay(args[0],jsObj[i]));
    }
    // Pop it all in a Fay list.
    fayObj = Fay$$list(serializedList);

  }
  else if(base == "tuple") {
    // Unserialize a JS array into a Fay tuple ((a,b,c,...)).
    var serializedTuple = [];
    for (var i = 0, len = jsObj.length; i < len; i++) {
      // Unserialize each JS value into a Fay value, too.
      serializedTuple.push(Fay$$jsToFay(args[i],jsObj[i]));
    }
    // Pop it all in a Fay list.
    fayObj = Fay$$list(serializedTuple);

  }
  else if(base == "defined") {
    if (jsObj === undefined) {
      fayObj = new $_Language$Fay$FFI$Undefined();
    } else {
      fayObj = new $_Language$Fay$FFI$Defined(Fay$$jsToFay(args[0],jsObj));
    }

  }
  else if(base == "nullable") {
    if (jsObj === null) {
      fayObj = new $_Language$Fay$FFI$Null();
    } else {
      fayObj = new $_Language$Fay$FFI$Nullable(Fay$$jsToFay(args[0],jsObj));
    }

  }
  else if(base == "int") {
    // Int are unboxed, so there's no forcing to do.
    // But we can do validation that the int has no decimal places.
    // E.g. Math.round(x)!=x? throw "NOT AN INTEGER, GET OUT!"
    fayObj = Math.round(jsObj);
    if(fayObj!==jsObj) throw "Argument " + jsObj + " is not an integer!";

  }
  else if (base == "double" ||
           base == "bool" ||
           base ==  "ptr" ||
           base ==  "unknown") {
    return jsObj;
  }
  else if(base == "automatic" || base == "user") {
    if (jsObj && jsObj['instance']) {
      fayObj = Fay$$jsToFayUserDefined(type,jsObj);
    }
    else
      fayObj = jsObj;

  }
  else { throw new Error("Unhandled JS->Fay translation type: " + base); }
  return fayObj;
}

/*******************************************************************************
 * Lists.
 */

// Cons object.
function Fay$$Cons(car,cdr){
  this.car = car;
  this.cdr = cdr;
}

// Make a list.
function Fay$$list(xs){
  var out = null;
  for(var i=xs.length-1; i>=0;i--)
    out = new Fay$$Cons(xs[i],out);
  return out;
}

// Built-in list cons.
function Fay$$cons(x){
  return function(y){
    return new Fay$$Cons(x,y);
  };
}

// List index.
// `list' is already forced by the time it's passed to this function.
// `list' cannot be null and `index' cannot be out of bounds.
function Fay$$index(index,list){
  for(var i = 0; i < index; i++) {
    list = Fay$$_(list.cdr);
  }
  return list.car;
}

// List length.
// `list' is already forced by the time it's passed to this function.
function Fay$$listLen(list,max){
  for(var i = 0; list !== null && i < max + 1; i++) {
    list = Fay$$_(list.cdr);
  }
  return i == max;
}

/*******************************************************************************
 * Numbers.
 */

// Built-in *.
function Fay$$mult(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) * Fay$$_(y);
    });
  };
}

function Fay$$mult$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) * Fay$$_(y);
  });

}

// Built-in +.
function Fay$$add(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) + Fay$$_(y);
    });
  };
}

// Built-in +.
function Fay$$add$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) + Fay$$_(y);
  });

}

// Built-in -.
function Fay$$sub(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) - Fay$$_(y);
    });
  };
}
// Built-in -.
function Fay$$sub$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) - Fay$$_(y);
  });

}

// Built-in /.
function Fay$$divi(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) / Fay$$_(y);
    });
  };
}

// Built-in /.
function Fay$$divi$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) / Fay$$_(y);
  });

}

/*******************************************************************************
 * Booleans.
 */

// Are two values equal?
function Fay$$equal(lit1, lit2) {
  // Simple case
  lit1 = Fay$$_(lit1);
  lit2 = Fay$$_(lit2);
  if (lit1 === lit2) {
    return true;
  }
  // General case
  if (lit1 instanceof Array) {
    if (lit1.length != lit2.length) return false;
    for (var len = lit1.length, i = 0; i < len; i++) {
      if (!Fay$$equal(lit1[i], lit2[i])) return false;
    }
    return true;
  } else if (lit1 instanceof Fay$$Cons && lit2 instanceof Fay$$Cons) {
    do {
      if (!Fay$$equal(lit1.car,lit2.car))
        return false;
      lit1 = Fay$$_(lit1.cdr), lit2 = Fay$$_(lit2.cdr);
      if (lit1 === null || lit2 === null)
        return lit1 === lit2;
    } while (true);
  } else if (typeof lit1 == 'object' && typeof lit2 == 'object' && lit1 && lit2 &&
             lit1.constructor === lit2.constructor) {
    for(var x in lit1) {
      if(!(lit1.hasOwnProperty(x) && lit2.hasOwnProperty(x) &&
           Fay$$equal(lit1[x],lit2[x])))
        return false;
    }
    return true;
  } else {
    return false;
  }
}

// Built-in ==.
function Fay$$eq(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$equal(x,y);
    });
  };
}

function Fay$$eq$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$equal(x,y);
  });

}

// Built-in /=.
function Fay$$neq(x){
  return function(y){
    return new Fay$$$(function(){
      return !(Fay$$equal(x,y));
    });
  };
}

// Built-in /=.
function Fay$$neq$36$uncurried(x,y){

  return new Fay$$$(function(){
    return !(Fay$$equal(x,y));
  });

}

// Built-in >.
function Fay$$gt(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) > Fay$$_(y);
    });
  };
}

// Built-in >.
function Fay$$gt$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) > Fay$$_(y);
  });

}

// Built-in <.
function Fay$$lt(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) < Fay$$_(y);
    });
  };
}


// Built-in <.
function Fay$$lt$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) < Fay$$_(y);
  });

}


// Built-in >=.
function Fay$$gte(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) >= Fay$$_(y);
    });
  };
}

// Built-in >=.
function Fay$$gte$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) >= Fay$$_(y);
  });

}

// Built-in <=.
function Fay$$lte(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) <= Fay$$_(y);
    });
  };
}

// Built-in <=.
function Fay$$lte$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) <= Fay$$_(y);
  });

}

// Built-in &&.
function Fay$$and(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) && Fay$$_(y);
    });
  };
}

// Built-in &&.
function Fay$$and$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) && Fay$$_(y);
  });
  ;
}

// Built-in ||.
function Fay$$or(x){
  return function(y){
    return new Fay$$$(function(){
      return Fay$$_(x) || Fay$$_(y);
    });
  };
}

// Built-in ||.
function Fay$$or$36$uncurried(x,y){

  return new Fay$$$(function(){
    return Fay$$_(x) || Fay$$_(y);
  });

}

/*******************************************************************************
 * Mutable references.
 */

// Make a new mutable reference.
function Fay$$Ref(x){
  this.value = x;
}

// Write to the ref.
function Fay$$writeRef(ref,x){
  ref.value = x;
}

// Get the value from the ref.
function Fay$$readRef(ref,x){
  return ref.value;
}

/*******************************************************************************
 * Dates.
 */
function Fay$$date(str){
  return window.Date.parse(str);
}

/*******************************************************************************
 * Application code.
 */

var Language$Fay$FFI$Nullable = function(slot1){return new Fay$$$(function(){return new $_Language$Fay$FFI$Nullable(slot1);});};var Language$Fay$FFI$Null = new Fay$$$(function(){return new $_Language$Fay$FFI$Null();});var Language$Fay$FFI$Defined = function(slot1){return new Fay$$$(function(){return new $_Language$Fay$FFI$Defined(slot1);});};var Language$Fay$FFI$Undefined = new Fay$$$(function(){return new $_Language$Fay$FFI$Undefined();});var Prelude$Just = function(slot1){return new Fay$$$(function(){return new $_Prelude$Just(slot1);});};var Prelude$Nothing = new Fay$$$(function(){return new $_Prelude$Nothing();});var Prelude$Left = function(slot1){return new Fay$$$(function(){return new $_Prelude$Left(slot1);});};var Prelude$Right = function(slot1){return new Fay$$$(function(){return new $_Prelude$Right(slot1);});};var Prelude$maybe = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){if (Fay$$_($p3) instanceof $_Prelude$Nothing) {var m = $p1;return m;}if (Fay$$_($p3) instanceof $_Prelude$Just) {var x = Fay$$_($p3).slot1;var f = $p2;return Fay$$_(f)(x);}throw ["unhandled case in maybe",[$p1,$p2,$p3]];});};};};var Prelude$Ratio = function(slot1){return function(slot2){return new Fay$$$(function(){return new $_Prelude$Ratio(slot1,slot2);});};};var Prelude$$62$$62$$61$ = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],Fay$$bind(Fay$$fayToJs(["action",[["unknown"]]],$p1))(Fay$$fayToJs(["function",[["unknown"],["action",[["unknown"]]]]],$p2))));});};};var Prelude$$62$$62$ = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],Fay$$then(Fay$$fayToJs(["action",[["unknown"]]],$p1))(Fay$$fayToJs(["action",[["unknown"]]],$p2))));});};};var Prelude$$_return = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],Fay$$return(Fay$$fayToJs(["unknown"],$p1))));});};var Prelude$when = function($p1){return function($p2){return new Fay$$$(function(){var m = $p2;var p = $p1;return Fay$$_(p) ? Fay$$_(Fay$$_(Fay$$then)(m))(Fay$$_(Fay$$$_return)(Fay$$unit)) : Fay$$_(Fay$$$_return)(Fay$$unit);});};};var Prelude$forM_ = function($p1){return function($p2){return new Fay$$$(function(){var m = $p2;var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(m)(x)))(Fay$$_(Fay$$_(Prelude$forM_)(xs))(m));}if (Fay$$_($p1) === null) {return Fay$$_(Fay$$$_return)(Fay$$unit);}throw ["unhandled case in forM_",[$p1,$p2]];});};};var Prelude$mapM_ = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var m = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(m)(x)))(Fay$$_(Fay$$_(Prelude$mapM_)(m))(xs));}if (Fay$$_($p2) === null) {return Fay$$_(Fay$$$_return)(Fay$$unit);}throw ["unhandled case in mapM_",[$p1,$p2]];});};};var Prelude$$61$$60$$60$ = function($p1){return function($p2){return new Fay$$$(function(){var x = $p2;var f = $p1;return Fay$$_(Fay$$_(Fay$$bind)(x))(f);});};};var Prelude$sequence = function($p1){return new Fay$$$(function(){var ms = $p1;return (function(){var k = function($p1){return function($p2){return new Fay$$$(function(){var m$39$ = $p2;var m = $p1;return Fay$$_(Fay$$_(Fay$$bind)(m))(function($p1){var x = $p1;return Fay$$_(Fay$$_(Fay$$bind)(m$39$))(function($p1){var xs = $p1;return Fay$$_(Fay$$$_return)(Fay$$_(Fay$$_(Fay$$cons)(x))(xs));});});});};};return Fay$$_(Fay$$_(Fay$$_(Prelude$foldr)(k))(Fay$$_(Fay$$$_return)(null)))(ms);})();});};var Prelude$sequence_ = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Fay$$$_return)(Fay$$unit);}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var m = $tmp1.car;var ms = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$then)(m))(Fay$$_(Prelude$sequence_)(ms));}throw ["unhandled case in sequence_",[$p1]];});};var Prelude$GT = new Fay$$$(function(){return new $_Prelude$GT();});var Prelude$LT = new Fay$$$(function(){return new $_Prelude$LT();});var Prelude$EQ = new Fay$$$(function(){return new $_Prelude$EQ();});var Prelude$compare = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$gt)(x))(y)) ? Prelude$GT : Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(x))(y)) ? Prelude$LT : Prelude$EQ;});};};var Prelude$succ = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$add)(x))(1);});};var Prelude$pred = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$sub)(x))(1);});};var Prelude$enumFrom = function($p1){return new Fay$$$(function(){var i = $p1;return Fay$$_(Fay$$_(Fay$$cons)(i))(Fay$$_(Prelude$enumFrom)(Fay$$_(Fay$$_(Fay$$add)(i))(1)));});};var Prelude$enumFromTo = function($p1){return function($p2){return new Fay$$$(function(){var n = $p2;var i = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$gt)(i))(n)) ? null : Fay$$_(Fay$$_(Fay$$cons)(i))(Fay$$_(Fay$$_(Prelude$enumFromTo)(Fay$$_(Fay$$_(Fay$$add)(i))(1)))(n));});};};var Prelude$enumFromBy = function($p1){return function($p2){return new Fay$$$(function(){var by = $p2;var fr = $p1;return Fay$$_(Fay$$_(Fay$$cons)(fr))(Fay$$_(Fay$$_(Prelude$enumFromBy)(Fay$$_(Fay$$_(Fay$$add)(fr))(by)))(by));});};};var Prelude$enumFromThen = function($p1){return function($p2){return new Fay$$$(function(){var th = $p2;var fr = $p1;return Fay$$_(Fay$$_(Prelude$enumFromBy)(fr))(Fay$$_(Fay$$_(Fay$$sub)(th))(fr));});};};var Prelude$enumFromByTo = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var to = $p3;var by = $p2;var fr = $p1;return (function(){var neg = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(x))(to)) ? null : Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(neg)(Fay$$_(Fay$$_(Fay$$add)(x))(by)));});};var pos = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$gt)(x))(to)) ? null : Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(pos)(Fay$$_(Fay$$_(Fay$$add)(x))(by)));});};return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(by))(0)) ? Fay$$_(neg)(fr) : Fay$$_(pos)(fr);})();});};};};var Prelude$enumFromThenTo = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var to = $p3;var th = $p2;var fr = $p1;return Fay$$_(Fay$$_(Fay$$_(Prelude$enumFromByTo)(fr))(Fay$$_(Fay$$_(Fay$$sub)(th))(fr)))(to);});};};};var Prelude$fromIntegral = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Fay$$fayToJs_int($p1));});};var Prelude$fromInteger = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Fay$$fayToJs_int($p1));});};var Prelude$not = function($p1){return new Fay$$$(function(){var p = $p1;return Fay$$_(p) ? false : true;});};var Prelude$otherwise = true;var Prelude$show = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_string(JSON.stringify(Fay$$fayToJs(["automatic"],$p1)));});};var Prelude$error = function($p1){return new Fay$$$(function(){return Fay$$jsToFay(["unknown"],(function() { throw Fay$$fayToJs_string($p1) })());});};var Prelude$$_undefined = new Fay$$$(function(){return Fay$$_(Prelude$error)(Fay$$list("Prelude.undefined"));});var Prelude$either = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){if (Fay$$_($p3) instanceof $_Prelude$Left) {var a = Fay$$_($p3).slot1;var f = $p1;return Fay$$_(f)(a);}if (Fay$$_($p3) instanceof $_Prelude$Right) {var b = Fay$$_($p3).slot1;var g = $p2;return Fay$$_(g)(b);}throw ["unhandled case in either",[$p1,$p2,$p3]];});};};};var Prelude$until = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var x = $p3;var f = $p2;var p = $p1;return Fay$$_(Fay$$_(p)(x)) ? x : Fay$$_(Fay$$_(Fay$$_(Prelude$until)(p))(f))(Fay$$_(f)(x));});};};};var Prelude$$36$$33$ = function($p1){return function($p2){return new Fay$$$(function(){var x = $p2;var f = $p1;return Fay$$_(Fay$$_(Fay$$seq)(x))(Fay$$_(f)(x));});};};var Prelude$$_const = function($p1){return function($p2){return new Fay$$$(function(){var a = $p1;return a;});};};var Prelude$id = function($p1){return new Fay$$$(function(){var x = $p1;return x;});};var Prelude$$46$ = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var x = $p3;var g = $p2;var f = $p1;return Fay$$_(f)(Fay$$_(g)(x));});};};};var Prelude$$36$ = function($p1){return function($p2){return new Fay$$$(function(){var x = $p2;var f = $p1;return Fay$$_(f)(x);});};};var Prelude$flip = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var y = $p3;var x = $p2;var f = $p1;return Fay$$_(Fay$$_(f)(y))(x);});};};};var Prelude$curry = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var y = $p3;var x = $p2;var f = $p1;return Fay$$_(f)(Fay$$list([x,y]));});};};};var Prelude$uncurry = function($p1){return function($p2){return new Fay$$$(function(){var p = $p2;var f = $p1;return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var x = Fay$$index(0,Fay$$_($tmp1));var y = Fay$$index(1,Fay$$_($tmp1));return Fay$$_(Fay$$_(f)(x))(y);}return (function(){ throw (["unhandled case",$tmp1]); })();})(p);});};};var Prelude$snd = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var x = Fay$$index(1,Fay$$_($p1));return x;}throw ["unhandled case in snd",[$p1]];});};var Prelude$fst = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var x = Fay$$index(0,Fay$$_($p1));return x;}throw ["unhandled case in fst",[$p1]];});};var Prelude$div = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;if (Fay$$_(Fay$$_(Fay$$_(Fay$$and)(Fay$$_(Fay$$_(Fay$$gt)(x))(0)))(Fay$$_(Fay$$_(Fay$$lt)(y))(0)))) {return Fay$$_(Fay$$_(Fay$$sub)(Fay$$_(Fay$$_(Prelude$quot)(Fay$$_(Fay$$_(Fay$$sub)(x))(1)))(y)))(1);} else {if (Fay$$_(Fay$$_(Fay$$_(Fay$$and)(Fay$$_(Fay$$_(Fay$$lt)(x))(0)))(Fay$$_(Fay$$_(Fay$$gt)(y))(0)))) {return Fay$$_(Fay$$_(Fay$$sub)(Fay$$_(Fay$$_(Prelude$quot)(Fay$$_(Fay$$_(Fay$$add)(x))(1)))(y)))(1);}}var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Prelude$quot)(x))(y);});};};var Prelude$mod = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;if (Fay$$_(Fay$$_(Fay$$_(Fay$$and)(Fay$$_(Fay$$_(Fay$$gt)(x))(0)))(Fay$$_(Fay$$_(Fay$$lt)(y))(0)))) {return Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Prelude$rem)(Fay$$_(Fay$$_(Fay$$sub)(x))(1)))(y)))(y)))(1);} else {if (Fay$$_(Fay$$_(Fay$$_(Fay$$and)(Fay$$_(Fay$$_(Fay$$lt)(x))(0)))(Fay$$_(Fay$$_(Fay$$gt)(y))(0)))) {return Fay$$_(Fay$$_(Fay$$sub)(Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Prelude$rem)(Fay$$_(Fay$$_(Fay$$add)(x))(1)))(y)))(y)))(1);}}var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Prelude$rem)(x))(y);});};};var Prelude$divMod = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;if (Fay$$_(Fay$$_(Fay$$_(Fay$$and)(Fay$$_(Fay$$_(Fay$$gt)(x))(0)))(Fay$$_(Fay$$_(Fay$$lt)(y))(0)))) {return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var q = Fay$$index(0,Fay$$_($tmp1));var r = Fay$$index(1,Fay$$_($tmp1));return Fay$$list([Fay$$_(Fay$$_(Fay$$sub)(q))(1),Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Fay$$add)(r))(y)))(1)]);}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Fay$$_(Prelude$quotRem)(Fay$$_(Fay$$_(Fay$$sub)(x))(1)))(y));} else {if (Fay$$_(Fay$$_(Fay$$_(Fay$$and)(Fay$$_(Fay$$_(Fay$$lt)(x))(0)))(Fay$$_(Fay$$_(Fay$$gt)(y))(1)))) {return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var q = Fay$$index(0,Fay$$_($tmp1));var r = Fay$$index(1,Fay$$_($tmp1));return Fay$$list([Fay$$_(Fay$$_(Fay$$sub)(q))(1),Fay$$_(Fay$$_(Fay$$sub)(Fay$$_(Fay$$_(Fay$$add)(r))(y)))(1)]);}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Fay$$_(Prelude$quotRem)(Fay$$_(Fay$$_(Fay$$add)(x))(1)))(y));}}var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Prelude$quotRem)(x))(y);});};};var Prelude$min = function($p1){return function($p2){return new Fay$$$(function(){return Fay$$jsToFay(["unknown"],Math.min(Fay$$fayToJs(["unknown"],$p1),Fay$$fayToJs(["unknown"],$p2)));});};};var Prelude$max = function($p1){return function($p2){return new Fay$$$(function(){return Fay$$jsToFay(["unknown"],Math.max(Fay$$fayToJs(["unknown"],$p1),Fay$$fayToJs(["unknown"],$p2)));});};};var Prelude$recip = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$divi)(1))(x);});};var Prelude$negate = function($p1){return new Fay$$$(function(){var x = $p1;return (-(Fay$$_(x)));});};var Prelude$abs = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(x))(0)) ? Fay$$_(Prelude$negate)(x) : x;});};var Prelude$signum = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$gt)(x))(0)) ? 1 : Fay$$_(Fay$$_(Fay$$_(Fay$$eq)(x))(0)) ? 0 : (-(1));});};var Prelude$pi = new Fay$$$(function(){return Fay$$jsToFay_double(Math.PI);});var Prelude$exp = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.exp(Fay$$fayToJs_double($p1)));});};var Prelude$sqrt = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.sqrt(Fay$$fayToJs_double($p1)));});};var Prelude$log = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.log(Fay$$fayToJs_double($p1)));});};var Prelude$$42$$42$ = new Fay$$$(function(){return Prelude$unsafePow;});var Prelude$$94$$94$ = new Fay$$$(function(){return Prelude$unsafePow;});var Prelude$unsafePow = function($p1){return function($p2){return new Fay$$$(function(){return Fay$$jsToFay(["unknown"],Math.pow(Fay$$fayToJs(["unknown"],$p1),Fay$$fayToJs(["unknown"],$p2)));});};};var Prelude$$94$ = function($p1){return function($p2){return new Fay$$$(function(){var b = $p2;var a = $p1;if (Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(b))(0))) {return Fay$$_(Prelude$error)(Fay$$list("(^): negative exponent"));} else {if (Fay$$_(Fay$$_(Fay$$_(Fay$$eq)(b))(0))) {return 1;} else {if (Fay$$_(Fay$$_(Prelude$even)(b))) {return (function(){var x = new Fay$$$(function(){return Fay$$_(Fay$$_(Prelude$$94$)(a))(Fay$$_(Fay$$_(Prelude$quot)(b))(2));});return Fay$$_(Fay$$_(Fay$$mult)(x))(x);})();}}}var b = $p2;var a = $p1;return Fay$$_(Fay$$_(Fay$$mult)(a))(Fay$$_(Fay$$_(Prelude$$94$)(a))(Fay$$_(Fay$$_(Fay$$sub)(b))(1)));});};};var Prelude$logBase = function($p1){return function($p2){return new Fay$$$(function(){var x = $p2;var b = $p1;return Fay$$_(Fay$$_(Fay$$divi)(Fay$$_(Prelude$log)(x)))(Fay$$_(Prelude$log)(b));});};};var Prelude$sin = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.sin(Fay$$fayToJs_double($p1)));});};var Prelude$tan = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.tan(Fay$$fayToJs_double($p1)));});};var Prelude$cos = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.cos(Fay$$fayToJs_double($p1)));});};var Prelude$asin = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.asin(Fay$$fayToJs_double($p1)));});};var Prelude$atan = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.atan(Fay$$fayToJs_double($p1)));});};var Prelude$acos = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_double(Math.acos(Fay$$fayToJs_double($p1)));});};var Prelude$sinh = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$divi)(Fay$$_(Fay$$_(Fay$$sub)(Fay$$_(Prelude$exp)(x)))(Fay$$_(Prelude$exp)((-(Fay$$_(x)))))))(2);});};var Prelude$tanh = function($p1){return new Fay$$$(function(){var x = $p1;return (function(){var a = new Fay$$$(function(){return Fay$$_(Prelude$exp)(x);});var b = new Fay$$$(function(){return Fay$$_(Prelude$exp)((-(Fay$$_(x))));});return Fay$$_(Fay$$_(Fay$$divi)(Fay$$_(Fay$$_(Fay$$sub)(a))(b)))(Fay$$_(Fay$$_(Fay$$add)(a))(b));})();});};var Prelude$cosh = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$divi)(Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Prelude$exp)(x)))(Fay$$_(Prelude$exp)((-(Fay$$_(x)))))))(2);});};var Prelude$asinh = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Prelude$log)(Fay$$_(Fay$$_(Fay$$add)(x))(Fay$$_(Prelude$sqrt)(Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Prelude$$42$$42$)(x))(2)))(1))));});};var Prelude$atanh = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$divi)(Fay$$_(Prelude$log)(Fay$$_(Fay$$_(Fay$$divi)(Fay$$_(Fay$$_(Fay$$add)(1))(x)))(Fay$$_(Fay$$_(Fay$$sub)(1))(x)))))(2);});};var Prelude$acosh = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Prelude$log)(Fay$$_(Fay$$_(Fay$$add)(x))(Fay$$_(Prelude$sqrt)(Fay$$_(Fay$$_(Fay$$sub)(Fay$$_(Fay$$_(Prelude$$42$$42$)(x))(2)))(1))));});};var Prelude$properFraction = function($p1){return new Fay$$$(function(){var x = $p1;return (function(){var a = new Fay$$$(function(){return Fay$$_(Prelude$truncate)(x);});return Fay$$list([a,Fay$$_(Fay$$_(Fay$$sub)(x))(Fay$$_(Prelude$fromIntegral)(a))]);})();});};var Prelude$truncate = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(x))(0)) ? Fay$$_(Prelude$ceiling)(x) : Fay$$_(Prelude$floor)(x);});};var Prelude$round = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_int(Math.round(Fay$$fayToJs_double($p1)));});};var Prelude$ceiling = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_int(Math.ceil(Fay$$fayToJs_double($p1)));});};var Prelude$floor = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_int(Math.floor(Fay$$fayToJs_double($p1)));});};var Prelude$subtract = new Fay$$$(function(){return Fay$$_(Prelude$flip)(Fay$$sub);});var Prelude$even = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$eq)(Fay$$_(Fay$$_(Prelude$rem)(x))(2)))(0);});};var Prelude$odd = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Prelude$not)(Fay$$_(Prelude$even)(x));});};var Prelude$gcd = function($p1){return function($p2){return new Fay$$$(function(){var b = $p2;var a = $p1;return (function(){var go = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === 0) {var x = $p1;return x;}var y = $p2;var x = $p1;return Fay$$_(Fay$$_(go)(y))(Fay$$_(Fay$$_(Prelude$rem)(x))(y));});};};return Fay$$_(Fay$$_(go)(Fay$$_(Prelude$abs)(a)))(Fay$$_(Prelude$abs)(b));})();});};};var Prelude$quot = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$eq)(y))(0)) ? Fay$$_(Prelude$error)(Fay$$list("Division by zero")) : Fay$$_(Fay$$_(Prelude$quot$39$)(x))(y);});};};var Prelude$quot$39$ = function($p1){return function($p2){return new Fay$$$(function(){return Fay$$jsToFay_int(~~(Fay$$fayToJs_int($p1)/Fay$$fayToJs_int($p2)));});};};var Prelude$quotRem = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;return Fay$$list([Fay$$_(Fay$$_(Prelude$quot)(x))(y),Fay$$_(Fay$$_(Prelude$rem)(x))(y)]);});};};var Prelude$rem = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$eq)(y))(0)) ? Fay$$_(Prelude$error)(Fay$$list("Division by zero")) : Fay$$_(Fay$$_(Prelude$rem$39$)(x))(y);});};};var Prelude$rem$39$ = function($p1){return function($p2){return new Fay$$$(function(){return Fay$$jsToFay_int(Fay$$fayToJs_int($p1) % Fay$$fayToJs_int($p2));});};};var Prelude$lcm = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === 0) {return 0;}if (Fay$$_($p1) === 0) {return 0;}var b = $p2;var a = $p1;return Fay$$_(Prelude$abs)(Fay$$_(Fay$$_(Fay$$mult)(Fay$$_(Fay$$_(Prelude$quot)(a))(Fay$$_(Fay$$_(Prelude$gcd)(a))(b))))(b));});};};var Prelude$find = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(p)(x)) ? Fay$$_(Prelude$Just)(x) : Fay$$_(Fay$$_(Prelude$find)(p))(xs);}if (Fay$$_($p2) === null) {return Prelude$Nothing;}throw ["unhandled case in find",[$p1,$p2]];});};};var Prelude$filter = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(p)(x)) ? Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$filter)(p))(xs)) : Fay$$_(Fay$$_(Prelude$filter)(p))(xs);}if (Fay$$_($p2) === null) {return null;}throw ["unhandled case in filter",[$p1,$p2]];});};};var Prelude$$_null = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return true;}return false;});};var Prelude$map = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var f = $p1;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$_(f)(x)))(Fay$$_(Fay$$_(Prelude$map)(f))(xs));}throw ["unhandled case in map",[$p1,$p2]];});};};var Prelude$nub = function($p1){return new Fay$$$(function(){var ls = $p1;return Fay$$_(Fay$$_(Prelude$nub$39$)(ls))(null);});};var Prelude$nub$39$ = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return null;}var ls = $p2;var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$_(Prelude$elem)(x))(ls)) ? Fay$$_(Fay$$_(Prelude$nub$39$)(xs))(ls) : Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$nub$39$)(xs))(Fay$$_(Fay$$_(Fay$$cons)(x))(ls)));}throw ["unhandled case in nub'",[$p1,$p2]];});};};var Prelude$elem = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var y = $tmp1.car;var ys = $tmp1.cdr;var x = $p1;return Fay$$_(Fay$$_(Fay$$or)(Fay$$_(Fay$$_(Fay$$eq)(x))(y)))(Fay$$_(Fay$$_(Prelude$elem)(x))(ys));}if (Fay$$_($p2) === null) {return false;}throw ["unhandled case in elem",[$p1,$p2]];});};};var Prelude$notElem = function($p1){return function($p2){return new Fay$$$(function(){var ys = $p2;var x = $p1;return Fay$$_(Prelude$not)(Fay$$_(Fay$$_(Prelude$elem)(x))(ys));});};};var Prelude$sort = new Fay$$$(function(){return Fay$$_(Prelude$sortBy)(Prelude$compare);});var Prelude$sortBy = function($p1){return new Fay$$$(function(){var cmp = $p1;return Fay$$_(Fay$$_(Prelude$foldr)(Fay$$_(Prelude$insertBy)(cmp)))(null);});};var Prelude$insertBy = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){if (Fay$$_($p3) === null) {var x = $p2;return Fay$$list([x]);}var ys = $p3;var x = $p2;var cmp = $p1;return (function($tmp1){if (Fay$$_($tmp1) === null) {return Fay$$list([x]);}var $tmp2 = Fay$$_($tmp1);if ($tmp2 instanceof Fay$$Cons) {var y = $tmp2.car;var ys$39$ = $tmp2.cdr;return (function($tmp2){if (Fay$$_($tmp2) instanceof $_Prelude$GT) {return Fay$$_(Fay$$_(Fay$$cons)(y))(Fay$$_(Fay$$_(Fay$$_(Prelude$insertBy)(cmp))(x))(ys$39$));}return Fay$$_(Fay$$_(Fay$$cons)(x))(ys);})(Fay$$_(Fay$$_(cmp)(x))(y));}return (function(){ throw (["unhandled case",$tmp1]); })();})(ys);});};};};var Prelude$conc = function($p1){return function($p2){return new Fay$$$(function(){var ys = $p2;var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$conc)(xs))(ys));}var ys = $p2;if (Fay$$_($p1) === null) {return ys;}throw ["unhandled case in conc",[$p1,$p2]];});};};var Prelude$concat = new Fay$$$(function(){return Fay$$_(Fay$$_(Prelude$foldr)(Prelude$conc))(null);});var Prelude$concatMap = function($p1){return new Fay$$$(function(){var f = $p1;return Fay$$_(Fay$$_(Prelude$foldr)(Fay$$_(Fay$$_(Prelude$$46$)(Prelude$$43$$43$))(f)))(null);});};var Prelude$foldr = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){if (Fay$$_($p3) === null) {var z = $p2;return z;}var $tmp1 = Fay$$_($p3);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var z = $p2;var f = $p1;return Fay$$_(Fay$$_(f)(x))(Fay$$_(Fay$$_(Fay$$_(Prelude$foldr)(f))(z))(xs));}throw ["unhandled case in foldr",[$p1,$p2,$p3]];});};};};var Prelude$foldr1 = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p2),1)) {var x = Fay$$index(0,Fay$$_($p2));return x;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var f = $p1;return Fay$$_(Fay$$_(f)(x))(Fay$$_(Fay$$_(Prelude$foldr1)(f))(xs));}if (Fay$$_($p2) === null) {return Fay$$_(Prelude$error)(Fay$$list("foldr1: empty list"));}throw ["unhandled case in foldr1",[$p1,$p2]];});};};var Prelude$foldl = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){if (Fay$$_($p3) === null) {var z = $p2;return z;}var $tmp1 = Fay$$_($p3);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var z = $p2;var f = $p1;return Fay$$_(Fay$$_(Fay$$_(Prelude$foldl)(f))(Fay$$_(Fay$$_(f)(z))(x)))(xs);}throw ["unhandled case in foldl",[$p1,$p2,$p3]];});};};};var Prelude$foldl1 = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var f = $p1;return Fay$$_(Fay$$_(Fay$$_(Prelude$foldl)(f))(x))(xs);}if (Fay$$_($p2) === null) {return Fay$$_(Prelude$error)(Fay$$list("foldl1: empty list"));}throw ["unhandled case in foldl1",[$p1,$p2]];});};};var Prelude$$43$$43$ = function($p1){return function($p2){return new Fay$$$(function(){var y = $p2;var x = $p1;return Fay$$_(Fay$$_(Prelude$conc)(x))(y);});};};var Prelude$$33$$33$ = function($p1){return function($p2){return new Fay$$$(function(){var b = $p2;var a = $p1;return (function(){var go = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("(!!): index too large"));}if (Fay$$_($p2) === 0) {var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var h = $tmp1.car;return h;}}var n = $p2;var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var t = $tmp1.cdr;return Fay$$_(Fay$$_(go)(t))(Fay$$_(Fay$$_(Fay$$sub)(n))(1));}throw ["unhandled case in go",[$p1,$p2]];});};};return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(b))(0)) ? Fay$$_(Prelude$error)(Fay$$list("(!!): negative index")) : Fay$$_(Fay$$_(go)(a))(b);})();});};};var Prelude$head = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("head: empty list"));}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var h = $tmp1.car;return h;}throw ["unhandled case in head",[$p1]];});};var Prelude$tail = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("tail: empty list"));}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var t = $tmp1.cdr;return t;}throw ["unhandled case in tail",[$p1]];});};var Prelude$init = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("init: empty list"));}if (Fay$$listLen(Fay$$_($p1),1)) {var a = Fay$$index(0,Fay$$_($p1));return Fay$$list([a]);}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var h = $tmp1.car;var t = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$cons)(h))(Fay$$_(Prelude$init)(t));}throw ["unhandled case in init",[$p1]];});};var Prelude$last = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("last: empty list"));}if (Fay$$listLen(Fay$$_($p1),1)) {var a = Fay$$index(0,Fay$$_($p1));return a;}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var t = $tmp1.cdr;return Fay$$_(Prelude$last)(t);}throw ["unhandled case in last",[$p1]];});};var Prelude$iterate = function($p1){return function($p2){return new Fay$$$(function(){var x = $p2;var f = $p1;return Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$iterate)(f))(Fay$$_(f)(x)));});};};var Prelude$repeat = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Prelude$repeat)(x));});};var Prelude$replicate = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p1) === 0) {return null;}var x = $p2;var n = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(n))(0)) ? Fay$$_(Prelude$error)(Fay$$list("replicate: negative length")) : Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$replicate)(Fay$$_(Fay$$_(Fay$$sub)(n))(1)))(x));});};};var Prelude$cycle = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("cycle: empty list"));}var xs = $p1;return (function(){var xs$39$ = new Fay$$$(function(){return Fay$$_(Fay$$_(Prelude$$43$$43$)(xs))(xs$39$);});return xs$39$;})();});};var Prelude$take = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p1) === 0) {return null;}if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var n = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(n))(0)) ? Fay$$_(Prelude$error)(Fay$$list("take: negative length")) : Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$take)(Fay$$_(Fay$$_(Fay$$sub)(n))(1)))(xs));}throw ["unhandled case in take",[$p1,$p2]];});};};var Prelude$drop = function($p1){return function($p2){return new Fay$$$(function(){var xs = $p2;if (Fay$$_($p1) === 0) {return xs;}if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var xs = $tmp1.cdr;var n = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(n))(0)) ? Fay$$_(Prelude$error)(Fay$$list("drop: negative length")) : Fay$$_(Fay$$_(Prelude$drop)(Fay$$_(Fay$$_(Fay$$sub)(n))(1)))(xs);}throw ["unhandled case in drop",[$p1,$p2]];});};};var Prelude$splitAt = function($p1){return function($p2){return new Fay$$$(function(){var xs = $p2;if (Fay$$_($p1) === 0) {return Fay$$list([null,xs]);}if (Fay$$_($p2) === null) {return Fay$$list([null,null]);}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var n = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$lt)(n))(0)) ? Fay$$_(Prelude$error)(Fay$$list("splitAt: negative length")) : (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var a = Fay$$index(0,Fay$$_($tmp1));var b = Fay$$index(1,Fay$$_($tmp1));return Fay$$list([Fay$$_(Fay$$_(Fay$$cons)(x))(a),b]);}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Fay$$_(Prelude$splitAt)(Fay$$_(Fay$$_(Fay$$sub)(n))(1)))(xs));}throw ["unhandled case in splitAt",[$p1,$p2]];});};};var Prelude$takeWhile = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(p)(x)) ? Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$takeWhile)(p))(xs)) : null;}throw ["unhandled case in takeWhile",[$p1,$p2]];});};};var Prelude$dropWhile = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(p)(x)) ? Fay$$_(Fay$$_(Prelude$dropWhile)(p))(xs) : Fay$$_(Fay$$_(Fay$$cons)(x))(xs);}throw ["unhandled case in dropWhile",[$p1,$p2]];});};};var Prelude$span = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return Fay$$list([null,null]);}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(p)(x)) ? (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var a = Fay$$index(0,Fay$$_($tmp1));var b = Fay$$index(1,Fay$$_($tmp1));return Fay$$list([Fay$$_(Fay$$_(Fay$$cons)(x))(a),b]);}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Fay$$_(Prelude$span)(p))(xs)) : Fay$$list([null,Fay$$_(Fay$$_(Fay$$cons)(x))(xs)]);}throw ["unhandled case in span",[$p1,$p2]];});};};var Prelude$$_break = function($p1){return new Fay$$$(function(){var p = $p1;return Fay$$_(Prelude$span)(Fay$$_(Fay$$_(Prelude$$46$)(Prelude$not))(p));});};var Prelude$zipWith = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var $tmp1 = Fay$$_($p3);if ($tmp1 instanceof Fay$$Cons) {var b = $tmp1.car;var bs = $tmp1.cdr;var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var a = $tmp1.car;var as = $tmp1.cdr;var f = $p1;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$_(Fay$$_(f)(a))(b)))(Fay$$_(Fay$$_(Fay$$_(Prelude$zipWith)(f))(as))(bs));}}return null;});};};};var Prelude$zipWith3 = function($p1){return function($p2){return function($p3){return function($p4){return new Fay$$$(function(){var $tmp1 = Fay$$_($p4);if ($tmp1 instanceof Fay$$Cons) {var c = $tmp1.car;var cs = $tmp1.cdr;var $tmp1 = Fay$$_($p3);if ($tmp1 instanceof Fay$$Cons) {var b = $tmp1.car;var bs = $tmp1.cdr;var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var a = $tmp1.car;var as = $tmp1.cdr;var f = $p1;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$_(Fay$$_(Fay$$_(f)(a))(b))(c)))(Fay$$_(Fay$$_(Fay$$_(Fay$$_(Prelude$zipWith3)(f))(as))(bs))(cs));}}}return null;});};};};};var Prelude$zip = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var b = $tmp1.car;var bs = $tmp1.cdr;var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var a = $tmp1.car;var as = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$list([a,b])))(Fay$$_(Fay$$_(Prelude$zip)(as))(bs));}}return null;});};};var Prelude$zip3 = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var $tmp1 = Fay$$_($p3);if ($tmp1 instanceof Fay$$Cons) {var c = $tmp1.car;var cs = $tmp1.cdr;var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var b = $tmp1.car;var bs = $tmp1.cdr;var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var a = $tmp1.car;var as = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$list([a,b,c])))(Fay$$_(Fay$$_(Fay$$_(Prelude$zip3)(as))(bs))(cs));}}}return null;});};};};var Prelude$unzip = function($p1){return new Fay$$$(function(){var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {if (Fay$$listLen(Fay$$_($tmp1.car),2)) {var x = Fay$$index(0,Fay$$_($tmp1.car));var y = Fay$$index(1,Fay$$_($tmp1.car));var ps = $tmp1.cdr;return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var xs = Fay$$index(0,Fay$$_($tmp1));var ys = Fay$$index(1,Fay$$_($tmp1));return Fay$$list([Fay$$_(Fay$$_(Fay$$cons)(x))(xs),Fay$$_(Fay$$_(Fay$$cons)(y))(ys)]);}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Prelude$unzip)(ps));}}if (Fay$$_($p1) === null) {return Fay$$list([null,null]);}throw ["unhandled case in unzip",[$p1]];});};var Prelude$unzip3 = function($p1){return new Fay$$$(function(){var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {if (Fay$$listLen(Fay$$_($tmp1.car),3)) {var x = Fay$$index(0,Fay$$_($tmp1.car));var y = Fay$$index(1,Fay$$_($tmp1.car));var z = Fay$$index(2,Fay$$_($tmp1.car));var ps = $tmp1.cdr;return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),3)) {var xs = Fay$$index(0,Fay$$_($tmp1));var ys = Fay$$index(1,Fay$$_($tmp1));var zs = Fay$$index(2,Fay$$_($tmp1));return Fay$$list([Fay$$_(Fay$$_(Fay$$cons)(x))(xs),Fay$$_(Fay$$_(Fay$$cons)(y))(ys),Fay$$_(Fay$$_(Fay$$cons)(z))(zs)]);}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Prelude$unzip3)(ps));}}if (Fay$$_($p1) === null) {return Fay$$list([null,null,null]);}throw ["unhandled case in unzip3",[$p1]];});};var Prelude$lines = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return null;}var s = $p1;return (function(){var isLineBreak = function($p1){return new Fay$$$(function(){var c = $p1;return Fay$$_(Fay$$_(Fay$$or)(Fay$$_(Fay$$_(Fay$$eq)(c))("\r")))(Fay$$_(Fay$$_(Fay$$eq)(c))("\n"));});};return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var a = Fay$$index(0,Fay$$_($tmp1));if (Fay$$_(Fay$$index(1,Fay$$_($tmp1))) === null) {return Fay$$list([a]);}var a = Fay$$index(0,Fay$$_($tmp1));var $tmp2 = Fay$$_(Fay$$index(1,Fay$$_($tmp1)));if ($tmp2 instanceof Fay$$Cons) {var cs = $tmp2.cdr;return Fay$$_(Fay$$_(Fay$$cons)(a))(Fay$$_(Prelude$lines)(cs));}}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Fay$$_(Prelude$$_break)(isLineBreak))(s));})();});};var Prelude$unlines = new Fay$$$(function(){return Fay$$_(Prelude$intercalate)(Fay$$list("\n"));});var Prelude$words = function($p1){return new Fay$$$(function(){var str = $p1;return (function(){var words$39$ = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return null;}var s = $p1;return (function($tmp1){if (Fay$$listLen(Fay$$_($tmp1),2)) {var a = Fay$$index(0,Fay$$_($tmp1));var b = Fay$$index(1,Fay$$_($tmp1));return Fay$$_(Fay$$_(Fay$$cons)(a))(Fay$$_(Prelude$words)(b));}return (function(){ throw (["unhandled case",$tmp1]); })();})(Fay$$_(Fay$$_(Prelude$$_break)(isSpace))(s));});};var isSpace = function($p1){return new Fay$$$(function(){var c = $p1;return Fay$$_(Fay$$_(Prelude$elem)(c))(Fay$$list(" \t\r\n\u000c\u000b"));});};return Fay$$_(words$39$)(Fay$$_(Fay$$_(Prelude$dropWhile)(isSpace))(str));})();});};var Prelude$unwords = new Fay$$$(function(){return Fay$$_(Prelude$intercalate)(Fay$$list(" "));});var Prelude$and = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return true;}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$and)(x))(Fay$$_(Prelude$and)(xs));}throw ["unhandled case in and",[$p1]];});};var Prelude$or = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return false;}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;return Fay$$_(Fay$$_(Fay$$or)(x))(Fay$$_(Prelude$or)(xs));}throw ["unhandled case in or",[$p1]];});};var Prelude$any = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return false;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(Fay$$or)(Fay$$_(p)(x)))(Fay$$_(Fay$$_(Prelude$any)(p))(xs));}throw ["unhandled case in any",[$p1,$p2]];});};};var Prelude$all = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return true;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var p = $p1;return Fay$$_(Fay$$_(Fay$$and)(Fay$$_(p)(x)))(Fay$$_(Fay$$_(Prelude$all)(p))(xs));}throw ["unhandled case in all",[$p1,$p2]];});};};var Prelude$intersperse = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var sep = $p1;return Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$prependToAll)(sep))(xs));}throw ["unhandled case in intersperse",[$p1,$p2]];});};};var Prelude$prependToAll = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var sep = $p1;return Fay$$_(Fay$$_(Fay$$cons)(sep))(Fay$$_(Fay$$_(Fay$$cons)(x))(Fay$$_(Fay$$_(Prelude$prependToAll)(sep))(xs)));}throw ["unhandled case in prependToAll",[$p1,$p2]];});};};var Prelude$intercalate = function($p1){return function($p2){return new Fay$$$(function(){var xss = $p2;var xs = $p1;return Fay$$_(Prelude$concat)(Fay$$_(Fay$$_(Prelude$intersperse)(xs))(xss));});};};var Prelude$maximum = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("maximum: empty list"));}var xs = $p1;return Fay$$_(Fay$$_(Prelude$foldl1)(Prelude$max))(xs);});};var Prelude$minimum = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("minimum: empty list"));}var xs = $p1;return Fay$$_(Fay$$_(Prelude$foldl1)(Prelude$min))(xs);});};var Prelude$product = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("product: empty list"));}var xs = $p1;return Fay$$_(Fay$$_(Fay$$_(Prelude$foldl)(Fay$$mult))(1))(xs);});};var Prelude$sum = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Fay$$_(Prelude$error)(Fay$$list("sum: empty list"));}var xs = $p1;return Fay$$_(Fay$$_(Fay$$_(Prelude$foldl)(Fay$$add))(0))(xs);});};var Prelude$scanl = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){var l = $p3;var z = $p2;var f = $p1;return Fay$$_(Fay$$_(Fay$$cons)(z))((function($tmp1){if (Fay$$_($tmp1) === null) {return null;}var $tmp2 = Fay$$_($tmp1);if ($tmp2 instanceof Fay$$Cons) {var x = $tmp2.car;var xs = $tmp2.cdr;return Fay$$_(Fay$$_(Fay$$_(Prelude$scanl)(f))(Fay$$_(Fay$$_(f)(z))(x)))(xs);}return (function(){ throw (["unhandled case",$tmp1]); })();})(l));});};};};var Prelude$scanl1 = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var f = $p1;return Fay$$_(Fay$$_(Fay$$_(Prelude$scanl)(f))(x))(xs);}throw ["unhandled case in scanl1",[$p1,$p2]];});};};var Prelude$scanr = function($p1){return function($p2){return function($p3){return new Fay$$$(function(){if (Fay$$_($p3) === null) {var z = $p2;return Fay$$list([z]);}var $tmp1 = Fay$$_($p3);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var z = $p2;var f = $p1;return (function($tmp1){var $tmp2 = Fay$$_($tmp1);if ($tmp2 instanceof Fay$$Cons) {var h = $tmp2.car;var t = $tmp2.cdr;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$_(Fay$$_(f)(x))(h)))(Fay$$_(Fay$$_(Fay$$cons)(h))(t));}return Prelude$$_undefined;})(Fay$$_(Fay$$_(Fay$$_(Prelude$scanr)(f))(z))(xs));}throw ["unhandled case in scanr",[$p1,$p2,$p3]];});};};};var Prelude$scanr1 = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {return null;}if (Fay$$listLen(Fay$$_($p2),1)) {var x = Fay$$index(0,Fay$$_($p2));return Fay$$list([x]);}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;var f = $p1;return (function($tmp1){var $tmp2 = Fay$$_($tmp1);if ($tmp2 instanceof Fay$$Cons) {var h = $tmp2.car;var t = $tmp2.cdr;return Fay$$_(Fay$$_(Fay$$cons)(Fay$$_(Fay$$_(f)(x))(h)))(Fay$$_(Fay$$_(Fay$$cons)(h))(t));}return Prelude$$_undefined;})(Fay$$_(Fay$$_(Prelude$scanr1)(f))(xs));}throw ["unhandled case in scanr1",[$p1,$p2]];});};};var Prelude$lookup = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) === null) {var _key = $p1;return Prelude$Nothing;}var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {if (Fay$$listLen(Fay$$_($tmp1.car),2)) {var x = Fay$$index(0,Fay$$_($tmp1.car));var y = Fay$$index(1,Fay$$_($tmp1.car));var xys = $tmp1.cdr;var key = $p1;return Fay$$_(Fay$$_(Fay$$_(Fay$$eq)(key))(x)) ? Fay$$_(Prelude$Just)(y) : Fay$$_(Fay$$_(Prelude$lookup)(key))(xys);}}throw ["unhandled case in lookup",[$p1,$p2]];});};};var Prelude$length = function($p1){return new Fay$$$(function(){var xs = $p1;return Fay$$_(Fay$$_(Prelude$length$39$)(0))(xs);});};var Prelude$length$39$ = function($p1){return function($p2){return new Fay$$$(function(){var $tmp1 = Fay$$_($p2);if ($tmp1 instanceof Fay$$Cons) {var xs = $tmp1.cdr;var acc = $p1;return Fay$$_(Fay$$_(Prelude$length$39$)(Fay$$_(Fay$$_(Fay$$add)(acc))(1)))(xs);}var acc = $p1;return acc;});};};var Prelude$reverse = function($p1){return new Fay$$$(function(){var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var x = $tmp1.car;var xs = $tmp1.cdr;return Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$reverse)(xs)))(Fay$$list([x]));}if (Fay$$_($p1) === null) {return null;}throw ["unhandled case in reverse",[$p1]];});};var Prelude$print = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],(function(x) { if (console && console.log) console.log(x) })(Fay$$fayToJs(["automatic"],$p1))));});};var Prelude$putStrLn = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],(function(x) { if (console && console.log) console.log(x) })(Fay$$fayToJs_string($p1))));});};var Language$Fay$FFI$Nullable = function(slot1){return new Fay$$$(function(){return new $_Language$Fay$FFI$Nullable(slot1);});};var Language$Fay$FFI$Null = new Fay$$$(function(){return new $_Language$Fay$FFI$Null();});var Language$Fay$FFI$Defined = function(slot1){return new Fay$$$(function(){return new $_Language$Fay$FFI$Defined(slot1);});};var Language$Fay$FFI$Undefined = new Fay$$$(function(){return new $_Language$Fay$FFI$Undefined();});var MyPrelude$listToMaybe = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) === null) {return Prelude$Nothing;}var $tmp1 = Fay$$_($p1);if ($tmp1 instanceof Fay$$Cons) {var a = $tmp1.car;return Fay$$_(Prelude$Just)(a);}throw ["unhandled case in listToMaybe",[$p1]];});};var MyPrelude$fromJust = function($p1){return new Fay$$$(function(){if (Fay$$_($p1) instanceof $_Prelude$Nothing) {return Fay$$_(Prelude$error)(Fay$$list("Maybe.fromJust: Nothing"));}if (Fay$$_($p1) instanceof $_Prelude$Just) {var x = Fay$$_($p1).slot1;return x;}throw ["unhandled case in fromJust",[$p1]];});};var MyPrelude$elemIndex = function($p1){return new Fay$$$(function(){var x = $p1;return Fay$$_(MyPrelude$findIndex)(function($p1){var $gen_1 = $p1;return Fay$$_(Fay$$_(Fay$$eq)(x))($gen_1);});});};var MyPrelude$findIndex = function($p1){return new Fay$$$(function(){var p = $p1;return Fay$$_(Fay$$_(Prelude$$46$)(MyPrelude$listToMaybe))(Fay$$_(MyPrelude$findIndices)(p));});};var MyPrelude$findIndices = function($p1){return function($p2){return new Fay$$$(function(){var xs = $p2;var p = $p1;return (function(){var $gen_1 = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var x = Fay$$index(0,Fay$$_($p1));var i = Fay$$index(1,Fay$$_($p1));return Fay$$_(Fay$$_(p)(x)) ? Fay$$list([i]) : null;}return null;});};return Fay$$_(Fay$$_(Prelude$concatMap)($gen_1))(Fay$$_(Fay$$_(Prelude$zip)(xs))(Prelude$enumFrom(0)));})();});};};var ChromeExtFay$main = new Fay$$$(function(){return Fay$$_(Fay$$_(Prelude$$36$)(ChromeExtFay$ready))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(80))(true))(false)))(ChromeExtFay$defaultSettings)))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(186))(true))(false)))(ChromeExtFay$defaultSettings)))))(Fay$$_(Fay$$_(Fay$$then)(ChromeExtFay$start))(Fay$$_(Fay$$$_return)(Fay$$unit)))));});var ChromeExtFay$printArg = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],console.log("%o",Fay$$fayToJs(["unknown"],$p1))));});};var ChromeExtFay$showDouble = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_string((Fay$$fayToJs_double($p1)).toString());});};var ChromeExtFay$showString = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_string(JSON.stringify(Fay$$fayToJs_string($p1)));});};var ChromeExtFay$select = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],jQuery(Fay$$fayToJs_string($p1))));});};var ChromeExtFay$addClassWith = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p2).addClass(Fay$$fayToJs(["function",[["double"],["string"],["action",[["string"]]]]],$p1))));});};};var ChromeExtFay$ready = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],jQuery(Fay$$fayToJs(["action",[["unknown"]]],$p1))));});};var ChromeExtFay$Key = function(getCode){return function(getCtrl){return function(getAlt){return new Fay$$$(function(){return new $_ChromeExtFay$Key(getCode,getCtrl,getAlt);});};};};var ChromeExtFay$getCode = function(x){return new Fay$$$(function(){return Fay$$_(x).getCode;});};var ChromeExtFay$getCtrl = function(x){return new Fay$$$(function(){return Fay$$_(x).getCtrl;});};var ChromeExtFay$getAlt = function(x){return new Fay$$$(function(){return Fay$$_(x).getAlt;});};var ChromeExtFay$defaultSettings = new Fay$$$(function(){return Fay$$list([Fay$$list([Fay$$list("START_HITAHINT"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(69))(true))(false)]),Fay$$list([Fay$$list("FOCUS_FORM"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(70))(true))(false)]),Fay$$list([Fay$$list("TOGGLE_SELECTOR"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(186))(true))(false)]),Fay$$list([Fay$$list("CANCEL"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(27))(false))(false)]),Fay$$list([Fay$$list("MOVE_NEXT_SELECTOR_CURSOR"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(40))(false))(false)]),Fay$$list([Fay$$list("MOVE_PREV_SELECTOR_CURSOR"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(38))(false))(false)]),Fay$$list([Fay$$list("MOVE_NEXT_FORM"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(34))(false))(false)]),Fay$$list([Fay$$list("MOVE_PREV_FORM"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(33))(false))(false)]),Fay$$list([Fay$$list("BACK_HISTORY"),Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(72))(true))(false)])]);});var ChromeExtFay$keyMap = new Fay$$$(function(){return Fay$$list([Fay$$list([9,Fay$$list("TAB")]),Fay$$list([16,Fay$$list("SHIFT")]),Fay$$list([17,Fay$$list("CTRL")]),Fay$$list([18,Fay$$list("ALT")]),Fay$$list([27,Fay$$list("ESC")]),Fay$$list([33,Fay$$list("PAGEUP")]),Fay$$list([34,Fay$$list("PAGEDONW")]),Fay$$list([35,Fay$$list("END")]),Fay$$list([36,Fay$$list("HOME")]),Fay$$list([37,Fay$$list("BACK")]),Fay$$list([38,Fay$$list("UP")]),Fay$$list([39,Fay$$list("FORWARD")]),Fay$$list([40,Fay$$list("DOWN")]),Fay$$list([48,Fay$$list("0")]),Fay$$list([49,Fay$$list("1")]),Fay$$list([50,Fay$$list("2")]),Fay$$list([51,Fay$$list("3")]),Fay$$list([52,Fay$$list("4")]),Fay$$list([53,Fay$$list("5")]),Fay$$list([54,Fay$$list("6")]),Fay$$list([55,Fay$$list("7")]),Fay$$list([56,Fay$$list("8")]),Fay$$list([57,Fay$$list("9")]),Fay$$list([65,Fay$$list("A")]),Fay$$list([66,Fay$$list("B")]),Fay$$list([67,Fay$$list("C")]),Fay$$list([68,Fay$$list("D")]),Fay$$list([69,Fay$$list("E")]),Fay$$list([70,Fay$$list("F")]),Fay$$list([71,Fay$$list("G")]),Fay$$list([72,Fay$$list("H")]),Fay$$list([73,Fay$$list("I")]),Fay$$list([74,Fay$$list("J")]),Fay$$list([75,Fay$$list("K")]),Fay$$list([76,Fay$$list("L")]),Fay$$list([77,Fay$$list("M")]),Fay$$list([78,Fay$$list("N")]),Fay$$list([79,Fay$$list("O")]),Fay$$list([80,Fay$$list("P")]),Fay$$list([81,Fay$$list("Q")]),Fay$$list([82,Fay$$list("R")]),Fay$$list([83,Fay$$list("S")]),Fay$$list([84,Fay$$list("T")]),Fay$$list([85,Fay$$list("U")]),Fay$$list([86,Fay$$list("V")]),Fay$$list([87,Fay$$list("W")]),Fay$$list([88,Fay$$list("X")]),Fay$$list([89,Fay$$list("Y")]),Fay$$list([90,Fay$$list("Z")]),Fay$$list([112,Fay$$list("F1")]),Fay$$list([113,Fay$$list("F2")]),Fay$$list([114,Fay$$list("F3")]),Fay$$list([115,Fay$$list("F4")]),Fay$$list([116,Fay$$list("F5")]),Fay$$list([117,Fay$$list("F6")]),Fay$$list([118,Fay$$list("F7")]),Fay$$list([119,Fay$$list("F8")]),Fay$$list([120,Fay$$list("F9")]),Fay$$list([121,Fay$$list("F10")]),Fay$$list([122,Fay$$list("F11")]),Fay$$list([123,Fay$$list("F12")]),Fay$$list([186,Fay$$list(": (or ;)")]),Fay$$list([187,Fay$$list("^")]),Fay$$list([188,Fay$$list(",")]),Fay$$list([189,Fay$$list("-")]),Fay$$list([190,Fay$$list(".")])]);});var ChromeExtFay$keyCodeFromKeyName$39$ = function($p1){return function($p2){return new Fay$$$(function(){var name = $p2;var kMap = $p1;return Fay$$_(MyPrelude$listToMaybe)((function(){var $gen_1 = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var k = Fay$$index(0,Fay$$_($p1));var v = Fay$$index(1,Fay$$_($p1));return Fay$$_(Fay$$_(Fay$$_(Fay$$eq)(v))(name)) ? Fay$$list([k]) : null;}return null;});};return Fay$$_(Fay$$_(Prelude$concatMap)($gen_1))(kMap);})());});};};var ChromeExtFay$keyCodeFromKeyName = new Fay$$$(function(){return Fay$$_(ChromeExtFay$keyCodeFromKeyName$39$)(ChromeExtFay$keyMap);});var ChromeExtFay$localStorageSet = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],localStorage.setItem(Fay$$fayToJs_string($p1), Fay$$fayToJs_string($p2))));});};};var ChromeExtFay$localStorageGet = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_string(localStorage.getItem(Fay$$fayToJs_string($p1)));});};var ChromeExtFay$ctrlKeycode = 17;var ChromeExtFay$altKeycode = 18;var ChromeExtFay$selectorNum = 20;var ChromeExtFay$formInputFields = new Fay$$$(function(){return Fay$$list("input[type=\"text\"]:not(\"#selectorInput\"), textarea, select");});var ChromeExtFay$clickables = new Fay$$$(function(){return Fay$$list("a");});var ChromeExtFay$_hintKeys = new Fay$$$(function(){return Fay$$list([Fay$$list([65,Fay$$list("A")]),Fay$$list([66,Fay$$list("B")]),Fay$$list([67,Fay$$list("C")]),Fay$$list([68,Fay$$list("D")]),Fay$$list([69,Fay$$list("E")]),Fay$$list([70,Fay$$list("F")]),Fay$$list([71,Fay$$list("G")]),Fay$$list([72,Fay$$list("H")]),Fay$$list([73,Fay$$list("I")]),Fay$$list([74,Fay$$list("J")]),Fay$$list([75,Fay$$list("K")]),Fay$$list([76,Fay$$list("L")]),Fay$$list([77,Fay$$list("M")]),Fay$$list([78,Fay$$list("N")]),Fay$$list([79,Fay$$list("O")]),Fay$$list([80,Fay$$list("P")]),Fay$$list([81,Fay$$list("Q")]),Fay$$list([82,Fay$$list("R")]),Fay$$list([83,Fay$$list("S")]),Fay$$list([84,Fay$$list("T")]),Fay$$list([85,Fay$$list("U")]),Fay$$list([86,Fay$$list("V")]),Fay$$list([87,Fay$$list("W")]),Fay$$list([88,Fay$$list("X")]),Fay$$list([89,Fay$$list("Y")]),Fay$$list([90,Fay$$list("Z")])]);});var ChromeExtFay$hintKeys = new Fay$$$(function(){var $gen_1 = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var i1 = Fay$$index(0,Fay$$_($p1));var s1 = Fay$$index(1,Fay$$_($p1));return (function(){var $gen_1 = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var i2 = Fay$$index(0,Fay$$_($p1));var s2 = Fay$$index(1,Fay$$_($p1));return Fay$$list([Fay$$list([Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Fay$$mult)(i1))(100)))(i2),Fay$$_(Fay$$_(Prelude$$43$$43$)(s1))(s2)])]);}return null;});};return Fay$$_(Fay$$_(Prelude$concatMap)($gen_1))(ChromeExtFay$_hintKeys);})();}return null;});};return Fay$$_(Fay$$_(Prelude$concatMap)($gen_1))(ChromeExtFay$_hintKeys);});var ChromeExtFay$keyCodeToIndex = function($p1){return function($p2){return new Fay$$$(function(){var secondKeyCode = $p2;var firstKeyCode = $p1;return Fay$$_(Fay$$_(Prelude$$36$)(Fay$$_(MyPrelude$elemIndex)(Fay$$_(Fay$$_(Fay$$add)(Fay$$_(Fay$$_(Fay$$mult)(firstKeyCode))(100)))(secondKeyCode))))(Fay$$_(Fay$$_(Prelude$map)(Prelude$fst))(ChromeExtFay$hintKeys));});};};var ChromeExtFay$indexToKeyCode = function($p1){return new Fay$$$(function(){var index = $p1;if (Fay$$_(Fay$$_(Fay$$_(Fay$$gt)(Fay$$_(Prelude$length)(ChromeExtFay$hintKeys)))(index))) {return Fay$$_(Fay$$_(Prelude$$36$)(Prelude$Just))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$fst))(Fay$$_(Fay$$_(Prelude$$33$$33$)(ChromeExtFay$hintKeys))(index)));} else {if (true) {return Prelude$Nothing;}}});};var ChromeExtFay$isHitAHintKey = function($p1){return new Fay$$$(function(){var keyCode = $p1;return Fay$$_(Fay$$_(Prelude$$36$)(Fay$$_(Prelude$elem)(keyCode)))(Fay$$_(Fay$$_(Prelude$map)(Prelude$fst))(ChromeExtFay$_hintKeys));});};var ChromeExtFay$Item = function(getId){return function(getTitle){return function(getUrl){return function(getType){return new Fay$$$(function(){return new $_ChromeExtFay$Item(getId,getTitle,getUrl,getType);});};};};};var ChromeExtFay$getId = function(x){return new Fay$$$(function(){return Fay$$_(x).getId;});};var ChromeExtFay$getTitle = function(x){return new Fay$$$(function(){return Fay$$_(x).getTitle;});};var ChromeExtFay$getUrl = function(x){return new Fay$$$(function(){return Fay$$_(x).getUrl;});};var ChromeExtFay$getType = function(x){return new Fay$$$(function(){return Fay$$_(x).getType;});};var ChromeExtFay$makeSelectorConsole = function($p1){return new Fay$$$(function(){var htmlStr = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("makeSelectorConsole"))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("#selectorList"))))(ChromeExtFay$remove)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("#selectorConsole"))))(Fay$$_(ChromeExtFay$append)(htmlStr))))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("#selectorList tr:first"))))(Fay$$_(ChromeExtFay$addClass)(Fay$$list("selected"))))));});};var ChromeExtFay$remove = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p1).remove()));});};var ChromeExtFay$append = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p2).append(Fay$$fayToJs_string($p1))));});};};var ChromeExtFay$addClass = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p2).addClass(Fay$$fayToJs_string($p1))));});};};var ChromeExtFay$keyMapper = function($p1){return function($p2){return new Fay$$$(function(){var settings = $p2;var key = $p1;return Fay$$_(Fay$$_(Prelude$$36$)(MyPrelude$listToMaybe))(Fay$$_(Fay$$_(Prelude$$36$)(Fay$$_(Prelude$map)(Prelude$fst)))(Fay$$_(Fay$$_(Prelude$filter)(Fay$$_(Fay$$_(Prelude$$46$)(function($p1){var $gen_1 = $p1;return Fay$$_(Fay$$_(Fay$$eq)($gen_1))(key);}))(Prelude$snd)))(settings)));});};};var ChromeExtFay$NeutralMode = new Fay$$$(function(){return new $_ChromeExtFay$NeutralMode();});var ChromeExtFay$HitAHintMode = new Fay$$$(function(){return new $_ChromeExtFay$HitAHintMode();});var ChromeExtFay$SelectorMode = new Fay$$$(function(){return new $_ChromeExtFay$SelectorMode();});var ChromeExtFay$FormFocusMode = new Fay$$$(function(){return new $_ChromeExtFay$FormFocusMode();});var ChromeExtFay$getKeyCode = function($p1){return new Fay$$$(function(){return Fay$$jsToFay_int(Fay$$fayToJs(["user","Event",[]],$p1).keyCode);});};var ChromeExtFay$keyupMap = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) instanceof $_ChromeExtFay$St) {var modeRef = Fay$$_($p2).getModeRef;var ctrlRef = Fay$$_($p2).getCtrlRef;var altRef = Fay$$_($p2).getAltRef;var e = $p1;return (function(){var keyupMap$39$ = function($p1){return function($p2){return function($p3){return function($p4){return new Fay$$$(function(){var altRef = $p4;var ctrlRef = $p3;if (Fay$$_($p2) instanceof $_ChromeExtFay$SelectorMode) {var e = $p1;return Fay$$_(Fay$$_(Prelude$$36$)(ChromeExtFay$filterSelector))(Fay$$_(ChromeExtFay$getKeyCode)(e));}var altRef = $p4;var ctrlRef = $p3;if (Fay$$_($p2) instanceof $_ChromeExtFay$FormFocusMode) {var e = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("keyupMap'"))))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(ctrlRef)))(function($p1){var ctrl = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(altRef)))(function($p1){var alt = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(ctrl))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(alt))))((function($tmp1){if (Fay$$_($tmp1) instanceof $_Prelude$Just) {if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("MOVE_NEXT_FORM"))) {return Fay$$_(ChromeExtFay$focusNextForm)(e);}if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("MOVE_PREV_FORM"))) {return Fay$$_(ChromeExtFay$focusPrevForm)(e);}if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("CANCEL"))) {return Fay$$_(ChromeExtFay$cancel)(e);}}var a = $tmp1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(a))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))(ChromeExtFay$defaultSettings)))))(Fay$$_(Fay$$$_return)(Fay$$unit))));})(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))(ChromeExtFay$defaultSettings))));});}));}return Fay$$_(Fay$$$_return)(Fay$$unit);});};};};};return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("keyupMap: ")))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(ChromeExtFay$getKeyCode)(e))))))(Fay$$_(Fay$$_(Fay$$then)((function($tmp1){if (Fay$$_($tmp1) === 17) {return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("ctrlKeyCode"))))(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(ctrlRef))(false));}if (Fay$$_($tmp1) === 18) {return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("altKeyCode"))))(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(altRef))(false));}return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(modeRef)))(function($p1){var mode = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(mode))))(Fay$$_(Fay$$_(Fay$$_(Fay$$_(keyupMap$39$)(e))(mode))(ctrlRef))(altRef));});})(Fay$$_(ChromeExtFay$getKeyCode)(e))))(Fay$$_(Fay$$$_return)(Fay$$unit)));})();}throw ["unhandled case in keyupMap",[$p1,$p2]];});};};var ChromeExtFay$keydownMap = function($p1){return function($p2){return new Fay$$$(function(){if (Fay$$_($p2) instanceof $_ChromeExtFay$St) {var modeRef = Fay$$_($p2).getModeRef;var ctrlRef = Fay$$_($p2).getCtrlRef;var altRef = Fay$$_($p2).getAltRef;var inputIdxRef = Fay$$_($p2).getInputIdxRef;var e = $p1;return (function(){var keydownMap$39$ = function($p1){return function($p2){return function($p3){return function($p4){return new Fay$$$(function(){var altRef = $p4;var ctrlRef = $p3;if (Fay$$_($p2) instanceof $_ChromeExtFay$NeutralMode) {var e = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("keydownMap'"))))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(ctrlRef)))(function($p1){var ctrl = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(altRef)))(function($p1){var alt = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(ctrl))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(alt))))((function($tmp1){if (Fay$$_($tmp1) instanceof $_Prelude$Just) {if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("START_HITAHINT"))) {return Fay$$_(ChromeExtFay$startHah)(modeRef);}if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("FOCUS_FORM"))) {return Fay$$_(Fay$$_(ChromeExtFay$focusForm)(modeRef))(inputIdxRef);}if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("TOGGLE_SELECTOR"))) {return Fay$$_(ChromeExtFay$toggleSelector)(modeRef);}}var a = $tmp1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(a))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))(ChromeExtFay$defaultSettings)))))(Fay$$_(Fay$$$_return)(Fay$$unit))));})(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))(ChromeExtFay$defaultSettings))));});}));}var altRef = $p4;var ctrlRef = $p3;if (Fay$$_($p2) instanceof $_ChromeExtFay$HitAHintMode) {var e = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(ctrlRef)))(function($p1){var ctrl = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(altRef)))(function($p1){var alt = $p1;return (function($tmp1){if (Fay$$_($tmp1) instanceof $_Prelude$Just) {if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("CANCEL"))) {return Fay$$_(ChromeExtFay$cancel)(e);}}return Fay$$_(Fay$$_(ChromeExtFay$isHitAHintKey)(Fay$$_(ChromeExtFay$getKeyCode)(e))) ? Fay$$_(ChromeExtFay$hitHintKey)(e) : Fay$$_(Fay$$$_return)(Fay$$unit);})(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))(ChromeExtFay$defaultSettings));});});}var altRef = $p4;var ctrlRef = $p3;if (Fay$$_($p2) instanceof $_ChromeExtFay$SelectorMode) {var e = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(ctrlRef)))(function($p1){var ctrl = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(altRef)))(function($p1){var alt = $p1;return (function($tmp1){if (Fay$$_($tmp1) instanceof $_Prelude$Just) {if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("MOVE_NEXT_SELECTOR_CURSOR"))) {return Fay$$_(ChromeExtFay$moveNextCursor)(e);}if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("MOVE_PREV_SELECTOR_CURSOR"))) {return Fay$$_(ChromeExtFay$movePrevCursor)(e);}if (Fay$$equal(Fay$$_($tmp1).slot1,Fay$$list("CANCEL"))) {return Fay$$_(ChromeExtFay$cancel)(e);}}return Fay$$_(Fay$$$_return)(Fay$$unit);})(Fay$$_(Fay$$_(ChromeExtFay$keyMapper)(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$Key)(Fay$$_(ChromeExtFay$getKeyCode)(e)))(ctrl))(alt)))(ChromeExtFay$defaultSettings));});});}return Fay$$_(Fay$$$_return)(Fay$$unit);});};};};};return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("keydownMap: ")))(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$show))(Fay$$_(ChromeExtFay$getKeyCode)(e))))))(Fay$$_(Fay$$_(Fay$$then)((function($tmp1){if (Fay$$_($tmp1) === 17) {return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("ctrlKeyCode"))))(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(ctrlRef))(true));}if (Fay$$_($tmp1) === 18) {return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("altKeyCode"))))(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(altRef))(true));}return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$readRef)(modeRef)))(function($p1){var mode = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Prelude$putStrLn))(Fay$$_(Prelude$show)(mode))))(Fay$$_(Fay$$_(Fay$$_(Fay$$_(keydownMap$39$)(e))(mode))(ctrlRef))(altRef));});})(Fay$$_(ChromeExtFay$getKeyCode)(e))))(Fay$$_(Fay$$$_return)(Fay$$unit)));})();}throw ["unhandled case in keydownMap",[$p1,$p2]];});};};var ChromeExtFay$keyup = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],$(document).keyup(Fay$$fayToJs(["function",[["user","Event",[]],["action",[["unknown"]]]]],$p1))));});};var ChromeExtFay$keydown = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],$(document).keydown(Fay$$fayToJs(["function",[["user","Event",[]],["action",[["unknown"]]]]],$p1))));});};var ChromeExtFay$startHah = function($p1){return new Fay$$$(function(){var modeRef = $p1;return (function(){var f = function($p1){return new Fay$$$(function(){if (Fay$$listLen(Fay$$_($p1),2)) {var i = Fay$$index(0,Fay$$_($p1));var oldHtml = Fay$$index(1,Fay$$_($p1));return (function($tmp1){if (Fay$$_($tmp1) instanceof $_Prelude$Just) {var keyCode = Fay$$_($tmp1).slot1;return (function($tmp2){if (Fay$$_($tmp2) instanceof $_Prelude$Just) {var hintKeyName = Fay$$_($tmp2).slot1;return Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("\u003cdiv class=\"hintKey\"\u003e")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(hintKeyName))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("\u003c/div\u003e ")))(oldHtml)));}return oldHtml;})(Fay$$_(Fay$$_(Prelude$lookup)(keyCode))(ChromeExtFay$hintKeys));}return oldHtml;})(Fay$$_(ChromeExtFay$indexToKeyCode)(i));}throw ["unhandled case in f",[$p1]];});};return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("startHah"))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(modeRef))(ChromeExtFay$HitAHintMode)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(ChromeExtFay$clickables)))(Fay$$_(ChromeExtFay$addClass)(Fay$$list("links")))))(Fay$$_(ChromeExtFay$jqHtml)(f))))(Fay$$_(Fay$$$_return)(Fay$$unit))));})();});};var ChromeExtFay$focusForm = function($p1){return function($p2){return new Fay$$$(function(){var inputIdxRef = $p2;var modeRef = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("focusForm"))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(modeRef))(ChromeExtFay$FormFocusMode)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(inputIdxRef))(0)))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(ChromeExtFay$formInputFields)))(function($p1){var inputFields = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(Fay$$_(ChromeExtFay$jqEq)(0))(inputFields)))(ChromeExtFay$jqFocus)))(Fay$$_(Fay$$$_return)(Fay$$unit));}))));});};};var ChromeExtFay$toggleSelector = function($p1){return new Fay$$$(function(){var modeRef = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("toggleSelector"))))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(modeRef))(ChromeExtFay$SelectorMode)))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("#selectorConsole"))))(function($p1){var console = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(ChromeExtFay$jqShow)(console)))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("#selectorInput"))))(function($p1){var input = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(ChromeExtFay$jqFocus)(input)))(Fay$$_(Fay$$$_return)(Fay$$unit));}));})));});};var ChromeExtFay$filterSelector = function($p1){return new Fay$$$(function(){var keyCode = $p1;return Fay$$_(Prelude$putStrLn)(Fay$$list("filterSelector"));});};var ChromeExtFay$focusNextForm = new Fay$$$(function(){return Prelude$$_undefined;});var ChromeExtFay$focusPrevForm = new Fay$$$(function(){return Prelude$$_undefined;});var ChromeExtFay$cancel = new Fay$$$(function(){return Prelude$$_undefined;});var ChromeExtFay$hitHintKey = new Fay$$$(function(){return Prelude$$_undefined;});var ChromeExtFay$moveNextCursor = new Fay$$$(function(){return Prelude$$_undefined;});var ChromeExtFay$movePrevCursor = new Fay$$$(function(){return Prelude$$_undefined;});var ChromeExtFay$jqHtml = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p2).html(f)));});};};var ChromeExtFay$jqEq = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p2).eq(Fay$$fayToJs_int($p1))));});};};var ChromeExtFay$jqShow = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p1).show()));});};var ChromeExtFay$jqFocus = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p1).focus()));});};var ChromeExtFay$on = function($p1){return function($p2){return function($p3){return function($p4){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","JQuery",[]],Fay$$fayToJs(["user","JQuery",[]],$p4).on(Fay$$fayToJs_string($p1), Fay$$fayToJs_string($p2), Fay$$fayToJs(["function",[["user","Event",[]],["action",[["unknown"]]]]],$p3))));});};};};};var ChromeExtFay$St = function(getModeRef){return function(getCtrlRef){return function(getAltRef){return function(getInputIdxRef){return function(getListRef){return new Fay$$$(function(){return new $_ChromeExtFay$St(getModeRef,getCtrlRef,getAltRef,getInputIdxRef,getListRef);});};};};};};var ChromeExtFay$getModeRef = function(x){return new Fay$$$(function(){return Fay$$_(x).getModeRef;});};var ChromeExtFay$getCtrlRef = function(x){return new Fay$$$(function(){return Fay$$_(x).getCtrlRef;});};var ChromeExtFay$getAltRef = function(x){return new Fay$$$(function(){return Fay$$_(x).getAltRef;});};var ChromeExtFay$getInputIdxRef = function(x){return new Fay$$$(function(){return Fay$$_(x).getInputIdxRef;});};var ChromeExtFay$getListRef = function(x){return new Fay$$$(function(){return Fay$$_(x).getListRef;});};var ChromeExtFay$start = new Fay$$$(function(){return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$newRef)(ChromeExtFay$NeutralMode)))(function($p1){var modeRef = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$newRef)(false)))(function($p1){var ctrlRef = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$newRef)(false)))(function($p1){var altRef = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$newRef)(0)))(function($p1){var inputIdxRef = $p1;return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$newRef)(null)))(function($p1){var listRef = $p1;return (function(){var st = new Fay$$$(function(){var St = new $_ChromeExtFay$St();St.getModeRef = modeRef;St.getCtrlRef = ctrlRef;St.getAltRef = altRef;St.getInputIdxRef = inputIdxRef;St.getListRef = listRef;return St;});return Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("body"))))(function($p1){var body = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(ChromeExtFay$keydown)(function($p1){var e = $p1;return Fay$$_(Fay$$_(ChromeExtFay$keydownMap)(e))(st);})))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(ChromeExtFay$keyup)(function($p1){var e = $p1;return Fay$$_(Fay$$_(ChromeExtFay$keyupMap)(e))(st);})))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$on)(Fay$$list("submit")))(Fay$$list("#selectorForm")))(ChromeExtFay$decideSelector))(body)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$on)(Fay$$list("focus")))(ChromeExtFay$formInputFields))(function($p1){return Fay$$_(Fay$$_(ChromeExtFay$writeRef)(modeRef))(ChromeExtFay$FormFocusMode);}))(body)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$_(Fay$$_(ChromeExtFay$on)(Fay$$list("blur")))(ChromeExtFay$formInputFields))(function($p1){return Fay$$_(Fay$$_(ChromeExtFay$writeRef)(modeRef))(ChromeExtFay$NeutralMode);}))(body)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Prelude$$36$)(Fay$$_(ChromeExtFay$chromeExtensionSendMessage)(Fay$$list("{\"mes\": \"makeSelectorConsole\"}"))))(function($p1){var is = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Prelude$putStrLn)(Fay$$list("extension.sendMessage"))))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(Fay$$_(Prelude$$36$)(ChromeExtFay$fromJSON))(Fay$$_(Prelude$show)(is))))(function($p1){var items = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(ChromeExtFay$writeRef)(listRef))(items)))(Fay$$_(Fay$$_(Fay$$then)(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(ChromeExtFay$select)(Fay$$list("body"))))(Fay$$_(ChromeExtFay$append)(Fay$$list("\u003cdiv id=\"selectorConsole\"\u003e\u003cform id=\"selectorForm\"\u003e\u003cinput id=\"selectorInput\" type=\"text\" /\u003e\u003c/form\u003e\u003c/div\u003e")))))(Fay$$_(Fay$$_(Fay$$bind)(Fay$$_(Fay$$_(Prelude$$36$)(ChromeExtFay$arrToStr))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("\u003ctable id=\"selectorList\"\u003e")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$concat)((function(){var $gen_1 = function($p1){return new Fay$$$(function(){var t = $p1;return Fay$$list([Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("\u003ctr id=\"")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$show)(Fay$$_(ChromeExtFay$getType)(t))))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("-")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$show)(Fay$$_(ChromeExtFay$getId)(t))))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("\"\u003e\u003ctd\u003e\u003cspan class=\"title\"\u003e[")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$show)(Fay$$_(ChromeExtFay$getType)(t))))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list("] ")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$show)(Fay$$_(ChromeExtFay$getTitle)(t))))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$list(" \u003c/span\u003e\u003cspan class=\"url\"\u003e ")))(Fay$$_(Fay$$_(Prelude$$43$$43$)(Fay$$_(Prelude$show)(Fay$$_(ChromeExtFay$getUrl)(t))))(Fay$$list("\u003c/span\u003e\u003c/td\u003e\u003c/tr\u003e")))))))))))]);return null;});};return Fay$$_(Fay$$_(Prelude$concatMap)($gen_1))(Fay$$_(Fay$$_(Prelude$take)(10))(items));})())))(Fay$$list("\u003c/table\u003e"))))))(function($p1){var items$39$ = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(ChromeExtFay$makeSelectorConsole)(items$39$)))(Fay$$_(Fay$$$_return)(Fay$$unit));})));}));})))(Fay$$_(Fay$$$_return)(Fay$$unit)))))));});})();});});});});});});var ChromeExtFay$decideSelector = function($p1){return new Fay$$$(function(){var e = $p1;return Fay$$_(Fay$$_(Fay$$then)(Fay$$_(ChromeExtFay$preventDefault)(e)))(Fay$$_(Fay$$$_return)(Fay$$unit));});};var ChromeExtFay$preventDefault = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],Fay$$fayToJs(["user","Event",[]],$p1).preventDefault()));});};var ChromeExtFay$newRef = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["user","Ref",[["unknown"]]],new Fay$$Ref(Fay$$fayToJs(["unknown"],$p1))));});};var ChromeExtFay$writeRef = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],Fay$$writeRef(Fay$$fayToJs(["user","Ref",[["unknown"]]],$p1),Fay$$fayToJs(["unknown"],$p2))));});};};var ChromeExtFay$readRef = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],Fay$$readRef(Fay$$fayToJs(["user","Ref",[["unknown"]]],$p1))));});};var ChromeExtFay$chromeExtensionSendMessage = function($p1){return function($p2){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["unknown"],chrome.extension.sendMessage(JSON.parse(Fay$$fayToJs_string($p1)), Fay$$fayToJs(["function",[["unknown"],["action",[["unknown"]]]]],$p2))));});};};var ChromeExtFay$fromJSON = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay(["list",[["user","Item",[]]]],JSON.parse(Fay$$fayToJs_string($p1))));});};var ChromeExtFay$arrToStr = function($p1){return new Fay$$$(function(){return new Fay$$Monad(Fay$$jsToFay_string(Fay$$fayToJs(["list",[["user","Char",[]]]],$p1).join('')));});};var $_Language$Fay$FFI$Nullable = function(slot1){this.slot1 = slot1;};var $_Language$Fay$FFI$Null = function(){};var $_Language$Fay$FFI$Defined = function(slot1){this.slot1 = slot1;};var $_Language$Fay$FFI$Undefined = function(){};var $_Prelude$Just = function(slot1){this.slot1 = slot1;};var $_Prelude$Nothing = function(){};var $_Prelude$Left = function(slot1){this.slot1 = slot1;};var $_Prelude$Right = function(slot1){this.slot1 = slot1;};var $_Prelude$Ratio = function(slot1,slot2){this.slot1 = slot1;this.slot2 = slot2;};var $_Prelude$GT = function(){};var $_Prelude$LT = function(){};var $_Prelude$EQ = function(){};var $_Language$Fay$FFI$Nullable = function(slot1){this.slot1 = slot1;};var $_Language$Fay$FFI$Null = function(){};var $_Language$Fay$FFI$Defined = function(slot1){this.slot1 = slot1;};var $_Language$Fay$FFI$Undefined = function(){};var $_ChromeExtFay$Key = function(getCode,getCtrl,getAlt){this.getCode = getCode;this.getCtrl = getCtrl;this.getAlt = getAlt;};var $_ChromeExtFay$Item = function(getId,getTitle,getUrl,getType){this.getId = getId;this.getTitle = getTitle;this.getUrl = getUrl;this.getType = getType;};var $_ChromeExtFay$NeutralMode = function(){};var $_ChromeExtFay$HitAHintMode = function(){};var $_ChromeExtFay$SelectorMode = function(){};var $_ChromeExtFay$FormFocusMode = function(){};var $_ChromeExtFay$St = function(getModeRef,getCtrlRef,getAltRef,getInputIdxRef,getListRef){this.getModeRef = getModeRef;this.getCtrlRef = getCtrlRef;this.getAltRef = getAltRef;this.getInputIdxRef = getInputIdxRef;this.getListRef = getListRef;};var Fay$$fayToJsUserDefined = function(type,obj){var _obj = Fay$$_(obj);var argTypes = type[2];if (_obj instanceof $_Language$Fay$FFI$Nullable) {var obj_ = {"instance": "Nullable"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Language$Fay$FFI$Null) {var obj_ = {"instance": "Null"};return obj_;}if (_obj instanceof $_Language$Fay$FFI$Defined) {var obj_ = {"instance": "Defined"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Language$Fay$FFI$Undefined) {var obj_ = {"instance": "Undefined"};return obj_;}if (_obj instanceof $_Prelude$Just) {var obj_ = {"instance": "Just"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Prelude$Nothing) {var obj_ = {"instance": "Nothing"};return obj_;}if (_obj instanceof $_Prelude$Left) {var obj_ = {"instance": "Left"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Prelude$Right) {var obj_ = {"instance": "Right"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Prelude$Ratio) {var obj_ = {"instance": "Ratio"};var obj_slot1 = Fay$$fayToJs_int(_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}var obj_slot2 = Fay$$fayToJs_int(_obj.slot2);if (undefined !== obj_slot2) {obj_['slot2'] = obj_slot2;}return obj_;}if (_obj instanceof $_Prelude$GT) {var obj_ = {"instance": "GT"};return obj_;}if (_obj instanceof $_Prelude$LT) {var obj_ = {"instance": "LT"};return obj_;}if (_obj instanceof $_Prelude$EQ) {var obj_ = {"instance": "EQ"};return obj_;}if (_obj instanceof $_Language$Fay$FFI$Nullable) {var obj_ = {"instance": "Nullable"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Language$Fay$FFI$Null) {var obj_ = {"instance": "Null"};return obj_;}if (_obj instanceof $_Language$Fay$FFI$Defined) {var obj_ = {"instance": "Defined"};var obj_slot1 = Fay$$fayToJs(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],_obj.slot1);if (undefined !== obj_slot1) {obj_['slot1'] = obj_slot1;}return obj_;}if (_obj instanceof $_Language$Fay$FFI$Undefined) {var obj_ = {"instance": "Undefined"};return obj_;}if (_obj instanceof $_ChromeExtFay$Key) {var obj_ = {"instance": "Key"};var obj_getCode = Fay$$fayToJs_int(_obj.getCode);if (undefined !== obj_getCode) {obj_['getCode'] = obj_getCode;}var obj_getCtrl = Fay$$fayToJs_bool(_obj.getCtrl);if (undefined !== obj_getCtrl) {obj_['getCtrl'] = obj_getCtrl;}var obj_getAlt = Fay$$fayToJs_bool(_obj.getAlt);if (undefined !== obj_getAlt) {obj_['getAlt'] = obj_getAlt;}return obj_;}if (_obj instanceof $_ChromeExtFay$Item) {var obj_ = {"instance": "Item"};var obj_getId = Fay$$fayToJs_string(_obj.getId);if (undefined !== obj_getId) {obj_['getId'] = obj_getId;}var obj_getTitle = Fay$$fayToJs_string(_obj.getTitle);if (undefined !== obj_getTitle) {obj_['getTitle'] = obj_getTitle;}var obj_getUrl = Fay$$fayToJs_string(_obj.getUrl);if (undefined !== obj_getUrl) {obj_['getUrl'] = obj_getUrl;}var obj_getType = Fay$$fayToJs_string(_obj.getType);if (undefined !== obj_getType) {obj_['getType'] = obj_getType;}return obj_;}if (_obj instanceof $_ChromeExtFay$NeutralMode) {var obj_ = {"instance": "NeutralMode"};return obj_;}if (_obj instanceof $_ChromeExtFay$HitAHintMode) {var obj_ = {"instance": "HitAHintMode"};return obj_;}if (_obj instanceof $_ChromeExtFay$SelectorMode) {var obj_ = {"instance": "SelectorMode"};return obj_;}if (_obj instanceof $_ChromeExtFay$FormFocusMode) {var obj_ = {"instance": "FormFocusMode"};return obj_;}if (_obj instanceof $_ChromeExtFay$St) {var obj_ = {"instance": "St"};var obj_getModeRef = Fay$$fayToJs(["user","Ref",[["user","Mode",[]]]],_obj.getModeRef);if (undefined !== obj_getModeRef) {obj_['getModeRef'] = obj_getModeRef;}var obj_getCtrlRef = Fay$$fayToJs(["user","Ref",[["bool"]]],_obj.getCtrlRef);if (undefined !== obj_getCtrlRef) {obj_['getCtrlRef'] = obj_getCtrlRef;}var obj_getAltRef = Fay$$fayToJs(["user","Ref",[["bool"]]],_obj.getAltRef);if (undefined !== obj_getAltRef) {obj_['getAltRef'] = obj_getAltRef;}var obj_getInputIdxRef = Fay$$fayToJs(["user","Ref",[["int"]]],_obj.getInputIdxRef);if (undefined !== obj_getInputIdxRef) {obj_['getInputIdxRef'] = obj_getInputIdxRef;}var obj_getListRef = Fay$$fayToJs(["user","Ref",[["list",[["user","Item",[]]]]]],_obj.getListRef);if (undefined !== obj_getListRef) {obj_['getListRef'] = obj_getListRef;}return obj_;}return obj;};var Fay$$jsToFayUserDefined = function(type,obj){var argTypes = type[2];if (obj["instance"] === "Nullable") {return new $_Language$Fay$FFI$Nullable(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Null") {return new $_Language$Fay$FFI$Null();}if (obj["instance"] === "Defined") {return new $_Language$Fay$FFI$Defined(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Undefined") {return new $_Language$Fay$FFI$Undefined();}if (obj["instance"] === "Just") {return new $_Prelude$Just(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Nothing") {return new $_Prelude$Nothing();}if (obj["instance"] === "Left") {return new $_Prelude$Left(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Right") {return new $_Prelude$Right(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Ratio") {return new $_Prelude$Ratio(Fay$$jsToFay_int(obj["slot1"]),Fay$$jsToFay_int(obj["slot2"]));}if (obj["instance"] === "GT") {return new $_Prelude$GT();}if (obj["instance"] === "LT") {return new $_Prelude$LT();}if (obj["instance"] === "EQ") {return new $_Prelude$EQ();}if (obj["instance"] === "Nullable") {return new $_Language$Fay$FFI$Nullable(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Null") {return new $_Language$Fay$FFI$Null();}if (obj["instance"] === "Defined") {return new $_Language$Fay$FFI$Defined(Fay$$jsToFay(argTypes && (argTypes)[0] ? (argTypes)[0] : (type)[0] === "automatic" ? ["automatic"] : ["unknown"],obj["slot1"]));}if (obj["instance"] === "Undefined") {return new $_Language$Fay$FFI$Undefined();}if (obj["instance"] === "Key") {return new $_ChromeExtFay$Key(Fay$$jsToFay_int(obj["getCode"]),Fay$$jsToFay_bool(obj["getCtrl"]),Fay$$jsToFay_bool(obj["getAlt"]));}if (obj["instance"] === "Item") {return new $_ChromeExtFay$Item(Fay$$jsToFay_string(obj["getId"]),Fay$$jsToFay_string(obj["getTitle"]),Fay$$jsToFay_string(obj["getUrl"]),Fay$$jsToFay_string(obj["getType"]));}if (obj["instance"] === "NeutralMode") {return new $_ChromeExtFay$NeutralMode();}if (obj["instance"] === "HitAHintMode") {return new $_ChromeExtFay$HitAHintMode();}if (obj["instance"] === "SelectorMode") {return new $_ChromeExtFay$SelectorMode();}if (obj["instance"] === "FormFocusMode") {return new $_ChromeExtFay$FormFocusMode();}if (obj["instance"] === "St") {return new $_ChromeExtFay$St(Fay$$jsToFay(["user","Ref",[["user","Mode",[]]]],obj["getModeRef"]),Fay$$jsToFay(["user","Ref",[["bool"]]],obj["getCtrlRef"]),Fay$$jsToFay(["user","Ref",[["bool"]]],obj["getAltRef"]),Fay$$jsToFay(["user","Ref",[["int"]]],obj["getInputIdxRef"]),Fay$$jsToFay(["user","Ref",[["list",[["user","Item",[]]]]]],obj["getListRef"]));}return obj;};
// Exports
this.ChromeExtFay$FormFocusMode = ChromeExtFay$FormFocusMode;
this.ChromeExtFay$HitAHintMode = ChromeExtFay$HitAHintMode;
this.ChromeExtFay$Item = ChromeExtFay$Item;
this.ChromeExtFay$Key = ChromeExtFay$Key;
this.ChromeExtFay$NeutralMode = ChromeExtFay$NeutralMode;
this.ChromeExtFay$SelectorMode = ChromeExtFay$SelectorMode;
this.ChromeExtFay$St = ChromeExtFay$St;
this.ChromeExtFay$_hintKeys = ChromeExtFay$_hintKeys;
this.ChromeExtFay$addClass = ChromeExtFay$addClass;
this.ChromeExtFay$addClassWith = ChromeExtFay$addClassWith;
this.ChromeExtFay$altKeycode = ChromeExtFay$altKeycode;
this.ChromeExtFay$append = ChromeExtFay$append;
this.ChromeExtFay$arrToStr = ChromeExtFay$arrToStr;
this.ChromeExtFay$cancel = ChromeExtFay$cancel;
this.ChromeExtFay$chromeExtensionSendMessage = ChromeExtFay$chromeExtensionSendMessage;
this.ChromeExtFay$clickables = ChromeExtFay$clickables;
this.ChromeExtFay$ctrlKeycode = ChromeExtFay$ctrlKeycode;
this.ChromeExtFay$decideSelector = ChromeExtFay$decideSelector;
this.ChromeExtFay$defaultSettings = ChromeExtFay$defaultSettings;
this.ChromeExtFay$filterSelector = ChromeExtFay$filterSelector;
this.ChromeExtFay$focusForm = ChromeExtFay$focusForm;
this.ChromeExtFay$focusNextForm = ChromeExtFay$focusNextForm;
this.ChromeExtFay$focusPrevForm = ChromeExtFay$focusPrevForm;
this.ChromeExtFay$formInputFields = ChromeExtFay$formInputFields;
this.ChromeExtFay$fromJSON = ChromeExtFay$fromJSON;
this.ChromeExtFay$getAlt = ChromeExtFay$getAlt;
this.ChromeExtFay$getAltRef = ChromeExtFay$getAltRef;
this.ChromeExtFay$getCode = ChromeExtFay$getCode;
this.ChromeExtFay$getCtrl = ChromeExtFay$getCtrl;
this.ChromeExtFay$getCtrlRef = ChromeExtFay$getCtrlRef;
this.ChromeExtFay$getId = ChromeExtFay$getId;
this.ChromeExtFay$getInputIdxRef = ChromeExtFay$getInputIdxRef;
this.ChromeExtFay$getKeyCode = ChromeExtFay$getKeyCode;
this.ChromeExtFay$getListRef = ChromeExtFay$getListRef;
this.ChromeExtFay$getModeRef = ChromeExtFay$getModeRef;
this.ChromeExtFay$getTitle = ChromeExtFay$getTitle;
this.ChromeExtFay$getType = ChromeExtFay$getType;
this.ChromeExtFay$getUrl = ChromeExtFay$getUrl;
this.ChromeExtFay$hintKeys = ChromeExtFay$hintKeys;
this.ChromeExtFay$hitHintKey = ChromeExtFay$hitHintKey;
this.ChromeExtFay$indexToKeyCode = ChromeExtFay$indexToKeyCode;
this.ChromeExtFay$isHitAHintKey = ChromeExtFay$isHitAHintKey;
this.ChromeExtFay$jqEq = ChromeExtFay$jqEq;
this.ChromeExtFay$jqFocus = ChromeExtFay$jqFocus;
this.ChromeExtFay$jqHtml = ChromeExtFay$jqHtml;
this.ChromeExtFay$jqShow = ChromeExtFay$jqShow;
this.ChromeExtFay$keyCodeFromKeyName = ChromeExtFay$keyCodeFromKeyName;
this.ChromeExtFay$keyCodeFromKeyName$39$ = ChromeExtFay$keyCodeFromKeyName$39$;
this.ChromeExtFay$keyCodeToIndex = ChromeExtFay$keyCodeToIndex;
this.ChromeExtFay$keyMap = ChromeExtFay$keyMap;
this.ChromeExtFay$keyMapper = ChromeExtFay$keyMapper;
this.ChromeExtFay$keydown = ChromeExtFay$keydown;
this.ChromeExtFay$keydownMap = ChromeExtFay$keydownMap;
this.ChromeExtFay$keyup = ChromeExtFay$keyup;
this.ChromeExtFay$keyupMap = ChromeExtFay$keyupMap;
this.ChromeExtFay$localStorageGet = ChromeExtFay$localStorageGet;
this.ChromeExtFay$localStorageSet = ChromeExtFay$localStorageSet;
this.ChromeExtFay$main = ChromeExtFay$main;
this.ChromeExtFay$makeSelectorConsole = ChromeExtFay$makeSelectorConsole;
this.ChromeExtFay$moveNextCursor = ChromeExtFay$moveNextCursor;
this.ChromeExtFay$movePrevCursor = ChromeExtFay$movePrevCursor;
this.ChromeExtFay$newRef = ChromeExtFay$newRef;
this.ChromeExtFay$on = ChromeExtFay$on;
this.ChromeExtFay$preventDefault = ChromeExtFay$preventDefault;
this.ChromeExtFay$printArg = ChromeExtFay$printArg;
this.ChromeExtFay$readRef = ChromeExtFay$readRef;
this.ChromeExtFay$ready = ChromeExtFay$ready;
this.ChromeExtFay$remove = ChromeExtFay$remove;
this.ChromeExtFay$select = ChromeExtFay$select;
this.ChromeExtFay$selectorNum = ChromeExtFay$selectorNum;
this.ChromeExtFay$showDouble = ChromeExtFay$showDouble;
this.ChromeExtFay$showString = ChromeExtFay$showString;
this.ChromeExtFay$start = ChromeExtFay$start;
this.ChromeExtFay$startHah = ChromeExtFay$startHah;
this.ChromeExtFay$toggleSelector = ChromeExtFay$toggleSelector;
this.ChromeExtFay$writeRef = ChromeExtFay$writeRef;

// Built-ins
this._ = Fay$$_;
this.$           = Fay$$$;
this.$fayToJs    = Fay$$fayToJs;
this.$jsToFay    = Fay$$jsToFay;

};
;
var main = new ChromeExtFay();
main._(main.ChromeExtFay$main);

