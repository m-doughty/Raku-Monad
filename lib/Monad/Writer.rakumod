use Monad;

unit class Monad::Writer is Monad;

has $.value;
has $.logs = '';

method unwrap {
	$!value;
}

method logs {
	$!logs;
}

method unit($value --> Monad::Writer) {
	self.new(value => $value);
}

method bind(&f --> Monad:D) {
	my $next = f($.value);
	die "bind must return a Monad::Writer" unless $next ~~ Monad::Writer;
	self.new(
		value => $next.value,
		logs  => self._combine(self.logs, $next.logs)
	)
}

method map(&f) {
	self.new(
		value => f($.value),
		logs  => self.logs
	)
}

method tell($extra-log) {
	self.new(
		value => $.value,
		logs  => self._combine(self.logs, $extra-log)
	)
}

# You can override these to support Array logs, Hash logs, etc.
method _combine($a, $b) {
	$a ~ $b
}

method gist {
	"Writer(value={$.value}, logs={$.logs})"
}

