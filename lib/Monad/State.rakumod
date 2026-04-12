use Monad;

#| The State monad — represents a stateful computation that threads a
#| state value through a series of operations, producing an output value
#| alongside a possibly-updated state.
#|
#| Not parameterized: the underlying C<run> callable is type-erased (it's
#| a closure Raku can't inspect), so type parameters here would be
#| documentation only. Use plain C<Monad::State> and document your state
#| and value types in comments where it matters.
#|
#|     my $s = Monad::State.unit(42);
#|     my ($val, $new-state) = $s.run($initial-state);
unit class Monad::State is Monad;

has $.run;

method bind(&f --> Monad::State:D) {
    self.new(run => sub ($state) {
        my ($val, $s1) = self.run($state);
        my $next = f($val);
        die "bind must return a Monad::State" unless $next ~~ Monad::State;
        return $next.run($s1);
    });
}

method run($state) {
    $!run($state);
}

method map(&f) {
    self.new(run => sub ($state) {
        my ($val, $s1) = self.run($state);
        return f($val), $s1;
    });
}

method unit($value --> Monad::State) {
    self.new(run => sub ($state) { $value, $state });
}

method gist {
    "<State Monad>";
}

method get() {
    Monad::State.new(run => -> $s { ($s, $s) });
}

method put($new) {
    Monad::State.new(run => -> $s { (Nil, $new) });
}

method modify(&f) {
    Monad::State.new(run => -> $s {
        my $new = f($s);
        (Nil, $new);
    });
}
