use Monad;

unit class Monad::Either is Monad;

role Left {
	has $.type = 'Left';
}

role Right {
	has $.type = 'Right';
}

has $.value = Nil;

method unwrap {
	$!value;
}

method unwrap-right {
    self.is-right
        ?? $!value
        !! die "Tried to unwrap-right from a Left";
}

method unwrap-left {
    self.is-left
        ?? $!value
        !! die "Tried to unwrap-left from a Right";
}

method is-left {
	self ~~ Left;
}

method is-right {
	self ~~ Right;
}

method bind(&f --> Monad:D) {
	return self if self.is-left;
	return f($.value);
}

method map(&f) {
	return self if self.is-left;
	self.right(f($.value));
}

method gist { 
	self.is-right ?? "Right($.value)" !! "Left($.value)";
}

method left($value --> Monad::Either) {
	self.new(:$value) but Left;
}

method right($value --> Monad::Either) {
	self.new(:$value) but Right; 
}

method unit($value --> Monad::Either) {
	self.right($value)
}
