<%doc>

=head1 NAME

keyword_list.mc - Get list of keywords

=head1 SYNOPSIS

  my @kw = $m->comp( '/util/keyword_list.mc',
                     which => 'total' );

=head1 DESCRIPTION

Outputs a list or anonymous array of keyword objects. The C<which> parameter
tells F<keyword_list.mc> which keywords to return. The possible values are:

=over 4

=item total

Return all of the keywords for the story, all of its categories, and all of
the parents of those categories.

=item context

Return all of the keywords for the story, for the current category (the one to
which the story is being burned), and for all of its parent categories.

=item cats

Return all of the keywords for the story and all of its categories.

=item local

Return all of the keywords for the story and for the current category (the one
to which the story is being burned).

=item story

Return only the story's keywords.

=back

The default is "cats". The keywords will be returned sorted by their
C<sort_name> properites.

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2003 by Kineticode, Inc and by Mac Publishing, LLC.

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, version 2.1 of the License.

This library is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with this library (see the the license.txt file); if not, write to the Free
Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA.

=cut

</%doc>
<%args>
$which => 'cats'
</%args>
<%once>;
my %subs =
 ( total => sub {
       my %kw = map { $_->get_id => $_ } $story->get_keywords;
       foreach my $cat ($story->get_categories) {
           foreach my $k ($cat->keywords) {
               $kw{$k->get_id} = $k;
           }
           while ($cat = $cat->get_parent) {
               foreach my $k ($cat->keywords) {
                   $kw{$k->get_id} = $k;
               }
           }
       }

       return sort { lc $a->get_sort_name cmp lc $b->get_sort_name }
         values %kw;
   },
   context => sub {
       my $cat = $burner->get_cat;
       my %kw = map { $_->get_id => $_ } $story->get_keywords, $cat->keywords;
       while ($cat = $cat->get_parent) {
           foreach my $k ($cat->keywords) {
               $kw{$k->get_id} = $k;
           }
       }
       return
         map  { $_->[0] }
         sort { $a->[1] cmp $b->[1] }
         map  { [ $_ => lc $_->get_sort_name] }
         values %kw;
   },
   cats => sub {
       $story->get_all_keywords
   },
   local => sub {
       my %kw = map { $_->get_id => $_ } $story->get_keywords,
         $burner->get_cat->keywords;
       return sort { lc $a->get_sort_name cmp lc $b->get_sort_name }
         values %kw;
   },
   story => sub {
       $story->get_keywords
   }
  );
</%once>
<%init>;
my $code = $subs{$which} or die "No such which parameter '$which'";
return wantarray ? $code->() : [$code->()];
</%init>