use Test;
use lib 'lib';
use Monad;
use Monad::Either;

plan 16;

sub dubz ($v) { Monad::Either.right($v * 2) }
sub dubzbare ($v) { $v * 2 }

my $right = Monad::Either.right(21);
my $left  = Monad::Either.left("Bad stuff");

ok $right ~~ Monad::Either, 'Right is an Either';
ok $left ~~ Monad::Either,  'Left is an Either';

is $right.is-right, True, 'Right is-right returns True';
is $left.is-left, True,   'Left is-left returns True';

is-deeply $right.unwrap, 21, 'Right unwrap returns value';
throws-like { $left.unwrap-right }, X::AdHoc, 'Unwrap-right on Left throws';
throws-like { $right.unwrap-left }, X::AdHoc, 'Unwrap-left on Right throws';

# bind on Right
my $bound = $right.bind(&dubz);
isa-ok $bound, Monad::Either, 'Bind on Right returns Either';
is $bound.is-right, True, 'Bind on Right stays Right';
is $bound.unwrap, 42, 'Bind on Right transforms correctly';

# bind on Left
my $bound2 = $left >>= &dubz;
isa-ok $bound2, Monad::Either;
is $bound2.is-left, True, 'Bind on Left remains unchanged';

# map on Right
my $mapped = $right.map(&dubzbare);
is $mapped.is-right, True, 'Map on Right stays Right';
is $mapped.unwrap-right, 42, 'Map on Right applies transformation';

# map on Left
my $mapped2 = $left >>- &dubzbare;
is $mapped2.is-left, True, 'Map on Left does not apply function';
is $mapped2.unwrap-left, "Bad stuff", 'Unwrap Left still returns the value';
