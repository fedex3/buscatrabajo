$(document).ready(function() {
  //formato de la cookie: true&fals&fals&fals. El primero es de las cookies de de funcionalidad y personalización, 
  //el segundo cookies análisis, tercero de publicidad, cuarto de  redes sociales.
  var locale =  $('#locale')[0].innerHTML 

  if((locale == "es" || window.location.pathname.startsWith('/es')) /* && (production || test)*/){
    var cookies_accepted = getCookie('cookies_accepted'); 
    var customization_cookies
    var analysis_cookies
    var advertising_cookies
    var social_cookies

    if (cookies_accepted == "") {//Primera vez que entra a la página
      $('body')[0].innerHTML += `
        <section id="cookies_popup">
          <div class="cookies-info">
            <h4>Su privacidad es importante</h4>
            <h5>Para mejorar tu experiencia con nuestra plataforma y brindarte contenido personalizado basándonos en tu navegación,
              utilizamos cookies e identificadores propios y de terceros para analítica, publicidad, personalización de la web y rendimiento.
              <br>Para más información: 
              <a href="/terminos#cookies-policy">Ver política de cookies</a>
            </h5>
          </div>
          <div id="popup-buttons">
            <button class="new-button" style="background-color:#2DB08C" id="accept-cookies-button">Aceptar</button>
            <button class="new-button" id="configure-cookies-button">Configurar</button>
          </div>
        </section>`;

      $('#accept-cookies-button').on('click', function(){
        $('#cookies_popup').hide();
        setCookie("cookies_accepted", "true&true&true&true", 365);
      })

      $('#configure-cookies-button').on('click', function(){
        $('#cookies_popup')[0].outerHTML =`
        <section id="cookies_configuration_popup">
          <h4>¿Que cookies desea aceptar?</h4>
          <div id="cookies_options">
            <span class="btn-toggle">
              <p>Cookies necesarias</p>
              <input disabled type="hidden" name="necessary_cookies" value="1">
              <input disabled type="checkbox" id="necessary_cookies" checked="checked" name="necessary_cookies" value="1">
              <label class="toggle" for="necessary_cookies"></label>
            </span>
            <br>
            <span class="btn-toggle">
              <p>Cookies de personalización</p>
              <input type="hidden" name="customization_cookies" value="0">
              <input type="checkbox" id="customization_cookies" checked="checked" name="customization_cookies" value="1">
              <label class="toggle" for="customization_cookies"></label>
            </span>
            <br>
            <span class="btn-toggle">
              <p>Cookies de análisis</p>
              <input type="hidden" name="analysis_cookies" value="0">
              <input type="checkbox" id="analysis_cookies" checked="checked" name="analysis_cookies" value="1">
              <label class="toggle" for="analysis_cookies"></label>
            </span>
            <br>
            <span class="btn-toggle">
              <p>Cookies de publicidad</p>
              <input type="hidden" name="advertising_cookies" value="0">
              <input type="checkbox" id="advertising_cookies" checked="checked" name="advertising_cookies" value="1">
              <label class="toggle" for="advertising_cookies"></label>
            </span>
            <br>
            <span class="btn-toggle">
              <p>Cookies de redes sociales</p>
              <input type="hidden" name="social_cookies" value="0">
              <input type="checkbox" id="social_cookies" checked="checked" name="social_cookies" value="1">
              <label class="toggle" for="social_cookies"></label>
            </span>
            <br>
          </div>
          <button class="new-button" style="background-color:#2DB08C" id="accept-cookies-configuration-button">Aceptar todas</button>
          <button class="new-button" style="background-color:#2DB08C" id="save-cookies-configuration-button">Guardar selección</button>
        </section>`;
        $('#accept-cookies-configuration-button').on('click', function(){
          setCookie("cookies_accepted", "true&true&true&true", 365);
          $('#cookies_configuration_popup').hide();
        })

        $('#save-cookies-configuration-button').on('click', function(){
          var customization_option =  $('#customization_cookies')[0].checked;
          var analysis_option =  $('#analysis_cookies')[0].checked;
          var advertising_option =  $('#advertising_cookies')[0].checked;
          var social_option =  $('#social_cookies')[0].checked;
          setCookie("cookies_accepted", `${customization_option}&${analysis_option}&${advertising_option}&${social_option}`, 365);
          $('#cookies_configuration_popup').hide();
        });
      })

    }
    else{
      if(cookies_accepted.slice(0,3) == "true") customization_cookies=true;
      if(cookies_accepted.slice(5,8) == "true") analysis_cookies=true;
      if(cookies_accepted.slice(10,13) == "true") advertising_cookies=true;
      if(cookies_accepted.slice(15,18) == "true") social_cookies=true;
    }
  }
});

function getCookie(name) {
  var cookie, c;
  cookies = document.cookie.split(';');
  for (var i=0; i < cookies.length; i++) {
      c = cookies[i].split('=');
      if (c[0] == name) {
          return c[1];
      }
  }
  return "";
}

function setCookie(name, value, exdays) {
  var d, expires;
  exdays = exdays || 1;
  d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  expires = "expires=" + d.toUTCString();
  document.cookie = name + "=" + value + "; " + expires;
} //setCookie('name', 'Batman', 365);

//delete a cookie: setCookie('name', '', -1);