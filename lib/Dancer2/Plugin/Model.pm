package Dancer2::Plugin::Model;

use strictures 2;

use Dancer2;
use Dancer2::Plugin;

use Dancer2::Plugin::AppRole::Helper;

# VERSION

# ABSTRACT: gantry to hang a model layer onto Dancer2

# COPYRIGHT

=head1 SYNOPSIS

In your app:

    package My;
    use Dancer2;
    use Dancer2::Plugin::Model;
    
    configure_model db => make_db();
    set_model;
    
    any '/' => sub {
        template 'index', { news => model( "News" )->get_latest };
    };

In the model factory:

    package My::Model;
    
    use Module::Runtime 'use_module';
    use Moo;
    
    has db => is => ro => required => 1;
    
    sub get {
        my ( $self, $entity_name ) = @_;
        use_module( __PACKAGE__ . "::$entity_name" )->new( db => $self->db );
    }

In the model entity:

    package My::Model;
    
    use Moo;
    
    has db => is => ro => required => 1;
    
    sub get_latest {
        my ( $self ) = @_;
        
        $self->db->search(
            "events",
            where => { event => 'New' }, sort => { date  => -1 }, per_page => 5,
        );
    }

=cut

on_plugin_import { ensure_approle_s Model => @_ };

register model => sub {
    my ( $dsl, $model ) = @_;
    return $dsl->app->model->get( $model );
};

register set_model => sub {
    my ( $dsl, $model ) = @_;
    return $dsl->app->model( $model ? $model : () );
};

register configure_model => sub { shift->app->model_args( {@_} ) };

register_plugin;

1;
