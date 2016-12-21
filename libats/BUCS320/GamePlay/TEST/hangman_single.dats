(*
** Hangman:
** A simple word game
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
#include
"share/HATS/atspre_staload_libats_ML.hats"
//
(* ****** ****** *)

#staload UN = $UNSAFE

(* ****** ****** *)
//
#staload"./../GamePlay_single.dats"
//
(* ****** ****** *)
//
assume
state_type = gvhashtbl
//
(* ****** ****** *)
//
extern
fun
state_make_word
  (given: string): state
//
(* ****** ****** *)

implement
state_make_word
(
  given
) = state where
{
//
val
state =
gvhashtbl_make_nil(8)
//
val () =
state["word"] := GVstring(given)
//
val () =
state["bword"] :=
GVptr($UN.cast{ptr}(array0_make_elt(length(given), false)))
//
val () = state["ntime"] := GVint(0)
//
} // end of [state_make_word]

(* ****** ****** *)
//
extern
fun
state_get_word(state): string
extern
fun
state_get_bword(state): array0(bool)
//
overload .word with state_get_word
overload .bword with state_get_bword
//
(* ****** ****** *)
//
implement
state_get_word(state) =
  GVstring_uncons(state["word"])
implement
state_get_bword(state) =
  $UN.cast(GVptr_uncons(state["bword"]))
//
(* ****** ****** *)
//
extern
fun
state_get_ntime(state): int
extern
fun
state_set_ntime(state, int): void
extern
fun
state_incby_ntime(state, int): void
extern
fun
state_decby_ntime(state, int): void
//
overload .ntime with state_get_ntime
overload .ntime with state_set_ntime
//
implement
state_get_ntime
  (state) =
  GVint_uncons(state["ntime"])
implement
state_set_ntime
  (state, n0) =
  (state["ntime"] := GVint(n0))
implement
state_incby_ntime
  (state, n0) =
  state.ntime(state.ntime() + n0)
implement
state_decby_ntime
  (state, n0) =
  state.ntime(state.ntime() - n0)
//
(* ****** ****** *)
//
extern
fun
state_get_inputs(state): Ptr0
extern
fun
state_set_inputs(state, Ptr0): void
//
overload .inputs with state_get_inputs
overload .inputs with state_set_inputs
//
implement
state_get_inputs(state) =
  $UN.castvwtp0(GVptr_uncons(state["inputs"]))
//
implement
state_set_inputs(state, inputs) =
  state["inputs"] := GVptr($UN.castvwtp0(inputs))
//
(* ****** ****** *)
//
#define NTIME 6
//
(* ****** ****** *)
//
fun
word_choose(): string = "camouflage"
//
(* ****** ****** *)
//
implement
GamePlay$is_over<>
  (state) = res where
{
//
var res: bool = false
//
val () =
if state.ntime() <= 0 then res := true
//
val () =
if (state.bword()).forall()(lam b => b) then res := true
//
} (* end of [GamePlay$is_over] *)
//
(* ****** ****** *)
//
implement
GamePlay$do_over<>
  (state) = () where
{
//
var res: bool = true
//
val () =
if state.ntime() <= 0 then res := false
//
val () =
  println!("------------------------------------")
val () =
if res then
  println!("You suceeded in solving the puzzle!")
val () =
if ~(res) then
  println!("Sorry, you failed to solve the puzzle!")
//
} (* end of [GamePlay$do_over] *)
//
(* ****** ****** *)

implement
GamePlay$show<>
  (state) = () where
{
//
val word = state.word()
val bword = state.bword()
val ntime = state.ntime()
//
(*
val () = println! ("bword = ", bword)
*)
//
val () =
word.iforeach()
(
  lam(i, c) => print_char(ifval(bword[i], c, '_'))
) (* end of [val] *)
val () = print_newline((*void*))
//
val () = println!("The number of chances available: ", ntime)
//
} (* end of [GamePlay$show] *)

(* ****** ****** *)
//
assume
input_vtype = Strptr1
//
implement
GamePlay$input<>
  (state) = let
//
val inputs = state.inputs()
//
in
//
if
iseqz(inputs)
then
(
string0_copy("")
) (* end-of-then *)
else let
//
val
inputs =
$UN.castvwtp0{stream_vt(Strptr1)}(inputs)
//
in
//
case+
!inputs
of // case+
| ~stream_vt_nil() =>
  let
    val () =
    state.inputs(the_null_ptr) in string0_copy("")
  end // end of [stream_vt_nil]
| ~stream_vt_cons(input, inputs) =>
  let
    val () =
    state.inputs($UN.castvwtp0(inputs)) in (input)
  end
end // end of [else]
//
end // end of [GamePlay$input]
//
(* ****** ****** *)

implement
GamePlay$update<>
(
  input, state
) = state where
{
//
val cs =
  $UN.castvwtp1{String}(input)
//
val n0 = length(cs)
val c0 = (if n0 > 0 then cs[0] else '_'): char
val ((*freed*)) = strptr_free(input)
//
val word = state.word()
val bword = state.bword()
//
var guess: int = 0
val guess = $UN.cast{ref(int)}(addr@guess)
//
val ((*void*)) =
word.iforeach()
(
  lam(i, c) =>
  if (c0 = c)
    then (!guess := !guess+1; bword[i] := true)
    else ((*void*))
  // end of [if]
) (* end of [val] *)
//
val () =
  if !guess = 0 then state_decby_ntime(state, 1)
//
} (* end of [GamePlay$update] *)

(* ****** ****** *)
//
#staload "./kbstream.dats"
//
staload "libats/libc/SATS/signal.sats"
//
(* ****** ****** *)

implement
main0() = () where
{
//
var sigact: sigaction
val () =
ptr_nullize<sigaction>
  (__assert () | sigact) where
{
  extern prfun __assert (): is_nullable(sigaction)
} (* end of [val] *)
//
val mysighandler = lam (sgn: signum_t): void => ()
val () = sigact.sa_handler := sighandler(mysighandler)
//
val () = assertloc (sigaction_null (SIGALRM, sigact) = 0)
//
val given = word_choose()
val state = state_make_word(given)
val ((*init*)) = state.ntime(NTIME)
val ((*init*)) = state.inputs($UN.castvwtp0(kbstream<>(stdin_ref, 60(*secs*))))
//
val ((*void*)) =
println! ("Welcome to the Hangman game!")
//
val ((*void*)) = GamePlay$main_loop(state)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [hangman_single.dats] *)
