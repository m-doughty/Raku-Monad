[![Actions Status](https://github.com/m-doughty/Raku-Monad/actions/workflows/test.yml/badge.svg)](https://github.com/m-doughty/Raku-Monad/actions)

NAME
====

Monad - Parametric-typed monads for Raku

SYNOPSIS
========

```raku
use Monad::Maybe;
use Monad::Either;

# Type-parameterized: compile-time checks on the contained value
my Monad::Maybe[Int] $n = Monad::Maybe[Int].some(42);
say $n.unwrap;                          # 42

my $err = Monad::Maybe[Int].some('x'); # throws: Str isn't Int

# Or untyped (legacy) — everything defaults to Any
my $m = Monad::Maybe.some([1, 2, 3]);
say $m.is-some;                         # True

# Infix operators
my $doubled = Monad::Maybe[Int].some(5) >>- { $_ * 2 };
say $doubled.unwrap;                    # 10
```

DESCRIPTION
===========

`Monad` is a small collection of parametric-typed monads for Raku: `Maybe`, `Either`, `List`, `Writer`, `Reader`, and `State`. The value-carrying monads accept a type parameter on their payload, giving you compile-time checking and self-documenting signatures:

```raku
sub load-user(Int $id --> Monad::Maybe[User]) { ... }
sub parse(Str $raw --> Monad::Either[Str, AST]) { ... }
```

The typed forms are opt-in. Legacy `Monad::Maybe.some(42)` (without the square brackets) still works — every type parameter defaults to `Any`.

WHY
===

Raku already has `Nil` and `Failure` for representing absent-or-errored values, but both blur the line between "no value" and "something went wrong". Monads give you a structural answer:

  * `Maybe[T]` — a `T` is either present (`Some`) or absent (`None`). Unambiguous.

  * `Either[L, R]` — a value is either a success (`Right R`) or a failure (`Left L`), both typed.

  * `List[T]` — a sequence of `T`s, with `bind` as flatMap.

  * `Writer[A, W]` — a value plus an accumulated log.

  * `Reader` / `State` — computations parameterized by an environment.

The payoff: your function signatures express optionality and error handling at the type level, so consumers have to handle both cases explicitly and can chain them fluently with `map` and `bind`.

INSTALLATION
============

```bash
zef install Monad
```

INFIX OPERATORS
===============

Two exported operators keep chains readable:

  * ``= >> — bind. The function you bind to should take an unwrapped value and return a monad.

  * ``- >> — map. The function you map to should take and return unwrapped values.

```raku
my $result = Monad::Maybe[Int].some(3)
    >>- { $_ * 2 }                                # Some(6)
    >>= -> $v { $v > 5 ?? Monad::Maybe[Int].some($v) !! Monad::Maybe[Int].none }
    >>- { $_ + 1 };                               # Some(7)
```

THE MONADS
==========

Monad::Maybe
------------

Represents a value that may or may not be present. Parameterized by the type of the contained value.

```raku
use Monad::Maybe;

my Monad::Maybe[Str] $user = Monad::Maybe[Str].some('alice');
my Monad::Maybe[Str] $none = Monad::Maybe[Str].none;

say $user.is-some;     # True
say $user.value;       # alice
say $none.is-none;     # True
say $none.unwrap;      # Nil

# Chain with map / bind
my $shout = $user.map({ .uc });
say $shout.value;      # ALICE

# Type mismatch throws at construction:
try {
    Monad::Maybe[Int].some('not an int');
    CATCH { default { say "rejected: {.message}" } }
}
```

Monad::Either
-------------

Represents a value that is one of two types. Conventionally `Left` carries an error and `Right` carries success. Parameterized by the left and right types independently.

```raku
use Monad::Either;

sub parse-int(Str $s --> Monad::Either[Str, Int]) {
    $s ~~ /^ (\d+) $/
        ?? Monad::Either[Str, Int].right(+$0)
        !! Monad::Either[Str, Int].left("'$s' is not a number");
}

given parse-int('42') {
    when .is-right { say "got: {.unwrap-right}" }   # got: 42
    when .is-left  { say "error: {.unwrap-left}" }
}

# bind skips on Left, chains on Right
my $result = parse-int('10')
    >>= -> $n { Monad::Either[Str, Int].right($n * 2) }
    >>= -> $n { $n > 100
                ?? Monad::Either[Str, Int].left('too big')
                !! Monad::Either[Str, Int].right($n) };
say $result.gist;      # Right(20)
```

Monad::List
-----------

A sequence monad. `bind` (aka flatMap) applies a function that returns a List and flattens one level.

```raku
use Monad::List;

my $lst = Monad::List[Int].of(1, 2, 3);

# Map
my $doubled = $lst.map({ $_ * 2 });
say $doubled.values.List;   # (2 4 6)

# flatMap
my $pairs = $lst.bind(-> $n {
    Monad::List[Int].of($n, $n * 10)
});
say $pairs.values.List;     # (1 10 2 20 3 30)
```

Monad::Writer
-------------

Carries a value alongside an accumulated log. Parameterized by the value type and the log type (defaulting to `Str`).

```raku
use Monad::Writer;

my $w = Monad::Writer[Int, Str].unit(5);
my $logged = $w.tell('starting with 5, ')
              .map({ $_ * 2 })
              .tell('doubled to ')
              .bind(-> $v {
                  Monad::Writer[Int, Str].new(value => $v + 1, logs => "added one = {$v + 1}")
              });

say $logged.value;    # 11
say $logged.logs;     # starting with 5, doubled to added one = 11
```

For non-string logs, subclass and override `_combine`:

```raku
class ArrayLogWriter is Monad::Writer {
    has @.logs;
    method _combine($a, $b) { [|$a, |$b] }
}
```

Monad::Reader and Monad::State
------------------------------

Computational monads for carrying an environment (Reader) or threading a state through a pipeline (State). These aren't parameterized — the underlying computation is a closure, so type parameters would only be documentation.

```raku
use Monad::State;

# Counter-style state manipulation
my $pipeline = Monad::State.get
    >>= -> $n { Monad::State.put($n + 1) }
    >>= -> $  { Monad::State.put(10)      }
    >>= -> $  { Monad::State.get          };

my ($val, $final-state) = $pipeline.run(0);
say "value: $val, state: $final-state";   # value: 10, state: 10
```

WRITING YOUR OWN
================

Subclass `Monad` (the base class) to define your own. You must implement `bind`, `map`, and `unit`:

```raku
use Monad;

class MyMonad is Monad {
    has $.value;
    method bind(&f) { f($.value) }
    method map(&f)  { self.new(value => f($.value)) }
    method unit($v) { self.new(value => $v) }
}
```

For a parametric type, use a role instead:

```raku
role MyMonad[::T = Any] is Monad {
    has T $.value;
    method bind(&f) { f($.value) }
    method map(&f)  { self.new(value => f($.value)) }
    method unit($v) { self.new(value => $v) }
}

# Usage:
my $m = MyMonad[Int].new(value => 42);
```

IMPLEMENTATION NOTES
====================

Parametric monads are implemented as Raku **roles**, not classes — Raku doesn't support parametric classes. Role auto-punning means:

  * `$x ~~ Monad::Maybe` works against the bare role name regardless of whether you constructed it with a type parameter.

  * `isa-ok $x, Monad::Maybe` likewise.

  * Class-method-style calls (`Monad::Maybe.some(42)`) work because Raku auto-puns parametric roles when you invoke them.

`Monad::State` and `Monad::Reader` remain plain classes because the underlying `run` callable is type-erased (it's a closure Raku can't inspect). Parameterizing them would only add documentation noise.

Some `State`/`Reader` class methods (like `put`, `get`, `modify`) intentionally live on a non-parametric class to avoid dispatch collisions with Raku's built-in `put` and `get` on role type objects.

AUTHOR
======

Matt Doughty <matt@apogee.guru>

COPYRIGHT AND LICENSE
=====================

Copyright 2024–2026 Matt Doughty

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

