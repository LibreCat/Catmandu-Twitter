#!/usr/bin/env perl

use lib "../lib";

use Catmandu::Importer::Twitter;
use Catmandu::Exporter::Atom;
use Config::Any::JSON;
use Date::Parse;
use URI::Escape;
use Encode;
use POSIX qw(strftime);

# get twitter keys from config file
my $conf_file = "twitter.json";
my $config    = undef;

my $query = shift;

die "usage: $0 query" unless $query;
die "no twitter config file 'twitter.json' found" unless ( -e $conf_file );

$config = Config::Any::JSON->load($conf_file);

my $in = Catmandu::Importer::Twitter->new(
    query => $query,
    %{$config}
);

my $out = Catmandu::Exporter::Atom->new(
    title => "$query - Twitter search",
    link  => [
        {
            type => 'text/html',
            rel  => 'alternate',
            href =>
              sprintf( 'https://twitter.com/search?q=%s', uri_escape($query) )
        }
    ]
);

$out->add_many(
    $in->map(
        sub {
            my $obj = $_[0];
            $ret->{id} = $obj->{id};
            $ret->{author}{name} = sprintf "@%s (%s)",
              $obj->{user}->{screen_name}, $obj->{user}->{name};
            $ret->{title} = $obj->{text};
            $ret->{content}{body} = $obj->{text};
            $ret->{content}{body} =~
              s{(@(\w+))}{<a href="https://twitter.com/$2">$1</a>}g;
            $ret->{content}{body} =~
s{(#(\w+))}{sprintf('<a href="https://twitter.com/search?q=%s" title="%s">%s</a>',uri_escape($1),$1,$1)}eg;
            $ret->{link}[0]{href} = sprintf "http://twitter.com/%s/statuses/%s",
              $obj->{from_user}, $obj->{id};
            $ret->{published} = strftime "%Y-%m-%dT%H:%M:%SZ",
              gmtime( str2time( $obj->{created_at} ) );
            $ret->{updated} = $ret->{published};
            $ret;
        }
    )
);

$out->commit;
