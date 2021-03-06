(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: May, 2011
//
(* ****** ****** *)
//
staload
ATSPRE =
"./pats_atspre.dats"
//
(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"

(* ****** ****** *)
//
staload LAB = "./pats_label.sats"
overload = with $LAB.eq_label_label
overload != with $LAB.neq_label_label
//
staload EFF = "./pats_effect.sats"
overload = with $EFF.eq_effset_effset
//
(* ****** ****** *)
//
staload INTINF = "./pats_intinf.sats"
//
macdef eq_int_intinf = $INTINF.eq_int_intinf
macdef eq_intinf_int = $INTINF.eq_intinf_int
macdef eq_intinf_intinf = $INTINF.eq_intinf_intinf
//
(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_stacst2.sats"
staload "./pats_staexp2_util.sats"

(* ****** ****** *)

#define l2l list_of_list_vt

(* ****** ****** *)
//
extern
fun
s2exp_linkrem_flag
(
  s2e0: s2exp, flag: &int >> int
) : s2exp // s2exp_linkrem_flag
//
(* ****** ****** *)
//
implement
s2exp_linkrem_flag
  (s2e0, flag) = let
(*
val () =
println! (
"s2exp_linkrem_flag: s2e0 = ", s2e0
) (* end of [val] *)
*)
//
(*
HX-2017-03-14:
1000 should be enough
*)
#define
S2EXP_LINKREM_DEPTH 1000
//
fun
auxlinkrem
(
  s2e0: s2exp
, flag: &int >> int, tick: int
) : s2exp = let
//
(*
val () =
prerrln! ("auxinkrem: tick = ", tick)
*)
//
val () =
if
(tick <= 0)
then () where
{
//
val () =
(
prerrln! ("Panic from [patsopt]:\n");
prerrln! ("The potential causes may be:\n");
prerrln! ("1. template arguments are not given explicitly;");
prerrln! ("2. ...(other potential causes are yet to be added!)");
)
//
val () = $ERR.abort_interr{void}()
//
} (* end of [if] *)
//
in
//
case+
s2e0.s2exp_node
of (* case+ *)
| S2Ecst(s2c) => let
//
    val
    isr =
    s2cst_get_isrec(s2c)
//
  in
    if isr then s2e0 else let
      val opt =
        s2cst_get_def(s2c)
      // end of [val]
    in
      case+ opt of
      | None() => s2e0
      | Some(s2e) => let
          val () =
            (flag := flag + 1)
          // end of [val]
        in
          auxlinkrem(s2e, flag, tick-1)
        end // end of [Some]
    end (* end of [if] *)
  end // end of [S2Ecst]
//
// HX: the link of s2V should not be updated!!!
//
| S2EVar(s2V) =>
  (
  case+
  s2Var_get_link(s2V)
  of (* case+ *)
  | Some(s2e) => let
      val () =
        (flag := flag + 1) in auxlinkrem(s2e, flag, tick-1)
      // end of [val]
    end // end of [Some]
  | None((*void*)) => s2e0
  ) (* end of [S2EVar] *)
//
| _ (* rest-of-s2exp *) => s2e0 // end of [_]
//
end // end of [auxlinkrem]
//
in
//
  auxlinkrem(s2e0, flag, S2EXP_LINKREM_DEPTH(*1000000*))
//
end (* end of [s2exp_linkrem_flag] *)
//
implement
s2exp_linkrem(s2e0) =
  let var flag: int = 0 in s2exp_linkrem_flag(s2e0, flag) end
// end of [s2exp_linkrem]
//
(* ****** ****** *)

fun
labs2explst_top
(
  knd: int, ls2es0: labs2explst
) : labs2explst = let
in
//
case+ ls2es0 of
| list_nil
    ((*void*)) => list_nil()
  // end of [list_nil]
//
| list_cons
    (ls2e, ls2es) => let
//
    val SLABELED(l, name, s2e) = ls2e
//
    val s2e = s2exp_top(knd, s2e)
    val ls2e = SLABELED(l, name, s2e) 
    val ls2es = labs2explst_top(knd, ls2es)
//
  in
    list_cons(ls2e, ls2es)
  end // end of [list_cons]
end // end of [labs2explst_top]

(* ****** ****** *)

extern
fun
s2exp_topize_flag
  (knd: int, s2e: s2exp, flag: &int >> int): s2exp
// end of [s2exp_topize_flag]

extern
fun
s2exp_invar_flag(s2e: s2exp, flag: &int >> int): s2exp

(* ****** ****** *)

extern
fun
s2exp_hnfize_flag
  (s2e: s2exp, flag: &int >> int): s2exp
extern
fun
s2explst_hnfize_flag
  (s2es: s2explst, flag: &int >> int): s2explst
extern
fun
labs2explst_hnfize_flag
  (ls2es: labs2explst, flag: &int >> int): labs2explst

(* ****** ****** *)

extern
fun
s2exp_hnfize_app
(
  s2e0: s2exp
, s2e_fun: s2exp, s2es_arg: s2explst, flag: &int >> int
) : s2exp // [s2exp_hnfize_app]

(* ****** ****** *)

implement
s2exp_topize_flag
  (knd, s2e0, flag) = let
//
val s2t0 = s2e0.s2exp_srt
//
in
//
case+ 0 of
| _ when
    s2rt_is_prf(s2t0) => let
    val () = flag := flag+1 in s2exp_unit_prop()
  end // end of [_ when ...]
| _ (*isprf=false*) => let
    val
    isdone =
    (
      if
      (knd > 0) // typization
      then (
        if s2exp_is_lin(s2e0) then false else true
      ) else false // end of [else]
    ) : bool // end of [val]
    val s2e0 = s2exp_hnfize_flag(s2e0, flag)
  in
    if isdone
    then s2e0 // no change
    else let
      val () = flag := flag+1
    in
      case+
      s2e0.s2exp_node
      of (* case+ *)
      | S2Etop(_, s2e) =>
          s2exp_topize_flag(knd, s2e, flag)
        // end of [S2Etop]
      | S2Etyarr
          (s2e_elt, dim) => let
          val s2e_elt = s2exp_top (knd, s2e_elt)
        in
          s2exp_tyarr_srt(s2rt_t0ype, s2e_elt, dim)
        end // end of [S2Etyarr]
      | S2Etyrec
          (recknd, npf, ls2es) => let
          val isboxed = tyreckind_is_boxed(recknd)
        in
          if isboxed
            then s2exp_ptr_type ()
            else let
              val ls2es = labs2explst_top(knd, ls2es)
            in
              s2exp_tyrec_srt(s2rt_t0ype, recknd, npf, ls2es)
            end // end of [else]
          // end of [if]
        end // end of [S2Etyrec]
      | _ when // HX: this seems adequate
          s2rt_is_boxed(s2t0) => s2exp_ptr_type()
      | _ => s2exp_top_srt(s2rt_t0ype, knd, s2e0)
    end (* end of [if] *)
  end // end of [_]
//
end (* end of [s2exp_topize_flag] *)

(* ****** ****** *)

implement
s2exp_topize
  (knd, s2e) = let
  var flag: int = 0
in
  s2exp_topize_flag(knd, s2e, flag)
end // end of [s2exp_topize_0]

implement
s2exp_topize_0(s2e) = s2exp_topize(0(*knd*), s2e)
implement
s2exp_topize_1(s2e) = s2exp_topize(1(*knd*), s2e)

(* ****** ****** *)

implement
s2exp_invar_flag
  (s2e0, flag) = let
//
val-S2Einvar(s2e) = s2e0.s2exp_node
//
in
//
case+
s2e.s2exp_node
of (*case+*)
//
| S2Evar _ => s2e0
//
| S2EVar _ => let
    val flag0 = flag
    val s2e =
      s2exp_hnfize_flag(s2e, flag)
    // end of [val]
  in
    if flag <= flag0 then s2e0 else s2e
  end // end of [S2Evar]
//
| _ => let
    val () = flag := flag + 1 in s2exp_hnfize_flag(s2e, flag)
  end // end of [_]
//
end // end of [s2exp_invar_flag]

(* ****** ****** *)

implement
s2exp_hnfize_app
(
  s2e0, s2e_fun, s2es_arg, flag
) = let
(*
//
val () =
println!
  ("s2exp_hnfize_app: s2e0 = ", s2e0)
//
*)
//
val flag0 = flag
//
val s2e_fun =
  s2exp_hnfize_flag(s2e_fun, flag)
//
val s2es_arg =
  s2explst_hnfize_flag(s2es_arg, flag)
//
(*
//
val () =
println!
  ("s2exp_hnfize_app: s2es_arg = ", s2es_arg)
//
*)
in
//
case+
s2e_fun.s2exp_node
of // case+
| S2Elam (
    s2vs_arg, s2e_body
  ) => let
    #define :: list_cons
    fun
    aux (
      s2vs: s2varlst
    , s2es: s2explst, sub: &stasub
    ) : void =
      case+
      (
        s2vs, s2es
      ) of (* case+ *)
      | (list_nil(), _) => ()
      | (_, list_nil()) => ()
      | (s2v :: s2vs, s2e :: s2es) =>
        aux(s2vs, s2es, sub) where
        {
          val () = stasub_add(sub, s2v, s2e)
        } (* end of [cons, cons] *)
    // end of [aux]
    val () = flag := flag + 1
    var sub = stasub_make_nil()
    val () =
      aux(s2vs_arg, s2es_arg, sub)
    // end of [val]
    val s2e0 =
      s2exp_subst(sub, s2e_body)
    // end of [val]
    val ((*freed*)) = stasub_free(sub)
  in
    s2exp_hnfize_flag(s2e0, flag)
  end // end of [S2Elam]
| _ (* non-S2Elam *) =>
  (
    if flag > flag0
      then s2exp_app_srt(s2e0.s2exp_srt, s2e_fun, s2es_arg)
      else s2e0 (* there is no change *)
    // end of [if]
  ) (* end of [non-S2Elam] *)
//
end // end of [s2exp_hnfize_flag_app]

(* ****** ****** *)

implement
s2exp_hnfize_flag
  (s2e0, flag) = let
//
(*
val () =
(
println!
(
"s2exp_hnfize_flag: s2e0(bef) = ", s2e0
)
) // end of [val]
*)
//
val s2t0 = s2e0.s2exp_srt
val s2e0 = s2exp_linkrem_flag(s2e0, flag)
//
(*
//
val () =
(
println!
(
"s2exp_hnfize_flag: s2e0(aft) = ", s2e0
)
) // end of [val]
*)
//
in
//
case+
s2e0.s2exp_node
of (* case+ *)
//
| S2Eint _ => s2e0
| S2Eintinf _ => s2e0
//
| S2Efloat _ => s2e0
| S2Estring _ => s2e0
//
| S2Ecst _ => s2e0
//
| S2Eextype _ => s2e0
| S2Eextkind _ => s2e0
//
| S2Evar (s2v) =>
    s2exp_hnfize_flag_svar (s2e0, s2v, flag)
  // end of [S2Evar]
//
| S2EVar _ => s2e0
//
| S2Ehole _ => s2e0
//
| S2Edatcontyp _ => s2e0
| S2Edatconptr _ => s2e0
//
| S2Eat _ => s2e0
| S2Esizeof _ => s2e0
//
| S2Eeff _ => s2e0
| S2Eeqeq _ => s2e0
//
| S2Eproj _ => s2e0
//
| S2Eapp
  (
    s2e_fun, s2es_arg
  ) =>
    s2exp_hnfize_app(s2e0, s2e_fun, s2es_arg, flag)
  // end of [S2Eapp]
| S2Elam
  (
    s2vs_arg, s2e_body
  ) => let
    val flag0 = flag
    val s2e_body = s2exp_hnfize_flag (s2e_body, flag)
  in
    if flag > flag0
      then s2exp_lam_srt(s2t0, s2vs_arg, s2e_body) else s2e0
    // end of [if]
  end // end of [S2Elam]
| S2Efun _ => s2e0
| S2Emetfun _ => s2e0
| S2Emetdec _ => s2e0
//
| S2Etop(knd, s2e) => s2exp_topize_flag (knd, s2e, flag)
| S2Ewithout _ => s2e0
//
| S2Etyarr _ => s2e0
| S2Etyrec _ => s2e0
//
| S2Einvar _ => s2exp_invar_flag (s2e0, flag)
//
(*
| S2Eexi _=> s2e0
| S2Euni _=> s2e0
*)
| S2Eexi
  (
    s2vs, s2ps, s2e_scope
  ) => let
    val flag0 = flag
    val s2e_scope = s2exp_hnfize_flag(s2e_scope, flag)
  in
    if flag > flag0 then s2exp_exi(s2vs, s2ps, s2e_scope) else s2e0
  end // end of [S2Eexi]
| S2Euni
  (
    s2vs, s2ps, s2e_scope
  ) => let
    val flag0 = flag
    val s2e_scope = s2exp_hnfize_flag(s2e_scope, flag)
  in
    if flag > flag0 then s2exp_uni(s2vs, s2ps, s2e_scope) else s2e0
  end // end of [S2Euni]
//
| S2Erefarg _ => s2e0
//
| S2Evararg _ => s2e0
//
| S2Ewthtype _ => s2e0
//
| S2Eerrexp((*void*)) => s2e0
//
(*
| _ (*rest-of-s2exp*) => let
    val () =
    (
      print "s2exp_hnfize_flag: s2e0 = "; print_s2exp (s2e0); print_newline ()
    ) // end of [val]
    val () = assertloc (false)
  in
    s2e0
  end // end of [_]
*)
//
end // end of [s2exp_hnfize_flag]

(* ****** ****** *)

implement
s2explst_hnfize_flag
  (s2es0, flag) = let
in
//
case+ s2es0 of
| list_nil
    ((*void*)) => list_nil()
  // end of [list_nil]
| list_cons
    (s2e, s2es) => let
//
    val
    flag0 = flag
//
    val s2e = s2exp_hnfize_flag(s2e, flag)
    val s2es = s2explst_hnfize_flag(s2es, flag)
//
  in
    if flag > flag0 then
      list_cons (s2e, s2es) else s2es0
    // end of [if]
  end // end of [list_cons]
//
end // end of [s2explst_hnfize_flag]

(* ****** ****** *)

implement
labs2explst_hnfize_flag
  (ls2es0, flag) = let
in
//
case+ ls2es0 of
| list_nil
    ((*void*)) => list_nil()
  // end of [list_nil]
| list_cons
    (ls2e, ls2es) => let
    val flag0 = flag
    val SLABELED(l, name, s2e) = ls2e
    val s2e = s2exp_hnfize_flag(s2e, flag)
    val ls2es = labs2explst_hnfize_flag(ls2es, flag)
  in
    if flag > flag0 then
      list_cons(SLABELED(l, name, s2e), ls2es) else ls2es0
    // end of [if]
  end // end of [list_cons]
//
end // end of [labs2explst_hnfize_flag]

(* ****** ****** *)

implement
s2exp_hnfize(s2e) = let
//
(*
  val () =
  println! ("s2exp_hnfize: s2e = ", s2e)
*)
//
  var flag: int = 0 in s2exp_hnfize_flag(s2e, flag)
end // end of [s2exp_hnfsize]

implement
s2explst_hnfize(s2es) = let
  var flag: int = 0 in s2explst_hnfize_flag(s2es, flag)
end // end of [s2explst_hnfsize]

implement
s2expopt_hnfize
  (opt) = let
  var flag: int = 0
in
//
case+ opt of
| None() => None()
| Some(s2e) => let
    val s2f =
      s2exp_hnfize_flag(s2e, flag)
    // end of [val]
  in
    if flag > 0 then Some(s2f) else opt
  end // end of [Some]
//
end // end of [s2expopt_hnfsize]

(* ****** ****** *)
//
extern
fun
s2exp_mhnfize_flag
  (x: s2exp, flag: &int >> int): s2exp
extern
fun
s2explst_mhnfize_flag
  (xs: s2explst, flag: &int >> int): s2explst
extern
fun
s2explstlst_mhnfize_flag
  (xss: s2explstlst, flag: &int >> int): s2explstlst
//
(*
extern
fun
labs2explst_mhnfize_flag
  (ls2es: labs2explst, flag: &int >> int): labs2explst
*)
//
(* ****** ****** *)

implement
s2exp_mhnfize_flag
  (s2e0, flag) = let
//
val s2e0 =
  s2exp_hnfize_flag(s2e0, flag)
//
in
//
case+
s2e0.s2exp_node of
| S2EVar(s2V) => let
    val f0 = flag
    val s2ze = s2Var_get_szexp(s2V)
  in
    case+ s2ze of
    | S2ZEvar (s2v) => let
        val () = flag := f0 + 1 in s2exp_var(s2v)
      end // end of [S2ZEvar]
    | _(*non-s2var*) => s2e0
  end // end of [S2EVar]
| _ (*non-S2EVar*) => s2e0 // HX: should be removed eventually!
//
end // end of [s2exp_mhnfize_flag]

(* ****** ****** *)

implement
s2explst_mhnfize_flag
  (s2es0, flag) = let
in
//
case+ s2es0 of
| list_nil
    () => list_nil()
  // list_nil
| list_cons
    (s2e, s2es) => let
    val flag0 = flag
    val s2e = s2exp_mhnfize_flag(s2e, flag)
    val s2es = s2explst_mhnfize_flag(s2es, flag)
  in
    if flag > flag0 then list_cons(s2e, s2es) else s2es0
  end // end of [list_cons]
//
end // end of [s2explst_mhnfize_flag]

(* ****** ****** *)

implement
s2explstlst_mhnfize_flag
  (s2ess0, flag) = let
in
//
case+ s2ess0 of
| list_nil
    () => list_nil()
  // list_nil
| list_cons
    (s2es, s2ess) => let
    val flag0 = flag
    val s2es = s2explst_mhnfize_flag (s2es, flag)
    val s2ess = s2explstlst_mhnfize_flag (s2ess, flag)
  in
    if flag > flag0 then list_cons (s2es, s2ess) else s2ess0
  end // end of [list_cons]
//
end // end of [s2explstlst_mhnfize_flag]

(* ****** ****** *)

implement
s2exp_mhnfize(s2e) = let
  var flag: int = 0 in s2exp_mhnfize_flag(s2e, flag)
end // end of [s2exp_mhnfize]

implement
s2explst_mhnfize(s2es) = let
  var flag: int = 0 in s2explst_mhnfize_flag(s2es, flag)
end // end of [s2explst_mhnfize]

implement
s2explstlst_mhnfize(s2ess) = let
  var flag: int = 0 in s2explstlst_mhnfize_flag(s2ess, flag)
end // end of [s2explstlst_mhnfize]

(* ****** ****** *)
//
implement
s2hnf2exp(s2f) = $UN.cast{s2exp}(s2f)
//
implement
s2exp2hnf(s2e) = let
//
val s2f =
s2exp_hnfize(s2e) in $UN.cast{s2hnf}(s2f)
//
end // end of [s2exp2hnf]
//
implement
s2exp2hnf_cast(s2e) = $UN.cast{s2hnf}(s2e)
//
(* ****** ****** *)
//
extern
fun
s2hnf_syneq_exn
  (s2f1: s2hnf, s2f2: s2hnf): void
and
s2exp_syneq_exn
  (s2e1: s2exp, s2e2: s2exp): void
//
extern
fun
s2hnflst_syneq_exn
  (xs1: s2hnflst, xs2: s2hnflst): void
and
s2explst_syneq_exn
  (xs1: s2explst, xs2: s2explst): void
//
extern
fun
s2explstlst_syneq_exn
  (xss1: s2explstlst, xss2: s2explstlst): void
// end of [s2explstlst_syneq_exn]
//
(* ****** ****** *)
//
exception SYNEQexn of ()
//
(* ****** ****** *)

implement
s2hnf_syneq
  (s2f1, s2f2) =
(
try let
//
val () =
  s2hnf_syneq_exn(s2f1, s2f2)
//
in
  true
end with
  | ~SYNEQexn((*void*)) => false
) (* end of [s2hnf_syneq] *)

implement
s2exp_syneq
  (s2e1, s2e2) =
(
try let
//
val () =
  s2exp_syneq_exn(s2e1, s2e2)
//
in
  true
end with
  | ~SYNEQexn((*void*)) => false
) (* end of [s2exp_syneq] *)

(* ****** ****** *)

implement
s2explst_syneq
  (xs1, xs2) =
(
try let
//
val () =
  s2explst_syneq_exn(xs1, xs2)
//
in
  true
end with
  | ~SYNEQexn((*void*)) => false
) (* end of [s2explst_syneq] *)

(* ****** ****** *)

implement
s2exp_syneq_exn
  (s2e10, s2e20) = let
  val s2f10 = s2exp2hnf (s2e10)
  and s2f20 = s2exp2hnf (s2e20)
in
  s2hnf_syneq_exn (s2f10, s2f20)
end // end of [s2exp_syneq_exn]

implement
s2hnflst_syneq_exn
  (xs1, xs2) = let
in
//
case+ (xs1, xs2) of
| (list_cons(x1, xs1),
   list_cons(x2, xs2)) => let
    val () = s2hnf_syneq_exn(x1, x2) in s2hnflst_syneq_exn(xs1, xs2)
  end // end of [cons, cons]
| (list_nil(), list_nil()) => ()
| (_, _) => $raise (SYNEQexn)
//
end // end of [s2hnflst_syneq_exn]

implement
s2explst_syneq_exn
  (xs1, xs2) = let
//
(*
val () =
println! ("s2explst_syneq_exn")
*)
//
in
//
case+
(xs1, xs2)
of (*case+*)
| (
   list_cons(x1, xs1)
  ,
   list_cons(x2, xs2)
  ) => let
    val () =
    s2exp_syneq_exn(x1, x2)
  in
    s2explst_syneq_exn(xs1, xs2)
  end // end of [cons, cons]
| (list_nil(), list_nil()) => ()
//
| (_(*s2explst*), _(*s2explst*)) => $raise (SYNEQexn)
//
end // end of [s2explst_syneq_exn]

implement
s2explstlst_syneq_exn
  (xss1, xss2) = let
//
(*
val () =
println! ("s2explstlst_syneq_exn")
*)
//
in
//
case+
(xss1, xss2)
of (*case+*)
| (
   list_cons(xs1, xss1)
  ,
   list_cons(xs2, xss2)
  ) => let
    val () =
    s2explst_syneq_exn(xs1, xs2)
  in
    s2explstlst_syneq_exn(xss1, xss2)
  end // end of [cons, cons]
| (list_nil(), list_nil()) => ()
//
| (_(*s2explstlst*), _(*s2explstlst*)) => $raise (SYNEQexn)
//
end // end of [s2explstlst_syneq_exn]

(* ****** ****** *)
//
fun
s2eff_syneq
(
  s2fe1: s2eff, s2fe2: s2eff
) : bool =
(
try let
//
val () =
  s2eff_syneq_exn (s2fe1, s2fe2)
//
in
  true
end with
  | ~SYNEQexn((*void*)) => false
) (* end of [s2eff_syneq_exn] *)
//
and
s2eff_syneq_exn
(
  s2fe1: s2eff, s2fe2: s2eff
) : void = let
in
//
case+
(s2fe1, s2fe2)
of (* case+ *)
| (
   S2EFFset(xs1)
  ,
   S2EFFset(xs2)
  ) =>
    if ~(xs1=xs2)
      then $raise (SYNEQexn)
    // end of [if]
  // end of [S2EFFset, S2EFFset]
//
| (
   S2EFFexp(s2e1)
  ,
   S2EFFexp(s2e2)
  ) => s2exp_syneq_exn(s2e1, s2e2)
//
| (
   S2EFFadd(s2fe11, s2fe12)
  ,
   S2EFFadd(s2fe21, s2fe22)
  ) =>
  {
    val () = s2eff_syneq_exn(s2fe11, s2fe21)
    val () = s2eff_syneq_exn(s2fe21, s2fe22)
  } // end of [S2EFFadd, S2EFFadd]
//
| (_(*s2eff*), _(*s2eff*)) => $raise (SYNEQexn)
//
end // end of [s2eff_syneq_exn]
//
(* ****** ****** *)

fun
s2lab_syneq
(
  s2l1: s2lab, s2l2: s2lab
) : bool =
(
//
try let
//
val () =
  s2lab_syneq_exn(s2l1, s2l2)
//
in true end with ~SYNEQexn() => false
//
) (* end of [s2lab_syneq] *)

and
s2lablst_syneq
(
  s2ls1: s2lablst, s2ls2: s2lablst
) : bool =
(
//
try let
//
val () =
  s2lablst_syneq_exn(s2ls1, s2ls2)
//
in true end with ~SYNEQexn() => false
//
) (* end of [s2lablst_syneq] *)

and
s2lab_syneq_exn
(
  s2l1: s2lab, s2l2: s2lab
) : void = let
in
//
case+ s2l1 of
| S2LABlab l1 => (
  case+ s2l2 of
  | S2LABlab(l2) =>
      if ~(l1=l2)
        then $raise (SYNEQexn)
      // end of [if]
    // end of [S2LABlab]
  | S2LABind(_) => $raise (SYNEQexn)
  )
| S2LABind(ind1) => (
  case+ s2l2 of
  | S2LABlab(_) => $raise (SYNEQexn)
  | S2LABind(ind2) => s2explst_syneq_exn(ind1, ind2)
  )
//
end // end of [s2lab_syneq_exn]

and
s2lablst_syneq_exn
(
  s2ls1: s2lablst, s2ls2: s2lablst
) : void = let
in
//
case+
(s2ls1, s2ls2)
of (* case+ *)
| (
   list_cons(s2l1, s2ls1)
  ,
   list_cons(s2l2, s2ls2)
  ) => let
    val () =
      s2lab_syneq_exn(s2l1, s2l2)
    // end of [val]
  in
    s2lablst_syneq_exn(s2ls1, s2ls2)
  end
| (list_nil(), list_nil()) => ()
//
| (_(*s2lablst*), _(*s2lablst*)) => $raise (SYNEQexn)
//
end // end of [s2lablst_syneq_exn]

and
labs2explst_syneq_exn
(
  ls2es1: labs2explst, ls2es2: labs2explst
) : void = let
in
//
case+
(
 ls2es1,ls2es2
) of // case+
| (
   list_cons(ls2e1, ls2es1)
  ,
   list_cons(ls2e2, ls2es2)
  ) => let
    val SLABELED(l1, _(*opt*), s2e1) = ls2e1
    val SLABELED(l2, _(*opt*), s2e2) = ls2e2
  in
    if (l1 = l2) then let
      val () = s2exp_syneq_exn(s2e1, s2e2)
    in
      labs2explst_syneq_exn(ls2es1, ls2es2)
    end else $raise (SYNEQexn)
  end // end of [cons, cons]
| (list_nil(), list_nil()) => ()
| (_(*ls2es1*), _(*ls2es2*)) => $raise (SYNEQexn)
//
end // end of [labs2explst_syneq_exn]

(* ****** ****** *)

implement
s2hnf_syneq_exn
  (s2f10, s2f20) = let
//
val s2e10 = s2hnf2exp(s2f10)
and s2e20 = s2hnf2exp(s2f20)
val s2en10 = s2e10.s2exp_node
and s2en20 = s2e20.s2exp_node
//
(*
val () =
println!
  ("s2hnf_syneq_exn: s2e10 = ", s2e10)
val () =
println!
  ("s2hnf_syneq_exn: s2e20 = ", s2e20)
*)
//
in
//
case s2en10 of
//
| _ when $UT.eqref_type(s2e10, s2e20) => ()
//
| S2Eint i1 => (
  case+ s2en20 of
  | S2Eint i2 =>
    if i1 != i2 then $raise (SYNEQexn)
  | S2Eintinf i2 =>
    if ~eq_int_intinf(i1, i2) then $raise (SYNEQexn)
  | _ (* non-integer *) => $raise (SYNEQexn)
  ) (* end of [S2Eint] *)
| S2Eintinf i1 => (
  case+ s2en20 of
  | S2Eint i2 =>
    if ~eq_intinf_int(i1, i2) then $raise (SYNEQexn)
  | S2Eintinf i2 =>
    if ~eq_intinf_intinf(i1, i2) then $raise (SYNEQexn)
  | _ (* non-integer *) => $raise (SYNEQexn)
  ) (* end of [S2Eintinf] *)
//
| S2Ecst(s2c1) => (
  case+ s2en20 of
  | S2Ecst(s2c2) =>
    if s2c1 != s2c2 then $raise (SYNEQexn)
  | _ (* non-S2Ecst *) => $raise (SYNEQexn)
  ) (* end of [S2Ecst] *)
//
| S2Eextype
  (name1, s2ess1) => (
  case+ s2en20 of
  | S2Eextype
      (name2, s2ess2) => (
    if name1 = name2 then
      s2explstlst_syneq_exn(s2ess1, s2ess2) else $raise(SYNEQexn)
    ) // end of [S2Eextype]
  | _ (* non-S2Eextype *) => $raise (SYNEQexn)
  ) (* end of [S2Eextype] *)
| S2Eextkind
  (name1, s2ess1) => (
  case+ s2en20 of
  | S2Eextkind
      (name2, s2ess2) => (
    if name1 = name2 then
      s2explstlst_syneq_exn(s2ess1, s2ess2) else $raise(SYNEQexn)
    ) // end of [S2Eextkind]
  | _ (* non-S2Eextkind *) => $raise (SYNEQexn)
  ) (* end of [S2Eextkind] *)
//
| S2Evar(s2v1) => (
  case+ s2en20 of
  | S2Evar(s2v2) =>
    if s2v1 != s2v2 then $raise (SYNEQexn)
  | _ (* non-S2Evar *) => $raise (SYNEQexn)
  ) (* end of [S2Evar] *)
//
| S2EVar(s2V1) => (
  case+ s2en20 of
  | S2EVar(s2V2) =>
    if s2V1 != s2V2 then $raise (SYNEQexn)
  | _ (* non-S2EVar *) => $raise (SYNEQexn)
  ) (* end of [S2EVar] *)
//
| S2Edatcontyp
    (d2c1, arg1) => (
  case+ s2en20 of
  | S2Edatcontyp
      (d2c2, arg2) => (
    if (d2c1 = d2c2)
      then s2explst_syneq_exn(arg1, arg2)
      else $raise(SYNEQexn)
    ) // end of [S2Edatcontyp]
  | _ (* non-S2Edatcontyp *) => $raise (SYNEQexn)
  ) (* end of [S2Edatcontyp] *)
| S2Edatconptr
    (d2c1, rt1, _) => (
  case+ s2en20 of
  | S2Edatconptr
      (d2c2, rt2, _) =>
    (
    if (d2c1 = d2c2)
      then s2exp_syneq_exn(rt1, rt2)
      else $raise (SYNEQexn)
    ) // end of [S2Edatconptr]
  | _ (* non-S2Edatconptr *) => $raise (SYNEQexn)
  ) (* end of [S2Edatconptr] *)
//
| S2Esizeof(s2e1) => (
  case+ s2en20 of
  | S2Esizeof(s2e2) =>
    s2exp_syneq_exn(s2e1, s2e2)
  | _ (*non-S2Esizeof*) => $raise (SYNEQexn)
  )
//
(*
| S2Eeff(s2fe1) => (
  case+ s2en20 of
  | S2Eeff(s2fe2) =>
    (
      s2eff_syneq_exn(s2fe1, s2fe2)
    )
  | _ (* non-S2Eeff *) => $raise (SYNEQexn)
  ) (* end of [S2Eeff] *)
*)
//
| S2Eeqeq
    (s2e11, s2e12) =>
  (
  case+ s2en20 of
  | S2Eeqeq
      (s2e21, s2e22) =>
    {
      val () = s2exp_syneq_exn(s2e11, s2e21)
      val () = s2exp_syneq_exn(s2e12, s2e22)
    } // end of [S2Eeqeq]
  | _ (* non-S2Eeqeq *) => $raise (SYNEQexn)
  ) (* end of[S2Eeqeq] *)
//
| S2Eproj
    (s2e1, _, s2ls1) =>
  (
  case+ s2en20 of
  | S2Eproj
      (s2e2, _, s2ls2) =>
    {
      val () = s2exp_syneq_exn(s2e1, s2e2)
      val () = s2lablst_syneq_exn(s2ls1, s2ls2)
    } // end of [S2Eproj]
  | _ (* non-S2Eproj *) => $raise (SYNEQexn)
  ) (* end of[S2Eproj] *)
//
| S2Eapp
    (s2e11, s2es12) =>
  (
  case+ s2en20 of
  | S2Eapp
      (s2e21, s2es22) =>
    {
      val () = s2exp_syneq_exn(s2e11, s2e21)
      val () = s2explst_syneq_exn(s2es12, s2es22)
    } // end of [S2Eapp]
  | _ (* non-S2Eapp *) => $raise (SYNEQexn)
  ) (* end of [S2Eapp] *)
//
| S2Efun
  (
    fc1, lin1, s2fe1, npf1, s2es1_arg, s2e1_res
  ) => (
  case+ s2en20 of
  | S2Efun
    (
      fc2, lin2, s2fe2, npf2, s2es2_arg, s2e2_res
    ) => {
      val () =
        if fc1 != fc2 then $raise (SYNEQexn)
      val () =
        if lin1 != lin2 then $raise (SYNEQexn)
      val () = s2eff_syneq_exn (s2fe1, s2fe2)
      val () =
        if npf1 != npf2 then $raise (SYNEQexn)
      val () = s2explst_syneq_exn (s2es1_arg, s2es2_arg)
      val () = s2exp_syneq_exn (s2e1_res, s2e2_res)
    } // end of [S2Efun]
  | _ (* non-S2Efun *) => $raise (SYNEQexn)
  ) (* end of [S2Efun] *)
//
| S2Etop
    (knd1, s2e1) => (
  case+ s2en20 of
  | S2Etop
      (knd2, s2e2) =>
    (
    if knd1 = knd2
      then s2exp_syneq_exn(s2e1, s2e2)
      else $raise(SYNEQexn)
    ) // end of [S2Etop]
  | _ (* non-S2Etop *) => $raise (SYNEQexn)
  ) (* end of [S2Etop] *)
//
| S2Ewithout(s2e1) =>
  (
  case+ s2en20 of
  | S2Ewithout(s2e2) => s2exp_syneq_exn(s2e1, s2e2)
  | _ (* non-S2Ewithout *) => $raise (SYNEQexn)
  ) // end of [S2Ewithout]
//
| S2Etyarr
    (s2e1_elt, s2es1_int) =>
  (
  case+ s2en20 of
  | S2Etyarr
      (s2e2_elt, s2es2_int) => {
      val () =
        s2exp_syneq_exn(s2e1_elt, s2e2_elt)
      val () =
        s2explst_syneq_exn(s2es1_int, s2es2_int)
    } // end of [S2Etyarr]
  | _ (* non-S2Etyarr *) => $raise (SYNEQexn)
  ) (* end of [S2Etyarr] *)
//
| S2Etyrec
    (knd1, npf1, ls2es1) =>
  (
  case+ s2en20 of
  | S2Etyrec
      (knd2, npf2, ls2es2) =>
    {
      val () =
        if knd1 != knd2 then $raise (SYNEQexn)
      val () =
        if npf1 != npf2 then $raise (SYNEQexn)
      val () = labs2explst_syneq_exn (ls2es1, ls2es2)
    } // end of [S2Etyrec]
  | _ (* non-S2Etyrec *) => $raise (SYNEQexn)
  ) (* end of [S2Etyrec] *)
//
| S2Einvar(s2e1) =>
  (
  case+ s2en20 of
  | S2Einvar(s2e2) =>
      s2exp_syneq_exn(s2e1, s2e2)
    // end of [S2Einvar]
  | _ (* non-S2Einvar *) => $raise (SYNEQexn)
  ) (* end of [S2Einvar] *)
//
| S2Erefarg
    (knd1, s2e1) => (
  case+ s2en20 of
  | S2Erefarg
      (knd2, s2e2) => (
    if knd1 = knd2
      then s2exp_syneq_exn(s2e1, s2e2)
      else $raise(SYNEQexn)
    ) // end of [S2Erefarg]
  | _ (* non-S2Erefarg *) => $raise (SYNEQexn)
  ) (* end of [S2Erefarg] *)
//
| S2Evararg(s2e1) =>
  (
  case+ s2en20 of
  | S2Evararg(s2e2) => s2exp_syneq_exn(s2e1, s2e2)
  | _ (* non-S2Evararg *) => $raise (SYNEQexn)
  ) (* end of [S2Evararg] *)
//
| _ (* rest-of-s2exp *) => $raise (SYNEQexn)
//
end // end of [s2hnf_syneq_exn]

(* ****** ****** *)
//
// HX-2015-03:
// s2exp_syneq2:
// this version handles bound variables
//
(* ****** ****** *)
//
extern
fun
labs2explst_syneq_env
(
  env1: !s2varlst_vt
, env2: !s2varlst_vt
, ls2es1: labs2explst, ls2es2: labs2explst
) : bool // end of [labs2explst_syneq_env]
//
(* ****** ****** *)

local

fun
aux0
(
  env1: s2varlst
, env2: s2varlst
, s2v10: s2var, s2v20: s2var
) : bool = (
//
case+ env1 of
| list_nil() =>
    aux1_0(env1, env2, s2v10, s2v20)
| list_cons
    (s2v1, env1) =>
  (
    if s2v1 = s2v10
      then aux1_t (env1, env2, s2v10, s2v20)
      else aux1_f (env1, env2, s2v10, s2v20)
    // end of [if]
  ) (* end of [list_cons] *)
//
) (* end of [aux0] *)

and
aux1_0
(
  env1: s2varlst
, env2: s2varlst
, s2v10: s2var, s2v20: s2var
) : bool = (
//
case+ env2 of
| list_nil() =>
    if s2v10=s2v20 then true else false
  // end of [list_nil]
| list_cons(s2v2, env2) =>
  (
    if s2v2 = s2v20
      then false else aux1_0(env1, env2, s2v10, s2v20)
    // end of [if]
  ) (* end of [list_cons] *)
//
) (* end of [aux1_0] *)

and
aux1_t
(
  env1: s2varlst
, env2: s2varlst
, s2v10: s2var, s2v20: s2var
) : bool = (
//
case+ env2 of
| list_nil() => false
| list_cons(s2v2, env2) =>
    if s2v2 = s2v20 then true else false
  // end of [list_cons]
//
) (* end of [aux1_t] *)

and
aux1_f
(
  env1: s2varlst
, env2: s2varlst
, s2v10: s2var, s2v20: s2var
) : bool = (
//
case+ env2 of
| list_nil () =>
    aux2_0 (env1, env2, s2v10, s2v20)
| list_cons (s2v2, env2) =>
    if s2v2 = s2v20
      then false else aux0(env1, env2, s2v10, s2v20)
    // end of [if]
//
) (* end of [aux1_f] *)

and
aux2_0
(
  env1: s2varlst
, env2: s2varlst
, s2v10: s2var, s2v20: s2var
) : bool = (
//
case+ env1 of
| list_nil() =>
    if s2v10=s2v20 then true else false
  // end of [list_nil]
| list_cons
    (s2v1, env1) =>
  (
    if s2v1 = s2v10
      then false else aux2_0(env1, env2, s2v10, s2v20)
    // end of [if]
  ) (* end of [list_cons] *)
//
) (* end of [aux2_0] *)

in (* in-of-local *)

implement
s2var_syneq_env
(
  env1, env2, s2v10, s2v20
) = let
//
val env1 = $UN.linlst2lst(env1)
and env2 = $UN.linlst2lst(env2)
//
in
  aux0 (env1, env2, s2v10, s2v20)
end // end of [s2var_syneq_env]

end // end of [local]

(* ****** ****** *)

local

fun
auxenv
(
  env: !s2varlst_vt, s2vs: s2varlst
) : s2varlst_vt = let
  val env2 = list_vt_copy(env)
in
  list_reverse_append2_vt<s2var>(s2vs, env2)
end // end of [auxenv]

in (* in-of-local *)

implement
s2hnf_syneq_env
(
  env1, env2, s2f10, s2f20
) = let
//
val s2e10 = s2hnf2exp (s2f10)
and s2e20 = s2hnf2exp (s2f20)
val s2en10 = s2e10.s2exp_node
and s2en20 = s2e20.s2exp_node
//
(*
val () =
println!
  ("s2hnf_syneq_env: s2e10 = ", s2e10)
val () =
println!
  ("s2hnf_syneq_env: s2e20 = ", s2e20)
*)
//
in
//
case+ s2en10 of
//
| S2Eint(i1) => (
  case+ s2en20 of
  | S2Eint(i2) =>
    if i1 = i2 then true else false
  | S2Eintinf i2 =>
    if eq_int_intinf(i1, i2) then true else false
  | _ (*non-integer*) => false
  ) (* end of [S2Eint] *)
| S2Eintinf(i1) =>
  (
  case+ s2en20 of
  | S2Eint(i2) =>
    if eq_intinf_int(i1, i2) then true else false
  | S2Eintinf(i2) =>
    if eq_intinf_intinf(i1, i2) then true else false
  | _ (*non-integer*) => false
  ) (* end of [S2Eintinf] *)
//
| S2Ecst(s2c1) => (
  case+ s2en20 of
  | S2Ecst(s2c2) =>
    if s2c1 = s2c2 then true else false | _ => false
  ) (* end of [S2Ecst] *)
//
| S2Eextype
    (name1, s2ess1) =>
  (
  case+ s2en20 of
  | S2Eextype
      (name2, s2ess2) => (
    if name1 = name2
      then (
        s2explstlst_syneq_env(env1, env2, s2ess1, s2ess2)
      ) else false
    ) // end of [S2Eextype]
  | _ (* non-S2Eextype *) => false
  ) (* end of [S2Eextype] *)
| S2Eextkind
    (name1, s2ess1) =>
  (
  case+ s2en20 of
  | S2Eextkind
      (name2, s2ess2) =>
    (
    if name1 = name2
      then (
        s2explstlst_syneq_env(env1, env2, s2ess1, s2ess2)
      ) else false
    ) // end of [S2Eextkind]
  | _ (* non-S2Eextkind *) => false
  ) (* end of [S2Eextkind] *)
//
| S2Evar(s2v1) => (
  case+ s2en20 of
  | S2Evar(s2v2) =>
    s2var_syneq_env(env1, env2, s2v1, s2v2)
  | _ (* non-S2Evar *) => false
  ) (* end of [S2Evar] *)
//
| S2EVar(s2V1) => (
  case+ s2en20 of
  | S2EVar(s2V2) =>
    if s2V1 = s2V2 then true else false | _ => false
  ) (* end of [S2EVar] *)
//
| S2Edatcontyp
    (d2c1, arg1) => (
  case+ s2en20 of
  | S2Edatcontyp
      (d2c2, arg2) => (
    if (d2c1 = d2c2)
      then s2explst_syneq_env(env1, env2, arg1, arg2)
      else false
    // end of [if]
    ) // end of [S2Edatcontyp]
  | _ (* non-S2Edatcontyp *) => false
  ) (* end of [S2Edatcontyp] *)
| S2Edatconptr
    (d2c1, rt1, _) => (
  case+ s2en20 of
  | S2Edatconptr
      (d2c2, rt2, _) => (
    if (d2c1 = d2c2)
      then s2exp_syneq_env(env1, env2, rt1, rt2) else false
    ) // end of [S2Edatconptr]
  | _ (* non-S2Edatconptr *) => false
  ) (* end of [S2Edatconptr] *)
//
| S2Eeqeq
    (s2e11, s2e12) => (
  case+ s2en20 of
  | S2Eeqeq
      (s2e21, s2e22) => let
      val syneq =
        s2exp_syneq_env(env1, env2, s2e11, s2e21)
      // end of [val]
    in
      if syneq
        then s2exp_syneq_env(env1, env2, s2e12, s2e22)
        else false
      // end of [if]
    end // end of [S2Eeqeq]
  | _ (* non-S2Eeqeq *) => false
  ) (* end of[S2Eeqeq] *)
//
| S2Eproj
    (s2e1, _, s2ls1) =>
  (
  case+ s2en20 of
  | S2Eproj
      (s2e2, _, s2ls2) => let
      val syneq =
        s2exp_syneq_env(env1, env2, s2e1, s2e2)
      // end of [val]
    in
      if syneq then s2lablst_syneq(s2ls1, s2ls2) else false
    end // end of [S2Eproj]
  | _ (* non-S2Eproj *) => false
  ) (* end of[S2Eproj] *)
//
| S2Eapp
    (s2e11, s2es12) =>
  (
  case+ s2en20 of
  | S2Eapp
      (s2e21, s2es22) => let
      val syneq =
        s2exp_syneq_env(env1, env2, s2e11, s2e21)
    in
      if syneq then
        s2explst_syneq_env(env1, env2, s2es12, s2es22) else false
      // end of [if]
    end // end of [S2Eapp]
  | _ (* non-S2Eapp *) => false
  ) (* end of [S2Eapp] *)
//
| S2Elam
    (s2vs1, s2e1) =>
 (
  case+ s2en20 of
  | S2Elam
      (s2vs2, s2e2) => syneq where
    {
      val env1 = auxenv(env1, s2vs1)
      val env2 = auxenv(env2, s2vs2)
      val syneq =
        s2exp_syneq_env (env1, env2, s2e1, s2e2)
      // end of [val]
      val () = list_vt_free(env1) and () = list_vt_free(env2)
    } // end of [S2Elam]
  | _ (* non-S2Elam *) => false
  ) (* end of [S2Elam] *)
//
| S2Efun
  (
    fc1, lin1, s2fe1, npf1, s2es1_arg, s2e1_res
  ) => (
  case+ s2en20 of
  | S2Efun
    (
      fc2, lin2, s2fe2, npf2, s2es2_arg, s2e2_res
    ) => let
      val syneq =
        (if fc1 = fc2 then true else false): bool
      val syneq =
        (if syneq then lin1 = lin2 else false): bool
      val syneq =
        (if syneq then s2eff_syneq(s2fe1, s2fe2) else false): bool
      val syneq =
        (if syneq then npf1 = npf2 else false): bool
      val syneq = (
        if syneq
          then s2explst_syneq_env(env1, env2, s2es1_arg, s2es2_arg)
          else false
      ) : bool // end of [val]
    in
      if syneq then
        s2exp_syneq_env(env1, env2, s2e1_res, s2e2_res) else false
      // end of [if]
    end // end of [S2Efun]
  | _ (* non-S2Efun *) => false
  ) (* end of [S2Efun] *)
//
| S2Etop
    (knd1, s2e1) => (
  case+ s2en20 of
  | S2Etop
      (knd2, s2e2) => (
    if knd1 = knd2 then
      s2exp_syneq_env(env1, env2, s2e1, s2e2) else false
    ) // end of [S2Etop]
  | _ (* non-S2Etop *) => false
  ) (* end of [S2Etop] *)
//
| S2Ewithout(s2e1) =>
  (
  case+ s2en20 of
  | S2Ewithout (s2e2) => s2exp_syneq_env(env1, env2, s2e1, s2e2)
  | _ (* non-S2Ewithout *) => false
  ) // end of [S2Ewithout]
//
| S2Etyarr
    (s2e1_elt, s2es1_int) =>
  (
  case+ s2en20 of
  | S2Etyarr
      (s2e2_elt, s2es2_int) => let
      val syneq =
        s2exp_syneq_env(env1, env2, s2e1_elt, s2e2_elt)
    in
      if syneq
        then s2explst_syneq_env(env1, env2, s2es1_int, s2es2_int)
        else false
      // end of [if]
    end // [S2Etyarr]
  | _ (* non-S2Etyarr *) => false
  ) (* end of [S2Etyarr] *)
//
| S2Etyrec
    (knd1, npf1, ls2es1) =>
  (
  case+ s2en20 of
  | S2Etyrec
      (knd2, npf2, ls2es2) => let
      val syneq =
        (if knd1 = knd2 then true else false): bool
      val syneq =
        (if syneq then npf1 = npf2 else false): bool
    in
      if syneq
        then labs2explst_syneq_env (env1, env2, ls2es1, ls2es2)
        else false
      // end of [if]
    end // [S2Etyrec]
  | _ (* non-S2Etyrec *) => false
  ) (* end of [S2Etyrec] *)
//
| S2Einvar(s2e1) => (
  case+ s2en20 of
  | S2Einvar (s2e2) => s2exp_syneq_env (env1, env2, s2e1, s2e2)
  | _ (* non-S2Einvar *) => false
  ) (* end of [S2Einvar] *)
//
| S2Eexi
    (s2vs1, s2ps1, s2e1) =>
  (
  case+ s2en20 of
  | S2Eexi
      (s2vs2, s2ps2, s2e2) => let
      val env1 = auxenv(env1, s2vs1)
      val env2 = auxenv(env2, s2vs2)
      val syneq =
        s2explst_syneq_env(env1, env2, s2ps1, s2ps2)
      val syneq =
      (
        if syneq then
          s2exp_syneq_env(env1, env2, s2e1, s2e2) else false
        // end of [if]
      ) : bool // end of [val]
      val () = list_vt_free(env1) and () = list_vt_free(env2)
    in
      syneq
    end // end of [S2Eexi]
  | _ (* non-S2Eexi *) => false
  ) (* end of [S2Eexi] *)
//
| S2Euni
    (s2vs1, s2ps1, s2e1) =>
  (
  case+ s2en20 of
  | S2Euni
      (s2vs2, s2ps2, s2e2) => let
      val env1 = auxenv(env1, s2vs1)
      val env2 = auxenv(env2, s2vs2)
      val syneq =
        s2explst_syneq_env(env1, env2, s2ps1, s2ps2)
      val syneq =
      (
        if syneq then
          s2exp_syneq_env(env1, env2, s2e1, s2e2) else false
        // end of [if]
      ) : bool // end of [val]
      val () = list_vt_free(env1) and () = list_vt_free(env2)
    in
      syneq
    end // end of [S2Euni]
  | _ (* non-S2Euni *) => false
  ) (* end of [S2Euni] *)
//
| S2Erefarg
    (knd1, s2e1) => (
  case+ s2en20 of
  | S2Erefarg
      (knd2, s2e2) => (
    if knd1 = knd2
      then s2exp_syneq_env(env1, env2, s2e1, s2e2) else false
    ) // end of [S2Erefarg]
  | _ (* non-S2Erefarg *) => false
  ) (* end of [S2Erefarg] *)
//
| S2Evararg(s2e1) => (
  case+ s2en20 of
  | S2Evararg(s2e2) => s2exp_syneq_env(env1, env2, s2e1, s2e2)
  | _ (* non-S2Evararg *) => false
  ) (* end of [S2Evararg] *)
//
| _ (* rest-of-s2exp *) => false
//
end // end of [s2hnf_syneq_env]

end // end of [local]

(* ****** ****** *)

implement
s2exp_syneq_env
  (env1, env2, s2e10, s2e20) = let
//
val s2f10 = s2exp2hnf (s2e10)
and s2f20 = s2exp2hnf (s2e20)
//
in
  s2hnf_syneq_env(env1, env2, s2f10, s2f20)
end // end of [s2exp_syneq_env]

(* ****** ****** *)

implement
s2explst_syneq_env
  (env1, env2, s2es1, s2es2) =
(
//
case+ s2es1 of
| list_nil() =>
  (
    case+ s2es2 of
    | list_nil() => true
    | list_cons(_, _) => false
  )
| list_cons
    (s2e1, s2es1) =>
  (
    case+ s2es2 of
    | list_nil
        ((*void*)) => false
      // list_nil
    | list_cons
        (s2e2, s2es2) =>
      (
        if s2exp_syneq_env(env1, env2, s2e1, s2e2)
          then s2explst_syneq_env(env1, env2, s2es1, s2es2) else false
      ) (* end of [list_cons] *)
  ) (* end of [list_cons] *)
//
) (* end of [s2explst_syneq_env] *)

(* ****** ****** *)

implement
s2explstlst_syneq_env
  (env1, env2, s2ess1, s2ess2) =
(
//
case+ s2ess1 of
| list_nil() =>
  (
    case+ s2ess2 of
    | list_nil() => true
    | list_cons(_, _) => false
  )
| list_cons
    (s2es1, s2ess1) =>
  (
    case+ s2ess2 of
    | list_nil
        ((*void*)) => false
      // list_nil
    | list_cons
        (s2es2, s2ess2) =>
      (
        if s2explst_syneq_env(env1, env2, s2es1, s2es2)
          then s2explstlst_syneq_env(env1, env2, s2ess1, s2ess2) else false
      ) (* end of [list_cons] *)
  ) (* end of [list_cons] *)
//
) (* end of [s2explstlst_syneq_env] *)

(* ****** ****** *)

implement
labs2explst_syneq_env
(
  env1, env2, ls2es1, ls2es2
) = let
in
//
case+
(
 ls2es1,ls2es2
) of // case+
| (list_cons(ls2e1, ls2es1),
   list_cons(ls2e2, ls2es2)) => let
    val SLABELED(l1, _(*opt*), s2e1) = ls2e1
    val SLABELED(l2, _(*opt*), s2e2) = ls2e2
  in
    if (l1 = l2) then let
      val syneq =
        s2exp_syneq_env(env1, env2, s2e1, s2e2)
      // end of [val]
    in
      if syneq
        then labs2explst_syneq_env(env1, env2, ls2es1, ls2es2)
        else false
    end else false
  end // end of [cons, cons]
| (list_nil(), list_nil()) => true
| (_(*ls2es1*), _(*ls2es2*)) => false
//
end // end of [labs2explst_syneq_env]

(* ****** ****** *)
//
implement
s2hnf_syneq2
  (s2f1, s2f2) = syneq where
{
  val env1 = list_vt_nil()
  val env2 = list_vt_nil()
  val syneq =
    s2hnf_syneq_env(env1, env2, s2f1, s2f2)
  val () = list_vt_free(env1) and () = list_vt_free(env2)
} (* end of [s2hnf_syneq2] *)
//
implement
s2exp_syneq2
  (s2e1, s2e2) = syneq where
{
  val env1 = list_vt_nil()
  val env2 = list_vt_nil()
  val syneq =
    s2exp_syneq_env(env1, env2, s2e1, s2e2)
  // end of [val]
  val () = list_vt_free(env1) and () = list_vt_free(env2)
} (* end of [s2exp_syneq2] *)
//
implement
s2explst_syneq2
  (s2es1, s2es2) = syneq where
{
  val env1 = list_vt_nil()
  val env2 = list_vt_nil()
  val syneq =
    s2explst_syneq_env(env1, env2, s2es1, s2es2)
  // end of [val]
  val () = list_vt_free(env1) and () = list_vt_free(env2)
} (* end of [s2explst_syneq2] *)
//
(* ****** ****** *)

local

fun
s2exp_prenexize
(
  knd: int // 0/1: exi/uni
, s2e0: s2exp
, flag: &int >> int
, s2vs_res: &s2varlst_vt
, s2ps_res: &s2explst_vt
) : s2exp = let
//
val s2e0 = s2exp_hnfize(s2e0)
//
in
//
case+
s2e0.s2exp_node
of (* case+ *)
//
| S2Eexi (
    s2vs, s2ps, s2e_body
  ) => (
    if knd = 0 then
    s2exp_prenexize_work
    (
      knd, s2vs, s2ps, s2e_body, flag, s2vs_res, s2ps_res
    ) else s2e0 // end of [if]
  ) (* end of [S2Eexi] *)
| S2Euni (
    s2vs, s2ps, s2e_body
  ) => (
    if knd > 0 then
    s2exp_prenexize_work
    (
      knd, s2vs, s2ps, s2e_body, flag, s2vs_res, s2ps_res
    ) else s2e0 // end of [if]
  ) (* end of [S2Euni] *)
//
| S2Eat (s2e1, s2e2) => let
    val
    flag0 = flag
    val s2e1 =
    (
      if knd = 0
        then // exists
        s2exp_prenexize
          (knd, s2e1, flag, s2vs_res, s2ps_res)
        // end of [then]
        else s2e1
    ) : s2exp // end of [val]
  in
    if flag > flag0 then s2exp_at (s2e1, s2e2) else (s2e0)
  end // end of [S2Eat]
//
(*
| S2Etyrec (
    recknd, npf, ls2es
  ) => let
    val
    flag0 = flag
    val
    ls2es =
    labs2explst_prenexize
      (knd, ls2es, s2vs_res, s2ps_res, flag)
    // end of [val]
  in
    if flag > flag0
      then s2exp_tyrec_srt(s2e0.s2exp_srt, recknd, npf, ls2es)
      else s2e0 // end of [else]
    // end of [if]
  end // end of [S2Etyrec]
*)
| _ (*non-s2exp*) => s2e0 // end of [_]
//
end // end of [s2exp_prenexize]

and
s2exp_prenexize_work
(
  knd: int
, s2vs: s2varlst, s2ps: s2explst, s2e_body: s2exp
, flag: &int >> int
, s2vs_res: &s2varlst_vt
, s2ps_res: &s2explst_vt
) : s2exp = let
  var sub = stasub_make_nil ()
  val s2vs = stasub_extend_svarlst (sub, s2vs)
  val s2ps = s2explst_subst_vt (sub, s2ps) // HX: returning a linear list
  val s2e_body = s2exp_subst (sub, s2e_body)
  val () = stasub_free (sub)
  val () = flag := flag + 1
  val () = s2vs_res := list_vt_reverse_append (s2vs, s2vs_res)
  val () = s2ps_res := list_vt_reverse_append (s2ps, s2ps_res)
  val s2e_body = s2exp_prenexize(knd, s2e_body, flag, s2vs_res, s2ps_res)
in
  s2e_body
end // end of [s2exp_prenexize_work]

and
s2explst_prenexize
(
  knd: int
, s2es0: s2explst
, flag: &int >> int
, s2vs_res: &s2varlst_vt
, s2ps_res: &s2explst_vt
) : s2explst = let
in
//
case+ s2es0 of
| list_nil() =>
  list_nil((*void*))
| list_cons(s2e, s2es) => let
    val
    flag0 = flag
    val s2e =
      s2exp_prenexize(knd, s2e, flag, s2vs_res, s2ps_res)
    // end of [val]
    val s2es =
      s2explst_prenexize(knd, s2es, flag, s2vs_res, s2ps_res)
    // end of [val]
  in
    if flag > flag0 then list_cons (s2e, s2es) else s2es0
  end // end of [cons]
//
end // end of [s2explst_prenexize]

and
labs2explst_prenexize
(
  knd: int
, ls2es0: labs2explst
, flag: &int >> int
, s2vs_res: &s2varlst_vt
, s2ps_res: &s2explst_vt
) : labs2explst = let
in
//
case+ ls2es0 of
| list_nil() =>
  list_nil((*void*))
| list_cons(ls2e, ls2es) => let
    val
    flag0 = flag
    val
    SLABELED(l, name, s2e) = ls2e
    val s2e =
      s2exp_prenexize(knd, s2e, flag, s2vs_res, s2ps_res)
    // end of [val]
    val ls2e = (
      if flag > flag0 then SLABELED(l, name, s2e) else ls2e
    ) : labs2exp // end of [val]
    val ls2es =
      labs2explst_prenexize(knd, ls2es, flag, s2vs_res, s2ps_res)
    // end of [val]
  in
    if flag > flag0 then list_cons (ls2e, ls2es) else ls2es0
  end // end of [list_cons]
//
end // end of [labs2explst_prenexize]

in (* in of [local] *)

implement
s2exp_absuni(s2e) = let
  var flag
    : int = 0
  var s2vs_res
    : s2varlst_vt = list_vt_nil()
  and s2ps_res
    : s2explst_vt = list_vt_nil()
  val s2e =
    s2exp_prenexize(1(*uni*), s2e, flag, s2vs_res, s2ps_res)
  // end of [val]
//
  val s2vs = list_vt_reverse(s2vs_res)
  and s2ps = list_vt_reverse(s2ps_res)
//
in
  (s2e, s2vs, s2ps)
end // end of [s2exp_absuni]

implement
s2exp_opnexi (s2e) = let
  var flag
    : int = 0
  var s2vs_res
    : s2varlst_vt = list_vt_nil()
  and s2ps_res
    : s2explst_vt = list_vt_nil()
  val s2e =
    s2exp_prenexize(0(*exi*), s2e, flag, s2vs_res, s2ps_res)
  // end of [val]
//
  val s2vs = list_vt_reverse(s2vs_res)
  and s2ps = list_vt_reverse(s2ps_res)
//
in
  (s2e, s2vs, s2ps)
end // end of [s2exp_opnexi]

end // end of [local]

(* ****** ****** *)

(* end of [pats_staexp2_util2.dats] *)
