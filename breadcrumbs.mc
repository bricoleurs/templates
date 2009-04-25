<%doc>

=head1 NAME

breadcrumbs.mc - Creates breadcrumb links from the category path

=head1 USAGE

Create a utility template with the distributed code and include the created
.mc into your cover/story-templates using C<< <& /breadcrumbs.mc &> >>.

=head1 AUTHOR

Tobias Kremer & Kirsten Frste

=cut

</%doc>
<!-- BREADCRUMBS: START -->

<%perl>
   my @path = ( '<a href="/">Home</a>' );
   my $cat = $burner->get_cat; 
   my @objs = $cat->ancestry();

   push( @path, map { '<a href="' . $_->ancestry_dir() . '">' . $_->get_name() . '</a>' } grep { $_->get_name() !~ /Root Category/i } @objs );
   if( $element->get_name =~ /Story/i ) {
      push( @path, '<a href="' . $story->get_uri() . '">' . $story->get_title() . '</a>' );
   }
</%perl>

<p class="breadcrumbs"><% join( " &raquo; ", @path ) %></p>

<!-- BREADCRUMBS: END -->
