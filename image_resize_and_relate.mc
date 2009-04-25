<%args>
%element_names_and_sizes
$picture
$target_image_element_type
$media_workflow
$publish_desk
</%args>
<%perl>
use Image::Magick;
my ($picture_is_good, $format, $scolding, $user, $new_media_document);



if (!$story->get_user__id) {
  $user = Bric::App::Session->get_user_id;
} else {
  $user = $story->get_user__id;
}
$m->out('<br><br>USER ID:' . $user . '<br><br>');


#pull out the media document inside the element and make sure it's a picture
if ($picture->get_related_media) {
  $scolding = $m->scomp('/util/image_check.mc',
    pic => $picture->get_related_media
  );
  if ($scolding) {
    $m->out('<strong>' . $scolding . '</strong><br>');
  } else {
    $picture_is_good = 1;
    $format = $burner->notes('ext');
    $burner->clear_notes;
  }
}

if ($picture_is_good) {
#  $m->out('<br><br>Full-size media is good!<br><br>');
  my (%check_list, %safe_list);

  #check for containers
  foreach my $container_type(keys %element_names_and_sizes) {
    foreach my $existing_container($picture->get_elements) {
      if (($existing_container->get_key_name eq $container_type) && (!$check_list{$container_type})) {
        #OK, we're working with this one
</%perl>

<br><br>Found a <% $existing_container->get_key_name %> container.
<br>Adding its ID(<% $existing_container->get_id %>) to the safe list. Will delete all other <% 
$existing_container->get_key_name %> containers.
       
<%perl>

        $check_list{$container_type} = 1;
        $safe_list{$existing_container->get_id} = 1;
      } 
    }
  }	

  #kill any duplicate containers
  foreach my $container_type(keys %element_names_and_sizes) {
    foreach my $existing_container($picture->get_elements) {
      if (($existing_container->get_key_name eq $container_type) && (!$safe_list{$existing_container->get_id})) {
        #OK, we're deleting this one
</%perl>

<br><br>Found an extra <% $existing_container->get_key_name %> container.
<br>Its ID(<% $existing_container->get_id %>) was not on the safe list. Deleting...
<br><br>       
<%perl>
        my @killswitch;
        $killswitch[0] = $existing_container;
        $picture->delete_elements(\@killswitch);
        $picture->save;
      } 
    }
  }

  #create any missing containers
  foreach my $container_type(keys %element_names_and_sizes) {

    $m->out('<br>working on ' . $container_type . '.<br>');

    if (!$check_list{$container_type}) {
</%perl>

<br><br>Did not find a <% $container_type %> container.
<br>Creating one...
<br><br>
<%perl>
      my $required_container_type = Bric::Biz::ElementType->lookup({ 'key_name' => $container_type });
      $picture->add_container($required_container_type);
      $picture->save;
    }
  }

  #OK, we now have all the containers we need.
  #Loop through them. If they already have pictures, leave them alone.
  #If they don't have pictures, create them and relate them. 
  foreach my $working_container($picture->get_containers(keys %element_names_and_sizes)) {
    $m->out('<br><br>working on container with ID: ' . $working_container->get_id . '.<br>');
    if ($working_container->get_related_media) {
      $m->out('<br><br>Found media in ' . $working_container->get_id . ' container. Making sure it is a picture...<br><br>');
      my $thumbScolding = $m->scomp('/util/image_check.mc',
        pic => $working_container->get_related_media
      );
      if ($thumbScolding) {
        #container has bad media file
        $m->out('<strong>' . $thumbScolding . '</strong><br>');
      } else {
        #container has good media file, so leave it alone
      }
    } else {
      #container is empty, so create image and relate it to container
      $m->out('<br><br>' . $working_container->get_key_name . ' container is empty. Will create image to fill it.<br><br>');
      my $target_element_type = Bric::Biz::ElementType->lookup({key_name => $target_image_element_type});

      my $media_document_title = $picture->get_related_media->get_title . '-' . $working_container->get_key_name;

      my %target_initial_state = (
        'user__id' => $user,
        'active' => 1,
        'priority' => $story->get_priority,
        'title' => $picture->get_related_media->get_title . '-' . $working_container->get_key_name,
        'description' => '',
        'workflow_id' => $media_workflow->get_id,
        'element_type' => $target_element_type,
        'site_id' => $story->get_site_id,
        'source__id' => $picture->get_related_media->get_source__id,
        'cover_date' => $picture->get_related_media->get_cover_date,
#        'media_type_id' => $picture->get_related_media->get_media_type->get_id,
        'category__id' => $picture->get_related_media->get_category__id
      );
      my $new_file_name = $picture->get_related_media->get_file_name;
      my $new_uri = $picture->get_related_media->get_primary_uri;
      my $extension = "_$element_names_and_sizes{$working_container->get_key_name}.$format";
      $new_file_name =~ s/....$/$extension/;
      $new_uri =~ s/....$/$extension/;
      $m->out('<br><br>OK. New image will be called' . $new_file_name. ' <br><br>');

      #check if there is already an image with the same URI in the Bricolage library.
      #If there is, open that media document. Otherwise create a new one.
  
      my @existing_media_document = Bric::Biz::Asset::Business::Media->list({
        'uri' => $new_uri,
        'active' => 1
      });

      if ($existing_media_document[0]) {
        $new_media_document = $existing_media_document[0];
        $m->out('<br><br>Found existing media document! Will upload new image into it.');
        $m->out('<br>UUID: ' . $new_media_document->get_uuid);
        $m->out('<br>ID: ' . $new_media_document->get_id);
        $m->out('<br>since there\'s an existing media document, check out first');
        $new_media_document->checkout({ user__id => $user });
      } else {
        $m->out('<br><br>creating new media document!');
        $new_media_document = Bric::Biz::Asset::Business::Media::Image->new(\%target_initial_state);
        #$new_media_document->set_current_desk($publish_desk);
        $new_media_document->set_workflow_id($media_workflow->get_id);
        $new_media_document->save;

        $m->out('<br>adding to publish desk!');
        $publish_desk->accept({ asset => $new_media_document });
        $publish_desk->save;

        $new_media_document->checkin;

        $m->out('<br>UUID: ' . $new_media_document->get_uuid);
        $m->out('<br>ID: ' . $new_media_document->get_id);
      }


      #Here we go, making the new image
      my $temp_file = "/tmp/$new_file_name";
      my $new_image = new Image::Magick;
      $new_image->Read($picture->get_related_media->get_path);
      $new_image->Thumbnail($element_names_and_sizes{$working_container->get_key_name});
      $new_image->Set(colorspace=>'RGB');
      $new_image->Write($temp_file);
      undef $new_image;

      #now upload our new image
      my $file_handler;
      open ($file_handler, "<$temp_file");

      $new_media_document->upload_file($file_handler, $new_file_name, $picture->get_related_media->get_media_type->get_name);

      $m->out("<br>media type is: ".$picture->get_related_media->get_media_type->get_name."<br>");
      $m->out("<br>class is: ".$new_media_document->get_class_id."<br>");
      #no need to close filehandler because upload_file does it automatically

      #delete the temp image here
      unlink ($temp_file);

      #save and check in if required
      $new_media_document->save;

      if ($new_media_document->get_checked_out) {
        $m->out("<br>the media file is checked out, so I'm checking it in<br>");
        #$publish_desk->checkin($new_media_document);
        $new_media_document->checkin;
      } else {
        $m->out("<br>the media file was not checked out; doing nothing<br>");
      }

      $m->out("current desk: ".$new_media_document->get_current_desk->get_name." / ".$new_media_document->get_desk_id."<br>");

      #relate the image to the container
      $working_container->set_related_media($new_media_document);
      $working_container->save;
    }
  }
}

</%perl>

Image is good!
<br>URI: <% $picture->get_related_media->get_primary_uri %>
<br>path: <% $picture->get_related_media->get_path %>
<br>
<br>
<%perl>




foreach my $element_type (keys %element_names_and_sizes) {
  $m->out($element_type . ' (' . $element_names_and_sizes{$element_type} . ' pixels wide)<br>');
}

$m->out('<br><br><img src="' . $picture->get_related_media->get_uri . '" alt=""><br>');
</%perl>
