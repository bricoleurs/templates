<%doc>

=head1 Name

introspect.mc - Outputs a graphical representation of a story type element tree

=head1 Version

1.0

=head1 Synopsis

  <& /util/xhtml/introspect.mc &>

=head1 Description

This template outputs a graphical representation of the element structure of a
story type element. To see examples of its output, visit
L<http://www.bricolage.cc/about/doc_models/> on the Bricolage Website.

To use this template, simply create a template for your story type element,
have it execute this template, and you're done. Create a new document for the
story type element and preview it.

The output is XHTML 1.1, containing a series of embedded C<< <div> >>s, each
representing a single element in the element tree. Each contains data about
the element, any fields and any subelements, as well as metadata about the
element itself (name, key name, related story, etc.). The story type element
itself also includes a list of associated sites and output channels.

This template is smart enough to correctly handle recursive elements. It also
has embedded CSS to make the whole thing look nice, with colors to distinguish
up to ten levels of the element tree. Patches to make it look even nicer are
warmly welcomed.

=head1 Parameters

=over 4

=item full_page

  $m->comp('/util/xhtml/introspect.mc', full_page => 0);

Pass a false value to this parameter to prevent the template from outputting a
complete XHTML page. That is, if you want to handle the output of the
C<< <html> >>, C<< <head> >>, and C<< <body> >> tags yourself, pass a false
value. Defaults to true.

=item include_css

  $m->comp('/util/xhtml/introspect.mc', include_css => 0);

Pass a false value to this parameter to prevent the template from outputting
its default CSS. True by default.

=head1 Prerequisites

=over 4

=item Bricolage 1.8

=back

=head1 Author

David Wheeler <david@kineticode.com>

=head1 Copyright and License

