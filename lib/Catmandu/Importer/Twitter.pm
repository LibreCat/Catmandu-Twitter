package Catmandu::Importer::Twitter;

use Catmandu::Sane;
use Net::Twitter;
use Moo;

with 'Catmandu::Importer';

our $VERSION = '0.02';

has query   => (is => 'ro', required => 1);
has twitter => (is => 'ro', init_arg => undef , lazy => 1 , builder => '_build_twitter');

sub _build_twitter {
    Net::Twitter->new();
}

sub generator {
    my ($self) = @_;
    
    sub {
        state $res = $self->twitter->search($self->query);
        return unless @{$res->{results}};
        return shift @{$res->{results}};
    };
}

=head1 NAME

Catmandu::Importer::Twitter - Package that imports Twitter feeds

=head1 SYNOPSIS

    use Catmandu::Importer::Twitter;

    my $importer = Catmandu::Importer::Twitter->new(query => '#elag2013' );

    my $n = $importer->each(sub {
        my $hashref = $_[0];
        # ...
    });

=head1 METHODS

=head2 new(query => '...')

Create a new Twitter importer using a query as input.

=head2 count

=head2 each(&callback)

=head2 ...

Every Catmandu::Importer is a Catmandu::Iterable all its methods are inherited. The
Catmandu::Importer::Twitter methods are not idempotent: Twitter feeds can only be read once.

=head1 SEE ALSO

L<Catmandu::Iterable>

=cut

1;
