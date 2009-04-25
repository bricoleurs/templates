<%perl>
my %element_names_and_sizes = (
  'blogger_mugshot' => 30,
  'column_mugshot' => 80,
  'host_columnist_mugshot' => 150
);

my $element_names_and_sizes_p = \%element_names_and_sizes;

$m->comp('/util/image_resize_and_relate.mc',
  'bad_parameter' => 'hello, world',
  'element_names_and_sizes' => $element_names_and_sizes_p,
  'picture' => $element,
  'target_image_element_type' => 'auto_generated_image',
  'media_workflow' => Bric::Biz::Workflow->lookup({ name => 'Media' }),
  'publish_desk' => Bric::Biz::Workflow::Parts::Desk->lookup({ name => 'Media Publish' })
);
</%perl>