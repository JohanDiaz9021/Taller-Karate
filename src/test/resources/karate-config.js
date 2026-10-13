function fn() {
  var config = {
    baseUrl: 'https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/'
  };
  // Render "duerme" el servicio cuando no hay tráfico: la primera petición puede tardar ~1 min
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 60000);
  return config;
}
