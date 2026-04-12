use Monad;

#| The List monad — represents a sequence of values, with bind flattening
#| one level of nesting (a.k.a. flatMap).
#|
#| Parameterized by C<::T>, the element type. Defaults to C<Any> so
#| legacy usage without brackets is unchanged.
#|
#|     # Untyped (legacy)
#|     my $a = Monad::List.of(1, 2, 3);
#|
#|     # Typed: elements constrained to Int
#|     my $b = Monad::List[Int].of(1, 2, 3);
role Monad::List[::T = Any] is Monad {
    has T @.values;

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
        return self.^name unless self.defined;
        "List[" ~ @.values.join(", ") ~ "]";
    }

    method unit($value --> Monad::List) {
        self.new(values => [$value]);
    }

    method of(*@values --> Monad::List) {
        self.new(values => @values);
    }
}
