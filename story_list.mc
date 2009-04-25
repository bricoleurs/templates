<%doc>

=head1 NAME

story_list.mc - Returns a list of related stories

=head1 VERSION

1.2

=head1 SYNOPSIS

  my @relateds = $m->comp(
      '/util/story_list.mc',
      max            => 10,
      site_ids       => [1024, 1025],
      related_subs   => [qw(related_article link_to_story)],
      exclude_ids    => [4453, 5298],
      story_types    => [qw(article story review)],
      which_keywords => 'story',
      until          => 'story',
      current_cats   => 0,
      subcats        => 1,
      all_subcats    => 1,
      by_cover_date  => 0,
  );

=head1 DESCRIPTION

This utility template returns a list or array reference of unexpired
stories. By using the optional parameters, the stories returned can be deemed
to be related to the story currently being published (hereafter referred to as
the "current story"). For example, using the C<current_cats> parameter, the
stories returned will be in the same categories as the current story. Using
the C<subcats> parameter, they will be in the same category or subcategories
as the category to which the current story is being published. Using the
C<all_subcats> parameter, they will be in the same categories or subcategories
as the current story. If the C<which_keywords> parameter is passed, then they
will also each be related to one or more of the keywords that the current
story is associated with. See below for further details of the parameters.

The stories returned will not exceed the C<max> parameter. If the
C<related_subs> parameter is passed, the number will be C<max> minus the
number of related stories found in the subelements of the current element that
have the key names passed via the C<related_subs> parameter.

In publish mode, only published stories will be returned, reverse ordered by
first publish date. In preview mode, published and unpublished stories may be
returned, reverse ordered by cover date.

Here's a full description of all of the supported parameters.

=over 4

=item max

The maximum number of stories to return. Note that the number to be returned
will actually be C<max> minus the number of story IDs found in C<related_subs>.
The number of stories returned may also be fewer if there are fewer than
C<max> stories that match the search criteria. Defaults to 10.

=item site_ids

An optional array of Site IDs to limit the stories returned to one or more
sites. If no site IDs are passed, stories from any site may be returned.

=item story_cats

Pass a true value to limit the stories returned to the same categories as
those with which the current story is associated. If C<story_cats> is false,
then stories from any category may be returned (but see also C<subcats> and
C<all_subcats>).

=item subcats

Pass a true value for this parameter to limit the stories returned to stories
in the same category or its subcategories that the current story is being
burned to, or the category passed via the C<category_uri> parameter and all of
its subcategories. This parameter is ignored if the C<story_cats> parameter is
passed a true value.

=item category_uri

Pass in the URI of the category to be used with the C<subcats> parameter.
Defaults to the value returned by C<< $burner->get_cat >>.

=item all_subcats

Pass a true value for this parameter to limit the stories returned to stories
in the same categories or subcategories as the current story is associated
with. In other words, the stories will be in any of the categories returned by
C<< $story->get_categories >> or any of their subcategories. This parameter is
ignored if either the C<story_cats> parameter or the C<subcats> parameter is
passed a true value.

=item by_cover_date

Pass a true value to this parameter in order to search for and return stories
in reverse chronological order by cover date. By default, F<story_list.mc>
sorts stories by cover date during previews and by first publish date during
publishes. But some may prefer to sort by cover date during publishes as well.
Pass a true value to this parameter in order to get that behavior. False by
default. Note that sorting is always by cover date during previews.

=item until

The maximum date for the stories returned. In publish mode, the
C<first_publish_date> date will be used unless the C<by_cover_date> parameter
is set to a true value; in preview mode, the C<cover_date> will be used. If
the value of this parameter is "story", then the first publish date or cover
date of the current story will be used. That is, it's equivalent to:

    until => $story->get_first_publish_date(Bric::Config::ISO_8601_FORMAT)
             || $story->get_cover_date(Bric::Config::ISO_8601_FORMAT)

