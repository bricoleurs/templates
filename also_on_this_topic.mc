%doc>

=head1 NAME

also_on_this_topic - Returns a list of related stories by a matching secondary category

=head1 VERSION

1.0

=head1 SYNOPSIS

To come...

=head1 DESCRIPTION

To come...

=head1 AUTHOR

Brad Harder <bch@methodlogic.net>

=head1 COPYRIGHT AND LICENSE

To come...

=cut

</%doc>\

<%args>
@secondary_categories
$skip_story_id => undef
$max_return => 5
</%args>

<%perl>
# setting max_return to "0" (either by passing in value when calling, or adjusting above), means return everything.
my $count_returned=0; # default to returning everything found.
my $need_to_print_header = 1; #header for returned article stubs.
my $return_limit; #this is passed to the Bric::Biz... call -- requires special handling.
if(0==$max_return){ #unlimited
    $return_limit = 0;
}else{
    $return_limit = $max_return + 1; #allow for potential match on a story ID we won't use
}
foreach my $secondary_cat (@secondary_categories){
    my $secondary_cat_id = $secondary_cat->{"id"};
    my @secondary_cat_stories = Bric::Biz::Asset::Business::Story->list({category_id=>$secondary_cat_id, element_id=>1, publish_status=>1, unexpired=>1, Order=>"cover_date", OrderDirection=>"DESC", Limit=>$return_limit});
    foreach my $secondary_cat_story (@secondary_cat_stories){
	my $current_id = $secondary_cat_story->get_id;
	if($skip_story_id != $current_id){
	    if ($need_to_print_header) {
			$m->print("<h4>more articles<br />ON RELATED TOPICS</h4>\n");
			$need_to_print_header = 0;
	    }
	    ++$count_returned;
	    my $secondary_cat_title = $secondary_cat_story->get_title;
	    my $secondary_cat_uri = $secondary_cat_story->get_uri;
	    my $secondary_cat_teaser = $secondary_cat_story->get_data('teaser');
	    $m->print("<p><a href=\"$secondary_cat_uri\" title=\"Read $secondary_cat_title\">$secondary_cat_title</a><br>$secondary_cat_teaser</p>\n");
	    if ($count_returned == $max_return) {last}
	}
    }
    if ($count_returned == $max_return) {last}
}
</%perl>




 


