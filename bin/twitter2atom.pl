#!/usr/bin/env perl
use Catmandu::Importer::Twitter;
use Catmandu::Exporter::Atom;
use Date::Parse;
use URI::Escape;
use POSIX qw(strftime);

my $query = shift;

die "usage: $0 query" unless $query;

my $in  = Catmandu::Importer::Twitter->new(query => $query);
my $out = Catmandu::Exporter::Atom->new(
            title => "$query - Twitter search" , 
            link => [ { type => 'text/html' , rel => 'alternate' , href => sprintf('https://twitter.com/search?q=%s' , uri_escape($query) ) }]
           );

$out->add_many($in->map(sub {
    my $obj = $_[0];
    $ret->{id}           = $obj->{id};
    $ret->{author}{name}  = sprintf "@%s (%s)" , $obj->{from_user} , $obj->{from_user_name};
    $ret->{title}         = $obj->{text};
    $ret->{content}{body} = $obj->{text};
    $ret->{content}{body} =~ s{(@(\w+))}{<a href="https://twitter.com/$2">$1</a>}g;
    $ret->{content}{body} =~ s{(#(\w+))}{sprintf('<a href="https://twitter.com/search?q=%s" title="%s">%s</a>',uri_escape($1),$1,$1)}eg;
    $ret->{link}[0]{href} = sprintf "http://twitter.com/%s/statuses/%s" , $obj->{from_user} , $obj->{id};
    $ret->{published}     = strftime "%Y-%m-%dT%H:%M:%S", localtime( str2time($obj->{created_at}) );
    $ret->{updated}       = $ret->{published}; 
    $ret;
}));

$out->commit;