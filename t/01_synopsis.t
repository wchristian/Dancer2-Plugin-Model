#!/usr/bin/perl
use warnings;
use strict;

{   package My::Model;

    use Module::Runtime 'use_module';
    use Moo;

    has db => is => ro => required => 1;

    sub get {
        my ( $self, $entity_name ) = @_;
        use_module( __PACKAGE__ . "::$entity_name" )->new( db => $self->db );
    }
}

{   package My::Model::News;

    use Moo;

    has db => is => ro => required => 1;

    sub get_latest {
        my ( $self ) = @_;

        $self->db->search(
            'events',
            where => { event => 'New' }, sort => { date  => -1 }, per_page => 5,
        );
    }
}

{   package My::MockDB;
    use Moo;
    sub search {
        return 'found';
    }
}

{   package My;
    use Dancer2;
    use Dancer2::Plugin::Model;

    configure_model db => make_db();
    set_model();

    any '/' => sub {
        return model( 'News' )->get_latest;
    };

    sub make_db {
        return My::MockDB->new;
    }
}

use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;

my $app  = My->to_app;
my $test = Plack::Test->create( $app );

my $res = $test->request( GET '/' );
is $res->code, 200, 'GET / successful';
is $res->content, 'found', 'GET / expected result';
