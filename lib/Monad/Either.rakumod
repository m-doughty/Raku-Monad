use Monad;

# Marker roles for the Left / Right variants. Defined at file scope so
# they can be referenced from inside the parametric role body.
role Monad::Either::Left  { has $.type = 'Left'  }
role Monad::Either::Right { has $.type = 'Right' }

our constant Left  is export = Monad::Either::Left;
our constant Right is export = Monad::Either::Right;

#| The Either monad — represents a value that is one of two types.
#| Conventionally C<Left> carries an error and C<Right> carries success.
#|
#| Parameterized by C<::L> (left type) and C<::R> (right type). Both
#| default to C<Any>, so legacy C<Monad::Either.left(...)> / C<.right(...)>
#| still work unchanged.
#|
#|     # Untyped (legacy)
#|     my $a = Monad::Either.right(42);
#|
#|     # Typed: error is Str, success is Int
#|     my $b = Monad::Either[Str, Int].right(42);
#|     my $c = Monad::Either[Str, Int].left('nope');
#|
#| The stored value can be of either L or R depending on variant, so
#| internally it remains untyped — the type parameters document intent
#| and constrain the C<left> / C<right> constructors.
role Monad::Either[::L = Any, ::R = Any] is Monad {
    has $.value;

    method unwrap {
        $!value;
    }

    method unwrap-right {
        self.is-right
            ?? $!value
            !! die "Tried to unwrap-right from a Left";
    }

    method unwrap-left {
        self.is-left
            ?? $!value
            !! die "Tried to unwrap-left from a Right";
    }

    method is-left {
        self ~~ Monad::Either::Left;
    }

    method is-right {
        self ~~ Monad::Either::Right;
    }

    method bind(&f --> Monad:D) {
        return self if self.is-left;
        return f($.value);
    }

    method map(&f) {
        return self if self.is-left;
        self.right(f($.value));
    }

    method gist {
        return self.^name unless self.defined;
        self.is-right ?? "Right($.value)" !! "Left($.value)";
    }

    method left(L $value --> Monad::Either) {
        self.new(:$value) but Monad::Either::Left;
    }

    method right(R $value --> Monad::Either) {
        self.new(:$value) but Monad::Either::Right;
    }

    method unit($value --> Monad::Either) {
        self.right($value);
    }
}
