use Test;
use lib 'lib';
use Monad;
use Monad::List;

plan 13;

sub duplicate($x) {
	Monad::List.of($x, $x)
}

sub double($x) {
	$x * 2
}

# unit
my $ml1 = Monad::List.unit(42);
isa-ok $ml1, Monad::List, 'unit() returns a Monad::List';
is $ml1.values.elems, 1, 'unit() wraps a single value';
is $ml1.values[0], 42, 'unit() contains the correct value';

# of
my $ml2 = Monad::List.of(1, 2, 3);
isa-ok $ml2, Monad::List, 'of() returns a Monad::List';
is-deeply $ml2.unwrap, [1, 2, 3], 'of() wraps all values';

# bind
my $ml3 = $ml2.bind(&duplicate);
isa-ok $ml3, Monad::List, 'bind() returns a monad::list';
is-deeply $ml3.values, [1,1,2,2,3,3], 'bind() duplicates each value and flattens';

# map
my $ml4 = $ml2.map(&double);
isa-ok $ml4, Monad::List, 'map() returns a monad::list';
is-deeply $ml4.values, [2, 4, 6], 'map() doubles each value correctly';

# bind (infix)
my $ml5 = $ml2 >>= &duplicate;
isa-ok $ml5, Monad::List, 'bind() returns a monad::list';
is-deeply $ml5.values, [1,1,2,2,3,3], 'bind() duplicates each value and flattens';

# map (infix)
my $ml6 = $ml2 >>- &double;
isa-ok $ml6, Monad::List, 'map() returns a monad::list';
is-deeply $ml6.values, [2, 4, 6], 'map() doubles each value correctly';

