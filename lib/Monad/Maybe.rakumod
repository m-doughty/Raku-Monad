use Monad;

# Marker roles mixed onto Maybe instances to distinguish Some from None.
# Defined at file scope because nested roles can't live inside a
# parametric role body. Exposed as module-level constants under the legacy
# names C<Some> and C<None> for backward compatibility.
role Monad::Maybe::Some { has $.type = 'Some' }
role Monad::Maybe::None { has $.type = 'None' }

our constant Some is export = Monad::Maybe::Some;
our constant None is export = Monad::Maybe::None;

#| The Maybe monad — represents a value that may or may not be present.
#|
#| Parameterized by C<::T>, the type of the contained value. Defaults to
#| C<Any>, so legacy C<Monad::Maybe.some(42)> (without brackets) works
#| unchanged.
#|
#|     # Untyped (legacy) — any value
#|     my $a = Monad::Maybe.some('hi');
#|
#|     # Typed — compile-time checking on the payload
#|     my Monad::Maybe[Int] $b = Monad::Maybe[Int].some(42);
#|     my $c = Monad::Maybe[Int].none;
#|
#| Implemented as a parametric role — Raku doesn't support parametric
#| classes. Role auto-punning means C<~~> and C<isa-ok> against the bare
#| C<Monad::Maybe> name still work.
role Monad::Maybe[::T = Any] is Monad {
    has T $.value;

    method unwrap {
        self.is-some ?? $!value !! Nil;
    }

    method is-some {
        self ~~ Monad::Maybe::Some;
    }

    method is-none {
        self ~~ Monad::Maybe::None;
    }

    method bind(&f --> Monad:D) {
        return self if self.is-none;
        return f($.value);
    }

    method map(&f) {
        return self if self.is-none;
        my $res = f($.value);

        (defined $res) ?? self.some($res) !! self.none;
    }

    method gist {
        return self.^name unless self.defined;
        self.is-some ?? "Some($.value)" !! "None";
    }

    method some($value --> Monad::Maybe) {
        self.new(:$value) but Monad::Maybe::Some;
    }

    method none(--> Monad::Maybe) {
        self.new() but Monad::Maybe::None;
    }

    method unit($value --> Monad::Maybe) {
        (defined $value) ?? self.some($value) !! self.none;
    }
}
