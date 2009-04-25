<%doc>

=head1 NAME

assetlink.mc - Very simple link to a related media document.

=head1 DESCRIPTION

This temlate will create a link to media such as video or audio, with the name
of the media as the link and the size of the media dsplayed below the link.

=head1 USAGE

Create an element of type related media, called AssetLink or whatever makes
sense to you. Make AssetLink a subelement of your page element. Now create a
template for AssetLink using the code below. When you need a link to media,
just include the AssetLink element in your page and relate media to it.

=cut

</%doc>
% my $rel_media = $element->get_related_media;
<a href="<% $rel_media->get_uri %>"><% $rel_media->get_title %></a>
<br />
File size: <% $rel_media->get_size %> kbs