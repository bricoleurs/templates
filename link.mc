<%doc>

=head1 NAME

newwindowlink.mc: Very simple link for opening a story in a new browser window.

=head1 DESCRIPTION

This will open a link from your story in a new browser.

=head1 USAGE

Create an element of type insets, called Link. Create two custom fields for
Link called URL and Link Title, both text boxes. Make Link a subelement of
your page element. Now create a template for Link using the code below. When
you need to link off to a different site, just include the Link element in
your page.

=head1 AUTHOR

Dave Dambacher

</%doc>
<br /><br />
<a href="<% $element->get_data('url') %>" target=_"blank"><% $element->get_data('Link Title') %></a>
<br /><br />
