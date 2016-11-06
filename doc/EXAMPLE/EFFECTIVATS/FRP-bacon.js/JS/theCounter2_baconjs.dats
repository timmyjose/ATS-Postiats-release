(*
theCounter2_baconjs
*)

(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME "theCounter2_baconjs_start"
//
(* ****** ****** *)
//
#include
"share/atspre_define.hats"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2JS}/staloadall.hats"
//
staload
"{$LIBATSCC2JS}/SATS/print.sats"
staload _(*anon*) =
"{$LIBATSCC2JS}/DATS/print.dats"
//
(* ****** ****** *)
//
staload
"{$LIBATSCC2JS}/SATS/Bacon.js/baconjs.sats"
//
(* ****** ****** *)

local
//
datatype act = Up | Down | Reset
//
val theUp_btn = $extval(ptr, "$(\"#theUp_btn\")")
val theDown_btn = $extval(ptr, "$(\"#theDown_btn\")")
val theReset_btn = $extval(ptr, "$(\"#theReset_btn\")")
//
val theUp_clicks = $extmcall(EStream(void), theUp_btn, "asEventStream", "click")
val theDown_clicks = $extmcall(EStream(void), theDown_btn, "asEventStream", "click")
val theReset_clicks = $extmcall(EStream(void), theReset_btn, "asEventStream", "click")
//
val theUp_clicks = theUp_clicks.map(TYPE{act})(lam _ => Up())
val theDown_clicks = theDown_clicks.map(TYPE{act})(lam _ => Down())
val theReset_clicks = theReset_clicks.map(TYPE{act})(lam _ => Reset())
//
val theComb_clicks = merge(theUp_clicks, theDown_clicks, theReset_clicks)
//
val
theCounts =
scan{int,act}
(
  theComb_clicks
, 0 // initial count
, lam(res, act) =>
  (
    case+ act of
    | Up() => min(res+1, 99)
    | Down() => max(0, res-1)
    | Reset() => 0 // the default
  )
) (* end of [theCounts] *)
//
in (* in-of-local *)
//
val () =
theCounts.onValue()
(
lam(count) =>
{
  val d0 = count%10 and d1 = count/10
  val d0 = String(d0) and d1 = String(d1)
  val theCount2_p = $extval(ptr, "$(\"#theCount2_p\")")
  val ((*void*)) = $extmcall(void, theCount2_p, "text", String(d1)+String(d0))
}
) (* end of [val] *)
//
end // end of [local]

(* ****** ****** *)

%{$
//
theCounter2_baconjs_start();
//
%} // end of [%{$]

(* ****** ****** *)

(* end of [theCounter2_baconjs.dats] *)
