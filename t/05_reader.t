use Test;
use lib 'lib';
use Monad;
use Monad::Reader;

plan 9;

my $m1 = Monad::Reader.unit("hello");
is $m1.run("ignored"), "hello", 'unit returns correct value regardless of environment';

my $ask = Monad::Reader.ask();
is $ask.run("my-env"), "my-env", 'ask returns current environment';

my $m2 = Monad::Reader.unit("hi").map(-> $v { $v ~ "!" });
is $m2.run("whatever"), "hi!", 'map transforms value correctly';

sub double-then-str($x) {
    Monad::Reader.unit($x * 2 ~ "");
}
my $m3 = Monad::Reader.unit(5).bind(&double-then-str);
is $m3.run("ctx"), "10", 'bind chains computation correctly';

my $m4 = Monad::Reader.ask().map(-> $env { $env.uc });
is $m4.run("lowercase"), "LOWERCASE", 'ask with map returns transformed environment';

my $m5 = Monad::Reader.ask().local(-> $env { $env ~ "-mod" });
is $m5.run("base"), "base-mod", 'local modifies env inside subreader';

my $outer = Monad::Reader.ask();
my $inner = Monad::Reader.ask().local(-> $e { $e ~ "-x" });

is $outer.run("unchanged"), "unchanged", 'outer reader returns original env';
is $inner.run("foo"), "foo-x", 'inner reader gets modified env';

# nested map and bind
my $nested = Monad::Reader.unit(2).map(* + 3).bind(-> $x {
    Monad::Reader.unit($x ~ " ok")
});
is $nested.run("ctx"), "5 ok", 'nested map and bind work correctly';

