<%doc>

=head1 Name

thumbnail.mc - Create a thumbnail document for an image document

=head1 SYNOPSIS

  my $thumbnail = $m->comp(
      '/util/thumbnail.mc',
      image => $image,
  );

=head1 Description

So you have lots of image documents, but you need thumbnails for them. You
could write a template that uses L<Imager|Imager> or some other module to
create a thumbnail version, but since Bricolage creates thumbnails for you,
why bother? Why not just take advantage of Bricolage's thumbnail images?

This utility template does just that. It creates image documents for Bricolage
thumbnail image files and associate them with the image document for which
they were created. Simply pass in an image document and it will create a
thumbnail document, relate it to the image document, and return it.

To get set up to use it, just follow these steps:

Here's some extra information (just playing with svn)

=over

=item *

Enable the C<USE_THUMBNAILS> F<bricolage.conf> directive and restart
Bricolage. If you have lots of images already, you'll need to view them all in
the "Find Media" interface in order to trigger the creation of thumbnail
images for them all.

=item *

Enable the C<PUBLISH_RELATED_ASSETS> F<bricolage.conf> directive. This will
force the thumbnail image to always be published at the same time as the
original image.

=item *

Check the "Related Media" checkbox for all image element types for documents
of which you plan to associate thumbnail images.

=item *

Create a utility template for this template code. I like to put utility
templates in the F</util> category, so this might be called
F</util/thumbnail.mc>.

=item *

From another template, call this utility template, passing in an image media
document to get back a thumbnail. Something like this:

  my $image = $element->get_related_media;
  $burner->throw_error($image->get_uri . ' is not an image document')
      unless $image->isa('Bric::Biz::Asset::Business::Media::Image');
  my $thumb = $m->comp('/util/thumbnail.mc', image => $image);
  $m->print(
      '<a href="', $image->get_uri, '" title="', $image->get_title, '">',
      '<img src="', $thumb->get_uri, '" alt="', $thumb->get_title,
      qq{" /></a>\n},
  );

That will create an C<img> tag for the thumbnail image that links to the
original image.

=back

=head1 Parameters

=over

=item C<image>

Required. A Bric::Biz::Asset::Business::Media::Image object for which you wish
to create a thumbnail.

=item C<key_name>

The key name of the media element type to use when creating the thumbnail
image document. Defaults to the same element type as is used by the C<$image>
document.

=item C<file_prefix>

The prefix to prepend to the image file name to create the thumbnail file
name. Defaults to "thumb-".

=item C<file_suffix>

The suffix to append to the image file name to create the thumbnail file
name. Defaults to the empty string ('').

=item C<title_prefix>

The prefix to prepend to the image title to create the thumbnail title.
Defaults to "Thumbnail for ".

=item C<title_suffix>

The suffix to append to the image title to create the thumbnail title.
Defaults to the empty string ('').

=back

=head1 Prerequisites

=over

=item Bricolage 1.8

=item C<USE_THUMBNAILS> F<bricolage.conf> directive enabled.

=item C<PUBLISH_RELATED_ASSETS> F<bricolage.conf> directive enabled.

=back

=head1 Caveats

If an image is modified, Bricolage will create a new thumbnail for it, but
this template will still relate to the old thumbnail. Perhaps a future version
of this template will address this issue.

=head1 Authors

Rod Taylor <pg@rbt.ca>

David Wheeler <david@kineticode.com>

=head1 Copyright and License

Copyright 2004-2006 by Rod Taylor and David Wheeler.

This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>
<%args>
$image
$key_name     => $image->get_element_key_name
$file_prefix  => 'thumb-'
$file_suffix  => ''
$title_prefix => 'Thumbnail for '
$title_suffix => ''
</%args>
<%once>;
my $ET_CLASS = $Bric::Biz::ElementType::VERSION
    ? 'Bric::Biz::ElementType'
    : 'Bric::Biz::AssetType';
</%once>
<%perl>;
my $melem = $image->get_element;

# Try to find an existing thumbnail image.
if (my $thumb = $melem->get_related_media) {
    return $thumb;
}

# We don't need the URI but calling it before _thumb_file will ensure that a
# thumbnail is created if it doesn't already exist.
$image->thumb_uri;

# XXX Yeah yeah, I know I shouldn't call a private method...
my $path      = $image->_thumb_file;
my $image_fn  = $image->get_file_name;
my $thumb_fn  = "$file_prefix$image_fn$file_suffix";
(my $uri      = URI::Escape::uri_unescape($image->get_uri))
    =~ s{\Q$image_fn\E$}{$thumb_fn};

# Make sure that the thumbnail file exists.
$burner->throw_error(
    qq{Thumbnail file "$path" does not exist; is USE_THUMBNAILS enabled?}
) unless -f $path;

# Look up the thumbnail element type.
my $et = $ET_CLASS->lookup({ key_name => $key_name })
    or $burner->throw_error(qq{Could not find the "$key_name" element type});

# Create the thumbnail media document.
my $thumb = Bric::Biz::Asset::Business::Media->new({
    priority      => $image->get_priority,
    title         => $title_prefix . $image->get_title . $title_suffix,
    description   => $title_prefix . $image->get_description . $title_suffix,
    site_id       => $image->get_site_id,
    source__id    => $image->get_source__id,
    media_type_id => $image->get_media_type->get_id,
    category__id  => $image->get_category__id,
    element_type  => $et,
    user__id      => Bric::App::Session::get_user_id,
});

$thumb->set_cover_date($image->get_cover_date(Bric::Config::ISO_8601_FORMAT));
$thumb->save;

# Add the thumbnail image file to the media document.
open my $thumb_fh, '<', $path or die "Cannot open '$path': $!\n";
$thumb->upload_file($thumb_fh => $thumb_fn);
close $thumb_fh;

# Check in the thumbnail document.
$thumb->checkin;
$thumb->save;

# Add the thumbnail to the media document and return it.
$melem->set_related_media($thumb);
$melem->save;
return $thumb;
</%perl>

