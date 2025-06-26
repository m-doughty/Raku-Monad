use Monad;

unit class Monad::Maybe is Monad;

role Some {
    has $.type = 'Some';
}

role None {
    has $.type = 'None';
}

has $.value = Nil;

method unwrap {
    self.is-some ?? $!value !! Nil;
}

method is-some {
	self ~~ Some;
}

method is-none {
	self ~~ None;
}

method bind(&f --> Monad:D) {
	return self if self.is-none;
	return f($.value);
}

method map(&f) {
	return self if self.is-none;
	my $res = f($.value);

	(defined $res) ?? self.some($res) !! self.none;
}

method gist { 
	self.is-some ?? "Some($.value)" !! "None";
}

method some($value --> Monad::Maybe) {
	self.new(:$value) but Some;
}

method none(--> Monad::Maybe) {
	self.new() but None; 
}

method unit($value --> Monad::Maybe) {
	(defined $value) ?? self.some($value) !! self.none;
}
