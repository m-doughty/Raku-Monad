unit class Monad;

method bind($f --> Monad:D) {
	die "bind() must be implemented by subclass"
}

method map($f --> Monad:D) {
	die "map() must be implemented by subclass"
}

method unit($f --> Monad:D) {
	die "unit() must be implemented by subclass"
}

method gist {
	"Not implemented";
}

method Str {
	self.gist
}

sub infix:<\>\>=> ($m, $f --> Monad) is export {
    $m.bind($f)
}

sub infix:<\>\>-> ($m, $f) is export {
    $m.map($f)
}

