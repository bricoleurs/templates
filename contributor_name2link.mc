<%doc>

=head1 NAME

contributor_name2link.mc

=head1 SYNOPSIS

  <& contributor_list.mc,
     asset   => $story,
     sep     => ', ',
     final   => ' and ',
     format  => '%f% l',
     default => ''
  &>

=head1 DESCRIPTION

Changes a contributor's name to a url structure called by contributor_list.mc on thetyee.ca
Utility template that returns the URI of a contributor page,
given the contributor's name.  Right now this just means
converting all non-alphanumeric characters to underscores.


=head1 AUTHOR

Dawn Buie <dawn@dawnthots.ca>

=head1 COPYRIGHT AND LICENSE


This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>


<%args>
$name => undef
$caturi => '/Bios'
</%args>
<%perl>
return unless defined $name;
my @names = ref($name) ? @$name : $name;
@names = map { 
    (my $slug = $_) =~ s/\W/_/g; 
    "<a class=\"contrib-link\" title=\"Bio page for $_\" href=\"$caturi/$slug\">$_</a>"
    } @names;
# return wantarray ? @names : $names[0];
return wantarray ? @names : $names[0];

#use Data::Dump 'dump';
#print dump(@names);
</%perl>