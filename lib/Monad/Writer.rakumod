use Monad;

#| The Writer monad — carries a value alongside an accumulated log.
#|
#| Parameterized by C<::A> (the value type) and C<::W> (the log type,
#| defaulting to C<Str>). Both default to sensible values so legacy
#| C<Monad::Writer.new(value => ..., logs => '...')> still works.
#|
#|     # Untyped (legacy) — string logs, any value
#|     my $a = Monad::Writer.unit(42);
#|
#|     # Typed — explicit Int value + Str log
#|     my $b = Monad::Writer[Int, Str].unit(42);
#|
#| For non-string logs (e.g. an array of messages), subclass / override
#| C<_combine>. With typed usage:
#|
#|     # Array-of-Str logs instead of concatenated strings
#|     class ArrayLogWriter is Monad::Writer[Any, Array[Str]] {
#|         method _combine($a, $b) { [|$a, |$b] }
#|     }
role Monad::Writer[::A = Any, ::W = Str] is Monad {
    has A $.value;
    has W $.logs = W ~~ Str ?? '' !! W.new;

    method unwrap {
        $!value;
    }

    method logs {
        $!logs;
    }

    method unit($value --> Monad::Writer) {
        self.new(:$value);
    }

    method bind(&f --> Monad:D) {
        my $next = f($.value);
        die "bind must return a Monad::Writer" unless $next ~~ Monad::Writer;
        self.new(
            value => $next.value,
            logs  => self._combine(self.logs, $next.logs),
        );
    }

    method map(&f) {
        self.new(
            value => f($.value),
            logs  => self.logs,
        );
    }

    method tell($extra-log) {
        self.new(
            value => $.value,
            logs  => self._combine(self.logs, $extra-log),
        );
    }

    # Default combines via concatenation. Override in a subclass for
    # Array logs, Hash logs, or anything else monoidal.
    method _combine($a, $b) {
        $a ~ $b;
    }

    method gist {
        return self.^name unless self.defined;
        "Writer(value={$.value}, logs={$.logs})";
    }
}
