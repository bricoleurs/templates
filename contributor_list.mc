<%doc>

=head1 NAME

contributor_list.mc -- Outputs a list of contributors

=head1 SYNOPSIS

  <& contributor_list.mc,
     asset   => $story,
     sep     => ', ',
     final   => ' and ',
     format  => '%f% l',
     default => ''
  &>

=head1 DESCRIPTION

Outputs a formatted list of the contributors to a story. The supported
parameters are all optional, and are as follows:

=over 4

=item C<$asset>

The asset from which to get the list of contributors. Useful for getting the
list of contributors for a related story or media asset. Defaults to the
global C<$story> object.

=item C<$sep>

The separator to put between each name in the list, except betwee the
second-to-last and last names in the list. The default is ", ".

=item C<$final>

The separator put between the second-to-last and last names in the list. The
default is " and ".

=item C<$format>

The C<strfname> formatting string used to format each person's name. Defaults
to the value of the "Name Format" preference. See Bric::Biz::Person for
complete documentation of the C<strfname> formats.

=item C<$sort>

The property on which to sort the list of contributors. By default, the list
of contributors will be output in the order they're returned by
C<< $story->get_contributors >>, but if you need them to be output in some
other order, use this argument. The possible options for this argument are:

=over 4

=item full_name

=item lname

=item fname

=item mname

=item prefix

=item suffix

=item type

=back

=item C<$default>

The default value to display if there are no contributors associated with the
story. Defaults to an empty string ("").

=back

=head1 AUTHOR

David Wheeler <david@kineticode.com> 
Revised by Dawn Buie <dawn@dawnthots.ca>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Kineticode, Inc and by Mac Publishing, LLC.

This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>
<%once>;
my $full_name_get = sub { $_[0]->get_name($_[1]) };
</%once>
<%args>
$sep     => ', '
$final   => ' and '
$format  => '%p% f% M% l%, s'
$sort    => undef
$asset   => $story
$default => ''
</%args>
<%init>;
# Get the list of contributors.
my @contribs = $asset->get_contributors;
unless (@contribs) {
    # If there are no contributors, just output the default and return.
    #$m->print($default);
    return 0;
}
if ($#contribs == 0) {
    # There's just one contributor. Format and return.
    my $contrib_link =  $m->comp("/util/contributor_name2link.mc", name=>$contribs[0]->get_name($format));
    $m->print('By&nbsp;'.$contrib_link);

    return 1;
}
if ($sort) {
    # We need to resort them.
    my $get = $sort eq 'full_list' ? sub { $_[0]->get_name($format) } :
      Bric::Util::Grp::Parts::Member::Contrib->my_meths->{$sort}{get_meth};
    @contribs = sort { lc $get->($a) cmp lc $get->($b) } @contribs;
}
# Grab the last name in the list.
my $last = pop @contribs;
my $lastcontrib = $m->comp("/util/contributor_name2link.mc", name=>$last->get_name($format));
# Convert the contributor names to links
@contribs = map { $_->get_name($format) } @contribs;
@contribs =  $m->comp("/util/contributor_name2link.mc", name=>\@contribs);
# Output the list.
$m->print('By&nbsp;'.join($sep, @contribs),
          $final, $lastcontrib);
return 1;
</%init>