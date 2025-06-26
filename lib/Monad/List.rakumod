use Monad;

unit class Monad::List is Monad;

has @.values;

method unwrap {
	@!values;
}

method bind(&f --> Monad::List:D) {
	my @result;
	for @.values -> $v {
		my $m = f($v);
		die "bind must return a Monad::List" unless $m ~~ Monad::List;
		@result.append: $m.values;
	}

	self.new(values => @result);
}

method map(&f) {
	my @result = @.values.map(&f);
	self.new(values => @result);
}

method gist {
	"List[" ~ @.values.join(", ") ~ "]"
}

method unit($value --> Monad::List) {
	self.new(values => [$value]);
}

method of(*@values --> Monad::List) {
	self.new(values => @values);
}
