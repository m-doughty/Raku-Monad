use Test;
use lib 'lib';
use Monad;
use Monad::Writer;

plan 10;

# unit
my $w1 = Monad::Writer.unit(42);
isa-ok $w1, Monad::Writer, 'unit() returns a Monad::Writer';
is $w1.unwrap, 42, 'unwrap returns correct value';
is $w1.logs, '', 'initial log is empty';

# tell()
my $w2 = $w1.tell("hello ");
is $w2.logs, 'hello ', 'tell() appends to log';
is $w2.unwrap, 42, 'tell() preserves value';

# bind
sub double-log ($v) {
    Monad::Writer.new(value => $v * 2, logs => "doubled ")
}
my $w3 = $w2.bind(&double-log);
isa-ok $w3, Monad::Writer, 'bind returns a Monad::Writer';
is $w3.unwrap, 84, 'bind applies function to value';
is $w3.logs, 'hello doubled ', 'bind combines logs';

# map
my $w4 = $w3.map({ $_ + 1 });
is $w4.unwrap, 85, 'map transforms value';
is $w4.logs, 'hello doubled ', 'map preserves log';