Copyright (c) 2004 David Wheeler & Kineticode. All rights reserved.

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
% if ($full_page) {
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
% }
% if ($include_css) {
    <style type="text/css">
.element {
  font: verdana, arial, sans-serif;
  border-top: 1px solid black;
  border-left: 1px solid black;
}

.element h1 { font-size: 1.4em; margin: 0; }
.element h2 { font-size: 1.2em; margin: .5em 0 .2em 0; }

.element table {
  border-spacing: 0;
  border-left: 1px solid black;
  border-top: 1px solid black;
}

.element, .fields tr, .fields td, .fields th, .sites tr, .sites td, .sites th {
  border-bottom: 1px solid black;
  border-right: 1px solid black;
  margin: 0;
  padding: .2em;
  vertical-align: top;
}

.fields { width: 100%; }

.element {
  padding: 1em;
  margin-bottom: 1em;
}

.element dt {
  font-weight: bold;
  float: left;
  padding-right: .5em;
}

.element td ul {
  list-style: square;
  margin: 0 0 0 1.5em;
  padding: 0;
}

.sites td ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

li.primary {
  font-weight: bold;
}

li.primary:after { content: " \2714"; }
.element dt:after { content: ":" }

/* Colors */
.level1  { background: #fbfbd8; }
.level2  { background: #eed2ee; }
.level3  { background: #add8e6; }
.level4  { background: #e1f5ba; }
.level5  { background: #ffe4e1; }
.level5  { background: #7fffd4; }
.level6  { background: #ffec8b; }
.level7  { background: #ffc1c1; }
.level8  { background: #87ceeb; }
.level9  { background: #deb887; }
.level10 { background: #ff6347; }
    </style>
% }
% if ($full_page) {
    <title><% $element->get_name %></title>
    <meta name="generator" content="Bricolage <% Bric->VERSION %>" />
  </head>
  <body>
% }
% $m->comp('.element', elem => $element->get_element);
% if ($full_page) {
  </body>
</html>
% }
<%args>
$include_css => 1
$full_page   => 1
</%args>
<%once>;
my $meta = 'html_info';
</%once>\
<%shared>
my %seen;
</%shared>\
<%def .element>
<%args>
$elem
$level   => 1
$no_nest => 0
</%args>\
% my $kn = $elem->get_key_name;
% $seen{$kn}++;
% my @keys = qw(type value length size);
    <div class="element level<% $level %>">
      <h1><% $elem->get_name %></h1>
      <dl>
        <dt>Key Name</dt>
        <dd><% $kn %></dd>
        <dt>Type</dt>
        <dd><% $elem->get_type_name %></dd>
        <dt>Paginated</dt>
        <dd><% $elem->get_paginated ? 'Yes' : 'No' %></dd>
        <dt>Related Media</dt>
        <dd><% $elem->is_related_media ? 'Yes' : 'No' %></dd>
        <dt>Related Story</dt>
        <dd><% $elem->is_related_story ? 'Yes' : 'No' %></dd>
% if ($elem->get_top_level) {
        <dt>Fixed URL</dt>
        <dd><% $elem->get_fixed_url ? 'Yes' : 'No' %></dd>
% }
        <dt>Description</dt>
        <dd><% $elem->get_description || '&nbsp;' %></dd>
      </dl>
% if ($elem->get_top_level) {
      <h2>Sites &amp; Output Channels</h2>
      <table class="sites">
        <tr>
          <th>Site</th>
          <th>Output Channels</th>
        </tr>
% my %ocs; push @{$ocs{$_->get_site_id}}, $_ for $elem->get_output_channels;
%     for my $site ($elem->get_sites) {
%         my $prim = $elem->get_primary_oc_id($site->get_id);
        <tr>
          <td><% $site->get_name %></td>
          <td>
            <ul>
%         for my $oc (@{$ocs{$site->get_id}}) {
%             my $attr = $oc->get_id == $prim
%               ? ' class="primary" title="Primary Output Channel"'
%               : '';
              <li<% $attr %>><% $oc->get_name %></li>
%         }
            </ul>
          </td>
        </tr>
%     }
      </table>
% }
% if (my @fields = $elem->get_data) {
      <h2>Fields</h2>
      <table class="fields">
        <tr>
          <th>Place</th>
          <th>Key Name</th>
          <th>Label</th>
%     for my $key (@keys) {
          <th><% $key eq 'value' ? 'Default' : ucfirst $key %></th>
%     }
          <th>Max Length</th>
          <th>Required</th>
          <th>Values</th>
        </tr>
%     for my $field (@fields) {
%         my $vals = $field->get_meta($meta, 'vals');
        <tr>
          <td><% $field->get_place %></td>
          <td><% $field->get_key_name %></td>
          <td><% $field->get_meta($meta, 'disp') %></td>
%         for my $key (@keys) {
%             my $val = $field->get_meta($meta, $key);
%             $val = ucfirst $val if $key eq 'type';
%             $val = '&nbsp;' unless defined $val && $val ne '';
          <td><% $val %></td>
%         }
          <td><% $field->get_max_length %></td>
          <td><% $field->get_required ? 'Yes' : 'No' %></td>
%         if ($vals) {
          <td>
            <ul>
%             for my $line (split /\n/, $vals)  {
%                 my ($val, $label) = split /,/, $line; $label ||= $val;
              <li><% "$val => $label" %></li>
%             }
            </ul>
          </td>
%         } else {
          <td>&nbsp;</td>
%         }
        </tr>
%     }
      </table>
% }
<%perl>;
if (my @subs = $elem->get_containers) {
    my $kn1 = $subs[0]->get_key_name;
    unless ($seen{$kn} > 1 || (@subs == 1 && $no_nest && $kn1 eq $kn)) {
        $m->print("      <h2>Subelements</h2>\n");
        for my $sub (@subs) {
            my $subkn = $sub->get_key_name;
            my $nest = $subkn eq $kn;
            next if $seen{$subkn} > 1 || ($nest && $no_nest);
            $m->comp('.element',
                elem    => $sub,
                level   => $level + 1,
                no_nest => $nest
            );
        }
    }
}
$seen{$kn}--;
</%perl>\
    </div>
</%def>\
