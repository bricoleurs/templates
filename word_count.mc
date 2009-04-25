<%doc>

=head1 NAME

word_count.mc -- Counts the number of words in a story

=head1 SYNOPSIS

  <& 'word_count.mc',
     elements => ['paragraph', 'pull_quote'] &>

=head1 DESCRIPTION

Counts the number of words in the given elements of the current
story. 

=over 4

=item C<$elements>

An optional array reference of the key names of the data subelements to
include in the count. Only specify data elements (fields) here; container
subelements will be ignored. Currently does not support subelements...patches
welcome!

=back

=head1 AUTHOR

Marshall Roch <marshall@exclupen.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Marshall Roch.

This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>
<%args>
@elements => ()
</%args>
<%init>;
my $count = 0;
$count += @{[split /\s+/, $_->get_data]} for $element->get_data_elements(@elements);
$m->print($count);
return 1;
</%init>
