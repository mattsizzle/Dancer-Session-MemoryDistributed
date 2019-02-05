package Dancer::Session::MemoryDistributed;

# ABSTRACT: Dancer Session Engine with in-memory storage that can be backed by an additional distributed engine such as
# Redis or CHI

use strict;
use warnings;
use parent 'Dancer::Session::Abstract';
use Dancer::Config 'setting';
use Carp;

use Dancer::ModuleLoader;

our $VERSION = '0.01'; # VERSION
our $AUTHORITY = 'cpan:MATTSIZLE'; # AUTHORITY

=head1 NAME

Dancer::Session::Memory::Distributed - The great new Dancer::Session::Memory::Distributed!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

An Abstract Session Engine for Dancer that provides the speed
of Dancer::Session::Simple with a distributed backing by
another Dancer::Session::* model such as Dancer::Session::Redis

This module was created to limit reads from the distributed backend
engine per request. The session will prefer a local in memory version
of any item retrieved with get_value. If it does not locate the item
in memory it will attempt to reach out to the b_engine

On write it will persist the data to the b_engine Dancer::Session:: model.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

# static

# singleton for the persistent backing
my $B_ENGINE;

# singleton for the memory backing
my %SESSIONS;

sub init {
    my $self = shift;

    $self->SUPER::init(@_);

    my $session_b_engine = setting("session_b_engine");
    croak "The setting session_b_engine must be defined"
        unless defined $session_b_engine;

    $B_ENGINE = $session_b_engine>new();
}

# create a new session and return the newborn object representing that session
sub create {
    my ($class) = @_;

    my $self = Dancer::Session::Memory::Distributed->new;
    $self->flush;
    return $self;
}

# Return the session object corresponding to the given id
sub retrieve {
    my ($self, $id) = @_;

    $SESSIONS{$id} and return $SESSIONS{$id};

    my $b_session = $B_ENGINE->retrieve(@_);

    if ( $b_session ) {
        $SESSIONS{$id} = $b_session;
    }

    return $b_session;
}

sub destroy {
    my ($self) = @_;
    undef $SESSIONS{$self->id};
    $B_ENGINE->destroy($self);
}

sub flush {
    my ($self) = @_;
    $SESSIONS{$self->id} = $self;

    $B_ENGINE->flush($self);
    return $self;
}

sub get_value {
    my ( $self, $key ) = @_;

    $self->{$key} and return $self->{$key};

    $B_ENGINE->get_value(@_);
}

1;




=head1 AUTHOR

Matthew Green, C<< <green.matt.na at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-session-memory-distributed at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Session-Memory-Distributed>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Session::Memory::Distributed


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Session-Memory-Distributed>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Session-Memory-Distributed>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Dancer-Session-Memory-Distributed>

=item * Search CPAN

L<https://metacpan.org/release/Dancer-Session-Memory-Distributed>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2019 Matthew Green.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Dancer::Session::Memory::Distributed
