package Linux::Nftables;

use strict;
use warnings;

=encoding utf-8

=head1 NAME

Linux::Nftables - Perl interface to L<libnftables|https://netfilter.org/projects/nftables/>

=cut

#----------------------------------------------------------------------

use Carp ();

use Call::Context ();
use Symbol::Get ();

use XSLoader;

our $VERSION = '0.01_01';
XSLoader::load( __PACKAGE__, $VERSION );

my $OUTPUT_OPT_PREFIX = '_NFT_CTX_OUTPUT_';
my $DEBUG_OPT_PREFIX = '_NFT_DEBUG_';

my $output_opts_hr;
my $debug_opts_hr;

#----------------------------------------------------------------------

sub get_output_options {
    my ($self) = @_;

    $output_opts_hr ||= _assemble_const_hr($OUTPUT_OPT_PREFIX);

    my $flags = $self->_output_get_flags();

    return _flags_to_names($flags, $output_opts_hr);
}

sub set_output_options {
    my ($self, @opts) = @_;

    my $flags = _names_to_flags( $OUTPUT_OPT_PREFIX, @opts );

    return $self->_output_set_flags($flags);
}

sub get_debug_options {
    my ($self) = @_;

    $debug_opts_hr ||= _assemble_const_hr($DEBUG_OPT_PREFIX);

    my $flags = $self->_output_get_debug();

    return _flags_to_names($flags, $debug_opts_hr);
}

sub set_debug_options {
    my ($self, @opts) = @_;

    my $flags = _names_to_flags( $DEBUG_OPT_PREFIX, @opts );

    return $self->_output_set_debug($flags);
}

#----------------------------------------------------------------------

sub _names_to_flags {
    my ($prefix, @names) = @_;

    my $flags = 0;

    for my $opt (@names) {
        my $uc_opt = $opt;
        $uc_opt =~ tr<a-z><A-Z>;

        my $cr = __PACKAGE__->can( $prefix . $uc_opt) or do {
            Carp::croak "Unknown option: $opt";
        };

        $flags |= $cr->();
    }

    return $flags;
}

sub _flags_to_names {
    my ($flags, $opts_hr) = @_;

    my @names;

    for my $optname (sort keys %$opts_hr) {
        next if !($flags & $opts_hr->{$optname});
        push @names, $optname;
    }

    return @names;
}

sub _assemble_const_hr {
    my $prefix = shift;

    my %opts;

    for my $name (Symbol::Get::get_names()) {
        next if $name !~ m<\A$prefix(.+)>;

        my $optname = $1;
        $optname =~ tr<A-Z><a-z>;

        $opts{$optname} = __PACKAGE__->$name();
    }

    return \%opts;
}

1;
