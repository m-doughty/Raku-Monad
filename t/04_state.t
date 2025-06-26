use Test;
use lib 'lib';
use Monad;
use Monad::State;

plan 12;

# Basic state unit
my $m = Monad::State.unit(42);
my ($val, $state) = $m.run('init');

is $val, 42, 'unit returns correct value';
is $state, 'init', 'unit preserves initial state';

sub inc-state ($_) {
	Monad::State.new(run => sub ($s) { $s, $s + 1 })
}

my $m2 = $m.bind(&inc-state);
my ($val2, $state2) = $m2.run(10);
is $val2, 10, 'bind chain: value passed correctly';
is $state2, 11, 'bind chain: state updated correctly';

# map: transform result, keep state
my $m3 = Monad::State.unit(5).map(-> $v { $v * 10 });
my ($val3, $state3) = $m3.run('unchanged');
is $val3, 50, 'map applies function to value';
is $state3, 'unchanged', 'map does not change state';

# get
my $get = Monad::State.get();
my ($got, $got_s) = $get.run(999);
is $got, 999, 'get returns current state';
is $got_s, 999, 'get does not change state';

# put
my $put = Monad::State.put(123);
my ($put_val, $put_s) = $put.run('old');
ok (!defined $put_val), 'put returns Nil value';
is $put_s, 123, 'put updates state';

# modify
my $mod = Monad::State.modify(-> $s { $s ~ '-mod' });
my ($mod_val, $mod_s) = $mod.run('pre');
ok (!defined $mod_val), 'modify returns Nil value';
is $mod_s, 'pre-mod', 'modify transforms state';

