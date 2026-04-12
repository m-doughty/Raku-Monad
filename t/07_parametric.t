use Test;
use lib 'lib';

use Monad::Maybe;
use Monad::Either;
use Monad::List;
use Monad::Writer;

plan 14;

# --- Maybe[T] ---

subtest "Maybe[Int] accepts Int" => {
    plan 3;
    my $a = Monad::Maybe[Int].some(42);
    isa-ok $a, Monad::Maybe, 'still a Maybe';
    is $a.value, 42, 'value preserved';
    is $a.value.WHAT.^name, 'Int', 'value typed as Int';
};

subtest "Maybe[Int] rejects Str" => {
    plan 1;
    my $caught = False;
    try {
        Monad::Maybe[Int].some('not an int');
        CATCH { default { $caught = True } }
    };
    ok $caught, 'type mismatch throws';
};

subtest "Maybe[Int].none is still a None" => {
    plan 2;
    my $n = Monad::Maybe[Int].none;
    ok $n.is-none, 'is-none';
    nok $n.is-some, 'not is-some';
};

subtest "Legacy Maybe (no brackets) still works" => {
    plan 3;
    my $m = Monad::Maybe.some('hello');
    isa-ok $m, Monad::Maybe, 'is a Maybe';
    is $m.value, 'hello', 'value preserved';
    ok $m.is-some, 'is-some';
};

# --- Either[L, R] ---

subtest "Either[Str, Int] accepts both variants" => {
    plan 4;
    my $r = Monad::Either[Str, Int].right(42);
    my $l = Monad::Either[Str, Int].left('error!');
    is $r.unwrap-right, 42, 'right unwraps to Int';
    is $l.unwrap-left, 'error!', 'left unwraps to Str';
    ok $r.is-right, 'right is-right';
    ok $l.is-left, 'left is-left';
};

subtest "Either[Str, Int] rejects wrong types" => {
    plan 2;
    my $r-bad = False;
    try {
        Monad::Either[Str, Int].right('not an int');
        CATCH { default { $r-bad = True } }
    };
    ok $r-bad, 'right with Str rejected';

    my $l-bad = False;
    try {
        Monad::Either[Str, Int].left(123);
        CATCH { default { $l-bad = True } }
    };
    ok $l-bad, 'left with Int rejected';
};

# --- List[T] ---

subtest "List[Int] values are typed" => {
    plan 2;
    my $lst = Monad::List[Int].of(1, 2, 3);
    isa-ok $lst, Monad::List, 'is a List';
    is $lst.values.WHAT.^name, 'Array[Int]', 'values are Array[Int]';
};

subtest "List[Int] rejects non-ints" => {
    plan 1;
    my $caught = False;
    try {
        Monad::List[Int].of(1, 'two', 3);
        CATCH { default { $caught = True } }
    };
    ok $caught, 'mixed-type list rejected';
};

# --- Writer[A, W] ---

subtest "Writer[Int, Str] typed value and log" => {
    plan 2;
    my $w = Monad::Writer[Int, Str].unit(42);
    is $w.value, 42, 'value preserved';
    is $w.logs, '', 'default log is empty';
};

subtest "Writer[Int, Str] rejects wrong value type" => {
    plan 1;
    my $caught = False;
    try {
        Monad::Writer[Int, Str].unit('not an int');
        CATCH { default { $caught = True } }
    };
    ok $caught, 'Str value on Writer[Int,Str] rejected';
};

# --- Interop / bind across typed monads ---

subtest "Maybe[Int] bind preserves type" => {
    plan 2;
    my $a = Monad::Maybe[Int].some(10);
    my $b = $a.bind(-> $v { Monad::Maybe[Int].some($v * 2) });
    ok $b.is-some, 'bound value is Some';
    is $b.value, 20, 'bind computed correctly';
};

subtest "~~ works against bare role name" => {
    plan 2;
    my $a = Monad::Maybe[Int].some(1);
    ok $a ~~ Monad::Maybe, 'typed Maybe smart-matches base Maybe';
    ok $a ~~ Monad, 'also smart-matches Monad';
};

# --- Unparameterized (legacy) defaults to Any ---

subtest "Legacy bare Maybe allows any type" => {
    plan 3;
    my $a = Monad::Maybe.some(42);
    my $b = Monad::Maybe.some('hi');
    my $c = Monad::Maybe.some([1, 2, 3]);
    is $a.value, 42,      'Int allowed';
    is $b.value, 'hi',    'Str allowed';
    is-deeply $c.value, [1, 2, 3], 'Array allowed';
};

# --- Edge case: Nil handling with typed Maybe ---

subtest "Maybe[Int].none.unwrap is Nil" => {
    plan 1;
    my $n = Monad::Maybe[Int].none;
    nok $n.unwrap.defined, 'unwrap of None is undefined';
};