Otherwise, pass in a date in ISO-8601 C<strftime> format (available from
C<Bric::Config::ISO_8601_FORMAT>. If no C<until> parameter is passed, then
stories with any date may be returned.

=item related_subs

An optional array of key names for any subelements of the current element that
may contain related stories. The related stories found in those subelements
will be excluded from the list of stories to return, and will decrease the
maximum number of stories returned by the number of of story IDs found. If the
number of story IDs found is greater than or equal to the number specified by
C<max>, no stories will be returned. If no element key names are passed via
the C<related_subs> parameter, no subelements of the current element will be
searched for related stories.

=item exclude_ids

An optional array of story IDs representing stories that should be excluded
from the list of related stories. The current story will always be excluded.

=item story_types

An optional array of key names for the story type elements of the stories to
be looked up and returned. Typical examples are "story", "article", "review",
"opinion", etc. If no story type element key names are passed, stories based on
any story type element may be returned.

=item which_keywords

An argument to be passed to the F</util/keyword_list.mc> utility template's
C<which> parameter. If a value is passed via the C<which_keywords> parameter,
then the stories returned will each be associated with one or more of the
keywords returned by F</util/keyword_list.mc>. See F</util/keyword_list.mc>
for documentation of the options to its C<which> parameter. Note that
F</util/keyword_list.mc> must be installed if the C<which_keywords> parameter
is used.

=back

=head1 PREREQUISITES

=over 4

=item Bricolage 1.8

=item F</util/keyword_list.mc>

=back

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2004-2006 David Wheeler & Kineticode, Inc.

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

</%doc>\
<%args>
$max            => 10
@related_subs   => ()
@exclude_ids    => ()
@story_types    => ()
@site_ids       => ()
$which_keywords => undef
$until          => undef
$story_cats     => undef
$subcats        => undef
$all_subcats    => undef
$category_uri   => undef
$by_cover_date  => undef
</%args>\
<%init>;
my $count = 0;
# Are there subelements to the current element that have related stories to
# exclude?
my %exclude = @related_subs
  ? grep { defined && ++$count }
    map  { $_->get_related_story_id }
    $element->get_containers(@related_subs)
  : ();

# Just return if unless we need more relateds.
return unless $count < $max;

# Map the stories to explicitly exclude, including the current story.
$exclude{$_} = 1 for @exclude_ids, $story->get_id;

# Get any keywords to search by.
my @keywords = $which_keywords
  ? map { $_->get_name }
    $m->comp('/util/keyword_list.mc', which => $which_keywords)
  : ();

# Figure out what column to sort by and if there is a date to select up to.
my $order_by;
if ($by_cover_date) {
    $order_by = 'cover_date';
    $until = $story->get_cover_date(Bric::Config::ISO_8601_FORMAT)
      if $until && $until eq 'story';
} else {
    $order_by = 'first_publish_date';
    $until = $story->get_first_publish_date(Bric::Config::ISO_8601_FORMAT)
      || Bric::Util::Time::strfdate
      if $until && $until eq 'story';
}

# Assemble the parameters.
my %params = (
    # We don't want any unexpired stories.
    unexpired                    => 1,
    # Account for the current story as a possible extra.
    Limit                        => $max + 1,
    # Start with the most recent stories fist.
    OrderDirection               => 'DESC',

    # Limit to stories in the same categories as the current story?
    ( $story_cats
      ? ( 'story.category'       => $story->get_id )
      # Limit to subcategories of the current category?
      : ( $subcats
          ? ( category_uri       => (defined $category_uri
                                       ? $category_uri
                                       : $burner->get_cat->get_uri) . '%' )
          # Limit to any categories and subcategories of the current story?
          : ( $all_subcats
              ? ( category_uri   => ANY(map { $_->get_uri . '%' }
                                        $story->get_categories ) )
              : ()
            )
        )
    ),

    # Limit by site IDs?
    ( @site_ids
      ? ( site_id                => ANY(@site_ids) )
      : ()
    ),

    # Limit by keywords?
    ( @keywords
      ? ( keyword                => ANY(@keywords) )
      : ()
    ),

    # Limit by element types?
    ( @story_types
      ? ( element_key_name       => ANY(@story_types) )
      : ()
    ),

    # Are we publishing?
    ( $burner->get_mode == PUBLISH_MODE
      ? (
          # Only return published stories ordered by first publish date.
          publish_status         => '1',
          Order                  => $order_by,
          ( $until
            ? ( "$order_by\_end" => $until )
            : ()
          )
        )
    # ...Or previewing?
      : (
          # Return published and unpublished stories ordered by cover date.
          Order                  => 'cover_date',
          ( $until
            ? ( cover_date       => $until )
            : ()
           )
        )
    )
);

# Get the related stories.
my @relateds =
  grep { ! $exclude{$_->get_id} }
  Bric::Biz::Asset::Business::Story->list(\%params);

# Truncate the array, if necessary.
$#relateds = $max - $count - 1 if @relateds > $max - $count;

# Return 'em!
return wantarray ? @relateds : \@relateds;
</%init>\