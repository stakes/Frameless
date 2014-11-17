$( document ).ready( function() {

    'use strict';

    // Responsive navigation
    // --------------------------------------------------
    $( '.navbar-nav-toggle, .navbar-nav a' ).on( 'click', function() {
        if ( $( '.navbar' ).css( 'z-index' ) === '4' ) {
            $( '.navbar-nav' ).slideToggle();
            $( '.navbar' ).toggleClass( 'open' );
        }
    } );

    // Handle contact form
    // --------------------------------------------------
    $( '.contact-form' ).on( 'submit', contactFormHandler );

    // Handle subscription form
    // --------------------------------------------------
    $( '.subscription-form' ).on( 'submit', subscriptionFormHandler );

    // Contact form toggle
    // --------------------------------------------------
    $( 'body' ).on( 'click', '.contact-toggle', function( event ) {
        event.preventDefault();
        $( 'body' ).toggleClass( 'open' );
    } );

    // Detect fixed navbar position
    // --------------------------------------------------
    fixedTopBar();

    // Initialize scrollReveal animations
    // --------------------------------------------------
    window.scrollReveal = new scrollReveal();

} );

$( window ).on( 'load', function() {

    'use strict';

    // Initialize sliders
    // --------------------------------------------------
    $( '.showcase-slider' ).owlCarousel( {
        itemsMobile: [480, 1],
        itemsTablet: [768, 2],
        items: 3
    } );
    $( '.testimonials-slider' ).bxSlider( {
        adaptiveHeight: true,
        auto: true,
        controls: false,
        mode: 'fade',
        pager: false,
        pause: 8000
    } );

    // Wait for background images to load
    // --------------------------------------------------
    $( '.background-image' ).each( function() {
        $( this ).addClass( 'loaded' );
    } );

    // Simple smoothscroll script
    // --------------------------------------------------
    $( 'body' ).on( 'click', '[data-smoothscroll]', function( event ) {
        event.preventDefault();

        var $this = $( this );

        $( 'html, body' ).stop().animate( {
            scrollTop: $( $this.attr( 'href' ) ).offset().top
        } );
    } );
} );


//
// Add "scrolling" class to the navbar when not at top
// --------------------------------------------------

function fixedTopBar() {

    'use strict';

    var offset,
        $navbar = $( '.navbar' );

    $( window ).on( 'scroll.happytodesign', function() {
        offset = $navbar.offset().top;
        if ( offset > 10 ) {
            if ( $navbar.attr( 'data-scrolling' ) !== 'true' ) {
                $navbar.attr( 'data-scrolling', 'true' );
            }
        }
        else {
            $navbar.attr( 'data-scrolling', 'false' );
        }
    } ).trigger( 'scroll.happytodesign' );
}


//
// Handle contact form submission
// --------------------------------------------------

function contactFormHandler( event ) {

    'use strict';

    // Prevent default form submission
    event.preventDefault();

    // Cache form for later use
    var $form = $( '.contact-form' ),
        $submit = $form.find( '[type="submit"]' );

    $submit.prop( 'disabled', true ).data( 'original-text', $submit.text() ).text( $submit.data( 'loading-text' ) );

    // Send ajax request
    $.ajax( {
        url: 'includes/functions.php',
        type: 'post',
        dataType: 'json',
        data: $form.serialize() + '&action=contact',
        success: function( msg ) {

            $submit.prop( 'disabled', false ).text( $submit.data( 'original-text' ) );

            // This needs heavy optimization
            var helperClass = 'helper',
                $helperElement = $( '<p class="' + helperClass + '">' + msg.message + '</p>' ),
                $form_control = $form.find( '[name="' + msg.field + '"]' ),
                $form_group = $form_control.closest( '.form-group' );

            $form_group.removeClass( function( index, css ) {
                return ( css.match( /\bhas-\S+/g ) || [] ).join( ' ' );
            } ).addClass( 'has-' + msg.status );

            if ( $form_group.find( '.' + helperClass ).length ) {
                $form_group.find( '.' + helperClass ).text( msg.message );
            }
            else {
                if ( $form_control.parent( '.input-group' ).length ) {
                    $helperElement.insertAfter( $form_control.parent( '.input-group' ) );
                }
                else {
                    $helperElement.insertAfter( $form_control );
                }
            }
        }
    } );
}


//
// Handle subscription form submission
// --------------------------------------------------

function subscriptionFormHandler( event ) {

    'use strict';

    // Prevent default form submission
    event.preventDefault();

    // Cache form for later use
    var $form = $( '.subscription-form' ),
        $submit = $form.find( '[type="submit"]' );

    $submit.prop( 'disabled', true ).data( 'original-text', $submit.text() ).text( $submit.data( 'loading-text' ) );

    // Send ajax request
    $.ajax( {
        url: 'includes/functions.php',
        type: 'post',
        dataType: 'json',
        data: $form.serialize() + '&action=newsletter',
        success: function( msg ) {

            $submit.prop( 'disabled', false ).text( $submit.data( 'original-text' ) );

            // This needs heavy optimization
            var helperClass = 'helper',
                $helperElement = $( '<p class="' + helperClass + '">' + msg.message + '</p>' ),
                $form_control = $form.find( '[name="' + msg.field + '"]' ),
                $form_group = $form_control.closest( '.form-group' );

            $form_group.removeClass( function( index, css ) {
                return ( css.match( /\bhas-\S+/g ) || [] ).join( ' ' );
            } ).addClass( 'has-' + msg.status );

            if ( $form_group.find( '.' + helperClass ).length ) {
                $form_group.find( '.' + helperClass ).text( msg.message );
            }
            else {
                if ( $form_control.parent( '.input-group' ).length ) {
                    $helperElement.insertAfter( $form_control.parent( '.input-group' ) );
                }
                else {
                    $helperElement.insertAfter( $form_control );
                }
            }
        }
    } );
}