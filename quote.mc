<%doc>

=head1 NAME

quote.mc = Very simple pull quote element

=head1 DESCRIPTION

This will create a 1 pixel outline box to include quotes in.

=head1 USAGE

Create an element of type insets, called StoryQuote or whatever you like. Make
it a subelement of your page element. In the StoryQuote element, create two
custom fields called Quote and WhosQuote. Make Quote a text area and WhosQuote
a text box, set the parameters to whatever you think you'll need. Now create a
template for StoryQuote using the code below and when you need a quote in your
story, just include the StoryQuote element in your page.

=head1 AUTHOR

Dave Dambacher

=cut

</%doc>
<table align="right" cellspacing="0" cellpadding="0" width="150" border="0">
  <tr>
    <td bgcolor="#cccccc" colspan="5"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
  </tr>
  <tr>
    <td bgcolor="#cccccc"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
    <td valign="top" colspan="3"><img height="4" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
    <td bgcolor="#cccccc"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
    <td bgcolor="#ffffff"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="3"></td>
  </tr>
  <tr>
    <td bgcolor="#cccccc"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
    <td>&nbsp;</td>
    <td valign="top">
      <br /><br />&quot;<% $element->get_data('quote') %>&quot;
      <br /><br />- <% $element->get_data('whosquote') %>
      <br />
      <img height="1" src="http://www.yourdomain.com/images/transp.gif" width="125">
    </td>
    <td>&nbsp;</td>
    <td bgcolor="#cccccc"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td bgcolor="#cccccc" colspan="5"><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="1"></td>
    <td><img height="1" src="http://www.yourdomain.com/images/transp.gif" width="3"></td>
  </tr>
</table>
