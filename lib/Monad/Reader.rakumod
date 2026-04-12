use Monad;

#| The Reader monad — represents a computation that reads from a shared
#| environment and produces a value.
#|
#| Not parameterized: the underlying C<run> callable is type-erased, so
#| type parameters here would be documentation only. Use plain
#| C<Monad::Reader> and document environment / value types where needed.
#|
#|     my $r = Monad::Reader.new(run => -> %env { %env<name> });
#|     say $r.run(%( name => 'Alice' ));   # 'Alice'
unit class Monad::Reader is Monad;

has $.run;

method bind(&f --> Monad::Reader:D) {
    self.new(run => sub ($env) {
        my $val = self.run($env);
        my $next = f($val);
        die "bind must return a Monad::Reader" unless $next ~~ Monad::Reader;
        return $next.run($env);
    });
}

method map(&f) {
    self.new(run => sub ($env) {
        my $val = self.run($env);
        return f($val);
    });
}

method run($state) {
    $!run($state);
}

method unit($value --> Monad::Reader) {
    self.new(run => sub ($env) { $value });
}

method gist {
    "<Reader Monad>";
}

method ask {
    self.new(run => -> $env { $env });
}

method local(&f) {
    self.new(run => -> $env {
        self.run(f($env));
    });
}
