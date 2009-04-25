<%doc>

=head1 NAME

last_saved.mc -- Returns the last time a story was saved

=head1 SYNOPSIS

  <h3>Last Updated: <& /util/text/last_saved.mc &></h3>

  <& /util/text/last_saved.mc,
     asset   => $story,
     format  => '%Y-%m-%dT%T'
  &>

=head1 DESCRIPTION

Outputs the date and/or time that a story was last saved in the UI. 
This is useful if you want to display a "Last Modified" timestamp 
that is not affected by republishes. The supported parameters are 
all optional, and are as follows:

=over 4

=item C<$asset>

The asset from which to get the time of the last save. Useful for 
getting the time for a related story or media asset. Defaults to the
global C<$story> object.

=item C<$format>

The C<strftime> formatting string used to format the date. Defaults
to the value of the "Date/Time Format" preference.

=back

=head1 AUTHORS

David Wheeler <david@kineticode.com>

Marshall Roch <marshall@exclupen.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by the Bricolage Development Team.

This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>
<%args>
$format  => undef
$asset   => $story
</%args>
<%init>;
# Output the timestamp.
my $event = Bric::Util::Event->list({
    obj_id   => $asset->get_id,
    key_name => 'story_save'
});
$m->print($event->[-1]->get_timestamp($format));
return 1;
</%init>
