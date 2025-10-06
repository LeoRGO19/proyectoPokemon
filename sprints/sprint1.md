# **Roles**
Scrum Master: Eduardo Mora.
Product Owner: Antonella Pincheira.
Equipo de desarrollo: Leonardo Guerrero, Benjamin Lopez.

# **Revisión**
Logramos a lo largo del Sprint, la lista completa de los pokemon a lo largo de las generaciones gracias a la conexion con la API, tambien la implementacion del motor de busqueda, el cual funciona con nombres, asi como con categorias dadas. El motor de busqueda permite mezclar categorias con los conectores "and" y "or" para una mejor busqueda de pokemon especificos. Se implementaron las tarjetas de pokemon con sus descripciones, al hacer clic en las cards mostradas en la lista se desplegara una pantalla mostrando su descripcion, asi como sus estadisticas en un grafico, su sprite animado (si es que posee uno), y sus evoluciones (si es que posee estas).

# **Retrospectiva**
## Problemas:
Al crear la logica de combinar busquedas ya que presentaba problemas actualizando la lista desplegable. Como el servicio con la API hacia multiples peticiones hubo que limitar el numero de pokemons por peticiones, implementando el client para reutilizar peticiones y consumir menos recursos al mantener la conexion abierta. Esto presentaba problemas con el hilo principal ya que hacia que la app se sobrecargara con informacion disminuyendo el rendimiento, como solucion se implementaron los Isolates. La funcion de evoluciones fue compleja al integrarla ya que se presentaban errores de overflow con respecto a los tamaños de los objetos graficos. Volviendo a la API nos dimos cuenta que esta presentaba errores de datos incompletos con pokemons mas alla del #1025.


## Mejoras: 
Nos gustaria trabajar en la optimizacion del codigo asi como la mejora en el rendimiento de la app. Aplicar bug fixes y centrarnos en estabilizar nuestro proyecto antes de seguir avanzando, centrandonos en como mencione antes la optimizacion general del proyecto, tomando en cuenta exceptions, bugs y demas.
Asi tambien como implementar una memoria cache para optimizar las cosas.