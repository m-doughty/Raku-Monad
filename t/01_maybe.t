use Test;
use lib 'lib';
use Monad;
use Monad::Maybe;

plan 21;

sub dubz ($v) { Monad::Maybe.some($v * 2) }
sub dubzbare ($v) { $v * 2 }
sub returnnil ($_) { Nil }

my $some = Monad::Maybe.some(42);
my $none = Monad::Maybe.none();

ok $some ~~ Monad::Maybe, 'Some is a Maybe';
ok $none ~~ Monad::Maybe, 'None is a Maybe';

is-deeply $some.value, 42, 'Some contains correct value';
ok (!defined $none.value), 'None is empty';

# bind on Some
my $bound = $some.bind(&dubz);
isa-ok $bound, Monad::Maybe, 'Bind on Some returns a Maybe';
is $bound.is-some, True, 'Bind on Some correctly stays Some';
is $bound.unwrap, 84, 'Bind on Some transforms correctly';

# bind on None
my $bound2 = $none >>= &dubz;
isa-ok $bound2, Monad::Maybe;
is $bound2.is-none, True, 'Bind on None correctly stays None';

# map on Some
my $bound3 = $some.map(&dubzbare);
isa-ok $bound3, Monad::Maybe, 'Map on Some returns a Maybe';
is $bound3.is-some, True, 'Map on Some correctly stays Some';
is $bound3.unwrap, 84, 'Map on Some transforms correctly';

# map on None
my $bound4 = $none.map(&dubzbare);
isa-ok $bound4, Monad::Maybe;
is $bound4.is-none, True, 'Map on None correctly stays None';

# returning nil from map on Some
my $bound5 = $some >>- &returnnil;
isa-ok $bound5, Monad::Maybe;
is $bound5.is-none, True, 'Map on Some that returns Nil becomes None';

# unit
my $some2 = Monad::Maybe.unit(3);
isa-ok $some2, Monad::Maybe;
is $some2.is-some, True, 'Unit with value correctly returns Some';
is $some2.unwrap, 3, 'Unwrapping returns 3';
my $none2 = Monad::Maybe.unit(Nil);
isa-ok $none2, Monad::Maybe;
is $none2.is-none, True, 'Unit with Nil correctly returns None';
