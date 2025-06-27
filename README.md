# Monad

## Introduction

Implementation of a few common Monads in Raku.

You can also use the base class `Monad` to implement your own.

Issues and pull requests welcome.

## Infix Operators

The `Monad` module implements two infix operators:

- `>>=` for `bind`. The function you `bind` to should take an unwrapped value & return a Monad.
- `>>-` for `map`. The function you `map` to should take an unwrapped value and return an unwrapped value.

## Monads

### Monad::Either

`Either` monads are regularly used to represent OK (Right) & Error (Left) values.

In some languages this is called a `Result` monad.

```raku
use Monad;
use Monad::Either;

sub double ($i) {
    $i * 2;
}

sub bind_double ($i) {
    Monad::Either.unit($i * 2);
}

my $ok         = Monad::Either.unit(4); # Monad::Either::Right(value=4)
my $ok_doubled = $ok >>- &double;       # Monad::Either::Right(value=8)
$ok_doubled.is-right                    # True
say $ok_doubled.unwrap-right            # 8

my $not_ok         = Monad::Either.left(4);   # Monad::Either::Left(value=4)
my $not_ok_doubled = $ok >>- &double;         # Monad::Either::Left(value=8)
$ok_doubled.is-right                          # False
say $ok_doubled.unwrap-left                   # 4

my $ok_doubled_bind = $ok >>= &bind_double;     # Monad::Either::Right(value=8)
my $not_ok_bind     = $not_ok >>= &bind_double; # Monad::Either::Left(value=4)
```

### Monad::List

`List` monads allow for chaining operators on lists and flattening them.

```raku
use Monad;
use Monad::List;

sub triplicate ($v) {
    ($v, $v, $v);
}

sub duplicate_half_bind ($v) {
  Monad::List.of($v, $v / 2);
}

my $list       = Monad::List.of(2, 3);               # Monad::List(value=[2,3])
my $tri_list   = $list >>- &triplicate;              # Monad::List(value=[2,2,2,3,3,3])
my $final_list = $tri_list >>= &duplicate_half_bind; # Monad::List(value=[2,1,2,1,2,1,3,1.5,3,1.5,3,1.5])
```

### Monad::Maybe

`Maybe` monads model a value which may or may not be present.

In some languages, this is called `Option` or `Optional`.

```raku
use Monad;
use Monad::Maybe;

sub double ($i) { $i * 2 }
sub bind_double ($i) { Monad::Maybe.some($i * 2) }

my $some = Monad::Maybe.some(5);    # Monad::Maybe::Some(value=5)
my $none = Monad::Maybe.none();     # Monad::Maybe::None(value=Nil)

my $doubled = $some >>- &double;      # Monad::Maybe::Some(value=10)
my $binded  = $some >>= &bind_double; # Monad::Maybe::Some(value=10)

my $none_mapped = $none >>- &double;      # Monad::Maybe::None(value=Nil)
my $none_binded = $none >>= &bind_double; # Monad::Maybe::None(value=Nil)

$none.is-some # False
$none.is-none # True
$some.is-some # True
$some.is-none # False

$some.unwrap # 5
$none.unwrap # Nil
```

### Monad::Reader

`Reader` monads model computations that depend on a shared environment.

```raku
use Monad;
use Monad::Reader;

sub ask-env {
    Monad::Reader.new(run => sub ($env) {
        "Hello, $env!";
    });
}

my $r = ask-env();
say $r.run("Alice"); # "Hello, Alice!"

# Reader composition
my $upper = $r.map(-> $env { $env.uc });
say $upper.run("Bob"); # "HELLO, BOB"
```

### Monad::State

`State` monads thread mutable state through pure functions.

```raku
my $m             = Monad::State.unit(42);
my ($val, $state) = $m.run('init');

say $val;   # 42
say $state; # "init"

sub inc-state ($_) {
	Monad::State.new(run => sub ($s) { $s, $s + 1 })
}

my $m2              = $m.bind(&inc-state);
my ($val2, $state2) = $m2.run(10);

say $val2;   # 10
say $state2; # 11
```

### Monad::Writer

`Writer` monads allow logging outside computations.

```raku
use Monad;
use Monad::Writer;

sub say_hi ($name) {
    Monad::Writer.new(value => "Hello $name", log => "Greeted $name.")
}

my $w1 = Monad::Writer.unit("World");
my $w2 = $w1 >>= &say_hi;

say $w2.value; # "Hello World"
say $w2.logs;   # "Greeted World."

# map does not change log
my $w3 = $w2 >>- *.uc;
say $w3.value; # "HELLO WORLD"
say $w3.logs;   # "Greeted World."
```

## More Examples

See the tests for more examples.
