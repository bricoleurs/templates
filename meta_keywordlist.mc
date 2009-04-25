<%doc>

=head1 NAME

meta_keywords.mc -- Outputs a keywords "meta" tag.

=head1 SYNOPSIS

  <& meta_keywords.mc, which => $which &>

=head1 DESCRIPTION

Outputs an XHTML-compliant "meta" tag for keywords. The C<which> parameter
tells F<keyword_list.mc> which keywords to return. The possible values are the
same as for the F<keyword_list.mc> template.

=head2 REQUIREMENTS

You must have the F<keyword_list.mc> template installed.

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Kineticode, Inc and by Mac Publishing, LLC.

This template is free software; you can redistribute it and/or modify it under
the same terms as Bricolage itself.

=cut

</%doc>
<%init>;
$m->print('<meta name="keywords" content="',
          Apache::Util::escape_html
            ( join (', ', map { $_->get_name }
                    $m->comp('/util/keyword_list.mc', %ARGS))),
          '" />');
return;
</%init>