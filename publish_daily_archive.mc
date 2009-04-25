<%doc>

=head1 NAME

publish_daily_archive.mc - Look up or create and publish a daily archive

=head1 VERSION

1.0

=head1 DESCRIPTION

Here's some example code demonstrating how to look up and publish a "Daily
Archive" story, or, if no such archive exists for the cover date of the
current story, to create a new "Daily Archive" story for that date and publish
it.

We first try to look up the appropriate "Daily Archive" story. If it exists,
we simply publish it with the C<publish_another()> burner method. If it does
not exist, we have to do a few tricks to create one. Once it's created,
it can be published.

=head1 PREREQUISITES

=over 4

=item Bricolage 1.8

=item A "Daily Archive" story type element

=back

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Kineticode, Inc.

This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>
<%once>;
# Set the ID for your "Daily Archive" element here.
my $daily_archive_element_id = 1032;
</%once>
<%cleanup>;
# Just bail unless we're publishing or the current story has been published
# before (and is therefore already in the archive--I hope its URI or cover
# date hasn't changed!
return unless $burner->get_mode == PUBLISH_MODE
  && $story->get_publish_status;

# Create the URI for the daily archive with the same date as the current
# story. Replace "/archive/daily" with whatever category you want for
# your archive documents.
my $daily_archive_uri = $story->get_cover_date("/archive/daily/%Y/%m/%d");

# Look for an existing daily archive for this date.
my ($daily_archive_story) = Bric::Biz::Asset::Business::Story->list({
     primary_uri      => $daily_archive_uri,
     element_key_name => 'daily_archive',
     Limit            => 1,
});

unless ($daily_archive_story) {
     # We need to create a new daily archive for this date.
     $daily_archive_story = Bric::Biz::Asset::Business::Story->new({
         element__id => $daily_archive_element_id,
         source__id  => $story->get_source__id,
         site_id     => $story->get_site_id,
         user__id    => Bric::App::Session::get_user_id(),
         title       => 'Daily Archive',
     });

     my ($category) = Bric::Biz::Category->list({
         uri => "/archive/daily"
     });

     $burner->throw_error("There is no daily archive category")
       unless $category;

     # Set it up and check it in.
     $daily_archive_story->add_categories( [ $category->get_id ] );
     $daily_archive_story->set_primary_category( $category->get_id );
     $daily_archive_story->set_cover_date(
         $story->get_cover_date("%Y-%m-%d 00:00:00")
     );
     $daily_archive_story->checkin;
     $daily_archive_story->save;
}

# Make sure to mark the current story published so that it will show up in
# the daily archive.
$story->set_publish_status(1);
$story->save;

# Publish the daily archive.
$burner->$action($daily_archive_story);
</%cleanup>
