# Respira Lima

Aplicación para medir la calidad del aire de los usuarios.

## Detalles

La función principal de la app es medir la calidad del aire de los usuario. Tienen dos formas de hacerlo:
- Especificar su destino final para que se le dibuje una ruta con la mejor calidad de aire posible. Luego, en su recorrido (valores de latitud y longitud) se va asignando los valores de calidad de aire en base a las predicciones (que se actualizan cada 15 minutos) realizadas en el backend  de toda la zona de estudio.
-  Salir sin un destino final, con la cual únicamente se utiliza el recorrido del usuario (latitud y longitud) para asignando los valores de calidad de aire en base a las predicciones (que se actualizan cada 15 minutos) realizadas en el backend  de toda la zona de estudio.
Al finalizar, en cualquier modo, se genera el valor de su exposición al PM25 (a menos valor, mejor calidad del aire), tiempo y distancia recorrido.
Por otro lado, el usuario puede ver la calidad del aire de las calles en tiempo real, puesto que estas se pintan al ubicarse en el mapa dentro de la zona de estudio.

La información de los usuarios y sus recorrido, se almacenan en nuestro backend, para que esta información no se pierda y pueda ser mostrada siempre que el usuario vuelva a ingresar al app.

## License

[GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt)
