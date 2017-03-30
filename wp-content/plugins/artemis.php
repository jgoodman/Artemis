<?php
/*
Plugin Name: Artemis
*/

//[artemis]
function artemis_func( $atts ){
    $current_user = wp_get_current_user();
    $user_id = $current_user->ID;
    $post    = get_post();
    $post_id = $post->ID;
    $service_url = "http://api.kayciegoodman.com/cgi-bin/artemis/page?user_id=$user_id&page_id=$post_id";
    $curl = curl_init($service_url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    $curl_response = curl_exec($curl);
    if ($curl_response === false) {
        $info = curl_getinfo($curl);
        curl_close($curl);
        die('error occured during curl exec. Additioanl info: ' . var_export($info));
    }
    curl_close($curl);
    return $curl_response;
}
add_shortcode( 'artemis', 'artemis_func' );
